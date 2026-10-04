---
name: canva
description: >-
  Canva でデザイン・画像を作成/編集/リサイズ/ブランドチェックする。SNS投稿・バナー・
  プレゼン・ブランド素材を Canva 上で量産したいとき、「Canvaで作って」「このデザインを
  SNS用にリサイズ」「ブランドガイドに沿っているか確認」と言われたときにトリガー。
  公式 Canva プラグイン（MCP）を併用する。
---

# Canva（公式プラグイン連携ブリッジ）

出典: 公式 Canva プラグイン（canva-sdks）。claude.ai で **Canva** プラグインを有効化すると、
`canva-edit-design` / `canva-resize-for-social-media` / `canva-brand-check` /
`canva-bulk-create` / `canva-design-feedback` / `canva-implement-feedback` スキルと
`canva` MCP サーバが使える。→ 有効化手順は `docs/bridges.md`。

## 使い分け（他の画像スキルとの整合性）
- **ゼロから自由な画像・写真・モック** → `image-gen`（GPT Image）。
- **実コードのUI** → `web-design`。
- **Canvaのテンプレ資産・ブランドキット・SNS定型・一括差し込み** → このスキル。

## ワークフロー
1. 目的物（投稿/バナー/スライド）とブランド（色・ロゴ・書体）を確認。
2. Canva MCP でデザインを作成/編集。複数サイズが要るなら resize-for-social-media。
3. 量産は bulk-create（データ差し込み）。
4. 納品前に brand-check でガイドライン適合を確認。

## 事業への適用
- **C 集客・資料**: SNS運用の定型物、クライアント向けバナー/スライドをブランド統一で量産。

## 出典
- Canva 公式プラグイン — Apache-2.0. github.com/canva-sdks/canva-skills
