---
name: docs-lookup
description: >-
  ライブラリ・フレームワークの最新版APIドキュメントとコード例を Context7 (ctx7) で取得し、
  コーディングアシスタントに最新情報を渡す。コードを書く・APIシグネチャを確認する・学習データが
  古い可能性があるとき、「ctx7」「context7」「最新のドキュメント」「このライブラリの使い方」
  と言われたときにトリガー。バージョン固有のドキュメントを引くことで、古い記憶による誤りを防ぐ。
---

# Docs Lookup（Context7 で最新ドキュメント参照）

出典: Context7 (upstash)。ライブラリの**バージョン固有**ドキュメントをソースから取得し、
学習データが古いことによるAPI誤用を防ぐ。

## 前提

```bash
npm install -g ctx7@latest     # または npx ctx7@latest <command>
```

claude.ai の Context7 プラグイン（MCP）を有効化する手もある（`docs/bridges.md`）。
リモートMCP利用時は認証を求められることがある。

## 使い方

```bash
# 1. ライブラリIDを解決
ctx7 library next.js "app router"

# 2. そのIDで最新ドキュメントを取得
ctx7 docs <libraryId> "server actions の使い方"
```

スキル管理機能も持つ:
```bash
ctx7 skills search <keywords>     # レジストリ検索
ctx7 skills suggest               # プロジェクト依存から自動提案
ctx7 skills install /owner/repo   # リポジトリから導入
```

## ワークフロー

1. 新しめ／更新の速いライブラリ（Next.js, React, Tailwind, Supabase SDK, polars, 最新のLLM SDK 等）を
   使う前に、記憶に頼らず `ctx7 library` → `ctx7 docs` で現行APIを確認。
2. 取得したシグネチャ・例に従って実装。`lean-code` と併用し、最小の正しい呼び出しにする。
3. バージョン差異が疑わしいエラー（非推奨API・引数変更）を踏んだら、まずここで最新仕様を引く。

## 事業への適用
- **A 自社SaaS/アプリ**: フロント/バックの依存を最新APIで実装し、非推奨による手戻りを防ぐ。
- **B データ分析/ML**: データ/ML ライブラリ（pandas, polars, sklearn, torch, LLM SDK）の現行APIを確認。

## 出典
- Context7 (upstash) — MIT License. github.com/upstash/context7
