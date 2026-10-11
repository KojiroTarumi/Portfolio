# Mac の Claude Code に貼る指示文

**街バルの作業をしているセッション**（デスクトップアプリの Code タブ）に、下の枠内をそのまま貼る。
そのセッション自身の会話を NAS へ引き継ぐので、別のセッションではなく街バルのセッションに貼ること。

---

```text
10/14 から 1 週間ほど入院する。その間、Mac mini の電源を切ったまま iPad から街バルの改修を続けたいので、
この会話と作業フォルダを NAS（DXP2800）の Docker 上の Claude Code へ移し、Remote Control で iPad から使えるようにしてほしい。
移行キットは GitHub の KojiroTarumi/Portfolio、ブランチ claude/stoic-hawking-qunhep の nas-claude-code/ にある。

  git clone --depth 1 -b claude/stoic-hawking-qunhep https://github.com/KojiroTarumi/Portfolio /tmp/nas-kit

まず /tmp/nas-kit/nas-claude-code/README.md を読み、その手順で進めて。補足:

1. コピーの前に、このプロジェクトの現状（完了したこと・未完了タスク・次の一手・判断済みの方針・保留中の論点・
   動かし方）をプロジェクトのメモリか CLAUDE.md に書き出しておく。会話を続きから開けなかった場合の保険。
2. 引き継ぐ会話ファイルは「この会話」の .jsonl。~/.claude/projects/ の中で一番新しいものが自分のはずだが、
   中身の最近の発言で照合して確定させる。作業フォルダ（cwd）が worktree かどうかも確認する。
3. プロジェクトが要求する Node のバージョン（.nvmrc / package.json の engines）を確認し、
   compose.yaml の image（node:22-bookworm）を合わせる。Linux で問題になる依存（Prisma のエンジン、sharp など）があれば教えて。
4. NAS の UGOS には癖がある（.env が読まれない、パスは /volume1/... の絶対パス 等）。
   ~/claude_pj/nas-setup/ の手順書とメモリに記録してあるので、それに沿って compose を登録する手順を案内して。
   UGOS の画面操作は私がやるので、何をどこに貼るか具体的に指示して。
5. RC_NAME="街バル (NAS)" で migrate-to-nas.sh を実行する。最後に出る .env の変数名一覧を見せて、
   AWS などの強い権限の鍵が含まれていれば NAS 側のコピーから外す相談をして。値は表示しないこと。~/.aws はコピーしない。
6. コンテナ起動後の初回ログイン・ワークスペースの信頼・Remote Control の許可、npm ci とビルド確認を案内して。
7. README の「4. iPad で確認」のチェックを私と一緒に全部通す。コンテナ再起動から同じ会話に戻れるところまで確認する。
8. Duplicati のジョブ（claude-gdrive）で node_modules と .next を除外する設定を案内して。
9. 最後に、この構成と入院中の復旧手順を ~/claude_pj/nas-setup/ の手順書とメモリに追記して。
   移行が済んだら、Mac 側では街バルを触らないこと（NAS 側が正）も記録しておいて。
```
