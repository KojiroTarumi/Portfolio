#!/usr/bin/env bash
# NAS 上のコンテナで Claude Code を常駐させ、Remote Control で iPad から操作できるようにする。
#
#   bootstrap.sh            コンテナの起動処理（root）。パッケージを入れ、HOME の持ち主に切り替えて --supervise へ
#   bootstrap.sh --supervise  Claude Code を入れ、tmux の中で --loop を動かし続ける
#   bootstrap.sh --loop       claude を前回の会話の続きで起動し、落ちたら再起動する
set -euo pipefail

SOCKET=/tmp/claude.tmux
SELF=$(readlink -f "${BASH_SOURCE[0]}")

load_config() {
  # migrate-to-nas.sh が書き出す。PROJECT_DIR と RC_NAME を定義する
  local config="$HOME/.nas-claude/config"
  if [[ -f "$config" ]]; then
    # shellcheck disable=SC1090
    source "$config"
  fi
  PROJECT_DIR="${PROJECT_DIR:-$HOME}"
  RC_NAME="${RC_NAME:-NAS}"
}

as_root() {
  if ! command -v tmux >/dev/null || ! command -v rg >/dev/null; then
    apt-get update
    apt-get install -y --no-install-recommends \
      tmux git ripgrep jq python3 less procps curl ca-certificates openssh-client
    rm -rf /var/lib/apt/lists/*
  fi

  # NAS 上のファイルの持ち主（SMB で書き込んだユーザー）と同じ uid で動かす
  local puid pgid
  puid=$(stat -c %u "$HOME")
  pgid=$(stat -c %g "$HOME")
  getent group "$pgid" >/dev/null || groupadd -g "$pgid" claude
  getent passwd "$puid" >/dev/null || useradd -u "$puid" -g "$pgid" -d "$HOME" -M -s /bin/bash claude

  exec setpriv --reuid="$puid" --regid="$pgid" --init-groups \
    env HOME="$HOME" USER=claude LANG=C.UTF-8 TZ="${TZ:-Asia/Tokyo}" \
    bash "$SELF" --supervise
}

supervise() {
  export PATH="$HOME/.local/bin:$PATH"
  if ! command -v claude >/dev/null; then
    # ネイティブ版を HOME に入れる。HOME は NAS 上なのでコンテナを作り直しても残り、自動更新も効く
    curl -fsSL https://claude.ai/install.sh | bash
  fi

  # Mac の settings.json はフック等が Mac 前提なので、permissions と model だけ引き継ぐ
  mkdir -p "$HOME/.claude"
  node - <<'JS'
const fs = require('fs');
const dir = `${process.env.HOME}/.claude`;
const path = `${dir}/settings.json`;
let settings = {};
if (fs.existsSync(path)) {
  settings = JSON.parse(fs.readFileSync(path, 'utf8'));
} else if (fs.existsSync(`${dir}/settings.mac.json`)) {
  const mac = JSON.parse(fs.readFileSync(`${dir}/settings.mac.json`, 'utf8'));
  for (const key of ['permissions', 'model']) {
    if (mac[key] !== undefined) settings[key] = mac[key];
  }
}
settings.remoteControlAtStartup = true;
fs.writeFileSync(path, JSON.stringify(settings, null, 2) + '\n');
JS

  load_config
  tmux -S "$SOCKET" kill-server 2>/dev/null || true
  tmux -S "$SOCKET" new-session -d -s claude -x 200 -y 50 -c "$PROJECT_DIR" "bash $SELF --loop"
  # tmux が生きている間はコンテナを止めない
  while tmux -S "$SOCKET" has-session -t claude 2>/dev/null; do
    sleep 30
  done
}

loop() {
  export PATH="$HOME/.local/bin:$PATH"
  load_config
  cd "$PROJECT_DIR"
  # 会話履歴は作業フォルダの絶対パス（英数字以外を - に置換）ごとに保存される
  local history_dir
  history_dir="$HOME/.claude/projects/$(printf '%s' "$PWD" | sed 's/[^A-Za-z0-9]/-/g')"
  while true; do
    local continue_flag=()
    # 一時的な失敗で新しい会話を作ってしまわないよう、履歴があれば必ず続きから開く
    if compgen -G "$history_dir/*.jsonl" >/dev/null; then
      continue_flag=(--continue)
    fi
    echo "[$(date '+%F %T')] claude を起動します（${continue_flag[*]:-新規会話}）"
    claude "${continue_flag[@]}" --remote-control "$RC_NAME" || true
    echo "[$(date '+%F %T')] claude が終了しました。15 秒後に再起動します（止めるなら Ctrl-C）"
    sleep 15
  done
}

case "${1:-}" in
  --supervise) supervise ;;
  --loop) loop ;;
  *) as_root ;;
esac
