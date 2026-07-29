# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## リポジトリ概要

macOS 用 dotfiles を **chezmoi** で管理するリポジトリ。従来のシンボリックリンク方式(`set_symlink.sh`)から chezmoi 方式へ移行中で、リポジトリルートがそのまま chezmoi のソースディレクトリになる(`~/.local/share/chezmoi` がこのリポジトリへの symlink なので、`--source` を省略しても動く)。

## よく使うコマンド

```bash
# 反映前に差分を確認(apply の前に必ず実行する)
chezmoi diff --source ~/src/github.com/hrk-m/dotfiles

# 変更をホームディレクトリへ反映
chezmoi apply --source ~/src/github.com/hrk-m/dotfiles

# 新しいマシンでの初期セットアップ
chezmoi init --apply hrk-m

# Brewfile の内容を手動で適用
brew bundle --file ~/Brewfile

# Brewfile にないインストール済みパッケージを一覧(--force で削除)
brew bundle cleanup --file ~/Brewfile
```

## アーキテクチャ

chezmoi のファイル名規約がそのまま実行順序・挙動を決める:

- `run_once_before_00_install_homebrew.sh.tmpl` — apply 時に**一度だけ**、dotfiles 配置**前**に実行。Xcode CLT と Homebrew をインストールする(Apple Silicon 前提で `/opt/homebrew` 決め打ち)。
- `run_onchange_after_01_homebrew_bundle.sh.tmpl` — dotfiles 配置**後**に実行。スクリプト内に `{{ include "Brewfile" | sha256sum }}` で Brewfile のハッシュを埋め込んでおり、**Brewfile を変更するとハッシュが変わって次回 apply 時に `brew bundle` が自動再実行される**仕組み。brew は起動時に `sudo --reset-timestamp` で認証キャッシュを破棄するため事前の `sudo -v` は効かず、sudo が必要な cask があると実行中に1回パスワードを聞かれる(仕様として許容)。
- `run_once_after_02_set_fish_as_default_shell.sh.tmpl` — fish をログインシェルに設定(/etc/shells への追記と chsh に sudo が必要)。
- `run_once_after_03_setup_github_ssh.sh.tmpl` — GitHub 公式ホスト鍵(api.github.com/meta の値をスクリプトに固定で記載)を known_hosts に追記し、SSH 鍵が1つもなければ ed25519 鍵をパスフレーズなしで生成。gh 認証済みなら `gh ssh-key add` で GitHub 登録、未認証なら手順を表示。**run_once スクリプトは内容を変更すると次回 apply で再実行される**ため、冪等に書くこと(このスクリプトは既存環境では no-op)。
- `.chezmoiignore` — `old/`・`README.md`・`CLAUDE.md`・`docs/` はホームへ配置しない。**リポジトリ用ドキュメントを追加したら必ずここにも追加する**(忘れるとホームに配置される)。
- `.chezmoi.toml.tmpl` — chezmoi 設定のテンプレート(diff から scripts を除外)。
- `Brewfile` — ホームの `~/Brewfile` として配置され、上記 run_onchange スクリプトから参照される。

`.tmpl` ファイルは Go テンプレートで、`{{ if eq .chezmoi.os "darwin" }}` により macOS 以外では中身が空になる。

## Brewfile の管理方針

- コメントアウトされた行は「過去ログ(zsh 履歴・アプリの最終使用日時)で使用実績がない」と判定して意図的に外したもの。勝手に復活させない。
- パッケージを追加する前に `brew info <name>` / `brew info --cask <name>` で存在確認する。Homebrew から削除済みの cask(例: spectacle, atom, skitch)や廃止済み tap(homebrew/cask, homebrew/bundle, homebrew/services)を書くと `brew bundle` がエラーになる。
- CLI ツールの使用判定では、履歴に出なくても `.zshrc` からフックされているもの(fzf, sheldon, asdf, direnv, rbenv)がある点に注意。

## 移行状況

`old/` には chezmoi 移行前の旧構成(vimrc、VSCode 設定、macos/setup.sh、シンボリックリンク方式の旧 README)が残っている。これらは順次 chezmoi ソース形式へ移行する予定の未移行資産であり、参照はするが新規変更は加えない。git 設定は `private_dot_gitconfig`(ghq.root 含む、600 権限)・`dot_gitignore_global` として移行済み。**git のグローバル設定を変えるときは `git config --global` ではなくソース側を編集して apply する**(直接変えると次の apply で消える)。

## 注意点

- ホームに配置するファイルを追加する場合は chezmoi の命名規約に従う(`dot_` プレフィックス = `.` ファイル、`.tmpl` サフィックス = テンプレート)。
- Brewfile にパッケージを追加したら、apply 時に `brew bundle` が走ることを認識しておく(意図しないインストールに注意)。
- `chezmoi apply` 中の brew bundle は時間がかかることがある(cask のダウンロード)。実行中は chezmoi の state ロックが取られるため、並行して `chezmoi diff` などを実行するとロックタイムアウトになる。
