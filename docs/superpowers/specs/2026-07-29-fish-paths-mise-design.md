# fish の PATH/環境変数移植と mise 一本化 設計

日付: 2026-07-29

## 目的

漏れチェックで見つかった「zsh にあって fish にない」設定のうち、実害のあるもの(PATH・環境変数・Ruby)を fish に移植する。同時にバージョン管理ツールの二重管理(zsh=asdf+rbenv / fish=mise)を mise に一本化する。

## 決定事項

- Ruby は rbenv から mise へ移行する(ユーザー決定)。zsh 側の rbenv 設定は触らない(zsh は現状維持のまま自然消滅させる)。
- 秘匿設定(zsh の `~/.zshrc.local` 相当)は新たな仕組みを作らない。fish が `conf.d/*.fish` を全部自動で読む性質を使い、chezmoi 管理外のファイル(例: `conf.d/local_secrets.fish`)を直接置く規約とし、README に記載。
- `.last_dir`(前回ディレクトリ復帰)と `GOPATH` 環境変数(デフォルト値と同一)は移植しない。
- sheldon(zsh プラグイン)・プロンプト・履歴設定・Kiro 統合は fish では不要のため対象外。

## 変更内容

1. `dot_config/fish/conf.d/paths.fish`(新規)— `fish_add_path -g` で `~/bin`・`~/.local/bin`・`~/go/bin`・`~/.bun/bin`・maestro・antigravity を追加。`ANDROID_HOME` を set -gx し emulator / platform-tools も PATH へ。universal 変数(fish_variables=マシン状態)ではなく conf.d 起点にすることで新マシンでも再現される。
2. Brewfile — `asdf` と `rbenv` をコメントアウト(理由コメント付き: mise に一本化)。このマシンからのアンインストールはしない(zsh がまだ参照)。
3. このマシンで `mise use -g ruby@3.4.9`(rbenv global と同じバージョン)を実行。
4. README — 秘匿設定の規約を追記。

## 検証

- クリーン環境(`env -i`)の新規ログイン fish で全 PATH エントリと ANDROID_HOME を確認済み。
- mise の ruby インストール後、fish で `ruby -v` が 3.4.9 になることを確認する。
- Brewfile 変更により apply 時に brew bundle が再実行されること(既存分は no-op)を確認済み。

## 既知の残課題

- `aic` alias は aicommit に依存するが、Brewfile では `aicommit` がコメントアウトされている(使用実績なし判定)。新マシンでは `aic` が動かない。復活させるかは別途判断。
- zsh 側の asdf / rbenv / aicommit は現状維持。fish 常用が安定したら .zshrc ごと整理する。
