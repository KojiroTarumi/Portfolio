#!/usr/bin/env bash
# Mac で実行する。Claude Code の会話 1 つと、その作業フォルダを NAS 上のコンテナで使えるようにする。
#
#   - 作業フォルダが Mac のホーム配下 → NAS 上のコンテナ用 HOME へコピーする
#   - 作業フォルダがすでに NAS 上（/Volumes/<共有>/...）→ コピーせず、compose.yaml に足す volumes の行を表示する
#   - .env 系ファイルは既定ではコピーしない（COPY_ENV=1 でコピー）。変数名の一覧だけ表示する
#
#   ./migrate-to-nas.sh <会話の .jsonl> [NAS 上の HOME]
#
#   会話の .jsonl : ~/.claude/projects/<フォルダ>/<セッションID>.jsonl
#   NAS 上の HOME : 既定は /Volumes/claude/claude-code/home（Finder で smb://192.168.11.2/claude を接続しておく）
#
# NAS で作業を始めた後に再実行すると、Mac の古い内容で上書きされるので注意。
# macOS 標準の bash 3.2 で動くように書いている。
set -euo pipefail

transcript="${1:?使い方: $0 <会話の .jsonl> [NAS 上の HOME]}"
nas_home="${2:-/Volumes/claude/claude-code/home}"

[[ -f "$transcript" ]] || { echo "会話ファイルがありません: $transcript" >&2; exit 1; }
share=$(printf '%s' "$nas_home" | cut -d/ -f1-3)  # /Volumes/claude
[[ -d "$share" ]] || { echo "NAS の共有フォルダが接続されていません: $share" >&2; exit 1; }
mkdir -p "$nas_home"

# 会話の作業フォルダは、会話ファイルの各行に記録されている cwd から取る
cwd=$(grep -m1 -o '"cwd":"[^"]*"' "$transcript" | cut -d'"' -f4)
[[ -n "$cwd" && -d "$cwd" ]] || { echo "作業フォルダを特定できません（cwd=$cwd）" >&2; exit 1; }
real_cwd=$(cd "$cwd" && pwd -P)

excludes=(--exclude node_modules --exclude .next --exclude .turbo --exclude .vercel --exclude .DS_Store)
if [[ "${COPY_ENV:-0}" != 1 ]]; then
  excludes+=(--exclude '.env*')
fi

copy_tree() {
  local src="$1" rel="${1#"$HOME"/}"
  echo "==> コピー: $src → $nas_home/$rel"
  mkdir -p "$nas_home/$rel"
  # SMB 越しなので権限・所有者は持ち込まない（-rlt）
  rsync -rlt "${excludes[@]}" "$src/" "$nas_home/$rel/"
}

# 1. 作業フォルダ
volume_line=""
case "$real_cwd" in
  /Volumes/*)
    # すでに NAS 上にある。コンテナには NAS 側の実体を、会話に記録されたパスのままマウントする
    vol_share=$(printf '%s' "$real_cwd" | cut -d/ -f3)
    nas_path="/volume1/${vol_share}${real_cwd#/Volumes/"$vol_share"}"
    volume_line="      - ${nas_path}:${cwd}"
    echo "==> 作業フォルダはすでに NAS 上にあるためコピーしません: $real_cwd"
    ;;
  "$HOME"/*)
    if [[ -f "$cwd/.git" ]]; then
      # git worktree の場合は本体のリポジトリも必要
      common=$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir)
      main_repo=$(dirname "$common")
      case "$main_repo" in
        "$HOME"/*) copy_tree "$main_repo" ;;
        *) echo "worktree の本体がホーム配下にありません: $main_repo" >&2; exit 1 ;;
      esac
      case "$cwd" in
        "$main_repo"/*) ;;  # 本体の中にある worktree は上でコピー済み
        *) copy_tree "$cwd" ;;
      esac
    else
      copy_tree "$cwd"
    fi
    ;;
  *)
    echo "作業フォルダがホーム配下にも NAS 上にもありません: $real_cwd" >&2
    exit 1
    ;;
esac

# 2. 会話履歴とプロジェクトのメモリ（同じフォルダに入っている）
history_dir=$(cd "$(dirname "$transcript")" && pwd)
dest_history="$nas_home/.claude/projects/$(basename "$history_dir")"
echo "==> コピー: 会話履歴 $history_dir"
mkdir -p "$dest_history"
rsync -rlt "$history_dir/" "$dest_history/"
# コンテナは claude --continue（そのフォルダで一番新しい会話）で起動するので、引き継ぐ会話を最新にしておく
touch "$dest_history/$(basename "$transcript")"

# 3. 全体設定。settings.json はフック等が Mac 前提なので別名で置き、コンテナ側で必要な項目だけ取り込む
echo "==> コピー: ~/.claude の共通設定"
mkdir -p "$nas_home/.claude"
for item in CLAUDE.md skills agents commands rules; do
  if [[ -e "$HOME/.claude/$item" ]]; then
    rsync -rlt "$HOME/.claude/$item" "$nas_home/.claude/"
  fi
done
if [[ -f "$HOME/.claude/settings.json" ]]; then
  cp "$HOME/.claude/settings.json" "$nas_home/.claude/settings.mac.json"
fi

# 4. コンテナの起動スクリプトと、それが読む設定
cp "$(dirname "$0")/bootstrap.sh" "$(dirname "$nas_home")/bootstrap.sh"
mkdir -p "$nas_home/.nas-claude"
{
  printf 'PROJECT_DIR=%q\n' "$cwd"
  printf 'RC_NAME=%q\n' "${RC_NAME:-街バル (NAS)}"
} > "$nas_home/.nas-claude/config"

# 5. 秘密情報の確認（値は表示しない）
echo
if [[ "${COPY_ENV:-0}" == 1 ]]; then
  echo "==> .env 系ファイルもコピーしました（COPY_ENV=1）。変数名（値は表示しません）:"
else
  echo "==> .env 系ファイルはコピーしていません。元のファイルの変数名（値は表示しません）:"
fi
found=0
while IFS= read -r f; do
  found=1
  echo "  $f"
  grep -oE '^[A-Za-z_][A-Za-z0-9_]*=' "$f" | sed 's/=$//; s/^/      /' || true
done < <(find "$real_cwd" -name node_modules -prune -o -name '.env*' -type f -print 2>/dev/null)
[[ $found -eq 1 ]] || echo "  （なし）"
if [[ -n "$volume_line" && $found -eq 1 ]]; then
  echo "  ※ 作業フォルダが NAS 上にあるため、これらのファイルはすでに NAS 上にあります"
fi

echo
echo "完了。作業フォルダ: $cwd"
echo "会話: $(basename "$transcript" .jsonl)"
if [[ -n "$volume_line" ]]; then
  echo
  echo "compose.yaml の volumes に次の 1 行を追加してください（UGOS 上の実際のパスと一致するか確認すること）:"
  echo "$volume_line"
fi
echo "node_modules は Mac 用なので、NAS 側で rm -rf node_modules && npm ci（Linux 用に入れ直し）が必要です。"
