#!/usr/bin/env bash
# Fast git branch + dirty indicator for the active tmux pane's directory.

pane_path="${1:-$PWD}"
[[ -d "$pane_path" ]] || exit 0

git_dir=$(git -C "$pane_path" rev-parse --show-toplevel 2>/dev/null) || exit 0
[[ -z "$git_dir" ]] && exit 0

branch=$(git -C "$git_dir" symbolic-ref --short HEAD 2>/dev/null \
      || git -C "$git_dir" describe --tags --exact-match 2>/dev/null \
      || git -C "$git_dir" rev-parse --short HEAD 2>/dev/null)
[[ -z "$branch" ]] && exit 0

# Truncate overly long branch names so the status bar stays compact
if (( ${#branch} > 22 )); then
  branch="${branch:0:20}…"
fi

dirty=""
if ! git -C "$git_dir" diff --quiet --ignore-submodules 2>/dev/null \
   || ! git -C "$git_dir" diff --quiet --ignore-submodules --cached 2>/dev/null; then
  dirty="*"
fi
if [[ -n "$(git -C "$git_dir" ls-files --others --exclude-standard 2>/dev/null | head -n 1)" ]]; then
  dirty="${dirty}+"
fi

printf "󰊢 %s%s" "$branch" "$dirty"
