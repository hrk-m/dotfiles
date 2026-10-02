---
name: dotfiles-sync-homebrew
description: ローカルにインストール済みの Homebrew パッケージのうち Brewfile に無い新規分を、chezmoi ソース(dotfiles リポジトリ)の Brewfile へ追記して取り込む。「Brewfile に反映」「brew の変更を取り込む」「homebrew を dotfiles 同期」「インストールしたパッケージを Brewfile に」と言われたら使用する。fish は dotfiles-sync-fish を使う。
---

# dotfiles-sync-homebrew

ローカルで `brew install` したパッケージを chezmoi ソース(dotfiles リポジトリ)の `Brewfile` に取り込む。

**対象**: `~/Brewfile`（chezmoi 管理。ソースは `$REPO/Brewfile`）
**リポジトリ(ソース)**: `~/src/github.com/hrk-m/dotfiles`

## 前提・原則(重要)

このリポジトリの Brewfile には明確な管理方針がある(CLAUDE.md より)。**単純な `brew bundle dump --force` での上書きは禁止**:

- **コメントアウト行は「過去ログで使用実績がないと判定して意図的に外したもの」。勝手に復活させない。**
- したがって dump の全量上書きは、コメント行を消し・外したパッケージを復活させてしまうため方針違反。
- このスキルは **「現在インストール済み vs Brewfile に未記載」の新規分だけを追記提案**する。既存行の削除・並べ替え・コメント復活はしない。

その他:
- `--source ~/src/github.com/hrk-m/dotfiles` を明示する。
- **コミット・push はしない**。追記後は `git diff` を提示してレビューに委ねる。
- `chezmoi apply` は実行しない。
- Brewfile は re-add 対象だが、ここでは「ソースの Brewfile を直接編集 → 必要なら home に再取り込み」する(dump の加工が必要なため re-add 一発では済まない)。

## 手順

### 1. 現在インストール済みを一時ファイルへ dump

```bash
REPO=~/src/github.com/hrk-m/dotfiles
TMP=$(mktemp -t Brewfile.current.XXXX)
brew bundle dump --force --file="$TMP"   # 一時ファイルのみ。既存 Brewfile には触れない
```

### 2. Brewfile に未記載の新規パッケージを抽出

既存 Brewfile の**有効行(コメント `#` を除く)**にあるエントリと比較し、dump 側にしか無い行を抽出する。

```bash
SRC="$REPO/Brewfile"
# 既存の有効エントリ(brew/cask/tap/mas/vscode 行)。コメント行は除外。
grep -E '^(brew|cask|tap|mas|vscode) ' "$SRC" | sort -u > /tmp/bf_existing.txt
grep -E '^(brew|cask|tap|mas|vscode) ' "$TMP" | sort -u > /tmp/bf_current.txt
echo "=== Brewfile に無い新規インストール分 ==="
comm -13 /tmp/bf_existing.txt /tmp/bf_current.txt
echo "=== 参考: Brewfile にあるが現在未インストール(=削除候補。このスキルでは触らない) ==="
comm -23 /tmp/bf_existing.txt /tmp/bf_current.txt
```

- 新規分が無ければ「取り込むものは無い」と報告して終了。
- 未インストール側(後半)は**コメントアウトで意図的に外した可能性がある**ので、このスキルでは一切変更しない(情報として提示するのみ)。

### 3. 新規分だけを Brewfile へ追記

- 抽出した新規行を**既存の該当セクション(tap / brew / cask / mas など)の末尾**に追記する。Edit ツールで追記し、既存行・コメントは変更しない。
- どのセクションに入れるべきか曖昧なときは、種別(`brew`/`cask`/`tap` など)に対応するブロックの末尾へ。
- 追記前に各パッケージの存在を確認してもよい(`brew info <name>` / `brew info --cask <name>`)。削除済み cask・廃止 tap を書くと `brew bundle` がエラーになるため。

### 4. 検証・報告

```bash
git -C "$REPO" diff -- Brewfile
rm -f "$TMP" /tmp/bf_existing.txt /tmp/bf_current.txt
```

報告に含める:
- 追記した新規パッケージ一覧
- 未インストール(削除候補)として検出したが**意図的な除外の可能性があり触らなかった**もの
- **コミット・push は未実施**である旨
- (任意)`~/Brewfile` を揃えたい場合は別途 `chezmoi apply` が必要だが、このスキルでは実行しない旨
