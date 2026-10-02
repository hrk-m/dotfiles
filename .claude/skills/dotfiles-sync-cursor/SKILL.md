---
name: dotfiles-sync-cursor
description: ローカルの Cursor 設定(settings.json・keybindings.json・snippets・~/.cursor のユーザー定義 rules/skills/commands・拡張一覧)を chezmoi ソース(dotfiles リポジトリ)へ取り込む。「Cursor の設定を dotfiles に反映」「Cursor の変更を取り込む」「Cursor を dotfiles 同期」「拡張を dotfiles に」と言われたら使用する。fish は dotfiles-sync-fish、homebrew は dotfiles-sync-homebrew を使う。
---

# dotfiles-sync-cursor

ローカルの Cursor 設定を chezmoi のソース(dotfiles リポジトリ)へ取り込む。
取り込みは常に `chezmoi add`(初回・2回目以降を区別しない。既にソースにあるファイルは home の内容で上書きされる)。

**リポジトリ(ソース)**: `~/src/github.com/hrk-m/dotfiles`

## 管理方針

**秘密情報・個人情報・機械固有の状態だけを除外し、それ以外は全て管理する。**

| 区分 | home 側パス | ソース側パス | 扱い |
|---|---|---|---|
| エディタ設定 | `~/Library/Application Support/Cursor/User/settings.json` | `private_Library/private_Application Support/private_Cursor/User/settings.json`(各階層が 700 なので `private_` が付く。chezmoi が自動で命名する) | 取り込む |
| キーバインド | `~/Library/Application Support/Cursor/User/keybindings.json` | 同上 `keybindings.json` | 取り込む |
| スニペット | `~/Library/Application Support/Cursor/User/snippets/` | 同上 `snippets/` | 中身があれば取り込む |
| ユーザー定義 rules / skills / commands / agents | `~/.cursor/rules/` `~/.cursor/skills/` `~/.cursor/commands/` `~/.cursor/agents/` | `dot_cursor/rules/` など | 存在し中身があれば取り込む |
| hooks / MCP 設定 | `~/.cursor/hooks.json` `~/.cursor/mcp.json` | `dot_cursor/hooks.json` など | 存在すれば取り込む(**mcp.json は env にトークンが入りがちなので秘密情報スキャン必須**) |
| 拡張一覧 | `cursor --list-extensions` の出力 | `dot_config/cursor/extensions.txt` | 毎回再生成(追加・削除とも反映) |
| 拡張の自動インストール | — | `run_onchange_after_04_cursor_extensions.sh.tmpl` | 無ければ作成(後述のテンプレ) |

**除外(取り込まない)**:

- `~/.cursor/cli-config.json` — `authInfo`(認証情報)を含む
- `~/.cursor/argv.json` — `crash-reporter-id`(機械固有 ID)を含み、他はデフォルト値
- `~/.cursor/skills-cursor/` `~/.cursor/plugins/` `~/.cursor/managed/` — Cursor 本体・チームが配布するもの(ユーザーの設定ではない)
- `~/.cursor/chats/` `projects/` `ai-tracking/` `*.json` の各種 state/cache、`statsig-cache.json`
- `~/Library/Application Support/Cursor/User/globalStorage/` `workspaceStorage/` `History/` — 状態・履歴
- `~/Library/Application Support/Cursor/` 直下の `Cache` `Cookies` `Local State` など

## 前提・原則

- `--source ~/src/github.com/hrk-m/dotfiles` を必ず明示する。
- **コミット・push はしない**。取り込み後は `git diff` を提示して人間のレビューに委ねる。
- `chezmoi apply` はこのスキルでは実行しない(取り込みは home → ソースの一方向)。
- **秘密情報スキャンでヒットしたファイルは取り込まない**。該当箇所を示して、別ファイルへ退避してもらう。
- `.tmpl` 化されたソースがあれば `chezmoi add` では上書きできないため検出して報告する。

## 手順

### 1. 前提確認

```bash
REPO=~/src/github.com/hrk-m/dotfiles
USERDIR="$HOME/Library/Application Support/Cursor/User"
command -v cursor >/dev/null || echo "NG: cursor CLI が無い(拡張一覧を取れない)"
test -d "$USERDIR" || echo "NG: Cursor の User ディレクトリが無い"
```

### 2. 取り込み候補を列挙

```bash
# 固定ファイル
for f in "$USERDIR/settings.json" "$USERDIR/keybindings.json" "$HOME/.cursor/hooks.json" "$HOME/.cursor/mcp.json"; do
  test -f "$f" && echo "FILE: $f"
done
# ディレクトリ(中身があるものだけ)
for d in "$USERDIR/snippets" "$HOME/.cursor/rules" "$HOME/.cursor/skills" "$HOME/.cursor/commands" "$HOME/.cursor/agents"; do
  test -d "$d" && [ -n "$(ls -A "$d" 2>/dev/null)" ] && echo "DIR: $d"
done
```

