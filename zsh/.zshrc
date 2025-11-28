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

wtc() {
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
    echo "✖ Error: cannot run wtn from a linked worktree. Run it from the main repo."
    return 1
  fi

  echo "• Fetching latest remote refs..."
  if ! git fetch --all --prune --quiet; then
    echo "✖ Error: failed to fetch remote refs"
    return 1
  fi
  echo "✔ Remote refs updated"

  # Determine repo name and safe directory name
  local ROOT_DIR
  ROOT_DIR="$(git rev-parse --show-toplevel)"

  local REPO_NAME
  REPO_NAME="$(basename "$ROOT_DIR")"

  local SAFE_BRANCH="${BRANCH//\//-}"
  local WT_DIR="../${REPO_NAME}-${SAFE_BRANCH}"

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
    if ! git worktree add "$WT_DIR" "$BRANCH"; then
      echo "✖ Error: failed to create worktree"
      return 1
    fi

  else
    echo "• Local branch not found. Checking remote..."
    if git ls-remote --exit-code --heads origin "$BRANCH" >/dev/null 2>&1; then
      echo "ℹ Remote branch exists — creating local tracking branch"
      if ! git worktree add -b "$BRANCH" "$WT_DIR" "origin/$BRANCH"; then
        echo "✖ Error: failed to create worktree from remote branch"
        return 1
      fi
    else
      echo "ℹ Branch does not exist anywhere — creating new branch from origin/main"
      if ! git worktree add -b "$BRANCH" "$WT_DIR" --no-track origin/main; then
        echo "✖ Error: failed to create worktree with new branch"
        return 1
      fi
    fi
  fi

  echo "• Switching into new worktree directory"
  cd "$WT_DIR" || exit

  echo "• Ensuring upstream relationship with remote"
  # Check if branch already has upstream configured
  if git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
    echo "ℹ Upstream already configured"
  else
    if ! git push --set-upstream origin "$BRANCH"; then
      echo "⚠ Warning: failed to set upstream (you may need to push manually)"
    else
      echo "✔ Remote branch created & tracking set"
    fi
  fi

  echo "🎉 Worktree ready at: $WT_DIR"
  echo "🎉 On branch: $BRANCH"
}

# Create new worktree with tmux workspace (nvim + AI CLI)
wtcai() {
  local BRANCH=""
  local AI_CLI="claude"

  # Parse arguments
  for arg in "$@"; do
    if [ "$arg" = "--codex" ]; then
      AI_CLI="codex"
    elif [ "$arg" = "--claude" ]; then
      AI_CLI="claude"
    else
      BRANCH="$arg"
    fi
  done

  # Require branch name
  if [ -z "$BRANCH" ]; then
    echo "✖ Error: branch name required"
    echo "Usage: wtcai <branch-name> [--codex|--claude]"
    return 1
  fi

  # Check if we're in a tmux session
  if [ -z "$TMUX" ]; then
    echo "✖ Error: must be run inside a tmux session"
    return 1
  fi

  echo "▶ Creating new worktree for branch: $BRANCH"

  # Ensure inside a Git repo
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "✖ Error: not inside a git repository"
    return 1
  fi

  # Ensure we are in the primary repo, not another worktree
  if [ -f .git ] && grep -q "gitdir:" .git; then
    echo "✖ Error: cannot run wtcai from a linked worktree. Run it from the main repo."
    return 1
  fi

  echo "• Fetching latest remote refs..."
  if ! git fetch --all --prune --quiet; then
    echo "✖ Error: failed to fetch remote refs"
    return 1
  fi
  echo "✔ Remote refs updated"

  # Determine repo name and safe directory name
  local ROOT_DIR
  ROOT_DIR="$(git rev-parse --show-toplevel)"

  local REPO_NAME
  REPO_NAME="$(basename "$ROOT_DIR")"

  local SAFE_BRANCH="${BRANCH//\//-}"
  local WT_DIR="../${REPO_NAME}-${SAFE_BRANCH}"

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
    if ! git worktree add "$WT_DIR" "$BRANCH"; then
      echo "✖ Error: failed to create worktree"
      return 1
    fi

  else
    echo "• Local branch not found. Checking remote..."
    if git ls-remote --exit-code --heads origin "$BRANCH" >/dev/null 2>&1; then
      echo "ℹ Remote branch exists — creating local tracking branch"
      if ! git worktree add -b "$BRANCH" "$WT_DIR" "origin/$BRANCH"; then
        echo "✖ Error: failed to create worktree from remote branch"
        return 1
      fi
    else
      echo "ℹ Branch does not exist anywhere — creating new branch from origin/main"
      if ! git worktree add -b "$BRANCH" "$WT_DIR" --no-track origin/main; then
        echo "✖ Error: failed to create worktree with new branch"
        return 1
      fi
    fi
  fi

  # Set upstream if needed (don't cd yet, we'll do it in tmux)
  echo "• Ensuring upstream relationship with remote"
  (
    cd "$WT_DIR" || exit
    if git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
      echo "ℹ Upstream already configured"
    else
      if ! git push --set-upstream origin "$BRANCH"; then
        echo "⚠ Warning: failed to set upstream (you may need to push manually)"
      else
        echo "✔ Remote branch created & tracking set"
      fi
    fi
  )

  # Create tmux window and set up workspace
  echo "• Creating tmux workspace..."

  # Get absolute path for the worktree
  local ABS_WT_DIR
  ABS_WT_DIR="$(cd "$WT_DIR" && pwd)"

  # Create new window with branch name and start nvim in it
  tmux new-window -n "$BRANCH" -c "$ABS_WT_DIR" "nvim"

  # Split window vertically (left/right) - this creates the right pane
  tmux split-window -h -c "$ABS_WT_DIR"

  # Send AI CLI to the newly created right pane
  tmux send-keys "$AI_CLI" C-m

  # Focus back on the left pane (nvim)
  tmux select-pane -L

  echo "🎉 Worktree ready at: $ABS_WT_DIR"
  echo "🎉 Tmux window '$BRANCH' created with nvim (left) + $AI_CLI (right)"
}

