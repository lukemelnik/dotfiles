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

alias gwl="git worktree list"

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

wt-new() {
  local BRANCH="$1"

  echo "▶ Creating new worktree for branch: $BRANCH"

  # Require branch name
  if [ -z "$BRANCH" ]; then
    echo "✖ Error: branch name required"
    return 1
  fi

  # Ensure inside a Git repo
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "✖ Error: not inside a git repository"
    return 1
  fi

  # Ensure we are in the primary repo, not another worktree
  if [ -f .git ] && grep -q "gitdir:" .git; then
    echo "✖ Error: cannot run wt-new from a linked worktree. Run it from the main repo."
    return 1
  fi

  echo "• Fetching latest remote refs..."
  git fetch --all --prune --quiet
  echo "✔ Remote refs updated"

  local ROOT_DIR
  ROOT_DIR="$(git rev-parse --show-toplevel)"
  local REPO_NAME
  REPO_NAME="$(basename "$ROOT_DIR")"
  local WT_DIR="../${REPO_NAME}-${BRANCH}"

  # Ensure no conflicting directory already exists
  if [ -e "$WT_DIR" ]; then
    echo "✖ Error: worktree directory already exists: $WT_DIR"
    return 1
  fi

  echo "• Checking if branch '$BRANCH' exists locally..."
  if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
    echo "ℹ Local branch exists"

    # Check if it's active in another worktree
    if git worktree list | grep -q "$BRANCH"; then
      echo "✖ Branch '$BRANCH' is already checked out in another worktree"
      return 1
    fi

    echo "• Creating worktree from existing local branch"
    git worktree add "$WT_DIR" "$BRANCH"

  else
    echo "• Local branch not found. Checking remote..."
    if git ls-remote --exit-code --heads origin "$BRANCH" >/dev/null 2>&1; then
      echo "ℹ Remote branch exists — creating local tracking branch"
      git worktree add -b "$BRANCH" "$WT_DIR" "origin/$BRANCH"
    else
      echo "ℹ Branch does not exist anywhere — creating new branch from origin/main"
      git worktree add -b "$BRANCH" "$WT_DIR" origin/main
    fi
  fi

  echo "• Switching into new worktree directory"
  cd "$WT_DIR" || exit

  echo "• Ensuring upstream relationship with remote"
  if git ls-remote --exit-code --heads origin "$BRANCH" >/dev/null 2>&1; then
    echo "ℹ Remote already exists — upstream assumed established"
  else
    git push --set-upstream --quiet origin "$BRANCH"
    echo "✔ Remote branch created & tracking set"
  fi

  echo "🎉 Worktree ready at: $WT_DIR"
  echo "🎉 On branch: $BRANCH"
}
# Remove worktree and delete branch

wt-done() {
  local BRANCH="$1"

  echo "▶ Cleaning up worktree + branch: $BRANCH"

  if [ -z "$BRANCH" ]; then
    echo "✖ Error: branch name required"
    return 1
  fi

  local ROOT_DIR
  ROOT_DIR="$(git rev-parse --show-toplevel)"
  local REPO_NAME
  REPO_NAME="$(basename "$ROOT_DIR")"
  local WT_DIR="../${REPO_NAME}-${BRANCH}"

  if [ ! -d "$WT_DIR" ]; then
    echo "✖ Error: worktree directory not found: $WT_DIR"
    return 1
  fi

  echo "• Removing worktree at $WT_DIR"
  git worktree remove "$WT_DIR"
  echo "✔ Worktree directory removed"

  echo "• Deleting local branch '$BRANCH'"
  git branch -D "$BRANCH"
  echo "✔ Local branch deleted"

  echo "• Checking whether remote branch exists..."
  if git ls-remote --exit-code --heads origin "$BRANCH" >/dev/null 2>&1; then
    echo "• Remote branch found — deleting origin/$BRANCH"
    git push origin --delete "$BRANCH" --quiet
    echo "✔ Remote branch deleted"
  else
    echo "ℹ No remote branch to delete"
  fi

  echo "• Pruning stale worktree references"
  git worktree prune
  echo "✔ Completed pruning"

  echo "🎉 Cleanup complete for branch '$BRANCH'"
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
