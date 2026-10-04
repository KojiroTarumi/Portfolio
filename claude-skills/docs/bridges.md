# 外部プラグイン / CLI の有効化手順

本セットのうち、外部の MCP サーバや CLI・Docker・クラウドが必要なものは、
重い実体をこのリポジトリに取り込まず、公式を有効化して使う方針です。以下に手順をまとめます。

## A. claude.ai 公式プラグイン（MCP）

claude.ai のプラグインディレクトリ（または Claude Code の `/plugin`）から有効化できます。
正規ディレクトリ経由が最も安全です。

| プラグイン | 提供元 | 本セットの対応スキル |
|---|---|---|
| Supabase | supabase-community（partner） | `supabase` |
| Canva | canva-sdks（partner） | `canva` |
| Legal | Anthropic | `legal` |
| context7 | Upstash（partner） | `docs-lookup`（CLIでも可） |
| playwright | Microsoft（partner） | `browser-automation`（CLIでも可） |
| codex-review / Codex Dispatch | コミュニティ | `codex-bridge` |

有効化後、各プラグインの MCP ツールがセッションに現れます。初回は認証（OAuth 等）を求められることがあります。

> この環境（クラウドセッション）でMCP接続やコネクタが必要な場合は、
> `read_documentation`（connectors.add）に設定手順があります。

## B. CLI / ランタイムの用意

対応スキルを使うには、それぞれのCLIをインストールします。

```bash
# image-gen / codex-bridge
npm i -g @openai/codex && codex login            # ChatGPT サブスク（APIキー不要）

# docs-lookup
npm i -g ctx7@latest

# browser-automation（この環境はChromiumプリインストール済み。playwright install は不要）
npm i -g @playwright/cli

# design-reverse
npm i -g skillui
# ultra モードを使うなら: npm i playwright && npx playwright install chromium

# file-to-markdown
pip install 'markitdown[all]'

# codebase-graph
pip install graphify        # 配布形態はリポジトリ参照: github.com/Graphify-Labs/graphify

# security-audit --active（Strix）
#   Docker 稼働が前提。OSS CLI:
curl -sSL https://strix.ai/install | bash        # or: pipx install strix-agent
export STRIX_LLM="anthropic/claude-opus-4-8"
export LLM_API_KEY="<provider api key>"           # コミット禁止
```

## C. 任意: ui-ux-pro-max の大規模スタイルDB

`web-design` を大規模制作で使うなら、スタイル/カラー/フォントのDBを導入できます。
導入は任意で、`web-design` 本体はDBなしでも機能します。

```bash
# 例（リポジトリの手順に従う）: github.com/nextlevelbuilder/ui-ux-pro-max-skill
claude install nextlevelbuilder/ui-ux-pro-max-skill
```

## D. 秘密情報の扱い（全スキル共通）

- APIキー・service_role キー・LLMキーは**ハードコードもコミットもしない**。
- 環境変数かこの環境のシークレット管理（`read_documentation` の environment.secrets 参照）で渡す。
- 外部サービス（Codex/Strix cloud/各MCP）へ送るデータは、機密を含むなら送信前に内容を確認。

## E. 安全・権限（合意事項の再掲）

- `security-audit --active`（Strix）と本番対象の監査は、**自社が所有・管理する環境のみ**。
- 第三者URL・所有未確認の対象には実行しない（スキル内ゲートで強制）。