# Remove worktree and delete branch

wtd() {
  local BRANCH=""
  local FORCE=""

  # Parse arguments to handle --force flag
  for arg in "$@"; do
    if [ "$arg" = "--force" ]; then
      FORCE="--force"
    else
      BRANCH="$arg"
    fi
  done

  # If no branch provided, use fzf to select from worktrees
  if [ -z "$BRANCH" ]; then
    echo "▶ Selecting worktree to delete..."
    local SELECTION
    SELECTION=$(git worktree list | grep -v "(bare)" | fzf --prompt="Delete worktree > " --height=40%)

    if [ -z "$SELECTION" ]; then
      echo "✖ No selection made"
      return 1
    fi

    # Extract branch name from worktree list output
    BRANCH=$(echo "$SELECTION" | awk '{print $NF}' | sed 's/^\[//' | sed 's/\]$//')
    echo "• Selected branch: $BRANCH"
  fi

  echo "▶ Cleaning up worktree + branch: $BRANCH"

  # Find the main repository directory (works from anywhere - main repo or worktree)
  local COMMON_DIR
  COMMON_DIR="$(git rev-parse --git-common-dir 2>/dev/null)"
  if [ -z "$COMMON_DIR" ]; then
    echo "✖ Error: not inside a git repository"
    return 1
  fi

  # Get the main repo root directory
  local ROOT_DIR
  if [[ "$COMMON_DIR" == *"/.git/worktrees/"* ]]; then
    # We're in a worktree, get the main repo location
    ROOT_DIR="$(dirname "$COMMON_DIR")"
  else
    # We're in the main repo
    ROOT_DIR="$(dirname "$COMMON_DIR")"
  fi

  local REPO_NAME
  REPO_NAME="$(basename "$ROOT_DIR")"
  local SAFE_BRANCH="${BRANCH//\//-}"
  local WT_DIR="$ROOT_DIR/../${REPO_NAME}-${SAFE_BRANCH}"

  if [ ! -d "$WT_DIR" ]; then
    echo "✖ Error: worktree directory not found: $WT_DIR"
    echo "ℹ Available worktrees:"
    git worktree list
    return 1
  fi

  # Fetch latest origin/main to ensure accurate merge check
  echo "• Fetching latest origin/main..."
  if ! git fetch origin main:refs/remotes/origin/main --quiet 2>/dev/null; then
    echo "⚠ Warning: failed to fetch origin/main, merge check may be stale"
  fi

  # Check if branch has been merged using GitHub PR status (handles squash merges)
  echo "• Checking PR merge status..."
  local PR_STATE=""
  local OPEN_PR=""
  if command -v gh >/dev/null 2>&1; then
    PR_STATE=$(gh pr list --head "$BRANCH" --state merged --json state --jq '.[0].state' 2>/dev/null)
    OPEN_PR=$(gh pr list --head "$BRANCH" --state open --json number --jq '.[0].number' 2>/dev/null)

    if [ "$PR_STATE" = "MERGED" ]; then
      echo "✓ PR for branch '$BRANCH' has been merged"
    elif [ -n "$OPEN_PR" ] && [ "$OPEN_PR" != "null" ]; then
      if [ "$FORCE" != "--force" ]; then
        echo "✖ Branch '$BRANCH' has an open PR (#$OPEN_PR) that hasn't been merged yet."
        echo "✖ Merge the PR first or run: wtd $BRANCH --force"
        return 1
      fi
      echo "⚠ Force deleting branch with open PR (#$OPEN_PR)"
    else
      # No PR found, fall back to commit-based check
      echo "ℹ No PR found for branch '$BRANCH'"
      if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
        if ! git merge-base --is-ancestor "refs/heads/$BRANCH" origin/main 2>/dev/null; then
          if [ "$FORCE" != "--force" ]; then
            echo "✖ Branch '$BRANCH' has unmerged commits."
            echo "✖ Create/merge a PR or run: wtd $BRANCH --force"
            return 1
          fi
          echo "⚠ Force deleting unmerged branch"
        else
          echo "✓ Branch commits are in origin/main"
        fi
      fi
    fi
  else
    echo "ℹ GitHub CLI not available, skipping PR check"
    # Fall back to commit-based check
    if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
      if ! git merge-base --is-ancestor "refs/heads/$BRANCH" origin/main 2>/dev/null; then
        if [ "$FORCE" != "--force" ]; then
          echo "✖ Branch '$BRANCH' has unmerged commits."
          echo "✖ Install 'gh' CLI for PR-based checks or run: wtd $BRANCH --force"
          return 1
        fi
        echo "⚠ Force deleting unmerged branch"
      fi
    fi
  fi

  echo "• Removing worktree at $WT_DIR"
  if [ "$FORCE" = "--force" ]; then
    if ! git worktree remove --force "$WT_DIR"; then
      echo "✖ Error: failed to remove worktree"
      return 1
    fi
  else
    if ! git worktree remove "$WT_DIR"; then
      echo "✖ Error: failed to remove worktree"
      return 1
    fi
  fi
  echo "✔ Worktree removed"

  echo "• Deleting local branch"
  if ! git branch -D "$BRANCH"; then
    echo "✖ Error: failed to delete local branch"
    return 1
  fi

  echo "• Checking whether remote branch exists..."
  if git ls-remote --exit-code --heads origin "$BRANCH" >/dev/null 2>&1; then
    echo "• Remote found — deleting origin/$BRANCH"
    if ! git push origin --delete "$BRANCH" --quiet; then
      echo "⚠ Warning: failed to delete remote branch (may require manual cleanup)"
    fi
  else
    echo "ℹ No remote branch to delete"
  fi

  echo "• Pruning stale worktree metadata"
  git worktree prune

  echo "🎉 Cleanup complete for '$BRANCH'"
}

# Pick worktree with fzf
#
wtl() {
  echo "▶ Selecting worktree..."

  local SELECTION
  SELECTION=$(git worktree list | fzf --prompt="Worktrees > " | awk '{print $1}')

  if [ -z "$SELECTION" ]; then
    echo "✖ No selection made"
    return 1
  fi

  echo "• Switching to $SELECTION"
  cd "$SELECTION" || exit
  echo "🎉 Now in $(pwd)"
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

f() {
  # Check dependency
  if ! command -v fzf >/dev/null 2>&1; then
    echo "Error: fzf is not installed. Install it first."
    return 1
  fi

  local file
  file="$(fzf)" || return 1
  nvim "$file"
}

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
