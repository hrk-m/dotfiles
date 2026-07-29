# fish キーバインド移植 設計

日付: 2026-07-29

## 目的

zsh で使っていた対話用キーバインドを fish に移植し chezmoi 管理にする。

## スコープ

- Ctrl+G: `ghq list | fzf` で選んだリポジトリへ cd(zsh の `cd_git_repo` 相当)
- fzf 標準バインド: Ctrl+R(履歴)/ Ctrl+T(ファイル名挿入)/ Alt+C(ディレクトリ移動)
- 対象外: `codei` 関数(未選択)、zsh 側の変更(現状維持)

## 変更内容

1. `dot_config/fish/functions/cd_git_repo.fish` — zsh と同名の関数。fish は関数を直接バインドできるため、zsh の `bindkey -s`(コマンド文字列流し込み)より素直な実装。キャンセル時は何もしない。実行後 `commandline -f repaint`。
2. `dot_config/fish/conf.d/fzf.fish` — `fzf --fish | source`。`status is-interactive` かつ `command -q fzf` のガード付き(fzf 未インストールでも壊れない)。
3. `dot_config/fish/conf.d/keybindings.fish` — `bind ctrl-g cd_git_repo`(fish 4 記法)。interactive ガード付き。

## 検証

- apply 後、対話 fish で `bind` に ctrl-r / ctrl-t / alt-c(fzf-*-widget)と ctrl-g(cd_git_repo)が登録されることを確認済み。
- `(ghq root)/$selected` のパス組み立てが正しく cd できることを確認済み。
