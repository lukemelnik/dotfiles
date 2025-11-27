export TERM=xterm-256color
# ---------------------------
# History
# ---------------------------
HISTFILE=$HOME/.zsh_history
SAVEHIST=1000
HISTSIZE=1000
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_reduce_blanks
setopt hist_verify
setopt inc_append_history

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
# Completion System
# ---------------------------
autoload -Uz compinit
compinit

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

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

# --------------------------
# Git
# --------------------------

# Create new worktree w/ branch name, set upstream on remote 
#
wt-new() {
  local BRANCH="$1"

  # require branch name
  if [ -z "$BRANCH" ]; then
    echo "Error: branch name required"
    return 1
  fi

  # ensure in a git repo
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Error: not inside a git repository"
    return 1
  fi

  # ensure in primary repo, not a linked worktree
  if [ -f .git ] && grep -q "gitdir:" .git; then
    echo "Error: cannot run wt-new from a linked worktree"
    return 1
  fi

  git fetch --all --prune --quiet

  local ROOT_DIR
  ROOT_DIR="$(git rev-parse --show-toplevel)"
  local REPO_NAME
  REPO_NAME="$(basename "$ROOT_DIR")"
  local WT_DIR="../${REPO_NAME}-${BRANCH}"

  # ensure no existing worktree dir
  if [ -e "$WT_DIR" ]; then
    echo "Error: worktree directory already exists: $WT_DIR"
    return 1
  fi

  # create worktree and branch based on origin/main
  git worktree add -b "$BRANCH" "$WT_DIR" origin/main

  # switch into worktree
  cd "$WT_DIR" || exit

  # automatically create remote branch + tracking
  git push --set-upstream --quiet origin "$BRANCH"

  echo "✔ Worktree created at $WT_DIR"
  echo "✔ Branch '$BRANCH' now tracks 'origin/$BRANCH'"
  echo "✔ You are now inside the new worktree"
}
# Remove worktree and delete branch
wt-done() {
  local BRANCH="$1"

  if [ -z "$BRANCH" ]; then
    echo "Error: branch name required"
    return 1
  fi

  local ROOT_DIR
  ROOT_DIR=$(git rev-parse --show-toplevel)
  local REPO_NAME
  REPO_NAME=$(basename "$ROOT_DIR")
  local WT_DIR="../${REPO_NAME}-${BRANCH}"

  # Ensure the worktree directory exists
  if [ ! -d "$WT_DIR" ]; then
    echo "Error: worktree directory $WT_DIR not found"
    return 1
  fi

  git worktree remove "$WT_DIR"
  git branch -D "$BRANCH"
  git push origin --delete "$BRANCH"
  git worktree prune
  echo "✔ Removed $WT_DIR and branch $BRANCH"
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

# NVM (lazy-loaded for performance)
export NVM_DIR="$HOME/.nvm"
nvm() {
    unset -f nvm
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    nvm "$@"
}

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
