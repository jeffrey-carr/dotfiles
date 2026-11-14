#!/usr/bin/env bash
# Instant tmux session switcher powered by active sessions + zoxide + fzf.

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

current_session=$(tmux display-message -p '#S' 2>/dev/null)

list_candidates() {
  # 1. Existing tmux sessions (excluding current session and hidden scratch session)
  tmux list-sessions -F '#{session_name}' 2>/dev/null | while read -r s; do
    if [[ -n "$s" && "$s" != "$current_session" && "$s" != "scratch" ]]; then
      printf "[session] %s\n" "$s"
    fi
  done

  # 2. Zoxide directories
  if command -v zoxide >/dev/null 2>&1; then
    zoxide query -l 2>/dev/null
  fi
}

preview_cmd='
  item={}
  if [[ "$item" == \[session\]* ]]; then
    sname="${item#\[session\] }"
    echo "=== Tmux Session: $sname ==="
    tmux list-windows -t "$sname" -F "  #I: #W (#{window_panes} panes) — #{pane_current_path}" 2>/dev/null
    echo ""
    tmux capture-pane -ep -t "$sname" 2>/dev/null | tail -n 25
  else
    echo "=== Directory: $item ==="
    if git -C "$item" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      git -C "$item" status -sb 2>/dev/null
      echo ""
      git -C "$item" log --oneline -n 10 --color=always 2>/dev/null
    else
      ls -la "$item" 2>/dev/null
    fi
  fi
'

selected=$(
  list_candidates | fzf \
    --reverse \
    --header="Switch Session / Open Project (current: ${current_session:-none})" \
    --prompt="󰇄 Project > " \
    --preview="$preview_cmd" \
    --preview-window="right:55%:wrap"
)

[[ -z "$selected" ]] && exit 0

if [[ "$selected" == \[session\]* ]]; then
  target_session="${selected#\[session\] }"
  tmux switch-client -t "$target_session"
  exit 0
fi

# Selected a directory path
target_dir="$selected"
session_name=$(basename "$target_dir" | tr '.: ' '---')
[[ -z "$session_name" ]] && session_name="root"

if ! tmux has-session -t="=$session_name" 2>/dev/null; then
  tmux new-session -ds "$session_name" -c "$target_dir"
fi

if [[ -n "$TMUX" ]]; then
  tmux switch-client -t "=$session_name"
else
  tmux attach-session -t "=$session_name"
fi
