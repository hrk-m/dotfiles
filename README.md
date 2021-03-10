## 初期設定

## 手順

1. macOS のソフトウェアアップデートをする
2. xcode のインストール
3. 必要な環境とアプリをインストール

```bash
$ curl https://raw.githubusercontent.com/hrk-m/dotfiles/master/install.sh | sh
```

4. fish shell の設定

```bash
$ cd ~/src/github.com/hrk-m/dotfiles
$ sh set_fish.sh
```

4. ドットファイルのシンボリング

```bash
$ cd ~/src/github.com/hrk-m/dotfiles
$ sh set_symlink.sh
```

5. インストールしたアプリの設定

- github
  - [GitHub に SSH で接続する(docs)](https://docs.github.com/ja/github/authenticating-to-github/connecting-to-github-with-ssh)
  - [GitHub で ssh 接続(Qiita)](https://qiita.com/shizuma/items/2b2f873a0034839e47ce)
- iterm hot-key の導入
  - https://qiita.com/okamu_/items/a5086d2d5ba405f35acb
  - Preferences -> General -> Selection にある`Copied text includes trailing newline`にチェックを入れる

## その他設定

```bash
$ git clone git@github.com:hrk-m/dotfiles.git
$ cd dotfiles
$ sh set_symlink.sh
```

## 参考

- fish
  - [fish アンインストール(完全削除)](https://natsukium.github.io/fish-docs-jp/faq/uninstall.html)
- Vscode
  - [Vscode version 確認](https://code.visualstudio.com/updates/v1_43)
- iterm
  - [iterm(hotkey が効かない時)](https://www.smartbowwow.com/2018/11/mojaveiterm2hot-key.html)
