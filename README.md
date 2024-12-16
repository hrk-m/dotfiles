## 初期設定

## 手順

- macOS のソフトウェアアップデートをする
- App Storeからxcode のインストール
- brew をインストール
  - https://chigusa-web.com/blog/homebrew/ を参考にインストール
- Modifier Keys（US）
  - https://support.apple.com/ja-jp/guide/mac-help/mchlp1011/mac
    - caps lock → control

- システム設定

```bash
$ curl https://raw.githubusercontent.com/hrk-m/dotfiles/master/install.sh | sh
```

- ドットファイルのシンボリング

```bash
$ cd ~/src/github.com/hrk-m/dotfiles
$ sh set_symlink.sh
```

- インストールしたアプリの設定

- github
  - [GitHub に SSH で接続する(docs)](https://docs.github.com/ja/github/authenticating-to-github/connecting-to-github-with-ssh)
  - [GitHub で ssh 接続(Qiita)](https://qiita.com/shizuma/items/2b2f873a0034839e47ce)

## 参考

- Vscode
  - [Vscode version 確認](https://code.visualstudio.com/updates/v1_43)
- iterm
  - [iterm(hotkey が効かない時)](https://www.smartbowwow.com/2018/11/mojaveiterm2hot-key.html)
