# ~/.zshrc

# -----------------------------------------------------------------------------
# ⚡ CORE UTILITIES & CACHING SYSTEM (For instant startup)
# -----------------------------------------------------------------------------
# Function to load a cached command or generate it if missing/outdated
cache_eval() {
  local cache_name="$1"
  local gen_cmd="$2"
  local binary="$3"
  local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
  local cache_file="${cache_dir}/${cache_name}.zsh"
  local binary_path
  binary_path=$(whence -p "$binary")

  if [[ ! -f "$cache_file" || ( -n "$binary_path" && "$binary_path" -nt "$cache_file" ) ]]; then
    mkdir -p "$cache_dir"
    eval "$gen_cmd" > "$cache_file" 2>/dev/null
  fi
  source "$cache_file"
}

# -----------------------------------------------------------------------------
# 🍺 1. HOMEBREW (Must be first to set up base PATH and $HOMEBREW_PREFIX)
# -----------------------------------------------------------------------------
if [[ -x "/opt/homebrew/bin/brew" ]]; then
  cache_eval "brew_env" "/opt/homebrew/bin/brew shellenv" "/opt/homebrew/bin/brew"
elif [[ -x "/usr/local/bin/brew" ]]; then
  cache_eval "brew_env" "/usr/local/bin/brew shellenv" "/usr/local/bin/brew"
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
KEYTIMEOUT=1  # 10ms — eliminates Esc lag without breaking arrow/function key sequences
bindkey -v  # vi mode: Esc = normal, i/a/A/I = insert, hjkl = move (normal), 0/$ = line start/end
            # In normal mode: w/b = word forward/back, d$/D = delete to end, cc = change line
            # History: Up/Down arrow works in both modes; Ctrl+R for fuzzy history search

# Cursor shape: beam in insert mode, block in normal mode
function zle-keymap-select {
  case $KEYMAP in
    vicmd)      echo -ne '\e[2 q' ;;  # steady block
    viins|main) echo -ne '\e[6 q' ;;  # steady bar
  esac
}
zle -N zle-keymap-select

function zle-line-init { echo -ne '\e[6 q' }  # start each prompt in insert mode (bar cursor)
zle -N zle-line-init

bindkey '^?' backward-delete-char  # fix backspace in vi mode
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
cache_eval "zoxide_init" "zoxide init zsh" "zoxide"
cache_eval "fzf_init" "fzf --zsh" "fzf"

# Starship Prompt
cache_eval "starship_init" "starship init zsh" "starship"

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
# We use extended glob to find if the file is older than 24 hours.
setopt EXTENDED_GLOB
local -a compdump_files
compdump_files=( ~/.config/zsh/.zcompdump(#qN.mh+24) )

if [[ ! -f ~/.config/zsh/.zcompdump ]] || (( ${#compdump_files} )); then
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
unsetopt MENU_COMPLETE
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

# bun completions
[ -s "/Users/jeff/.bun/_bun" ] && source "/Users/jeff/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"


# Antigravity CLI
export PATH="/Users/jeff/.local/bin:$PATH"
