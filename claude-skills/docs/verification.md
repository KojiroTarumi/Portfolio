# 疎通確認レポート（このクラウドセッションで実測）

実施日: 2026-10-04 / 環境: Claude Code クラウドコンテナ
（Node 22.22 / Python 3.11（3.12 も `/usr/bin/python3.12` に存在）/ Docker 29.6 / Chromium プリインストール）

ネットワークはエージェントプロキシ経由。`npmjs.org` / `pypi.org` は許可リスト内のため導入は概ね成功。
一部の外部CDN・サービスはプロキシで制限される。

## 結果サマリ

| ツール | 導入 | 実動作 | 判定 | 備考 |
|---|---|---|---|---|
| **markitdown** | `pip install 'markitdown[all]'` → 0.1.8 | xlsx→md 変換成功（日本語保持・表構造保持） | ✅ 完全動作 | `file-to-markdown` スキルそのまま利用可 |
| **codex** | `npm i -g @openai/codex` → 0.160.0 | `codex login status` = Not logged in | ✅ 導入OK（要ログイン） | 画像生成/レビューは `codex login`（ChatGPT）後に機能。APIキー不要 |
| **skillui** | `npm i -g skillui` → 1.3.4 | ローカルHTMLから `site-design/`（CLAUDE.md+SKILL.md）生成成功 | ✅ 完全動作 | `design-reverse` スキルそのまま利用可。URL対象はネット許可が必要 |
| **graphify** | `pip install graphifyy` → 0.9.75 | ローカル2ファイルをグラフ化（4 nodes/5 edges/1 community, graph.json出力）成功 | ✅ 完全動作 | **PyPI名は `graphifyy`（yが2つ）**。SKILL修正済み |
| **strix** | `python3.12 -m venv` + `pip install strix-agent` → 1.6.2 | `strix --help` 正常（全ペンテストオプション表示） | ✅ 導入OK（要Docker+LLMキー+対象） | **Python>=3.12 必須**。3.11環境は3.12 venvへ隔離。実スキャンはDocker稼働とLLMキーと所有対象が前提 |
| **ctx7 (Context7)** | `npm i -g ctx7@latest` → 0.5.12 | `ctx7 library` = HTTP 403 | ⚠️ 要ログイン | **`ctx7 login` が必須**（未認証で403）。SKILL修正済み。MCP版の利用も可 |
| **playwright-cli** | `npm i -g @playwright/cli` → 0.1.22 | `open` が同梱要求ブラウザ(chromium-1247)をDL不可で失敗 | ⚠️ 代替で動作 | この環境ではCDN制限で固定ブラウザDL不可。**プリインストール Chromium(1194)＋`playwright-core@1.56` 直叩きで起動・操作・入力を確認済み（✅）**。SKILLにフォールバック追記 |

## 判定の意味

- **✅ 完全動作**: この環境で実際に機能まで確認。
- **✅ 導入OK（要〜）**: CLIは入りバージョン応答するが、本機能は資格情報/外部条件が必要（想定どおり）。
- **⚠️**: そのままでは制約あり。回避策を各SKILLに反映済み。

## スキルへの反映（この確認で修正した点）

1. `codebase-graph`: 導入コマンドを `pip install graphify` → **`graphifyy`** に修正。
2. `security-audit`: strix の **Python 3.12 必須** と venv/pipx 隔離手順を追記。
3. `docs-lookup`: **`ctx7 login` 必須**（403回避）を追記。
4. `browser-automation`: この環境向けの **プリインストールChromium直叩きフォールバック**を追記。

## 未確認（外部条件が必要なため本セッションでは実行せず）

- codex の実画像生成（`codex login` 必要）
- ctx7 の実ドキュメント取得（`ctx7 login` 必要）
- strix の実ペンテスト（Docker稼働 + LLMキー + 所有対象。合意どおり自社所有対象のみ対象）
- 公式プラグイン（Supabase/Canva/Legal）のMCP接続（claude.aiでの有効化が前提）

これらはローカル/本番の実運用環境で、各SKILL・`bridges.md` の手順に沿って有効化すれば動作します。
