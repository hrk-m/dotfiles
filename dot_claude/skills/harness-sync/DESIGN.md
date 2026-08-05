# src ハーネス設計 (2026-07-07 / 2026-07-08 スキル同梱化 / 2026-08-03 SessionEnd トリガー化・dotfiles 管理化)

OpenAI の [Harness engineering](https://openai.com/index/harness-engineering/) を参考に、
`~/src` 配下のマルチリポジトリ環境をエージェントが迷わず作業できる「ハーネス」にする。

## 原則(記事より)

- **地図を渡す、マニュアルは渡さない**: 入口ドキュメントは短く保ち、詳細はポインタで辿らせる
- **ドキュメントは製品**: バックグラウンド実行(日次)で鮮度を機械的に維持する
- **エージェントのミスはハーネスのバグ**: 迷ったら本ファイルと SKILL.md 側を直す

## プログラムとデータの分離(新Mac移行対応)

- **プログラム**(このスキルディレクトリ `~/.claude/skills/harness-sync/`): SKILL.md / DESIGN.md / scripts/ / install.sh。真実源は dotfiles(`github.com/hrk-m/dotfiles` の `dot_claude/skills/harness-sync/`)で、`chezmoi apply` で配置される。**編集は dotfiles 側で行う**
- **データ**(`~/src/.harness/` と `~/src/HARNESS.md`): すべて再生成可能な生成物。移行不要。新Macでは chezmoi apply(install.sh 自動実行)→ `/harness-sync` で再構築される

## 構成物

| パス | 役割 |
|---|---|
| `~/.claude/skills/harness-sync/SKILL.md` | 同期スキル本体。手動 `/harness-sync` でも実行可 |
| `~/.claude/skills/harness-sync/scripts/scan.sh` | リポジトリ機械スキャン(TSV出力)。分類判定ロジックはすべてここに集約 |
| `~/.claude/skills/harness-sync/scripts/build-map.sh` | TSV から HARNESS.md(地図)を決定論的に生成 |
| `~/.claude/skills/harness-sync/scripts/sync.sh` | scan → GC → 地図再生成 → 再生成対象の列挙 |
| `~/.claude/skills/harness-sync/scripts/sessions.sh` | フィードバック抽出対象のセッション列挙(キュー消費 + mtime スキャンの統合・重複排除) |
| `~/.claude/skills/harness-sync/scripts/session-end-hook.sh` | Claude Code の SessionEnd hook。~/src 配下で作業したセッションをキューに記録し、`--run-sync`(自己再起動)で `claude -p "/harness-sync"` をバックグラウンド起動 |
| `~/.claude/skills/harness-sync/install.sh` | セットアップ(SessionEnd hook 登録・権限設定・データディレクトリ作成)。chezmoi apply から毎回実行される。冪等。`--with-launchd` で日次ジョブも登録 |
| `~/src/HARNESS.md` | 地図。全リポジトリの1行インデックス(目的/スタック/最終コミット/状態) |
| `~/src/.harness/repos/<host>/<org>/<repo>.md` | アクティブリポジトリの個別ドキュメント(AGENTS.md 相当) |
| `~/src/.harness/state/scan.tsv` | スキャン結果の中間データ |
| `~/src/.harness/state/pending-sessions.tsv` | SessionEnd hook が書くセッションキュー(cwd<TAB>transcript_path)。sessions.sh が消費 |
| `~/src/.harness/state/feedback-since` | フィードバック抽出の前回処理時刻(mtime スキャンの基準。全抽出成功時のみ前進) |
| `~/src/.harness/state/sync.lock` | hook 起動の直列化 lock(pid 入り。実行中はスキップ、死んだ pid は奪取) |
| `~/src/.harness/logs/` | 日次 sync の実行ログ |
| `~/Library/LaunchAgents/com.hrk-m.harness-sync.plist` | オプションの launchd 日次実行(毎日 8:47、取りこぼし回収用)。`install.sh --with-launchd` 時のみ生成 |
| `~/src/.claude/settings.json` | ヘッドレス実行時の権限(defaultMode: bypassPermissions。~/src 配下の実行のみ権限プロンプトなし。書き込み先の制約は SKILL.md の原則で担保)。install.sh が生成 |
| `~/.claude/CLAUDE.md` | 「src 配下では HARNESS.md を参照」のポインタセクション(dotfiles の dot_claude/CLAUDE.md で管理) |

## 判定ルール(scan.sh に実装)

- **active**: 最終コミットが90日以内
- **stale**: それ以外
- **copy**: ディレクトリ名が「のコピー」を含む(NFD 正規化のため「のコ」でマッチ)、または `old_` で始まる(個別ドキュメント生成対象外)

## フィードバックループ(セッション由来の運用知見)

記事の「AGENTS.md は生きた制約システム」を実現する書き戻しの仕組み。

- セッションの検出は2経路(`scripts/sessions.sh` が統合し、file パスで重複排除):
  1. **SessionEnd キュー**(主経路、Claude のみ): `scripts/session-end-hook.sh` が
     Claude Code の SessionEnd hook として `~/src` 配下で作業したセッションの
     (cwd, transcript_path) を `state/pending-sessions.tsv` に記録する。
     完結したセッションだけが正確に入る。sessions.sh が読み込み時に消費する。
     記録後、同 hook が `claude -p "/harness-sync"` をバックグラウンド起動するため、
     セッション終了が sync の実行契機になる(lock で直列化。実行中に閉じたセッションの
     分は次のトリガーか手動実行が回収する。hook のヘッドレス実行自身は cwd=~/src 直下の
     ため除外され、再帰しない)
  2. **mtime スキャン**(フォールバック + Codex 用): 前回実行以降(state/feedback-since)に
     更新された Claude(`~/.claude/projects/**/*.jsonl`)/ Codex
     (`~/.codex/sessions/**/rollout-*.jsonl`)のログを列挙し、cwd から対応付ける。
     hook の取りこぼし(未登録期間・jq 不在)や抽出失敗時の再処理はこちらが担保する
- リポジトリごとにサブエージェントがログを選択的に読み、
  「次のエージェントが同じ失敗をしないための知見」を 0〜3 個抽出
- 個別 doc の「## 注意点」内「### 運用知見(セッション由来)」に `- [日付] 知見` で追記
  (重複排除・最大10件・資格情報や個人情報の転記は禁止)
- doc 再生成テンプレートはこの小節を一字一句保持するため、再生成で知見は消えない
- 手動ループも併設: 作業中にハマった知見はエージェント/人が直接この小節に追記してよい
  (CLAUDE.md のハーネスセクションに記載)

## 個別ドキュメントの再生成条件

リポジトリの最終コミット時刻 > 個別 md のフロントマター `generated_epoch` のときのみ再生成。
差分駆動なので日次実行は通常ほぼ no-op で軽い。

## 置き場所の判断

個別ドキュメントは各リポジトリ内ではなく中央 `~/src/.harness/` に置く。
理由: 各リポジトリの git status を汚さない・コミット権限が不要・リポジトリ削除時も地図側だけで完結。
