#!/bin/bash
# build-map.sh — scan.sh の TSV から ~/src/HARNESS.md(地図)を決定論的に生成する。
# purpose の優先順位: .harness/repos/<rel>.md の frontmatter `purpose:` > README 先頭見出し > "-"
# 使い方: scan.sh | build-map.sh > ~/src/HARNESS.md
set -euo pipefail

SRC="${SRC:-$HOME/src}"
HARNESS="$SRC/.harness"
TODAY=$(date +%Y-%m-%d)

purpose_of() {
  local rel="$1" doc="$HARNESS/repos/$1.md" readme p=""
  if [ -f "$doc" ]; then
    p=$(sed -n 's/^purpose:[[:space:]]*//p' "$doc" | head -1)
  fi
  if [ -z "$p" ]; then
    for readme in "$SRC/$rel/README.md" "$SRC/$rel/README.rdoc" "$SRC/$rel/readme.md"; do
      if [ -f "$readme" ]; then
        p=$(grep -m1 -vE '^\s*$|^\s*(#+\s*$|!\[|<|\[!|=begin|---)' "$readme" 2>/dev/null | sed 's/^#*[[:space:]]*//' | cut -c1-80)
        break
      fi
    done
  fi
  echo "${p:--}"
}

cat <<EOF
# HARNESS.md — ~/src リポジトリ地図

> 自動生成: $TODAY(/harness-sync)。手で編集しない。
> これは「地図」であり詳細は各リンク先を参照する。
> - **active** リポジトリの詳細(目的・アーキテクチャ・コマンド)は \`.harness/repos/<path>.md\`
> - 仕組みの設計とスクリプトは \`~/.claude/skills/harness-sync/\`(DESIGN.md / scripts/)
> - status: active=90日以内にコミット / stale=それ以外 / copy=複製(触らない)

EOF

sort -t$'\t' -k4,4 -k1,1 /dev/stdin | awk -F'\t' '{print $0}' | {
  # ホスト/org ごとにグループ化するため path 順に並べ直す
  sort -t$'\t' -k1,1
} | {
  prev_group=""
  while IFS=$'\t' read -r rel iso epoch status stack remote; do
    group=$(dirname "$rel")
    if [ "$group" != "$prev_group" ]; then
      printf '\n## %s\n\n' "$group"
      printf '| repo | purpose | stack | last commit | status |\n|---|---|---|---|---|\n'
      prev_group="$group"
    fi
    name=$(basename "$rel")
    if [ "$status" = "active" ] && [ -f "$HARNESS/repos/$rel.md" ]; then
      link="[$name](.harness/repos/$rel.md)"
    else
      link="$name"
    fi
    purpose=$(purpose_of "$rel" | tr '|' '/')
    printf '| %s | %s | %s | %s | %s |\n' "$link" "$purpose" "$stack" "$iso" "$status"
  done
}
