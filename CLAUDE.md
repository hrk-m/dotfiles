# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## リポジトリ概要

macOS 用 dotfiles を **chezmoi** で管理するリポジトリ。従来のシンボリックリンク方式(`set_symlink.sh`)から chezmoi 方式へ移行中で、リポジトリルートがそのまま chezmoi のソースディレクトリになる。

## よく使うコマンド

```bash
# 変更をホームディレクトリへ反映
chezmoi apply --source ~/src/github.com/hrk-m/dotfiles

# 反映前に差分を確認(apply の前に必ず実行する)
chezmoi diff --source ~/src/github.com/hrk-m/dotfiles

# 新しいマシンでの初期セットアップ
chezmoi init --apply hrk-m

# Brewfile の内容を手動で適用
brew bundle --file ~/Brewfile
```

## アーキテクチャ

chezmoi のファイル名規約がそのまま実行順序・挙動を決める:

- `run_once_before_00_install_homebrew.sh.tmpl` — apply 時に**一度だけ**、dotfiles 配置**前**に実行。Xcode CLT と Homebrew をインストールする(Apple Silicon 前提で `/opt/homebrew` 決め打ち)。
- `run_onchange_after_01_homebrew_bundle.sh.tmpl` — dotfiles 配置**後**に実行。スクリプト内に `{{ include "Brewfile" | sha256sum }}` でBrewfile のハッシュを埋め込んでおり、**Brewfile を変更するとハッシュが変わって次回 apply 時に `brew bundle` が自動再実行される**仕組み。
- `.chezmoiignore` — `old/` と `README.md` はホームへ配置しない。
- `.chezmoi.toml.tmpl` — chezmoi 設定のテンプレート(diff から scripts を除外)。
- `Brewfile` — ホームの `~/Brewfile` として配置され、上記 run_onchange スクリプトから参照される。

`.tmpl` ファイルは Go テンプレートで、`{{ if eq .chezmoi.os "darwin" }}` により macOS 以外では中身が空になる。

## 移行状況

`old/` には chezmoi 移行前の旧構成(git 設定、vimrc、VSCode 設定、macos/setup.sh、シンボリックリンク方式の旧 README)が残っている。これらは順次 chezmoi ソース形式(`dot_gitconfig` 等)へ移行する予定の未移行資産であり、参照はするが新規変更は加えない。

## 注意点

- ホームに配置するファイルを追加する場合は chezmoi の命名規約に従う(`dot_` プレフィックス = `.` ファイル、`.tmpl` サフィックス = テンプレート)。
- Brewfile にパッケージを追加したら、apply 時に `brew bundle` が走ることを認識しておく(意図しないインストールに注意)。
