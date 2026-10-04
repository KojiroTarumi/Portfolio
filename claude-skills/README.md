# claude-skills — Kojiro Tarumi 事業特化スキルセット

公式／GitHub に公開されている Claude Code 向けスキル・プラグイン18件を調査し、
**自分の事業のやり方に合わせて再構成**したローカルスキル集です。
重複する役割は統合し、既存の同期スキルと名前が衝突しないように命名しています。

## 事業の3本柱（スキルはこれに合わせて最適化）

- **A. 自社 SaaS / アプリ開発・運営** — 計画→実装→検証のプロセス、DB、ブラウザE2E、セキュリティ。
- **B. データ分析・AI/ML 提供** — 大規模コードベース把握、最新ライブラリ参照、再現性。
- **C. 資料・画像・契約まわりの効率化** — 画像生成、ファイルのmd化、デザイン、法務。

## 収録スキル一覧

| スキル | 由来（出典） | 事業 | 役割 |
|---|---|---|---|
| `plan-first` ★ | Superpowers (obra) | A/B/C | いきなり着手せず、意図確認→設計→計画→実装のゲートを敷く |
| `lean-code` | Ponytail | A/B | 最小・最短で動くコードに寄せ、トークンと複雑性を削る |
| `codebase-graph` | Graphify | A/B | 大規模リポジトリをグラフ化し、読み直しのトークンを抑える |
| `docs-lookup` | Context7 | A/B | ライブラリ最新版のAPIドキュメントを取得 |
| `browser-automation` | Playwright CLI | A | トークン効率の良いブラウザ自動操作とE2E |
| `file-to-markdown` | MarkItDown | C/B | pdf/word/excel/ppt を一括md化して低トークンで読む |
| `image-gen` | codex-image 系 ×3 統合 | C | GPT Image を Codex CLI 経由で生成・編集（APIキー不要） |
| `web-design` | frontend-design + taste-skill + ui-ux-pro-max 統合 | A/C | AIっぽくない、ブリーフに即したUIを作る |
| `design-reverse` | SkillUI | A/C | 任意サイトのデザインシステムをリバエンしてmd化 |
| `security-audit` | security-audit-skill + Strix 統合 | A | 証拠ベース監査（既定）＋能動ペンテスト（権限ゲート付き） |
| `supabase` (bridge) | 公式 Supabase プラグイン | A/B | アプリ用DB・認証・ストレージ構築 |
| `canva` (bridge) | 公式 Canva プラグイン | C | Canva で画像・デザイン生成 |
| `legal` (bridge) | 公式 Legal プラグイン | C | 契約レビュー・NDAトリアージ・コンプラ |
| `codex-bridge` (bridge) | codex-plugin-cc / Codex Dispatch | A/B | 計画・コードを Codex にセカンドオピニオン依頼 |

★ = ユーザー最重要指定（「いきなり作業せずに計画を考えさせる」）。

`skill-creator`（スキルを作るスキル）はアカウントに同期済みのため本セットには含めていません。
新規スキル作成時はそちらを使ってください。

## インストール

```bash
cd claude-skills
./install.sh            # ~/.claude/skills/ にコピー
./install.sh --link     # コピーではなくシンボリックリンク（開発時に便利）
./install.sh --dry-run  # 何が起きるか確認だけ
```

インストール後、`bridge` スキルの冒頭に書かれた公式プラグインの有効化と
各CLI（`codex` / `ctx7` / `playwright-cli` / `skillui` / `markitdown` / `strix`）の
セットアップを済ませると、すべてのスキルが機能します（→ `docs/bridges.md`）。

## ドキュメント

- `docs/integration-report.md` — 既存スキルとの整合性チェック結果と統合方針。
- `docs/sources.md` — 全スキルの出典リポジトリとライセンス（再構成物の帰属）。
- `docs/bridges.md` — 外部プラグイン／CLI の有効化手順と事業用プレイブック。

## 再構成の考え方

各 `SKILL.md` はオリジナルを丸写しせず、**判断基準・ワークフロー・トリガー語**を
自分の事業に合わせて書き直しています。末尾の「出典」節で元リポジトリとライセンスを明示しています。
