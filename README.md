# Instructions

---

## Dotfiles Install

---

1. Install packages (includes stow)

```bash
cd ~ && git clone git@github.com:lukemelnik/dotfiles.git
cd ~/dotfiles
brew bundle
```

2. Backup/remove any existing configs that might conflict

```bash
# Check what exists
ls -la ~/.config

# Backup if needed
mv ~/.config/nvim ~/.config/nvim.backup
mv ~/.config/ghostty ~/.config/ghostty.backup
# ... etc
```

3. Symlink dotfiles (directories only)

```bash
cd ~/dotfiles && stow */
```

4. Restart your terminal or source your shell config

---

## To update Brewfile

---

### Adding new programs

1. Install new program

```bash
brew install newtool
```

2. Update Brewfile

```bash
cd ~/dotfiles
brew bundle dump --force
```

3. Commit and push

```bash
git add Brewfile
git commit -m "add newtool"
git push
```

4. On other machine, pull and install

```bash
cd ~/dotfiles
git pull
brew bundle check --verbose  # Optional: see what will be installed
brew bundle
```

### Removing programs

1. Uninstall program

```bash
brew uninstall oldtool
```

2. Update Brewfile

```bash
cd ~/dotfiles
brew bundle dump --force
```

3. Commit and push

```bash
git add Brewfile
git commit -m "remove oldtool"
git push
```

4. On other machine, pull and cleanup

```bash
cd ~/dotfiles
git pull
brew bundle cleanup  # This uninstalls packages not in Brewfile
```
