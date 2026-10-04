---
name: image-gen
description: >-
  ラスター画像（写真・イラスト・モックアップ・ヒーロー画像・商品画像・ビットマップアイコン・
  透過切り抜き）を OpenAI GPT Image で生成・編集する。ローカルの Codex CLI を非対話で叩き、
  ユーザーの ChatGPT サブスクで課金されるためAPIキー不要。「画像を生成」「イラスト/モックを作って」
  「gpt image で」「この画像を編集」「背景を消して」や、プロジェクトにビットマップ素材が要るとき
  にトリガー。動画・SVG・コードで描くべき図はこのスキルの対象外。
---

# Image Gen（Codex CLI 経由 GPT Image 統合）

出典統合: claude-code-image-generation / codex-image / Codex Plugin CC の画像生成部分。
実体は同じ「Codex CLI の `image_gen`（GPT Image）を非対話で呼ぶ」なので1本に統合した。

## 前提

```bash
npm i -g @openai/codex    # Codex CLI
codex login               # ChatGPT アカウントでサインイン（APIキー不要）
```

生成スクリプト `gen.sh` は本スキルのディレクトリにある（`<skill-dir>/gen.sh`）。1回の生成は概ね30〜90秒。

## コマンド

```bash
<skill-dir>/gen.sh -o <out.png> [options] "<prompt>"
```

| オプション | 意味 |
|---|---|
| `-o PATH` | 出力ファイル（必須）。プロジェクト素材はプロジェクト内、試作はscratchへ |
| `-n N` | 1〜4 バリアント → `out-1.png`, `out-2.png`, … |
| `-r FILE` | スタイル/構図の参照画像（複数可） |
| `-e FILE` | 編集対象画像（プロンプトが指示した箇所だけ変える） |
| `-t` | 背景透過 |
| `-a square\|portrait\|landscape` | アスペクト比 |

保存した絶対パスを表示。既存名は上書きせず時刻サフィックスを付ける。
Bash 呼び出しの timeout は **最低 300000ms**（`-n 3`/`-n 4` は 600000ms）。
複数の異なる画像は、1プロンプトに詰めず**別コマンドで並列実行**する方が安全で速い。

## ワークフロー

1. 依頼を明確なプロンプトに: 被写体・スタイル/画材・構図・ライティング・配色・
   （文字を入れるなら）引用符で正確な文字列・避けたいもの。ユーザー指定は残し、曖昧なときだけ詳細を足す。
2. `gen.sh` を実行。
3. **出力画像を実際に見て**一致を確認（被写体・文字のスペル・フレーミング）。ずれたら
   プロンプトを1点だけ変えて再実行、または結果に `-e` で小修正。
4. 保存パスと最終プロンプトを報告。プロジェクト用途ならコードから参照する。

## トラブルシュート

- `codex CLI not found` → `npm i -g @openai/codex`。
- `Codex is not logged in` → `codex login` で ChatGPT サインイン。
- `No image was generated` → プランの画像上限切れ、またはプロンプト拒否。

## 事業への適用
- **C 資料・集客**: LP/スライド/SNS のヒーロー画像・モック・商品カット。`web-design` と併用。
- **A 自社プロダクト**: OGP画像、空状態イラスト、ビットマップアイコンの量産。

## 出典
- claude-code-image-generation (mishagavura) — MIT. github.com/mishagavura/claude-code-image-generation
- codex-image (wjb127) — MIT. github.com/wjb127/codex-image
- Codex Plugin CC (openai) — Apache-2.0. github.com/openai/codex-plugin-cc
  （Codex のコードレビュー委譲機能は `codex-bridge` 側に分離した）
