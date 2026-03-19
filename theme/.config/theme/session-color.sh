#!/bin/bash

# Get the session name as an argument or from tmux directly
SESSION_NAME=${1:-$(tmux display-message -p '#S')}

# A curated list of soft pastel hex colors
PASTELS=(
  "#B2F2BB" "#D0BFFF" "#FFC9C9" "#A5D8FF" "#FFD8A8" 
  "#FFF9DB" "#FFF3BF" "#E5DBFF" "#C2F3FF" "#D3F9D8"
  "#F06292" "#BA68C8" "#9575CD" "#7986CB" "#64B5F6"
  "#4FC3F7" "#4DD0E1" "#4DB6AC" "#81C784" "#AED581"
  "#DCE775" "#FFF176" "#FFD54F" "#FFB74D" "#FF8A65"
  "#A1887F" "#E0E0E0" "#90A4AE" "#F8BBD0" "#E1BEE7"
  "#D1C4E9" "#C5CAE9" "#BBDEFB" "#B3E5FC" "#B2EBF2"
  "#B2DFDB" "#C8E6C9" "#DCEDC8" "#F0F4C3" "#FFF9C4"
)

# Try to get the existing color for this session
COLOR=$(tmux show-options -qv -t "$SESSION_NAME" "@session_color")

# Log for debugging
echo "DEBUG: SESSION_NAME='$SESSION_NAME', COLOR='$COLOR', RANDOM=$RANDOM" >> /tmp/tmux_session_color.log

if [ -z "$COLOR" ]; then
    # Pick a random color if none is set
    INDEX=$((RANDOM % ${#PASTELS[@]}))
    COLOR="${PASTELS[$INDEX]}"
    # Persist it for the session
    tmux set-option -q -t "$SESSION_NAME" "@session_color" "$COLOR"
fi

# Output the full tmux formatting
echo "#[fg=$COLOR]#[bg=$COLOR]#[fg=black,bold]󰇄 #S#[bg=default]#[fg=$COLOR,nobold]"
