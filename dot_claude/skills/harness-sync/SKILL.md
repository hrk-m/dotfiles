---
name: harness-sync
description: ~/src 配下のリポジトリ地図(HARNESS.md)と個別ドキュメント(.harness/repos/)を同期し、前回実行以降の Claude / Codex セッションログから運用知見を抽出して個別ドキュメントに書き戻す(フィードバックループ)。~/src 配下のセッション終了時(SessionEnd hook)に自動実行されるほか、リポジトリを追加・移動した後や地図が古いと感じたときに手動で /harness-sync を実行する。
---

# harness-sync

`~/src` のハーネス(リポジトリ地図 + 個別ドキュメント)を最新化する。
設計はこのスキルと同じディレクトリの `DESIGN.md` を参照。判定ロジックはすべて `scripts/` のスクリプト側にあり、このスキルはそれを呼び出して差分だけを埋める。

プログラム(このスキルディレクトリ)とデータ(`~/src/.harness/`)は分離されており、データはすべて再生成可能。

## 手順

### 1. 決定論的同期を実行

```bash
~/.claude/skills/harness-sync/scripts/sync.sh
```

これがスキャン → 孤児ドキュメントのGC → `~/src/HARNESS.md` 再生成までを行い、
**再生成が必要な active リポジトリの相対パス**(例: `github.com/hrk-m/what-next`)を標準出力に列挙する。

- 出力が空なら doc 再生成は不要。手順2〜3をスキップして手順4(フィードバック抽出)へ進む。**フィードバック抽出とログ記録(手順4〜5)は再生成の有無にかかわらず毎回実行する。**

### 2. 個別ドキュメントをサブエージェントで再生成

手順1で列挙された各リポジトリについて、**1リポジトリ = 1サブエージェント**を並列起動する。サブエージェントを起動できない実行環境では、その制約を最終報告に明記した上で、同じテンプレートを現在のエージェントでリポジトリごとに順番に実行してよい。

プロンプトは以下のテンプレートの `<rel>` を相対パス、`<name>` をリポジトリ名(basename)に置換して使う(`~` は実行ユーザーのホーム。Write ツールを使う場合は絶対パスに展開すること):

```
あなたはリポジトリドキュメント生成エージェント。対象リポジトリ: ~/src/<rel>

1. リポジトリを調査する(README、主要設定ファイル、ディレクトリ構造、エントリポイント)。全ファイルは読まず要点のみ。
2. `mkdir -p` で親ディレクトリを作った上で ~/src/.harness/repos/<rel>.md に以下の形式で書き込む:

---
repo: <rel>
purpose: <60字以内の一行説明>
head_commit: <対象リポジトリで git rev-parse HEAD した結果>
generated_epoch: <date +%s の結果>
generated_at: <date -Iseconds の結果>
---
# <name>

## 目的
## 技術スタック・アーキテクチャ
## 主要ディレクトリ
## コマンド(セットアップ/ビルド/テスト/実行)
## 注意点(エージェントが作業する際のハマりどころ)

全体で120行以内。コマンドは Makefile / package.json / README 等に実在するものだけを書き、推測で書かない。日本語で書く。既存の doc がある場合も全体を書き直してよいが、「注意点」セクションに人手で追記された知見があれば保持し、「### 運用知見(セッション由来)」小節は一字一句そのまま保持する。人手追記か生成済み記述か判別できない既存の注意点は、削除せずすべて保持する。
3. 最終メッセージは「ファイルパス + purpose の一行」のみ返す。
```

サブエージェント(または fallback の順次実行)が書いた doc は、手順3の前に最低限だけ検証する:

- frontmatter の `repo` / `purpose` / `head_commit` / `generated_epoch` / `generated_at` が各1回だけ存在する
- `head_commit` が対象リポジトリの `git rev-parse HEAD` と一致する
- `generated_epoch` が数値で、`generated_at` が `date -Iseconds` 形式である
- 必須見出し(目的 / 技術スタック・アーキテクチャ / 主要ディレクトリ / コマンド / 注意点)が揃っている

対象リポジトリは読み取り専用で扱う(サブエージェントのプロンプトにもその旨を一文含める)。書き込み監査は必須ではない。行う場合は、サブエージェント起動**前**に対象リポジトリごとに `git -C ~/src/<rel> status --porcelain` の結果を控え、完了後に同じコマンドの結果と比較する。作業前からある dirty state は harness-sync の変更として扱わない(baseline を取り損ねた場合は mtime 比較で代替してよい)。

### 3. 地図を再ビルド

新しい purpose を地図に反映するため、もう一度実行する:

```bash
~/.claude/skills/harness-sync/scripts/sync.sh
```

(直前に doc を再生成したばかりなので、今回は再生成対象は列挙されないはず。列挙された場合はサブエージェントの frontmatter 書き込み失敗なので、該当リポジトリだけ手順2をやり直す)

### 4. 前日セッションからフィードバックを抽出して書き戻す

前回実行以降の Claude / Codex セッションログから「次のエージェントが同じ失敗をしないための知見」を抽出し、個別 doc の注意点に書き戻す(ハーネスを生きた制約システムにするフィードバックループ)。対象セッションの検出は sessions.sh が内部で行う(SessionEnd hook のキューが主経路、mtime スキャンがフォールバック。詳細は DESIGN.md)。キューは sessions.sh が実行時に消費するので、このスキル側でキューを操作する必要はない。

