#!/bin/bash

# bootstrap-bazzite.sh - Terminal-as-an-OS Automated Setup (Bazzite)
# ------------------------------------------------------------------

set -e # Exit on error

DOTFILES_DIR=$(pwd)

echo "🚀 Starting Terminal-as-an-OS setup for Bazzite..."

# 1. Install CLI Tools via Homebrew
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew not found. Bazzite usually has it pre-installed."
    echo "If missing, install it from https://brew.sh/"
    exit 1
fi

echo "📦 Installing CLI dependencies from Brewfile.linux..."
brew bundle --file="$DOTFILES_DIR/Brewfile.linux"

# 2. Install GUI Apps via Flatpak & ujust
echo "📦 Installing GUI dependencies..."
flatpak install -y flathub org.wezfurlong.wezterm || true
flatpak install -y flathub com.mitchellh.ghostty || true
echo "📦 Installing 1Password via Bazzite ujust command..."
ujust install-1password || true

# 3. Install Nerd Fonts
echo "🔤 Installing Nerd Fonts..."
mkdir -p ~/.local/share/fonts
for font in "FiraCode" "JetBrainsMono"; do
    if [ ! -d "$HOME/.local/share/fonts/$font" ]; then
        curl -fLo "${font}.zip" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font}.zip"
        unzip -q -o "${font}.zip" -d ~/.local/share/fonts/$font
        rm "${font}.zip"
    fi
done
fc-cache -fv || echo "⚠️ fc-cache failed, fonts might require a restart to be discovered."

# 4. Reset Environment
echo "🧹 Cleaning up existing files to ensure symlinks work..."
chmod +x "$DOTFILES_DIR/reset_environment.sh"
"$DOTFILES_DIR/reset_environment.sh"

# 5. Stow Configurations
echo "📦 Stowing configurations targeting $HOME..."
mkdir -p ~/.config

# Note: shades is removed for Linux
packages=("zsh" "tmux" "starship" "git" "nvim" "lazygit")

for pkg in "${packages[@]}"; do
    echo "  -> Stowing $pkg..."
    stow --ignore=".DS_Store" -v -t ~ -R "$pkg"
done

# Deep link for Ghostty
echo "  -> Stowing ghostty (Deep Link for reload stability)..."
mkdir -p ~/.config/ghostty
ln -sf "$DOTFILES_DIR/ghostty/.config/ghostty/config" ~/.config/ghostty/config
ln -sf "$DOTFILES_DIR/ghostty/.config/ghostty/themes" ~/.config/ghostty/themes
ln -sf "$DOTFILES_DIR/ghostty/.config/ghostty/theme-current.conf" ~/.config/ghostty/theme-current.conf

echo "✅ Bazzite setup complete."
