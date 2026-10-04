---
name: legal
description: >-
  契約レビュー、NDAトリアージ、コンプライアンス確認、法務ブリーフ作成、ベンダー審査、
  署名依頼などの法務ワークフローを支援する。「この契約を見て」「NDAを確認」「リーガルチェック」
  「コンプラ確認」「契約のリスク評価」と言われたときにトリガー。公式 Legal プラグインの
  スキル群を使い、受領文書は file-to-markdown で取り込んでからレビューする。
---

# Legal（公式プラグイン連携ブリッジ）

出典: 公式 Legal プラグイン（Anthropic / knowledge-work-plugins）。claude.ai で **Legal** を
有効化すると `review-contract` / `triage-nda` / `compliance-check` / `legal-risk-assessment` /
`brief` / `vendor-check` / `signature-request` / `meeting-briefing` / `legal-response` スキルと
関連 MCP（Gmail, Google Calendar, DocuSign, Box, Slack 等）が使える。→ `docs/bridges.md`。

## ワークフロー
1. 受領した契約書/NDA/資料（PDF/Word）は **`file-to-markdown`** で md 化してから読む（低トークン・構造保持）。
2. 文書種別に応じて: NDAは `triage-nda`、一般契約は `review-contract`、社内規程適合は `compliance-check`。
3. リスクは `legal-risk-assessment` で整理。要点は `brief` で意思決定者向けに要約。
4. 署名が必要なら `signature-request`（DocuSign 等）。

## 重要な免責
- 本スキルは法務**実務の効率化支援**であり、弁護士による法的助言の代替ではない。
- 重要な契約・紛争・規制判断は、最終的に有資格の専門家の確認を得る。
- 機密文書・個人情報の取り扱いは最小権限で。外部サービスへ不要に送らない。

## 事業への適用
- **C 受託/取引**: 業務委託契約・NDA・利用規約の一次レビューと論点抽出を高速化。

## 出典
- Legal 公式プラグイン — Apache-2.0. github.com/anthropics/knowledge-work-plugins (legal)
