#!/bin/bash
# sync.sh — harness 同期の決定論的パート。/harness-sync スキルから呼ばれる。
# 1. scan.sh で全リポジトリをスキャンし state/scan.tsv に保存
# 2. リポジトリが消えた個別ドキュメントを削除(GC)
# 3. HARNESS.md(地図)を再生成
# 4. 再生成が必要な active リポジトリの相対パスを標準出力に列挙
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
SRC="${SRC:-$HOME/src}"
HARNESS="$SRC/.harness"
mkdir -p "$HARNESS/state" "$HARNESS/repos" "$HARNESS/logs"

"$SCRIPT_DIR/scan.sh" "$SRC" > "$HARNESS/state/scan.tsv"

# GC: 対応するリポジトリが存在しない doc を削除
find "$HARNESS/repos" -name '*.md' 2>/dev/null | while read -r doc; do
  rel="${doc#"$HARNESS"/repos/}"
  rel="${rel%.md}"
  if [ ! -d "$SRC/$rel" ]; then
    rm "$doc"
    echo "GC: removed $rel" >&2
  fi
done

"$SCRIPT_DIR/build-map.sh" < "$HARNESS/state/scan.tsv" > "$SRC/HARNESS.md"

# 再生成が必要な active リポジトリを列挙
while IFS=$'\t' read -r rel iso epoch status stack remote; do
  [ "$status" = "active" ] || continue
  doc="$HARNESS/repos/$rel.md"
  if [ ! -f "$doc" ]; then echo "$rel"; continue; fi
  gen=$(sed -n 's/^generated_epoch:[[:space:]]*//p' "$doc" | head -1)
  if [ -z "$gen" ] || [ "$epoch" -gt "$gen" ]; then echo "$rel"; fi
done < "$HARNESS/state/scan.tsv"
