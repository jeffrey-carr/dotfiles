#!/bin/bash

# reset_environment.sh - Clean up and backup existing configurations
# ------------------------------------------------------------------

BACKUP_DIR=~/config_backup_$(date +%Y%m%d_%H%M%S)
mkdir -p "$BACKUP_DIR"

echo "🧹 Backing up existing configurations to $BACKUP_DIR..."

# List of targets to backup and remove
targets=(
    ".zshrc"
    ".zshenv"
    ".zprofile"
    ".tmux.conf"
    ".gitconfig"
    ".config/zsh"
    ".config/nvim"
    ".config/ghostty"
    ".config/theme"
    ".config/starship.toml"
    ".local/share/nvim"
    ".local/state/nvim"
    ".cache/nvim"
    "Library/Application Support/com.mitchellh.ghostty"
    "Library/Application Support/ghostty"
    ".DS_Store"
    ".config/.DS_Store"
)

for target in "${targets[@]}"; do
    FILE_PATH=~/"$target"
    if [ -e "$FILE_PATH" ] || [ -L "$FILE_PATH" ]; then
        # If it's a real file/dir, copy it to backup before removing
        if [ ! -L "$FILE_PATH" ]; then
            echo "  -> Backing up $target..."
            # Ensure the structure exists in the backup dir
            mkdir -p "$(dirname "$BACKUP_DIR/$target")"
            cp -R "$FILE_PATH" "$BACKUP_DIR/$target" 2>/dev/null || true
        fi
        # Remove the file, dir, or symlink to clear the path for stow
        rm -rf "$FILE_PATH"
    fi
done

echo "✅ Old world backed up and cleared."
