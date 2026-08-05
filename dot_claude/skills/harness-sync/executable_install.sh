#!/bin/bash
# install.sh — src ハーネスを有効化する。何度実行しても安全(冪等)。
# dotfiles の chezmoi apply(run_after_05_setup_harness_sync)から毎回実行されるほか、手動実行も可。
# やること: データディレクトリ作成 / ヘッドレス権限設定 / SessionEnd hook 登録
#   (SessionEnd hook がセッション終了ごとにキュー追記 + harness-sync のバックグラウンド起動を行う)
# オプション: --with-launchd で毎日 8:47 の定期実行(launchd)も追加登録する
#   (通常は SessionEnd トリガーで足りるため不要。取りこぼしの日次回収が欲しい場合のみ)
set -euo pipefail

SKILL_DIR=$(cd "$(dirname "$0")" && pwd)
SRC="$HOME/src"
LABEL="com.hrk-m.harness-sync"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
WITH_LAUNCHD=0
[ "${1:-}" = "--with-launchd" ] && WITH_LAUNCHD=1

# ~/src が未配置の段階(新Mac初回 apply 等)は正常スキップ。次回の chezmoi apply で再実行される
[ -d "$SRC" ] || { echo "skip: $SRC がありません。リポジトリ群を配置後、chezmoi apply か本スクリプトを再実行してください。"; exit 0; }
command -v claude >/dev/null 2>&1 || echo "WARN: claude CLI が見つかりません。hook は登録しますが、sync の実行には claude が必要です(~/.local/bin か /opt/homebrew/bin にあれば実行時に自動検出されます)。" >&2

chmod +x "$SKILL_DIR"/scripts/*.sh
mkdir -p "$SRC/.harness/repos" "$SRC/.harness/state" "$SRC/.harness/logs" "$SRC/.claude"

# ヘッドレス実行用の権限(既存ファイルがあれば上書きしない)
# ~/src をプロジェクトディレクトリとする実行のみ権限プロンプトなしで動かす。
# 書き込み先の制約は SKILL.md の原則(HARNESS.md と .harness/ 以外に書かない)側で担保する
SETTINGS="$SRC/.claude/settings.json"
if [ -f "$SETTINGS" ]; then
  echo "skip: $SETTINGS は既存。defaultMode が bypassPermissions になっているか確認してください。"
else
  cat > "$SETTINGS" <<EOF
{
  "permissions": {
    "defaultMode": "bypassPermissions"
  }
}
EOF
  echo "created: $SETTINGS"
fi

# SessionEnd hook 登録(~/.claude/settings.json に冪等マージ)
GLOBAL_SETTINGS="$HOME/.claude/settings.json"
HOOK_CMD="$SKILL_DIR/scripts/session-end-hook.sh"
if command -v jq >/dev/null 2>&1; then
  [ -f "$GLOBAL_SETTINGS" ] || echo '{}' > "$GLOBAL_SETTINGS"
  if grep -q 'session-end-hook.sh' "$GLOBAL_SETTINGS"; then
    echo "skip: SessionEnd hook は登録済み"
  else
    tmp=$(mktemp)
    jq --arg cmd "$HOOK_CMD" \
      '.hooks.SessionEnd = ((.hooks.SessionEnd // []) + [{"hooks": [{"type": "command", "command": $cmd, "timeout": 10}]}])' \
      "$GLOBAL_SETTINGS" > "$tmp" && mv "$tmp" "$GLOBAL_SETTINGS"
    echo "hook registered: SessionEnd → $HOOK_CMD"
  fi
else
  echo "WARN: jq がないため SessionEnd hook を自動登録できません。~/.claude/settings.json の hooks.SessionEnd に以下を手動追加してください:" >&2
  echo "  {\"hooks\": [{\"type\": \"command\", \"command\": \"$HOOK_CMD\", \"timeout\": 10}]}" >&2
fi

# launchd 日次実行(--with-launchd 指定時のみ。SessionEnd トリガーの取りこぼし回収用)
if [ "$WITH_LAUNCHD" = 1 ]; then
  CLAUDE_BIN=$(command -v claude) || { echo "ERROR: --with-launchd には claude CLI が必要です。" >&2; exit 1; }
  if [ -f "$PLIST" ]; then
    echo "skip: $PLIST は既存。スケジュール変更は直接 plist を編集してください。"
  else
    cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>$LABEL</string>
	<key>ProgramArguments</key>
	<array>
		<string>/bin/zsh</string>
		<string>-lc</string>
		<string>$CLAUDE_BIN -p "/harness-sync" --model sonnet --max-turns 80</string>
	</array>
	<key>WorkingDirectory</key>
	<string>$SRC</string>
	<key>StartCalendarInterval</key>
	<dict>
		<key>Hour</key>
		<integer>8</integer>
		<key>Minute</key>
		<integer>47</integer>
	</dict>
	<key>StandardOutPath</key>
	<string>$SRC/.harness/logs/launchd.log</string>
	<key>StandardErrorPath</key>
	<string>$SRC/.harness/logs/launchd.err.log</string>
</dict>
</plist>
EOF
  fi
  launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
  launchctl bootstrap "gui/$(id -u)" "$PLIST"
  echo "launchd registered: $LABEL (daily 08:47)"
fi

cat <<'MSG'
harness-sync セットアップ完了(SessionEnd トリガー方式)。
初回のみ: claude で /harness-sync を手動実行して地図と個別 doc を生成してください。
MSG
