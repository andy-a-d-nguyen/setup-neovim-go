#!/bin/sh

echo "Installing Homebrew..."
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >>~/.bashrc

echo "Installing Homebrew packages..."
brew install gcc neovim ripgrep lazygit gitui zoxide eza yazi ffmpegthumbnailer unar jq poppler fd fzf bat jesseduffield/lazydocker/lazydocker

echo "Installing LazyVim(https://www.lazyvim.org/installation)..."
echo "Backing up current Neovim config..."
mv ~/.config/nvim{,.bak}
mv ~/.local/share/nvim{,.bak}
mv ~/.local/state/nvim{,.bak}
mv ~/.cache/nvim{,.bak}
echo "Cloning LazyVim starter..."
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

echo "Setting up ~/.bashrc..."
echo "export PATH=${PATH}:/home/linuxbrew/.linuxbrew/bin/nvim" >>~/.bashrc
echo "eval $(zoxide init bash)" >>~/.bashrc

echo "Setting up LazyVim"
cat >~/.config/nvim/lazyvim.json <<EOF
{
  "extras": [
    "lazyvim.plugins.extras.coding.mini-surround",
    "lazyvim.plugins.extras.coding.yanky",
    "lazyvim.plugins.extras.dap.core",
    "lazyvim.plugins.extras.editor.fzf",
    "lazyvim.plugins.extras.editor.outline",
    "lazyvim.plugins.extras.editor.refactoring",
    "lazyvim.plugins.extras.lang.git",
    "lazyvim.plugins.extras.lang.go",
    "lazyvim.plugins.extras.lang.json",
    "lazyvim.plugins.extras.lang.markdown",
    "lazyvim.plugins.extras.lang.ruby",
    "lazyvim.plugins.extras.lang.toml",
    "lazyvim.plugins.extras.lang.yaml",
    "lazyvim.plugins.extras.test.core",
    "lazyvim.plugins.extras.ui.mini-indentscope",
    "lazyvim.plugins.extras.ui.treesitter-context",
    "lazyvim.plugins.extras.util.dot",
    "lazyvim.plugins.extras.util.gitui",
    "lazyvim.plugins.extras.util.project"
  ],
  "news": {
    "NEWS.md": "6077"
  },
  "version": 6
}
EOF

mkdir -p ~/.config/yazi
cat >~/.config/yazi/yazi.toml <<EOF
[opener]
edit = [{ run = 'nvim "$@"', block = true }]
EOF

eval "$(fzf --bash)"
source <(fzf --zsh)
eval $(cat ~/.bashrc)
echo "Done..."
