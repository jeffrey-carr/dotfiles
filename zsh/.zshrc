# ~/.zshrc

# -----------------------------------------------------------------------------
# 🍺 1. HOMEBREW (Must be first to set up base PATH and $HOMEBREW_PREFIX)
# -----------------------------------------------------------------------------
if [[ -x "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x "/usr/local/bin/brew" ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# -----------------------------------------------------------------------------
# 🛣️ 2. EXPORTS & PATH
# -----------------------------------------------------------------------------
export GOPATH=~/go
export CUSTOMGOPATH=~/go/bin
export JUMPPATH=~/dev/podcache_playbooks/inventory/bin
# Hardcoded Node path for instant startup
export NODEPATH=$HOME/.nvm/versions/node/v20.19.6/bin
export LOCALINSTALLS=$HOME/.local/bin
export CARGO=$HOME/.cargo/bin
export THEME_SWITCHER=$HOME/.config/theme

# BREWPATH is removed because Homebrew shellenv already handles it automatically
export PATH=$NODEPATH:$GOPATH:$CUSTOMGOPATH:$JUMPPATH:$LOCALINSTALLS:$CARGO:$THEME_SWITCHER:$PATH

export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LANG="en_US.UTF-8"

# -----------------------------------------------------------------------------
# 🚀 3. LAZY LOAD NVM (Only loads the script when you actually type 'nvm')
# -----------------------------------------------------------------------------
nvm() {
  unset -f nvm
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  nvm "$@"
}

# -----------------------------------------------------------------------------
# 🛠️ 4. PLUGINS & TOOLS
# -----------------------------------------------------------------------------
source "$HOME/.config/zsh/aliases"

# Fast directory switching & fuzzy finding
eval "$(zoxide init zsh)"
source <(fzf --zsh)

# Starship Prompt
eval "$(starship init zsh)"

# Zsh Auto-suggestions (Sourced before syntax highlighting)
if [[ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  bindkey '^L' autosuggest-accept
fi

# -----------------------------------------------------------------------------
# 📜 5. HISTORY & ALIASES
# -----------------------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt sharehistory
setopt incappendhistory

alias v="nvim"
alias vi="nvim"
alias vim="nvim"
alias c="clear"
alias ls="ls -G"
alias ll="ls -lG"
alias la="ls -laG"

# -----------------------------------------------------------------------------
# 🎈 6. COMPLETION SYSTEM (Optimized for speed)
# -----------------------------------------------------------------------------
[[ -d ~/.config/zsh ]] || mkdir -p ~/.config/zsh
autoload -Uz compinit

# Check compdump once a day to save massive startup time
if [[ -n ~/.config/zsh/.zcompdump(#qN.mh+24) ]]; then
  compinit -i -d ~/.config/zsh/.zcompdump
else
  compinit -C -d ~/.config/zsh/.zcompdump
fi

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*:default' list-colors ''

setopt NO_CASE_GLOB
setopt NO_CASE_MATCH
setopt AUTO_CD
setopt AUTO_LIST
setopt AUTO_MENU
setopt MENU_COMPLETE
setopt GLOB_DOTS
setopt EXTENDED_GLOB

# -----------------------------------------------------------------------------
# 🔐 7. SECRETS
# -----------------------------------------------------------------------------
if [ -f ~/.env.secrets ]; then
  source ~/.env.secrets
fi

# -----------------------------------------------------------------------------
# 🎨 8. SYNTAX HIGHLIGHTING (MUST BE AT THE VERY END)
# -----------------------------------------------------------------------------
if [[ -f "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
