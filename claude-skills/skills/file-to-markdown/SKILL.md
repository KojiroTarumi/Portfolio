---
name: file-to-markdown
description: >-
  PDF・Word・Excel・PowerPoint・HTML・画像・音声などを Microsoft MarkItDown で Markdown に
  一括変換し、低トークンで読み込む。「このPDF/資料/スライドを読んで要約」「大量のファイルを
  取り込んで」「markitdownで」「md化して」と言われたとき、または多数・多種のファイルを
  Claudeに渡す前処理が要るときにトリガー。※ファイルの"編集・生成"は行わない——
  編集が必要なら pdf / docx / xlsx / pptx スキルに渡す。
---

# File to Markdown（MarkItDown で低トークン取り込み）

出典: Microsoft MarkItDown。目的は「多種・大量のファイルを、構造を保ったMarkdownにして
**読み込みトークンを抑え、Claudeに正確に伝える**」こと。生成・編集は守備範囲外。

> 住み分け（既存スキルとの整合性）:
> - **読むための前処理** → このスキル（markitdown で md 化）。
> - **PDFの作成/フォーム記入/結合分割** → `pdf` スキル。
> - **Word/Excel/PPTの作成・編集** → `docx` / `xlsx` / `pptx` スキル。
> 迷ったら「読むだけか、書くか」で判断する。

## 前提

```bash
pip install 'markitdown[all]'      # 全フォーマット対応
# または最小構成: pip install markitdown
markitdown --version
```

## 使い方

```bash
# 単一ファイルを md 化して標準出力
markitdown input.pdf > out.md

# スライド・表計算・文書
markitdown deck.pptx    > deck.md
markitdown report.xlsx  > report.md
markitdown contract.docx > contract.md

# ディレクトリ一括（scratchに出してから読む）
mkdir -p ./_md
for f in ./inbox/*; do markitdown "$f" > "./_md/$(basename "${f%.*}").md" || echo "skip $f"; done
```

## ワークフロー

1. 対象ファイルを `markitdown` で md 化（大量なら一括ループ）。
2. 生成した `.md` を読む。元のバイナリを直接読むよりトークンが大幅に減り、表や見出し構造も保たれる。
3. 要約・抽出・分析など本来のタスクを md に対して行う。
4. 変換に失敗/文字化けしたファイルだけ、個別に `pdf`（OCR含む）等の専用スキルへ回す。

## セキュリティ注意

MarkItDown は現在のプロセス権限でI/Oする（`open()` や `requests.get()` と同じ）。
信頼できない入力は扱う前にサニタイズし、リモートURLの変換は中身を確認してから行う。

## 事業への適用
- **C 契約・資料**: 受領したPDF契約書・提案資料・スライドを md 化して高速レビュー（`legal` と併用）。
- **B データ分析**: 配布資料・仕様書・論文PDFを md 化して要件/数式/表を取り込む。

## 出典
- MarkItDown (Microsoft) — MIT License. github.com/microsoft/markitdown
