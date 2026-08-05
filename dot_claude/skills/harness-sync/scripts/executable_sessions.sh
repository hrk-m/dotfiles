#!/bin/bash
# sessions.sh — フィードバック抽出対象のセッションログを列挙する。入力源は2つ:
#   1. SessionEnd hook が書くキュー(state/pending-sessions.tsv、cwd<TAB>transcript_path)
#      → 完結したセッションだけが正確に入る。Claude セッションの主経路。
#   2. 前回実行以降(state/feedback-since)に更新されたログの mtime スキャン
#      → Codex 用 + hook 取りこぼし(hook 未登録期間・jq 不在等)のフォールバック。
# 出力: 1行目 "# since=<epoch> now=<epoch>"(呼び出し側は処理成功後に now を
#       state/feedback-since へ書き込む)、以降 rel<TAB>source<TAB>file(file 列で重複排除済み)。
# rel が "-" の行は ~/src 配下のリポジトリに対応しないセッション(スキップ対象)。
# キューはこのスクリプトが読み込み時点で消費(リネーム)するが、後続の抽出が失敗しても
# feedback-since が進まない限り mtime スキャンが同じファイルを翌回拾うため、取りこぼしにはならない。
set -euo pipefail

SRC="${SRC:-$HOME/src}"
HARNESS="$SRC/.harness"
STATE="$HARNESS/state/feedback-since"
SCAN="$HARNESS/state/scan.tsv"
QUEUE="$HARNESS/state/pending-sessions.tsv"
NOW=$(date +%s)

if [ -f "$STATE" ]; then SINCE=$(cat "$STATE"); else SINCE=$((NOW - 86400)); fi
SINCE_STR=$(date -r "$SINCE" '+%Y-%m-%dT%H:%M:%S')
echo "# since=$SINCE now=$NOW"

[ -f "$SCAN" ] || { echo "ERROR: $SCAN がない。先に sync.sh を実行すること。" >&2; exit 1; }

repo_of() {
  # cwd(引数)に最長一致するリポジトリ相対パスを返す。無ければ "-"
  local cwd="$1" best="-" bestlen=0 rel
  while IFS=$'\t' read -r rel _rest; do
    case "$cwd" in
      "$SRC/$rel" | "$SRC/$rel"/*)
        if [ "${#rel}" -gt "$bestlen" ]; then best="$rel"; bestlen=${#rel}; fi ;;
    esac
  done < "$SCAN"
  echo "$best"
}

{
  # 1. SessionEnd キュー(mv で消費。処理中に終了したセッションの hook 追記は新しいキューに入る)
  if [ -s "$QUEUE" ]; then
    SNAP="$QUEUE.consuming.$$"
    mv "$QUEUE" "$SNAP"
    while IFS=$'\t' read -r cwd f; do
      [ -n "$cwd" ] && [ -f "$f" ] || continue
      printf '%s\tclaude\t%s\n' "$(repo_of "$cwd")" "$f"
    done < "$SNAP"
    rm -f "$SNAP"
  fi

  # 2. Claude Code フォールバック: ~/.claude/projects/**/*.jsonl(各行の "cwd" フィールド)
  find "$HOME/.claude/projects" -name '*.jsonl' -newermt "$SINCE_STR" 2>/dev/null | while read -r f; do
    cwd=$(grep -m1 -o '"cwd":"[^"]*"' "$f" 2>/dev/null | head -1 | cut -d'"' -f4)
    [ -n "$cwd" ] || continue
    printf '%s\tclaude\t%s\n' "$(repo_of "$cwd")" "$f"
  done

  # 3. Codex: ~/.codex/sessions/YYYY/MM/DD/rollout-*.jsonl(先頭行 session_meta の cwd)
  find "$HOME/.codex/sessions" -name 'rollout-*.jsonl' -newermt "$SINCE_STR" 2>/dev/null | while read -r f; do
    cwd=$(head -1 "$f" 2>/dev/null | grep -m1 -o '"cwd":"[^"]*"' | head -1 | cut -d'"' -f4)
    [ -n "$cwd" ] || continue
    printf '%s\tcodex\t%s\n' "$(repo_of "$cwd")" "$f"
  done
} | awk -F'\t' '!seen[$3]++'
