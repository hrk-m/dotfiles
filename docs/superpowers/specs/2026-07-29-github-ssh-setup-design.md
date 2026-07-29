# GitHub SSH セットアップの chezmoi 管理 設計

日付: 2026-07-29

## 目的

新マシンで `ghq get git@github.com:...` が「ホスト鍵未登録」「SSH 鍵なし」で失敗する問題を、chezmoi の run_once スクリプトで自動化する。

## 決定事項

- `~/.ssh/config` は管理**しない** — 現マシンの config は会社内部ホスト専用の設定であり、公開の個人 dotfiles に置けない。GitHub 接続はデフォルト鍵名(`id_ed25519` / `id_rsa`)なら config 不要。
- SSH 秘密鍵はマシン間で同期せず、**マシンごとに生成**する(1台紛失時にその鍵だけ GitHub から無効化できる)。Bitwarden SSH エージェントは現在使われていない(エージェント空・`SSH_AUTH_SOCK` は Apple 標準)ため採用しない。
- GitHub ホスト鍵は `ssh-keyscan`(接続先を無検証で信用)ではなく、`https://api.github.com/meta` の公開鍵をスクリプトに固定で埋め込む。
- 鍵はパスフレーズなし(`-N ""`)で生成する。無人セットアップを優先した判断。

## 変更内容

`run_once_after_03_setup_github_ssh.sh.tmpl`(新規)— apply 時に一度だけ実行:

1. `~/.ssh` / `known_hosts` を用意し、GitHub 公式ホスト鍵3種(ed25519 / ecdsa / rsa)を未登録なら追記。
2. `id_ed25519` / `id_rsa` のどちらも無ければ ed25519 鍵を生成。
3. `gh` が認証済みなら `gh ssh-key add` で公開鍵を GitHub に登録。未認証なら手動コマンドを表示して終了(新マシンでは brew bundle 直後は未認証のため、通常こちらになる)。

新マシンで残る手作業は `gh auth login` → 表示された `gh ssh-key add` の実行のみ。

## 検証

- 現マシンで `chezmoi apply` → ホスト鍵・鍵とも既存のため no-op であることを確認済み。
- `HOME` を空ディレクトリに向けたサンドボックスで新マシン相当を再現し、ホスト鍵3種の追記・鍵生成・未認証時の案内表示、および2回目実行の no-op(冪等)を確認済み。
