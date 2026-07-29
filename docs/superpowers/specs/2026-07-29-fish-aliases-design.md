# zsh alias の fish 移植 設計

日付: 2026-07-29

## 目的

zsh(.zshrc)の alias 26個を fish に移植し chezmoi 管理にする。移植範囲は全部(選別しない)、方式は abbr ではなく alias(zsh と同じ使い勝手を優先。ユーザー選択)。

## 変更内容

`dot_config/fish/conf.d/aliases.fish`(新規)— 全 alias を zsh と同じカテゴリ構成で定義。`status is-interactive` ガード付き(zsh の alias は対話専用なので挙動を揃える。スクリプト実行時に add / commit 等が git を握る事故も防ぐ)。

### fish 固有の吸収点

- `ls`・`code`・`cursor` の自己参照 — fish の alias ビルトインが自動で `command` を前置するため無限再帰しない(検証済み)。
- `gstash` の `stash@{0}` — fish はブレース展開するため body 内でシングルクォートして保護。
- `ip` の perl ワンライナー — fish のシングルクォート内 `\'` エスケープで perl の引数クォートを維持。`$1` はシングルクォート内なので literal のまま。

## 検証

- apply 後、対話 fish で全個数の関数定義を機械チェック(未定義ゼロ)。
- 自己参照3つが `command` 化されていることを確認。
- 実動作: `..`(cd)、`lp`、`ip`(IP 出力)、`g --version` を確認済み。
