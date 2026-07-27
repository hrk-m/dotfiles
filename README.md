# dotfiles

macOS 用の dotfiles を [chezmoi](https://www.chezmoi.io/) で管理するリポジトリ。

`chezmoi apply` すると以下が自動で行われる:

1. `run_once_before_00_install_homebrew.sh` — Homebrew 未インストールなら自動インストール(初回のみ)
2. dotfiles をホームディレクトリへ配置(`Brewfile` → `~/Brewfile` など)
3. `run_onchange_after_01_homebrew_bundle.sh` — `brew bundle` でパッケージをインストール(Brewfile 変更時のみ再実行)

## 新しい Mac でのセットアップ

```bash
# chezmoi のインストールと init --apply を一発で実行
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply hrk-m
```

chezmoi インストール済みなら:

```bash
chezmoi init --apply hrk-m
```

## 日常の使い方

```bash
cd ~/src/github.com/hrk-m/dotfiles

# 反映前に差分を確認(apply の前に必ず実行する)
chezmoi diff --source .

# 変更をホームディレクトリへ反映
chezmoi apply --source .
```

Brewfile にパッケージを追加したら `chezmoi apply` で `brew bundle` が自動実行される。

## 手動で行う初期設定

- macOS のソフトウェアアップデート
- Modifier Keys(US 配列): caps lock → control
  - https://support.apple.com/ja-jp/guide/mac-help/mchlp1011/mac
- GitHub に SSH で接続する
  - https://docs.github.com/ja/github/authenticating-to-github/connecting-to-github-with-ssh
- インストールしたアプリの個別設定

## 参考

- iterm2(hotkey が効かない時)
  - https://www.smartbowwow.com/2018/11/mojaveiterm2hot-key.html
- HHKB(key 配置変更アプリ)
  - https://happyhackingkb.com/jp/download/

## 移行状況

`old/` に chezmoi 移行前の旧構成(git 設定、vimrc、VSCode 設定、macos/setup.sh など)が残っている。順次 chezmoi ソース形式へ移行予定。
