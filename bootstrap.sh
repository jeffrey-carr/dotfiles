#!/bin/bash

# bootstrap.sh - Terminal-as-an-OS Automated Setup (Deep Link Edition)
# ------------------------------------------------------------------

set -e # Exit on error

DOTFILES_DIR=$(pwd)

echo "🚀 Starting Terminal-as-an-OS setup..."

# 1. Check for Homebrew
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew not found. Please install it first: https://brew.sh/"
    exit 1
fi

# 2. Install Dependencies
echo "📦 Installing dependencies from Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

# 3. Reset Environment (Backup and Clear paths)
echo "🧹 Cleaning up existing files to ensure symlinks work..."
chmod +x "$DOTFILES_DIR/reset_environment.sh"
"$DOTFILES_DIR/reset_environment.sh"

# 4. Stow New Configurations
echo "📦 Stowing new configurations targeting $HOME..."
mkdir -p ~/.config

# Standard packages
packages=("zsh" "tmux" "starship" "git" "nvim" "shades" "lazygit")

for pkg in "${packages[@]}"; do
    echo "  -> Stowing $pkg..."
    stow --ignore=".DS_Store" -v -t ~ -R "$pkg"
done

# Special handling for Ghostty
# We create a REAL directory for Ghostty because its file watcher 
# often fails to trigger live-reloads if the directory itself is a symlink.
echo "  -> Stowing ghostty (Deep Link for reload stability)..."
mkdir -p ~/.config/ghostty
ln -sf "$DOTFILES_DIR/ghostty/.config/ghostty/config" ~/.config/ghostty/config
ln -sf "$DOTFILES_DIR/ghostty/.config/ghostty/themes" ~/.config/ghostty/themes
ln -sf "$DOTFILES_DIR/ghostty/.config/ghostty/theme-current.conf" ~/.config/ghostty/theme-current.conf

# 4.5 Install Shades and Setup Launchd Daemons
echo "⚙️ Installing shades..."
go install github.com/brianmargolis/shades@latest
echo "⚙️ Registering shades Launchd agents..."
shades uninstall &>/dev/null || true
shades install

# 4.6 Build and Register Alfred Workflow
if [ -d "/Applications/Alfred 5.app" ] || [ -d "/Applications/Alfred.app" ]; then
    echo "⚙️ Setting up Alfred Shades Theme Picker..."
    (
        cd "$DOTFILES_DIR/shades"
        python3 build_workflow.py
        echo "⚙️ Launching Alfred to import the workflow..."
        open shades.alfredworkflow
    )
else
    echo "⚠️ Alfred app not found; skipping workflow registration."
fi

echo "✅ Stowing complete."


# 5. Final Instructions
echo "--------------------------------------------------"
echo "🎉 Setup complete! All files are now symlinked."
echo "If you edit files in $DOTFILES_DIR, they will reflect in your home directory."
echo ""
echo "Remaining Manual Steps:"
echo "1. Run 'source ~/.zshrc' or restart your terminal."
echo "2. Run 'nvim' to let lazy.nvim install plugins."
echo "--------------------------------------------------"
