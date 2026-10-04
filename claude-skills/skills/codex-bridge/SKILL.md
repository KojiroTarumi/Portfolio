---
name: codex-bridge
description: >-
  実装計画やコードを OpenAI Codex (GPT) にセカンドオピニオンとしてレビュー/委譲する。
  重要な設計や難所で別モデルの視点が欲しいとき、「Codexにレビューさせて」「別モデルで検証」
  「Codexに任せて」と言われたときにトリガー。Codex CLI（ChatGPTサブスク）を使う。
  ※画像生成の Codex 利用は image-gen スキル側。
---

# Codex Bridge（Codex にレビュー/委譲）

出典: codex-plugin-cc (OpenAI) / Codex Dispatch。Claude の計画・コードを Codex (GPT) に渡し、
往復レビューや背景タスクの委譲を行う「多モデル」運用のためのブリッジ。

## 前提

```bash
npm i -g @openai/codex
codex login            # ChatGPT アカウント（APIキー不要）/ または OPENAI_API_KEY
```

公式プラグイン運用なら claude.ai で **codex-review** / **Codex Dispatch** を有効化し、
`/codex:review`（読み取りレビュー）、`/codex:adversarial-review`（挑戦的レビュー）、
`/codex:rescue` `/codex:transfer` `/codex:status` などのコマンドを使う（→ `docs/bridges.md`）。

## 使いどころ（`plan-first` と連動）
- **計画の壁打ち**: Architectural 経路で書いた仕様/計画を Codex にレビューさせ、
  抜け・リスクを洗い出してから実装承認に進む。
- **コードの第二の目**: 難所の実装や、セキュリティ/並行性が絡む箇所を別モデルで検証。
- **委譲**: 独立した明確なサブタスクを Codex に背景実行させ、結果を取り込む。

Codex の出力は「参考意見」。採否は `plan-first` の設計と本人の承認で決める。鵜呑みにしない。

## 事業への適用
- **A/B**: 重要アーキテクチャ・モデル設計で、Claude と Codex の二重チェックにより品質を上げる。

## 出典
- codex-plugin-cc (OpenAI) — Apache-2.0. github.com/openai/codex-plugin-cc
- Codex Dispatch（コミュニティ）
