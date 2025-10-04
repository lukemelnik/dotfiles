export TERM=xterm-256color
# ---------------------------
# History
# ---------------------------
HISTFILE=$HOME/.zsh_history
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# ---------------------------
# Plugins
# ---------------------------
# zsh-autosuggestions
if [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# zsh-syntax-highlighting
if [ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# ---------------------------
# Autosuggestions keybindings
# ---------------------------

# Accept the whole suggestion with Ctrl-F
bindkey -M viins '^F' autosuggest-accept

# Accept a single word with Ctrl-W
bindkey -M viins '^W' autosuggest-accept-word


# ---------------------------
# Force claude to use bash so it doesn't error with zoxide alias
# ---------------------------
claude() {
  SHELL=/bin/bash command claude "$@"
}

# ---------------------------
# Aliases
# ---------------------------
alias py='python3'
alias lg='lazygit'
alias n='nvim'
alias cat='bat'
alias zc='nvim ~/.zshrc'
alias sz='source ~/.zshrc'
alias nc='cd ~/.config/nvim && nvim'
alias gc='nvim ~/.config/ghostty/config'
alias on='cd ~/iawriter/ && nvim'
alias ac='nvim ~/.config'
alias cd='z'
alias tns="tmux new-session -s"

alias le="eza --icons -a"
alias lt="eza --tree"
alias ll="eza --long"
alias leo="eza --oneline --icons --hyperlink"

# ---------------------------
# Functions
# ---------------------------
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}

# ---------------------------
# Editor
# ---------------------------
if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
else
    export EDITOR='nvim'
fi

export NVIM_TUI_ENABLE_TRUE_COLOR=1

# ---------------------------
# PATHs
# ---------------------------
# PostgreSQL (if installed)
if [ -d "/Library/PostgreSQL/16/bin" ]; then
    export PATH="/Library/PostgreSQL/16/bin:$PATH"
fi

# NVM
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

# Local binaries
export PATH="$HOME/.local/bin:$PATH"

# ---------------------------
# Extra tools
# ---------------------------
if command -v thefuck >/dev/null 2>&1; then
    eval $(thefuck --alias)
fi

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# ---------------------------
# TMUX and keybindings
# ---------------------------
bindkey -v
bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward

# ---------------------------
# Prompt: Starship
# ---------------------------
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi
