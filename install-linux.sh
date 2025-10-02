#!/bin/bash

set -e

echo "🚀 Installing dotfiles and packages..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Detect package manager
if command -v apt &> /dev/null; then
    PKG_MANAGER="apt"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
else
    echo "❌ Unsupported package manager. This script supports apt (Debian/Ubuntu) or dnf (Fedora/RHEL)"
    exit 1
fi

# Update package lists
echo -e "${BLUE}Updating package lists...${NC}"
if [ "$PKG_MANAGER" = "apt" ]; then
    sudo apt update
fi

# Install packages available via system package manager
echo -e "${BLUE}Installing system packages...${NC}"
if [ "$PKG_MANAGER" = "apt" ]; then
    sudo apt install -y \
        zsh \
        git \
        curl \
        wget \
        gpg \
        stow \
        tmux \
        fzf \
        ripgrep \
        fd-find \
        bat \
        tree \
        jq \
        nmap \
        ffmpeg \
        unzip \
        build-essential

    # Create symlinks for fd and bat (Debian uses different names)
    mkdir -p ~/.local/bin
    ln -sf $(which fdfind) ~/.local/bin/fd 2>/dev/null || true
    ln -sf $(which batcat) ~/.local/bin/bat 2>/dev/null || true

elif [ "$PKG_MANAGER" = "dnf" ]; then
    sudo dnf install -y \
        zsh \
        git \
        curl \
        wget \
        stow \
        tmux \
        fzf \
        ripgrep \
        fd-find \
        bat \
        tree \
        jq \
        nmap \
        ffmpeg \
        unzip \
        gcc \
        gcc-c++ \
        make
fi

# Install latest Neovim (apt version is too old for LazyVim)
if ! command -v nvim &> /dev/null || [[ $(nvim --version | head -n1 | grep -oP '\d+\.\d+' | head -n1) < "0.9" ]]; then
    echo -e "${BLUE}Installing latest Neovim...${NC}"
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    sudo rm -rf /opt/nvim-linux-x86_64
    sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
    rm nvim-linux-x86_64.tar.gz

    # Add to PATH in zshrc if not already there
    if ! grep -q '/opt/nvim-linux-x86_64/bin' ~/.zshrc 2>/dev/null; then
        echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> ~/.zshrc
    fi
fi

# Install eza
if ! command -v eza &> /dev/null; then
    echo -e "${BLUE}Installing eza...${NC}"
    if [ "$PKG_MANAGER" = "apt" ]; then
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt update
        sudo apt install -y eza
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        sudo dnf install -y eza
    fi
fi

# Install zoxide via install script (pre-built binary)
if ! command -v zoxide &> /dev/null; then
    echo -e "${BLUE}Installing zoxide...${NC}"
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# Install GitHub CLI
if ! command -v gh &> /dev/null; then
    echo -e "${BLUE}Installing GitHub CLI...${NC}"
    if [ "$PKG_MANAGER" = "apt" ]; then
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
        sudo apt install -y gh
    elif [ "$PKG_MANAGER" = "dnf" ]; then
        sudo dnf install -y gh
    fi
fi

# Install pnpm
if ! command -v pnpm &> /dev/null; then
    echo -e "${BLUE}Installing pnpm...${NC}"
    curl -fsSL https://get.pnpm.io/install.sh | sh -
fi

# Install Node.js via nvm (more flexible than system package)
if ! command -v node &> /dev/null; then
    echo -e "${BLUE}Installing Node.js via nvm...${NC}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
fi

# Install lazygit
if ! command -v lazygit &> /dev/null; then
    echo -e "${BLUE}Installing lazygit...${NC}"
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    rm lazygit lazygit.tar.gz
fi

# Install zsh-autosuggestions
if [ ! -d "$HOME/.zsh/zsh-autosuggestions" ]; then
    echo -e "${BLUE}Installing zsh-autosuggestions...${NC}"
    mkdir -p ~/.zsh
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
fi

# Install TPM (Tmux Plugin Manager)
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo -e "${BLUE}Installing TPM (Tmux Plugin Manager)...${NC}"
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Stow dotfiles
echo -e "${BLUE}Stowing dotfiles...${NC}"
cd ~/dotfiles
stow .config

# Install tmux plugins non-interactively
if [ -f "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
    echo -e "${BLUE}Installing tmux plugins...${NC}"
    ~/.tmux/plugins/tpm/bin/install_plugins || echo "Skipping tmux plugins (run manually in tmux with prefix + I)"
fi

# Add ~/.local/bin to PATH if not already there
if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' ~/.zshrc 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
fi

# Change default shell to zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    echo -e "${BLUE}Changing default shell to zsh...${NC}"
    # Add zsh to /etc/shells if not there
    if ! grep -q "$(which zsh)" /etc/shells; then
        which zsh | sudo tee -a /etc/shells
    fi
    chsh -s $(which zsh)
fi

echo -e "${GREEN}✅ Installation complete!${NC}"
echo -e "${GREEN}Please log out and log back in for shell change to take effect.${NC}"