### 3. 秘密情報・個人情報スキャン(必須)

候補ファイル全てに対して実行する。**ヒットしたファイルは取り込みから除外**し、報告で該当行を示す。

```bash
# 秘密情報(ヒットしたら除外)
grep -rniE 'token|secret|password|passwd|api[_-]?key|authInfo|bearer|ntn_[A-Za-z0-9]|sk-[A-Za-z0-9]|ghp_[A-Za-z0-9]|AKIA[0-9A-Z]{12}' <候補パス...>
# 個人情報(警告として報告。メールアドレス・ホームの絶対パス)
grep -rnE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[a-z]{2,}|/Users/[a-z]+' <候補パス...>
```

個人情報の警告はブロックしないが、ホームの絶対パスは `{{ .chezmoi.homeDir }}` でテンプレ化できる旨を報告に添える(スキル内では自動変換しない)。

### 4. テンプレ化済みソースの確認

```bash
chezmoi managed --source "$REPO" --include files 'Library/Application Support/Cursor' .cursor .config/cursor 2>/dev/null | while read -r f; do
  sp=$(chezmoi source-path --source "$REPO" "$HOME/$f")
  case "$sp" in *.tmpl|*encrypted_*) echo "SKIP(手動編集が必要): $f -> $sp";; esac
done
```

### 5. 設定ファイルの取り込み

スキャンを通過したファイル・ディレクトリだけを `chezmoi add` する(ディレクトリは再帰的に取り込まれる)。

```bash
chezmoi add --source "$REPO" "$USERDIR/settings.json" "$USERDIR/keybindings.json"
# 以下は存在するものだけ
chezmoi add --source "$REPO" "$USERDIR/snippets"
chezmoi add --source "$REPO" ~/.cursor/rules ~/.cursor/skills ~/.cursor/commands ~/.cursor/agents
chezmoi add --source "$REPO" ~/.cursor/hooks.json ~/.cursor/mcp.json
```

### 6. 拡張一覧の再生成

```bash
mkdir -p "$REPO/dot_config/cursor"
cursor --list-extensions | sort -f > "$REPO/dot_config/cursor/extensions.txt"
git -C "$REPO" diff -- dot_config/cursor/extensions.txt   # 追加・削除を確認して報告
```

`run_onchange_after_04_cursor_extensions.sh.tmpl` が **無ければ** 次の内容で作成する(あれば触らない)。
Brewfile と同様に `extensions.txt` の sha256 を埋め込み、変更時だけ apply で再実行される。未インストール分だけを入れる冪等な実装。

```sh
{{ if eq .chezmoi.os "darwin" -}}
#!/bin/sh
# extensions.txt hash: {{ include "dot_config/cursor/extensions.txt" | sha256sum }}
# ~/.config/cursor/extensions.txt に列挙された Cursor 拡張のうち未インストールのものを入れる。
set -eu

LIST="$HOME/.config/cursor/extensions.txt"
if ! command -v cursor >/dev/null 2>&1; then
  echo "cursor CLI が見つからないため拡張のインストールをスキップ"
  exit 0
fi
[ -f "$LIST" ] || exit 0

installed=$(cursor --list-extensions | tr '[:upper:]' '[:lower:]')
grep -vE '^[[:space:]]*(#|$)' "$LIST" | while read -r ext; do
  lower=$(printf '%s' "$ext" | tr '[:upper:]' '[:lower:]')
  if printf '%s\n' "$installed" | grep -qxF "$lower"; then
    echo "already installed: $ext"
  else
    cursor --install-extension "$ext"
  fi
done
{{ end -}}
```

### 7. 検証・報告

```bash
chezmoi diff --source "$REPO" "$USERDIR" ~/.cursor ~/.config/cursor   # 取り込めていればクリーン
git -C "$REPO" status --short
git -C "$REPO" diff
```

報告に含める:
- 取り込んだファイル・ディレクトリ一覧
- 拡張の追加・削除
- **秘密情報スキャンで除外したファイルと該当行**(あれば、退避先の案内付き)
- 個人情報の警告(あれば)
- テンプレ化済みでスキップしたファイル(あれば)
- run_onchange スクリプトを新規作成したかどうか
- **コミット・push・`chezmoi apply` は未実施**である旨。初回は `chezmoi apply` 時に run_onchange が走り拡張がインストールされる(既に入っていれば no-op)
