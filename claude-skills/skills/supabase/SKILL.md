---
name: supabase
description: >-
  アプリ用のDB・認証・ストレージを Supabase で設計・構築・運用する。Postgresのスキーマ設計、
  RLS（行レベルセキュリティ）ポリシー、Auth フロー、Storage、マイグレーション、
  パフォーマンス最適化。「DBを作って」「Supabaseで」「認証を実装」「RLSを設定」
  「テーブル設計」と言われたときにトリガー。公式 Supabase プラグイン（MCP）を併用する。
---

# Supabase（公式プラグイン連携ブリッジ）

出典: 公式 Supabase プラグイン（supabase-community）。重い実体はvendorせず、
**公式プラグイン＋MCPを有効化**し、事業のやり方に沿った使い方をここで定める。

## 有効化（初回のみ）

claude.ai のプラグインディレクトリで **Supabase** を有効化すると、
`supabase` / `supabase-postgres-best-practices` スキルと `supabase` MCP サーバが入る。
→ 手順は `docs/bridges.md`。

## 使う前の原則（`plan-first` と連動）

スキーマ変更・RLS・認証は **Architectural 経路**。いきなり `CREATE TABLE` しない:
1. エンティティと関係、アクセス主体（誰がどの行を読めるか）を書面化しユーザー承認。
2. マイグレーションで変更（手でスキーマをいじらない）。
3. **RLS を既定で有効化**し、テナント/所有者でフィルタするポリシーを明示。
4. `security-audit` で認可を検証してからリリース。

## ベストプラクティス要点
- すべての公開テーブルに RLS。`auth.uid()` ベースのポリシーで所有者限定。
- 秘密鍵（service_role key）はサーバ側のみ。クライアントに出さない・コミットしない。
- マイグレーションはバージョン管理。破壊的変更は計画承認必須。
- N+1 を避け、必要な列だけ select（`lean-code` と整合）。

## 事業への適用
- **A 自社SaaS/アプリ**: マルチテナントの土台。RLS＋Auth で行単位の分離を担保。
- **B データ分析**: 収集データの保管先、分析結果の配信APIのバックエンド。

## 出典
- Supabase 公式プラグイン — github.com/supabase-community/supabase-plugin
  （正規の有効化は claude.ai プラグインディレクトリ経由を推奨）
