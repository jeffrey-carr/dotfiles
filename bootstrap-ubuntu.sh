#!/bin/bash

# bootstrap-ubuntu.sh - Ubuntu Server Automated Setup
# ------------------------------------------------------------------

set -e # Exit on error

DOTFILES_DIR=$(pwd)

echo "🚀 Starting Terminal-as-an-OS setup for Ubuntu Server..."

# 1. Update and Install APT Dependencies
echo "📦 Installing APT dependencies..."
sudo apt update
sudo apt install -y \
    zsh \
    tmux \
    git \
    neovim \
    stow \
    ripgrep \
    fd-find \
    jq \
    fzf \
    zoxide \
    xclip \
    curl \
    build-essential \
    python3

# Fix fd-find symlink if needed (Ubuntu calls it fdfind, some plugins expect fd)
if ! command -v fd &> /dev/null && command -v fdfind &> /dev/null; then
    mkdir -p ~/.local/bin
    ln -s $(which fdfind) ~/.local/bin/fd
fi

# 2. Install Starship
if ! command -v starship &> /dev/null; then
    echo "⭐ Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# 3. Change Default Shell to Zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "🐚 Changing default shell to zsh..."
    chsh -s $(which zsh)
fi

# 4. Stow Configurations
echo "📦 Stowing configurations targeting $HOME..."
mkdir -p ~/.config

# Standard packages (skipping macOS specific ones like shades, ghostty)
packages=("zsh" "tmux" "starship" "git" "nvim" "lazygit")

for pkg in "${packages[@]}"; do
    if [ -d "$DOTFILES_DIR/$pkg" ]; then
        echo "  -> Stowing $pkg..."
        stow --ignore=".DS_Store" -v -t ~ -R "$pkg"
    fi
done

echo "✅ Ubuntu setup complete."
echo "--------------------------------------------------"
echo "🎉 Setup complete! All files are now symlinked."
echo "Please logout and log back in via SSH for the Zsh default shell to take effect."
echo "--------------------------------------------------"
