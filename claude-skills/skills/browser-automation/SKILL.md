---
name: browser-automation
description: >-
  ブラウザ操作の自動化・Webページのテスト・Playwrightテストの作成を、トークン効率の良い
  playwright-cli で行う。ページを開く/遷移/クリック/入力/スクショ、E2Eテストの記録と実行、
  実装したUIを実ブラウザで動作確認するときにトリガー。大きなツールスキーマを読み込むMCPより、
  短いCLIコマンドでアクセシビリティスナップショットを見ながら操作する方が低トークン。
allowed-tools: Bash(playwright-cli:*) Bash(npx playwright:*) Bash(npx --no-install playwright:*)
---

# Browser Automation（Playwright CLI）

出典: Playwright CLI (Microsoft)。ブラウザのツールスキーマをコンテキストに読み込む代わりに、
短いシェルコマンドで操作し、各コマンドが差分スナップショット（要素ref付き）を返す。

> この環境には Chromium がプリインストール済み（`PLAYWRIGHT_BROWSERS_PATH=/opt/pw-browsers`）。
> `playwright install` は実行しない。

## 前提

```bash
npm i -g @playwright/cli      # または npx で playwright-cli
playwright-cli --version
```

## クイックスタート

```bash
playwright-cli open https://example.com/   # ブラウザを開いて遷移
playwright-cli goto https://playwright.dev # 遷移（スナップショットが返る）
playwright-cli click e15                   # スナップショットの ref で操作
playwright-cli fill e5 "user@example.com" --submit
playwright-cli type "search query"
playwright-cli press Enter
playwright-cli screenshot                  # スクショ（通常はスナップショットで足りる）
playwright-cli close
```

操作のたびに新しいスナップショットが出るので、「何が変わったか」を見ながら次の `ref` を選ぶ。

## ワークフロー（UI検証 / E2E）

1. `web-design` で実装したページをローカルで起動（この環境の `run` スキルも活用可）。
2. `playwright-cli open <localhost url>` で開き、主要導線（フォーム送信・遷移・エラー表示）を操作して確認。
3. 不具合はスナップショットとスクショで特定し、実装へフィードバック。
4. 回帰防止が要るフローは Playwright テストに落とす（`npx playwright` でテスト実行）。

## 事業への適用
- **A 自社SaaS/アプリ**: リリース前のクリティカルパス（サインアップ・課金・主要操作）のE2E確認。
- **C 受託/集客**: 納品前のLP/フォームの動作・リンク切れ・表示崩れチェック。

## 出典
- Playwright CLI (Microsoft) — Apache-2.0. github.com/microsoft/playwright-cli