```bash
~/.claude/skills/harness-sync/scripts/sessions.sh
```

- 1行目のヘッダ `# since=<epoch> now=<epoch>` の `now` の値を控える(手順4の最後で state に書く)
- 2行目以降は `rel<TAB>source<TAB>file`。**rel が `-` の行と、`.harness/repos/<rel>.md` が存在しない rel の行はスキップ**する
- スキップ後の対象行が0件なら抽出エージェントは起動せず、state 更新(本手順末尾)だけ行って手順5へ進む
- 残った行を rel ごとにグループ化し、**1リポジトリ = 1サブエージェント**を並列起動する(手順2と同じ fallback 可)。プロンプトテンプレート:

```
あなたはハーネスのフィードバック抽出エージェント。対象リポジトリ: ~/src/<rel>
入力は前日のセッションログ(JSONL):
<source と file の一覧>

制約: セッションログと対象リポジトリは読み取り専用。書き込んでよいのは ~/src/.harness/repos/<rel>.md のみ。

1. 各ファイルは丸ごと読まず、grep / tail で選択的に読む。探すもの: エラーと最終的にどう解決したか、失敗したコマンドと代替、ユーザーによる訂正・指摘、環境起因のハマり。
   - claude 形式: ツール結果のエラーや user メッセージの訂正に注目
   - codex 形式: exit_code が 0 以外の shell 結果や user turn に注目
2. 「次にこのリポジトリで作業するエージェントが同じ失敗をしないための知見」を 0〜3 個抽出する。
   - 除外: 一般論、そのセッション限りの一時的な話、進行中タスクの経過。資格情報・トークン・個人情報は絶対に書かない。
3. 知見が 0 個ならファイルに触らず「知見なし」とだけ報告して終了する。
4. 知見があれば ~/src/.harness/repos/<rel>.md の「## 注意点」内の「### 運用知見(セッション由来)」小節(なければ小節ごと作る)に `- [YYYY-MM-DD] <知見>` 形式で追記する。YYYY-MM-DD は**このスキルの実行日**(ローカルタイムの今日。セッションの発生日ではない)。既存知見と同内容なら追加しない。小節が10件を超えたら古い日付から削る。ファイルの他の部分は変更しない。
5. 最終メッセージは追記した知見の箇条書き(または「知見なし」)のみ返す。
```

- 全サブエージェントが**成功**した場合のみ、控えた `now` の値で state を更新する。失敗した抽出サブエージェントが1つでもあった場合は state を更新しない(キューは消費済みだが、feedback-since が進まない限り mtime スキャンが次回同じログを拾い直すため、知見は失われない):

```bash
echo <now> > ~/src/.harness/state/feedback-since
```

### 5. ログを記録

```bash
echo "$(date -Iseconds) regenerated=<件数> repos=<スペース区切りの相対パス or none> feedback=<件数>" >> ~/src/.harness/logs/sync.log
```

- `feedback=` は**1件以上の追記が発生したリポジトリ数**(抽出を実行した対象リポジトリ数ではない。例: 対象4リポジトリ中2つに追記したら `feedback=2`)

## 原則

- `~/src/HARNESS.md` と `~/src/.harness/` 以外には**一切書き込まない**。各リポジトリ内のファイルは読み取り専用。
- セッションログ(`~/.claude/projects/`、`~/.codex/sessions/`)も読み取り専用。ログ内の資格情報・個人情報を doc に転記しない。
- 分類ルール(active/stale/copy)を変えたいときはこのスキルではなく `scripts/scan.sh` を修正する。地図の体裁は `scripts/build-map.sh`。
- 同日に複数回実行されても安全(冪等)。過去の実行痕跡(sync.log のエントリ等)があっても、真実源は state(`feedback-since` と各 doc の `generated_epoch`)であり、それに基づいてそのまま続行してよい。
- エージェントが地図で迷ったら、それはこのハーネスのバグ。`DESIGN.md` と本スキルを直す。

## 新しい Mac への移行

このスキルは dotfiles(`github.com/hrk-m/dotfiles`、chezmoi 管理の `dot_claude/skills/harness-sync/`)に含まれており、`chezmoi init --apply hrk-m` で `~/.claude/skills/harness-sync/` への配置と `install.sh` の実行(SessionEnd hook 登録・ヘッドレス権限設定・データディレクトリ作成)まで自動で行われる。`~/src/.harness/` のデータは持っていかなくてよい(すべて再生成される)。`~/.claude/CLAUDE.md` の「~/src リポジトリハーネス」セクションも dotfiles(`dot_claude/CLAUDE.md`)で配布される。

1. リポジトリ群を新Macの `~/src` に配置する(初回 apply 時点で `~/src` が無かった場合も、install.sh は毎回の `chezmoi apply` で再実行されるため配置後の apply で回収される)
2. `/harness-sync` を手動実行して地図と個別ドキュメントを初回生成する
3. セッション終了トリガーに加えて日次の定期実行(取りこぼし回収)も欲しい場合のみ、`~/.claude/skills/harness-sync/install.sh --with-launchd` を実行する
