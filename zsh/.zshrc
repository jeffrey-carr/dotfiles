# ~/.zshrc

export GOPATH=~/go
export CUSTOMGOPATH=~/go/bin
export JUMPPATH=~/dev/podcache_playbooks/inventory/bin
export BREWPATH=/opt/homebrew/bin
export NODEPATH=$HOME/.nvm/versions/node/v20.17.0/bin
export LOCALINSTALLS=$HOME/.local/bin
export CARGO=$HOME/.cargo/bin
export THEME_SWITCHER=$HOME/.config/theme
export PATH=$NODEPATH:$GOPATH:$CUSTOMGOPATH:$JUMPPATH:$BREWPATH:$LOCALINSTALLS:$CARGO:$THEME_SWITCHER:$PATH

# Initialize Homebrew PATH
if [[ -x "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x "/usr/local/bin/brew" ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Custom commands
source "$HOME/.config/zsh/aliases"

# General Settings
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LANG="en_US.UTF-8"

# Fast directory switching & fuzzy finding
eval "$(zoxide init zsh)"
source <(fzf --zsh)

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt sharehistory
setopt incappendhistory

# Starship Prompt
eval "$(starship init zsh)"

# 1. Zsh Auto-suggestions (Sourced before syntax highlighting)
if [[ -f "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  bindkey '^L' autosuggest-accept
elif [[ -f "/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  bindkey '^L' autosuggest-accept
fi

# Aliases
alias v="nvim"
alias vi="nvim"
alias vim="nvim"
alias c="clear"
alias ls="ls -G"
alias ll="ls -lG"
alias la="ls -laG"

# -----------------------------------------------------------------------------
# 🎈 COMPLETION SYSTEM
# -----------------------------------------------------------------------------

# Initialize completion
# Using -d for a specific dump file location to keep things clean
[[ -d ~/.config/zsh ]] || mkdir -p ~/.config/zsh
autoload -Uz compinit
compinit -i -d ~/.config/zsh/.zcompdump

# Case-insensitive completion
# This allows 'cd myfolder' -> [TAB] -> 'cd MyFolder/'
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Colorize completions
zstyle ':completion:*:default' list-colors ''

# Options for case-insensitivity and better navigation
setopt NO_CASE_GLOB      # Case-insensitive globbing (e.g., ls *.png matches *.PNG)
setopt NO_CASE_MATCH     # Case-insensitive regex matching
setopt AUTO_CD           # If a command is a directory, cd into it
setopt AUTO_LIST         # Automatically list choices on ambiguous completion
setopt AUTO_MENU         # Show completion menu on a second tab press
setopt MENU_COMPLETE     # Automatically highlight the first completion entry
setopt GLOB_DOTS         # Match hidden files by default
setopt EXTENDED_GLOB     # Use advanced globbing (e.g., ^ for excluding)

# Secret Management
if [ -f ~/.env.secrets ]; then
  source ~/.env.secrets
fi

# 2. Zsh Syntax Highlighting (MUST BE AT THE VERY END)
if [[ -f "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ -f "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
