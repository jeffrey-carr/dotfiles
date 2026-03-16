# 🚀 Next Steps: Terminal-as-an-OS Setup (Stow-Ready)

Your "Terminal-as-an-OS" environment is now structured and ready!

## ⚡️ The Fast Track (Automated Setup)

I've created a bootstrap script that handles the Homebrew installation, safely backs up your old configs, and stows the new ones automatically.

```bash
cd ~/dev/new_dev_environment
chmod +x bootstrap.sh
./bootstrap.sh
```

---

## 📖 Manual Steps (If you prefer)

Ensure Homebrew is installed, then run:

```bash
cd ~/dev/new_dev_environment
brew bundle --file=Brewfile
```
*(Note: Deprecated taps have been removed from the Brewfile. It now uses built-in Homebrew commands and the standard cask repository for fonts.)*

## 2. 🧹 Full Environment Reset (Backup the Old World)

To avoid conflicts, run these commands to backup your current setup.

```bash
# Define a backup directory
BACKUP_DIR=~/config_backup_$(date +%Y%m%d_%H%M%S)
mkdir -p "$BACKUP_DIR"

# Move old configs to backup
mv ~/.zshrc ~/.zshenv ~/.zprofile "$BACKUP_DIR/" 2>/dev/null
mv ~/.config/zsh "$BACKUP_DIR/config_zsh" 2>/dev/null
mv ~/.config/nvim "$BACKUP_DIR/config_nvim" 2>/dev/null
mv ~/.local/share/nvim "$BACKUP_DIR/share_nvim" 2>/dev/null
mv ~/.local/state/nvim "$BACKUP_DIR/state_nvim" 2>/dev/null
mv ~/.cache/nvim "$BACKUP_DIR/cache_nvim" 2>/dev/null
mv ~/.config/ghostty "$BACKUP_DIR/config_ghostty" 2>/dev/null
mv ~/.gitconfig "$BACKUP_DIR/old_gitconfig" 2>/dev/null
mv ~/.tmux.conf "$BACKUP_DIR/old_tmux.conf" 2>/dev/null

echo "Old world backed up to $BACKUP_DIR"
```

## 3. 📦 Apply Configs with GNU Stow

GNU Stow is a symlink manager. It links files from this folder into your home directory based on the directory structure.

```bash
cd ~/dev/new_dev_environment

# Create target directories if they don't exist
mkdir -p ~/.config

# Stow the packages targeting your home directory
stow -t ~ zsh
stow -t ~ tmux
stow -t ~ starship
stow -t ~ ghostty
stow -t ~ git
stow -t ~ nvim
stow -t ~ theme
```

### How Stow works for this setup:
- `stow zsh` links `zsh/.zshrc` -> `~/.zshrc`
- `stow nvim` links `nvim/.config/nvim/` -> `~/.config/nvim/`
- `stow theme` links `theme/.config/theme/` -> `~/.config/theme/`

## 4. Global Theme Synchronization (Theme Hub)

Your dotfiles now include a custom, zero-dependency "Theme Hub" that synchronizes Neovim, Tmux, and Ghostty with your macOS Light/Dark mode!

To enable automatic switching in the background, run the Swift listener:
```bash
# Run this in the background, or configure it to run on login
swift ~/.config/theme/macos-theme-listener.swift &
```
*(Alternatively, you can manually toggle it anytime using `~/.config/theme/theme-switch.sh dark`)*

## 5. macOS Keyboard Tuning

Set high-speed key repeat (requires logout/restart):

```bash
defaults write -g KeyRepeat -int 1
defaults write -g InitialKeyRepeat -int 10
```

## 5. Initialization

### Neovim
Open Neovim: `nvim`. `lazy.nvim` will automatically install the themes, LSP, and plugins.
Run `:Copilot setup` to authenticate.

### Secrets
Create a local secrets file:
```bash
touch ~/.env.secrets
# Add your keys here: export ANTHROPIC_API_KEY=...
```

---
**Enjoy your zero-latency, heavily integrated workflow!**
