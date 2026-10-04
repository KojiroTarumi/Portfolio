# 整合性チェック & 統合方針レポート

調査対象18件を、アカウントに**既に同期済みのスキル**と突き合わせ、
衝突・重複・役割分担を整理した結果です。

## 1. 既存（同期済み）スキルの棚卸し

`~/.claude/skills/` と claude.ai アカウントで有効なスキル：

- ドキュメント生成系: `docs`, `docx`, `pdf`, `pptx`, `xlsx`, `google-workspace`
- メタ: `skill-creator`, `import-memory`, `morning`
- Artifact系（ホスト提供）: `artifact-design`, `artifact-capabilities`, `dataviz` ほか
- フック: `session-start-hook`

→ **名前の再利用を避ける**こと、`pdf`/`xlsx`/`pptx`/`docx` と役割が被らないことが整合性の肝。

## 2. 衝突回避（命名）

| 新スキル | 衝突の懸念 | 回避策 |
|---|---|---|
| `file-to-markdown` | `pdf`/`xlsx`/`docx`/`pptx` と入力が重なる | **用途を限定**：生成・編集はしない。「大量・多種のファイルを低トークンで"読む"ための一括md化」だけを担当し、編集が要るなら既存の `pdf`/`docx`/`xlsx`/`pptx` に委譲するようSKILL内で明記 |
| `web-design` | ホストの `artifact-design` | artifact は claude.ai のページ生成専用。こちらは**実コードのUI実装**（React/HTML/CSS）に限定し、SKILL内で住み分けを明記 |
| `image-gen` | なし（新規） | — |
| `skill-creator` | 同期済みと同名 | **収録しない**（既存を使う） |
| `plan-first` | Superpowers の `brainstorming` 等 | プラグイン未導入のため衝突せず。導入済みなら `plan-first` が上位ゲート、個別スキルが下位実装という関係をSKILL内で明記 |

## 3. 重複の統合

| 統合後 | 統合元 | 方針 |
|---|---|---|
| `image-gen` | Codex Plugin CC（画像）, Codex Image in CC, 他 codex-image 系 | 実体は同じ「Codex CLI 経由 GPT Image」。**1本に統合**し、生成/編集/透過/参照画像/複数バリアントを1スキルで。Codex Plugin CC 自体は"コードレビュー委譲"が主目的なので `codex-bridge` 側に分離 |
| `web-design` | frontend-design, taste-skill, ui-ux-pro-max-skill | 3つとも「AIっぽくないUI」。**1本のルーター**に統合：①ブリーフ読解→②アンチスロップ規律（frontend-design/taste）→③スタイル/トークンDB参照（ui-ux-pro-max）。元の巨大アセットDBは `docs/bridges.md` から任意導入 |
| `security-audit` | Security Audit skill, Strix | **1本に2モード**：既定は読み取り専用の証拠ベース監査、`--active` で Strix による能動的ペンテスト。能動テストは**対象所有権の確認ゲート**を必須化 |
| （トークン削減2系統は役割が違うため分離維持） | Ponytail, Graphify | Ponytail=**書くコードを減らす**、Graphify=**読むコードのトークンを減らす**。目的が直交するので `lean-code` と `codebase-graph` に**別建て**。ただし両者を併用する手順をREADMEに記載 |

## 4. ローカルスキル化 vs ブリッジ化

重い実体（MCPサーバ常駐・外部CLI・Docker・クラウドAPI）が必要なものは、
コードをvendorせず**公式を有効化する薄いブリッジ**にした。

- **ローカル完結（Markdownのみで機能）**: `plan-first`, `lean-code`, `web-design`, `security-audit`（監査モード）
- **外部CLIが要る（手順はSKILL/bridgesに記載）**: `image-gen`(codex), `docs-lookup`(ctx7), `browser-automation`(playwright-cli), `file-to-markdown`(markitdown), `codebase-graph`(graphify), `design-reverse`(skillui), `security-audit --active`(strix)
- **公式プラグイン/MCPを有効化するブリッジ**: `supabase`, `canva`, `legal`, `codex-bridge`

## 5. 優先順位（スキルが複数該当したときの順序）

1. `plan-first`（★）— 創作・実装の前に必ず。意図確認と設計ゲート。
2. ドメイン実装スキル（`web-design`, `supabase`, `image-gen` …）
3. 効率化スキル（`lean-code`, `codebase-graph`, `docs-lookup`, `file-to-markdown`）
4. 検証（`browser-automation`, `security-audit`）

この順序は `plan-first/SKILL.md` にも明記してあり、Superpowers 導入時の
「process skills first」方針と一致させてある。

## 6. 安全・権限方針（ユーザー合意事項）

- 能動的攻撃テスト（Strix）／セキュリティ監査は **自社が所有・管理する環境（本番含む）を対象に実施可**。
- 第三者のURL・インフラ、所有が確認できない対象には実行しない（SKILL内ゲートで強制）。
- APIキー・資格情報はハードコード／コミット禁止（全スキル共通ルール）。
