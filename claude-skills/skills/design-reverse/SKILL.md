---
name: design-reverse
description: >-
  任意のサイト・GitHubリポジトリ・ローカルプロジェクトのデザインシステム（色・タイポ・
  余白・アニメ・コンポーネント・スクショ）を純静的解析でリバースエンジニアリングし、
  Claudeが読めるMarkdown/フォルダに落とす。「このサイトのデザインを真似たい」「◯◯風に」
  「デザインシステムを抽出」「参照サイトから作って」と言われたときにトリガー。抽出結果は
  web-design スキルの入力として使う。
---

# Design Reverse（SkillUI でデザインシステム抽出）

出典: SkillUI (amaancoderx/npxskillui) を事業向けに再構成。AIもAPIキーも使わない純静的解析で、
参照サイトの「色・書体・余白・レイアウト・コンポーネント・モーション」を抽出し、md化する。

## 前提

```bash
npm install -g skillui          # Node.js 18+
# ultra モード（Playwrightでフル視覚抽出）を使うなら:
npm install playwright && npx playwright install chromium
```

## 使い方

```bash
# URL から抽出
skillui --url https://example.com

# GitHub リポジトリから
skillui --repo https://github.com/owner/repo

# ローカルのフロントエンドから
skillui --dir ./my-frontend

# フル視覚抽出（スクショ・モーション込み）
skillui --url https://example.com --ultra
```

出力フォルダには `SKILL.md`（マスター参照）、`CLAUDE.md`（Claude Code が自動で読む）、
`DESIGN.md`（色/タイポ/余白）、animations/ layout/ components/ interactions/ と
スクショ付きの visual guide が入る。

## ワークフロー

1. 参照サイト/リポジトリを1つ選び、`skillui` で抽出。
2. 出力の `DESIGN.md` を読み、パレット・書体・スケールを把握。
3. **`web-design` スキルに切り替え**、抽出したトークンを Design Read の入力にして実装。
   そのまま丸写しにしない——抽出は出発点、`web-design` のアンチスロップ規律で自分の文脈に寄せる。

## 注意・権限

- 抽出は静的解析で対象サイトに過負荷をかけないが、**公開情報のみ**を対象にする。
- 他者サイトのデザインを参照するのは着想までとし、商標・独自表現の丸写しや誤認を招く複製はしない。
- 自社プロジェクトの一貫性チェック（既存プロダクトのトークン抽出）にも有効。

## 事業への適用
- **C 集客/受託**: クライアント競合や参照URLから素早くトーンを掴む。
- **A 自社プロダクト**: 既存画面からデザイントークンを吸い出し、新機能の一貫性を担保。

## 出典
- SkillUI (amaancoderx) — MIT License. github.com/amaancoderx/npxskillui
