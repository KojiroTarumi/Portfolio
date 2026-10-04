# 出典とライセンス（再構成物の帰属）

本セットの各スキルは、以下の公開リポジトリを調査・参照して**事業向けに書き直した**ものです。
原文の丸写しではありませんが、設計思想・用語・手順を引き継いでいます。元リポジトリの
ライセンス（MIT / Apache-2.0）に従い、ここに帰属を明記します。

| 本スキル | 由来プロジェクト | リポジトリ | ライセンス |
|---|---|---|---|
| `plan-first` | Superpowers | github.com/obra/superpowers | MIT |
| `lean-code` | Ponytail | github.com/DietrichGebert/ponytail | MIT |
| `codebase-graph` | Graphify | github.com/Graphify-Labs/graphify | Apache-2.0 / MIT |
| `docs-lookup` | Context7 | github.com/upstash/context7 | MIT |
| `browser-automation` | Playwright CLI | github.com/microsoft/playwright-cli | Apache-2.0 |
| `file-to-markdown` | MarkItDown | github.com/microsoft/markitdown | MIT |
| `image-gen` | codex-image 系 | github.com/mishagavura/claude-code-image-generation, github.com/wjb127/codex-image, openai/codex-plugin-cc | MIT / Apache-2.0 |
| `web-design` | frontend-design / taste-skill / ui-ux-pro-max | github.com/anthropics/skills, github.com/Leonxlnx/taste-skill, github.com/nextlevelbuilder/ui-ux-pro-max-skill | Apache-2.0 / MIT |
| `design-reverse` | SkillUI | github.com/amaancoderx/npxskillui | MIT |
| `security-audit` | security-audit-skill / Strix | github.com/bartek-filipiuk/security-audit-skill, github.com/usestrix/strix | MIT / Apache-2.0 |
| `supabase` | 公式 Supabase プラグイン | github.com/supabase-community/supabase-plugin | — (公式ディレクトリ) |
| `canva` | 公式 Canva プラグイン | github.com/canva-sdks/canva-skills | Apache-2.0 |
| `legal` | 公式 Legal プラグイン | github.com/anthropics/knowledge-work-plugins (legal) | Apache-2.0 |
| `codex-bridge` | codex-plugin-cc / Codex Dispatch | github.com/openai/codex-plugin-cc | Apache-2.0 |

## 注意

- これらは第三者の商標・プロジェクトです。本セットは互換スキルの再構成であり、各プロジェクトの公式配布物ではありません。
- 公式プラグイン（Supabase/Canva/Legal/Context7/Playwright）は claude.ai のプラグインディレクトリから
  正規に有効化するのが最も安全です（`docs/bridges.md` 参照）。
- 元のライセンス全文が必要な場合は各リポジトリの LICENSE を参照してください。
