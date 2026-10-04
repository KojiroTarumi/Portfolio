---
name: codebase-graph
description: >-
  コードベースの構造・ファイル間の関係・アーキテクチャに関する質問に、Graphify で作った
  知識グラフを使って答える。特に `graphify-out/` が存在するときは、質問をまずグラフ照会として
  扱う。大規模リポジトリを読み直すたびに全ファイルを grep する代わりに、グラフのエッジを辿って
  必要な部分グラフだけを読み、トークンを大幅に抑える。「このコードベースを把握」「依存関係を調べて」
  「アーキテクチャを説明」「大きいリポジトリを読むのが重い」ときにトリガー。
---

# Codebase Graph（Graphify で読み直しトークンを削減）

出典: Graphify (Graphify-Labs)。コード・ドキュメント・設定・SQL・PDF を
決定論的なAST解析で知識グラフ化し、照会時は関連部分グラフだけを読む。
`lean-code`（書くコードを減らす）と役割が直交する「読むコードを減らす」スキル。

## 前提

```bash
pip install graphify        # もしくはリポジトリの手順に従う
# Node/uv版など配布形態は github.com/Graphify-Labs/graphify を参照
```

## 使い方

```bash
# カレントディレクトリ全体をグラフ化（graphify-out/ に出力）
graphify .

# 特定パス / GitHubリポジトリ
graphify ./services/api
graphify https://github.com/owner/repo --branch main

# 深い抽出（INFERREDエッジを豊富に）
graphify . --mode deep

# 変更分だけ再抽出（増分更新）
graphify . --update

# 照会（BFS=広い文脈 / DFS=特定経路を追う / 回答トークン上限）
graphify query "認証はどこで行われている?"
graphify query "決済フローのエラー処理" --dfs --budget 1500

# 2概念間の最短経路 / ノードの平易な説明
graphify path "AuthModule" "Database"
graphify explain "FeatureStore"

# エージェント連携（MCP stdio サーバ）/ 変更監視で自動再構築
graphify . --mcp
graphify . --watch
```

出力: インタラクティブHTML・GraphRAG向けJSON・平易な `GRAPH_REPORT.md`。

## ワークフロー

1. 大きめのリポジトリで作業を始める前に `graphify .`（または対象サブツリー）でグラフ化。
2. 以降の「どこで何をしているか」系の問いは、全読みせず `graphify query/path/explain` で解く。
3. コードを変えたら `--update` で増分更新。`--watch` を使えば自動。
4. グラフが示したファイル/関数だけを実際に開いて読む。

## 事業への適用
- **A 自社SaaS/アプリ**: 肥大化したリポジトリの機能追加前に全体構造を把握。
- **B データ分析/ML**: パイプライン・前処理・モデル定義の依存を可視化し、影響範囲を特定。

## 出典
- Graphify (Graphify-Labs) — Apache-2.0 / MIT. github.com/Graphify-Labs/graphify
