---
name: security-audit
description: >-
  コードベースやアプリケーションのセキュリティを評価する。既定は読み取り専用の証拠ベース監査
  （脆弱性診断・認証実装レビュー・一部スコープ監査）。`--active` 指定時は Strix による能動的な
  ペネトレーションテスト（実際に攻撃を試み、PoCで実証）を行う。「セキュリティ監査」「脆弱性を探して」
  「ペンテスト」「認証まわりを見て」「攻撃してみて」と言われたときにトリガー。能動テストは対象の
  所有権確認ゲートを必須とする。
---

# Security Audit（証拠ベース監査 ＋ Strix 能動ペンテスト統合）

出典統合: security-audit-skill (bartek-filipiuk) ＝読み取り監査、Strix (usestrix) ＝能動ペンテスト。
2つを **1スキル・2モード** に再構成。

## モード選択

- **既定（監査モード）**: 読み取り専用。コードを読み、データフローと認可モデルを推論し、
  **file:line の証拠がある指摘だけ**を出す。コードは一切変更しない。
- **`--active`（Strix ペンテストモード）**: サンドボックスで実際に攻撃を試み、PoC で実証された
  脆弱性だけを報告する。下の**所有権ゲート**を必ず通す。

## 🔒 対象所有権ゲート（`--active` と本番対象で必須）

能動テスト、または本番環境を対象にする前に、次を確認する:

1. 対象（URL / ドメイン / IP / リポジトリ）を **ユーザー自身が所有・管理**しているか。
2. 第三者のインフラ・所有が確認できない対象には**実行しない**。
3. 本番を対象にする場合、毎回その対象の所有を明示確認してから進む。

> 合意済み方針: 自社が所有・管理する環境（**本番含む**）は能動テスト可。
> localhost / ステージングは基本的に許可。所有が曖昧ならユーザーに確認。

資格情報・APIキーはハードコード／コミットしない（全モード共通）。

---

## 監査モード（既定・読み取り専用）

証拠ベース・計測駆動・スタック非依存。Recon → 並列監査 → 検証 → テスト品質 → レポート。

### ハードルール
1. **推測脆弱性を出さない。** file:line を指せないなら指摘にしない。
2. **深刻度を盛らない。** 具体的影響がなければ最大でも LOW。
3. **全指摘に必須**: ファイルパス・行番号・コードスニペット・Impact（誰が何を不正にできるか）。

### スコープ指定
- 全体監査（引数なし）、または `--scope auth,payments,webhooks,admin,files,api,jobs` など領域指定。
- `--scope top15` で最もリスクの高い N 箇所だけの素早い監査。
- スコープ監査は必ずレポートに「部分監査（対象: …）」と明記し、全体監査と偽らない。

---

## 能動モード（`--active`／Strix）

Strix は自律エージェントが対象を動的に攻撃し、**実証できた脆弱性のみ**報告する
（OWASP Top 10 ＋ インジェクション・XSS・SSRF・認可/アクセス制御欠陥・IDOR・ビジネスロジック）。

### 前提（OSS CLI 自己ホスト）
```bash
docker info                                   # Docker 稼働確認（初回はサンドボックスimageを取得）
curl -sSL https://strix.ai/install | bash     # or: pipx install strix-agent
strix --version
export STRIX_LLM="anthropic/claude-opus-4-8"   # 任意の LiteLLM モデルID
export LLM_API_KEY="<provider api key>"        # 未設定ならユーザーに依頼。コミット禁止
```

### 実行
```bash
# ローカルの作業ツリー（クリーンなチェックアウトで）
strix -n -t ./ --scan-mode standard --max-budget 15

# 稼働中インスタンスも渡すと実挙動で実証でき、精度が上がる
strix -n -t ./ -t http://host.docker.internal:3000 --max-budget 20

# 変更分だけ（大規模リポジトリの全体走査は無駄）
strix -n -t ./ --scope-mode diff --diff-base origin/main --max-budget 10

# スコープと前提を伝える（テナンシ・信頼境界・攻撃者制御入力は推論しにくい）
strix -n -t ./services/api --max-budget 15 \
  --instruction "src/auth の認可層と src/routes/admin 配下の全ルートに集中。マルチテナント: テナントIDはJWT由来。object id だけでフィルタしテナントでフィルタしないクエリを指摘。"
```

### 結果の読み方
`strix_runs/<run>/` の `penetration_test_report.md`（まずここ）、`vulnerabilities/*.md`（PoC＋修正付き）、
`vulnerabilities.json`/`.csv`、`findings.sarif`（GitHub code scanning へアップロード可）、`run.json`。

報告前に各 finding を開き、**PoC が実際に影響を示しているか**確認。file:line を併記して修正を自明にする。
終了コード 0 は「分析範囲で実証できる脆弱性がなかった」であって「安全」ではない。
`run.json` の status と `--max-budget` に対するコストを確認し、未診断パスがあれば明記する。

## 修正まで行う場合
監査/ペンテストで出た指摘は、`plan-first` で影響範囲を確認 → `lean-code` で最小修正 →
再監査（`--verify-fixes` 相当の再チェック）で検証、の順。テストを無効化して「緑」にしない。

## 事業への適用
- **A 自社SaaS/アプリ**: リリース前に監査モード、重要リリースや定期診断で `--active`。
- CI連携（diff スコープ・PRコメント・SARIFアップロード）で継続的にゲートできる。

## 出典
- security-audit-skill (bartek-filipiuk) — MIT. github.com/bartek-filipiuk/security-audit-skill
- Strix (usestrix) — Apache-2.0. github.com/usestrix/strix
