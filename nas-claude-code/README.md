# NAS で Claude Code を常駐させ、iPad から作業する

Mac mini の電源を切っていても、iPad の Claude アプリから街バルの改修を続けられるようにするキット。
DXP2800 の Docker で Claude Code を動かし、Remote Control で iPad とつなぐ。

```
iPad の Claude アプリ（Code タブ）
        │  Remote Control（NAS から外向きの HTTPS のみ。ポート開放は不要）
        ▼
DXP2800 / Docker コンテナ claude-code（node:22-bookworm）
  tmux の中で claude --continue --remote-control を常駐（落ちたら 15 秒後に自動再起動）
  HOME = /Users/tarumi  ←  /volume1/claude/claude-code/home
    ├─ claude_pj/<街バル>/              作業フォルダ（Mac と同じパス）
    ├─ .claude/projects/<…>/*.jsonl     会話履歴とプロジェクトのメモリ
    └─ .local/bin/claude                Claude Code（自動更新される）
```

会話履歴は「作業フォルダの絶対パス」ごとに保存される。コンテナの HOME を Mac と同じ `/Users/tarumi` にしておくことで、Mac から持ってきた会話を `--continue` でそのまま続きから開ける。

| ファイル | 置き場所 | 役割 |
|---|---|---|
| `migrate-to-nas.sh` | Mac で実行 | 会話・作業フォルダ・共通設定を NAS へコピーし、`bootstrap.sh` も配置する |
| `bootstrap.sh` | `/volume1/claude/claude-code/bootstrap.sh` | コンテナ起動時の処理（パッケージ導入 → ユーザー切替 → tmux で常駐） |
| `compose.yaml` | UGOS の Docker →「プロジェクト」に貼る | コンテナ定義 |

## 1. Mac：NAS へコピーする

1. Finder →「サーバへ接続」で `smb://192.168.11.2/claude` を接続（`/Volumes/claude` に出る）
2. 引き継ぐ会話のファイルを特定する（`~/.claude/projects/<フォルダ>/<セッションID>.jsonl`）
3. 実行する

```bash
RC_NAME="街バル (NAS)" ./migrate-to-nas.sh ~/.claude/projects/<フォルダ>/<セッションID>.jsonl
```

- `node_modules` と `.next` はコピーしない（Mac 用のネイティブ部品が入っているため。NAS 側で入れ直す）
- 最後に、コピーした `.env` 系ファイルの変数名が一覧表示される。**AWS の強い権限の鍵が入っていたら NAS 側から消す**
- `~/.claude/settings.json` は `settings.mac.json` として置く。コンテナはそこから `permissions` と `model` だけを取り込む（フックは Mac 前提なので持ち込まない）

> **再実行の注意**：NAS 側で作業を始めた後にもう一度実行すると、Mac の古い内容で上書きされる。再実行は NAS で作業する前だけにする。

## 2. UGOS：コンテナを作る

1. Docker →「プロジェクト」→ 作成。名前は `claude-code`
2. `compose.yaml` の内容を貼り付けて作成・起動
3. 初回はパッケージと Claude Code の導入で 1〜3 分かかる

## 3. 初回だけ：ログインと Remote Control の許可

コンテナの端末に入り、tmux の画面につなぐ。

- UGOS の Docker → コンテナ `claude-code` →「ターミナル」が使えればそこから
- 無ければ一時的に SSH を有効にして `sudo docker exec -it claude-code bash`（終わったら SSH は無効に戻す）

```bash
tmux -S /tmp/claude.tmux attach
```

画面の指示に従う。

1. ログイン方法は **claude.ai のアカウント**を選ぶ（API キーでは Remote Control が使えない）。表示された URL を Mac か iPad で開き、出てきたコードを貼り付ける
2. `Trust this folder?` → 信頼する
3. Remote Control の確認が出たら許可する。出なければ、プロンプトで `/remote-control` を実行する
4. **Ctrl-b → d** で tmux から抜ける（Claude は動き続ける）

依存関係を Linux 用に入れ直して動作を確認する（tmux で **Ctrl-b → c** を押して別ウィンドウを開く）。

```bash
source ~/.nas-claude/config && cd "$PROJECT_DIR"
npm ci && npx prisma generate && npm run build
```

## 4. iPad で確認（入院前に必ず）

Claude アプリ → **Code** → 一覧に「街バル (NAS)」（緑の点）が出る。開いて次を確認する。

- [ ] 直近のやり取りが見え、「前回どこまで進んだ？」に正しく答える
- [ ] ファイルを 1 つ小さく直して、ビルドが通る
- [ ] 承認ダイアログが iPad に出て、許可・拒否できる
- [ ] UGOS でコンテナを再起動 → 1〜2 分で同じ会話のままオンラインに戻る

確認が済んだら、**Mac 側では街バルを触らない**（2 か所で編集すると食い違う）。Mac の電源は切ってよい。

## 入院中に困ったら

| 症状 | 対処 |
|---|---|
| 一覧でオフライン（グレー）のまま数分戻らない | iPad で Tailscale をオン → UGOS 管理画面（Tailscale 上の NAS のアドレスの `:9443`）→ コンテナ `claude-code` を再起動 |
| 再起動しても戻らない | UGOS のコンテナのログ／ターミナルで `tmux -S /tmp/claude.tmux attach` して画面を見る。ログイン切れなら `/login` |
| 会話が新しいものに変わった | iPad から `/resume` で元の会話を選び直す |

## 注意

- コンテナの HOME は `claude` 共有の中にあるので、Duplicati の毎日のバックアップ（暗号化済み）に Claude のログイン情報も含まれる。容量を食う `node_modules` と `.next` は Duplicati のフィルタで除外するとよい
- コンテナ内の Claude は `/Users/tarumi` 配下（＝NAS の `claude-code/home`）しか触れない。NAS の他の共有フォルダはマウントしていない
- 処理はすべて NAS の上で動く。会話内容は Remote Control のため Anthropic のサーバーにも保存される（通常のクラウドセッションと同じ扱い）
