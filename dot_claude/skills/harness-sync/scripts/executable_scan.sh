#!/bin/bash
# scan.sh — ~/src 配下の git リポジトリを機械スキャンして TSV を出力する。
# 列: path<TAB>last_commit_iso<TAB>last_commit_epoch<TAB>status<TAB>stack<TAB>remote
# status: active(90日以内にコミット) / stale / copy(「のコピー」or old_ プレフィックス)
set -euo pipefail

SRC="${1:-$HOME/src}"
NOW=$(date +%s)
ACTIVE_WINDOW=$((90 * 24 * 3600))

detect_stack() {
  local d="$1" s=()
  [ -f "$d/go.mod" ] && s+=("Go")
  [ -f "$d/Cargo.toml" ] && s+=("Rust")
  [ -f "$d/Gemfile" ] && s+=("Ruby")
  { [ -f "$d/pyproject.toml" ] || [ -f "$d/requirements.txt" ]; } && s+=("Python")
  { [ -f "$d/pom.xml" ] || [ -f "$d/build.gradle" ] || [ -f "$d/build.gradle.kts" ]; } && s+=("Java")
  if [ -f "$d/package.json" ]; then
    if [ -f "$d/tsconfig.json" ]; then s+=("TS"); else s+=("JS"); fi
  fi
  { [ -f "$d/main.tf" ] || compgen -G "$d/*.tf" > /dev/null 2>&1; } && s+=("Terraform")
  if [ ${#s[@]} -eq 0 ]; then echo "-"; else (IFS=/; echo "${s[*]}"); fi
}

find "$SRC" -maxdepth 4 -name .git \( -type d -o -type f \) 2>/dev/null | sed 's|/\.git$||' | sort | while read -r repo; do
  rel="${repo#"$SRC"/}"
  epoch=$(git -C "$repo" log -1 --format=%ct 2>/dev/null || echo 0)
  if [ "$epoch" -eq 0 ]; then iso="-"; else iso=$(date -r "$epoch" +%Y-%m-%d); fi

  base=$(basename "$repo")
  # 「のコピー」判定は「のコ」で行う(macOS の NFD 正規化で「ピ」が分解されるため)
  if [[ "$base" == *のコ* || "$base" == old_* ]]; then
    status="copy"
  elif [ $((NOW - epoch)) -le "$ACTIVE_WINDOW" ] && [ "$epoch" -gt 0 ]; then
    status="active"
  else
    status="stale"
  fi

  stack=$(detect_stack "$repo")
  remote=$(git -C "$repo" remote get-url origin 2>/dev/null || echo "-")
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$rel" "$iso" "$epoch" "$status" "$stack" "$remote"
done
