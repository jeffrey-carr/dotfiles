#!/bin/bash

# Theme Hub Switcher (Profile Driven)
# Orchestrates theme changes based on profiles defined in theme_config

# Ensure we have Homebrew in the PATH
if [[ -x "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x "/usr/local/bin/brew" ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

STATE_FILE="$HOME/.config/theme/theme_state"
CONFIG_FILE="$HOME/.config/theme/theme_config"
MODE=$1

if [[ "$MODE" != "dark" && "$MODE" != "light" ]]; then
    echo "Usage: $0 [dark|light]"
    exit 1
fi

# Load Config
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    echo "❌ Config file not found at $CONFIG_FILE"
    exit 1
fi

# Determine Profile
PROFILE_VAR="${MODE}_profile"
PROFILE_NAME="${!PROFILE_VAR}"
PROFILE_FILE="$HOME/.config/theme/profiles/${PROFILE_NAME}.sh"

if [[ -f "$PROFILE_FILE" ]]; then
    source "$PROFILE_FILE"
else
    echo "❌ Profile file not found at $PROFILE_FILE"
    exit 1
fi

# 1. Update State
echo "$MODE" > "$STATE_FILE"
echo "Switching to $MODE mode (Profile: $PROFILE_NAME)..."

# 2. Update Ghostty Config
GHOSTTY_PATHS=(
    "$HOME/.config/ghostty/config" 
    "$HOME/.config/ghostty/ghostty.conf"
    "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
    "$HOME/Library/Application Support/ghostty/config"
)

for config in "${GHOSTTY_PATHS[@]}"; do
    if [[ -f "$config" ]]; then
        # Use sed -i to update while preserving symlinks
        sed -i '' "s|^theme[[:space:]]*=.*|theme = \"$GHOSTTY_THEME\"|" "$config"
        # Force a file-system event
        touch "$config"
        echo "✅ Ghostty updated: $config"
    fi
done

# 3. Force Ghostty UI Refresh (AppleScript Fail-safe)
if pgrep -ix "ghostty" > /dev/null; then
    osascript -e 'tell application "System Events" to tell process "Ghostty" to keystroke "," using {command down, shift down}' &>/dev/null
    echo "✅ Ghostty reload signal sent"
fi

# 4. Update Tmux
TMUX_THEME_FILE="$HOME/.config/theme/tmux_theme.conf"
BORDER_COLOR=$([[ "$MODE" == "dark" ]] && echo "brightblack" || echo "brightwhite")
BG_COLOR=$([[ "$MODE" == "dark" ]] && echo "black" || echo "white")

cat << EOF > "$TMUX_THEME_FILE"
set -g pane-border-format " #[fg=$TMUX_ACCENT]#[fg=$BG_COLOR,bg=$TMUX_ACCENT,bold] #P #[bg=default,fg=$TMUX_ACCENT,nobold] "
set -g pane-active-border-style fg=$TMUX_ACCENT
set -g pane-border-style fg=$BORDER_COLOR
set -g window-status-current-format "#[fg=$TMUX_ACCENT]#[fg=$BG_COLOR,bg=$TMUX_ACCENT,bold]#I:#W#[bg=default,fg=$TMUX_ACCENT,nobold]"
EOF

if command -v tmux &> /dev/null && tmux info &> /dev/null; then
    tmux source-file "$HOME/.tmux.conf"
    tmux refresh-client -S &>/dev/null || true
    echo "✅ Tmux updated: $TMUX_ACCENT"
fi

# 5. Update Neovim
if command -v nvim &> /dev/null; then
    for server in $(find "${TMPDIR:-/tmp}" -name "nvim.*.0" 2>/dev/null); do
        nvim --server "$server" --remote-send "<Esc>:set background=$MODE<CR>" &> /dev/null || true
    done
    echo "✅ Neovim signaled"
fi

echo "🎉 Theme sync complete!"
