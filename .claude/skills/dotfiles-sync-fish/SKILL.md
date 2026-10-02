---
name: dotfiles-sync-fish
description: ローカルの fish 設定(~/.config/fish/ 配下の config.fish・conf.d・functions)の変更を chezmoi ソース(dotfiles リポジトリ)へ取り込む。「fish の設定を dotfiles に反映」「fish の変更を取り込む」「fish を dotfiles 同期」と言われたら使用する。homebrew は dotfiles-sync-homebrew を使う。
---

# dotfiles-sync-fish

ローカルで編集した fish 設定(`~/.config/fish/`)を chezmoi のソース(dotfiles リポジトリ)へ取り込む。
chezmoi 管理のため、ソースを直接編集するのではなく `chezmoi re-add` でローカルの実ファイルからソースを更新する。

**対象**: `~/.config/fish/`（`config.fish` / `conf.d/*.fish` / `functions/*.fish`）
**リポジトリ(ソース)**: `~/src/github.com/hrk-m/dotfiles`

## 前提・原則

- `--source ~/src/github.com/hrk-m/dotfiles` を必ず明示する(symlink で省略可だが堅牢性のため)。
- **コミット・push はしない**。取り込み後は `git diff` を提示して人間のレビューに委ねる。
- `chezmoi apply` はこのスキルでは実行しない(取り込みは home → ソースの一方向)。
- `re-add` は**テンプレート(`.tmpl`)・暗号化ファイルをスキップする**。fish 設定に該当があれば取り込まれないので検出して報告する。

## 手順

### 1. 差分を検出・提示

```bash
REPO=~/src/github.com/hrk-m/dotfiles
chezmoi status --source "$REPO" | grep -E '\.config/fish/' || echo "(fish に差分なし)"
chezmoi diff --source "$REPO" ~/.config/fish
```

`chezmoi status` の2列の意味:
- 2列目(右) `M` = home(実ファイル)がソースと異なる → **re-add の取り込み対象**。
- 1列目(左) `M` = ソースから apply すると home が変わる = ソース側が変更済み。
- **`MM`(両方変更)はコンフリクト**。re-add するとソース側の編集が home の内容で上書きされ消える。該当があれば両者の diff を提示し、取り込む(home 優先)か中止するかを確認してから進める。

差分が無ければ「取り込むものは無い」と報告して終了。

### 2. テンプレート/暗号化の確認

```bash
# fish 配下にテンプレ/暗号化ソースが無いか確認(あれば re-add では取り込めない)
chezmoi managed --source "$REPO" --include files .config/fish | while read -r f; do
  sp=$(chezmoi source-path --source "$REPO" "$HOME/$f")
  case "$sp" in *.tmpl|*encrypted_*) echo "SKIP(手動編集が必要): $f -> $sp";; esac
done
```

該当ファイルがあれば「`re-add` では取り込めない。ソース側テンプレ(`$sp`)を手で編集する必要がある」と報告する。

### 3. 取り込み

```bash
chezmoi re-add --source "$REPO" ~/.config/fish
```

特定ファイルだけ取り込む場合はパスを指定(例 `chezmoi re-add --source "$REPO" ~/.config/fish/config.fish`)。

### 4. 検証・報告

```bash
chezmoi diff --source "$REPO" ~/.config/fish   # 取り込めていればクリーンになる
git -C "$REPO" status --short
git -C "$REPO" diff
```

報告に含める:
- 取り込んだファイル一覧
- スキップしたテンプレ/暗号化ファイル(あれば、手動対応の案内付き)
- コンフリクト(`MM`)の扱い結果
- **コミット・push は未実施**である旨
