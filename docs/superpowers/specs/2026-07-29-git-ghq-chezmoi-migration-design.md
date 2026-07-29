# git / ghq 設定の chezmoi 移行 設計

日付: 2026-07-29

## 目的

`~/.gitconfig`(ghq 設定 `[ghq] root = ~/src` を含む)と `~/.gitignore_global` を chezmoi 管理へ移行する。内容は現状のまま変更しない。email のみテンプレート変数化し、将来別マシンで `chezmoi init` する際に切り替え可能にする。

## 決定事項

- email は個人 gmail `haruki.miyagi11@gmail.com` で固定する(当初は `promptStringOnce` でマシンごとに分岐する案を実装したが、個人アカウントの dotfiles であり会社 email に切り替える必要がないため、レビューでシンプルな固定値に変更)。
- `.gitconfig` の内容はモダン化せず現状のまま移行する。
- ghq は専用設定ファイルを持たず `.gitconfig` の `[ghq]` セクションのみなので、追加ファイルは不要。
- git 操作(commit / push / checkout 等)は一切行わない。

## 変更内容

1. `.chezmoi.toml.tmpl` — 変更なし(email 固定のため `[data]` セクション不要)。
2. `private_dot_gitconfig`(新規)— 現在の `~/.gitconfig` と同一内容の静的ファイル。現状の `~/.gitconfig` はパーミッション 600 のため `private_` プレフィックスで再現する。
3. `dot_gitignore_global`(新規)— home 側の最新版(`**/.claude/settings.local.json` 行を含む)を採用。
4. `old/git/` を削除 — 移行完了につき不要。旧版との差分(gitignore_global の1行)は home 版に包含済み。

## 検証

1. `chezmoi managed` に `.gitconfig` と `.gitignore_global` が現れることを確認。
3. `chezmoi diff` が空(内容・パーミッションとも現状と同一)であることを確認。
4. `chezmoi apply` 後、`git config user.email` / `git config ghq.root` が変わっていないことを確認。
