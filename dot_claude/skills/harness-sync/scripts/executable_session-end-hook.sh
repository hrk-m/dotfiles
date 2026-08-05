#!/bin/bash
# session-end-hook.sh — Claude Code の SessionEnd hook。
# ~/src 配下のリポジトリで作業したセッションの (cwd, transcript_path) を
# キュー(state/pending-sessions.tsv)に1行追記し、キューを消費する harness-sync を
# バックグラウンドで起動する(--run-sync で自己再起動)。hook 自体は即座に exit 0 で
# 終わり、セッション終了をブロックしない。記録・起動に失敗しても sessions.sh の
# mtime スキャンと次回トリガーがフォールバックになる。
set -uo pipefail

SRC="${SRC:-$HOME/src}"
STATE="$SRC/.harness/state"
QUEUE="$STATE/pending-sessions.tsv"
LOCK="$STATE/sync.lock"
LOG="$SRC/.harness/logs/hook-sync.log"

resolve_claude() {
  if [ -n "${HARNESS_SYNC_CLAUDE_BIN:-}" ]; then echo "$HARNESS_SYNC_CLAUDE_BIN"; return 0; fi
  command -v claude 2>/dev/null && return 0
  local c
  for c in "$HOME/.local/bin/claude" /opt/homebrew/bin/claude; do
    [ -x "$c" ] && { echo "$c"; return 0; }
  done
  return 1
}

# --run-sync: バックグラウンド実行体(hook 末尾から nohup で起動される)
if [ "${1:-}" = "--run-sync" ]; then
  # lock で直列化。実行中(pid 生存)ならスキップ。スキップ中に溜まった
  # キューは次のセッション終了トリガー(または手動 /harness-sync)が回収する
  if ! mkdir "$LOCK" 2>/dev/null; then
    pid=$(cat "$LOCK/pid" 2>/dev/null)
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then exit 0; fi
    rm -rf "$LOCK" && mkdir "$LOCK" 2>/dev/null || exit 0
  fi
  echo $$ > "$LOCK/pid"
  trap 'rm -rf "$LOCK"' EXIT
  CLAUDE_BIN=$(resolve_claude) || exit 0
  mkdir -p "$(dirname "$LOG")" 2>/dev/null
  # cwd=$SRC で実行する: ~/src/.claude/settings.json の権限が効き、かつ
  # この実行自身のセッション終了は下の除外条件(cwd が $SRC 直下)に当たるため再帰しない
  cd "$SRC" || exit 0
  echo "$(date -Iseconds) trigger=session-end start" >> "$LOG"
  "$CLAUDE_BIN" -p "/harness-sync" --model sonnet --max-turns 80 >> "$LOG" 2>&1
  rc=$?
  echo "$(date -Iseconds) trigger=session-end exit=$rc" >> "$LOG"
  exit 0
fi

input=$(cat) || exit 0
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null) || exit 0
file=$(printf '%s' "$input" | jq -r '.transcript_path // empty' 2>/dev/null) || exit 0
[ -n "$cwd" ] && [ -n "$file" ] || exit 0

# ~/src 配下のみ記録($SRC 直下そのもの = --run-sync のヘッドレス実行自身は除外 → 再帰防止)
case "$cwd" in
  "$SRC"/*) ;;
  *) exit 0 ;;
esac

mkdir -p "$STATE" 2>/dev/null || exit 0
printf '%s\t%s\n' "$cwd" "$file" >> "$QUEUE" 2>/dev/null

# キュー消費のため harness-sync をバックグラウンドで起動(hook はブロックしない)
nohup "$0" --run-sync >/dev/null 2>&1 &
exit 0
