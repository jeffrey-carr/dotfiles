# ~/.zshrc

# Initialize Homebrew PATH
if [[ -x "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x "/usr/local/bin/brew" ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# General Settings
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LANG="en_US.UTF-8"

# Fast directory switching & fuzzy finding
eval "$(zoxide init zsh)"
source <(fzf --zsh)

# Add Theme Switcher to PATH
export PATH="$HOME/.config/theme:$PATH"

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

# Custom directory jumping
alias dev="cd ~/dev"
alias dot="cd ~/dev/new_dev_environment"

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
