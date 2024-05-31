#!/bin/sh

echo "Installing Homebrew..."
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
echo "eval \"$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"" >>~/.bashrc

echo "Installing Homebrew packages..."
brew install gcc neovim ripgrep fd lazygit zoxide eza

echo "Installing LazyVim(https://www.lazyvim.org/installation)..."
echo "Backing up current Neovim config..."
mv ~/.config/nvim{,.bak}
mv ~/.local/share/nvim{,.bak}
mv ~/.local/state/nvim{,.bak}
mv ~/.cache/nvim{,.bak}
echo "Cloning LazyVim starter..."
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

echo "Setting up Treesitter for Neovim(https://www.lazyvim.org/configuration/examples)..."
cat >~/.config/nvim/lua/plugins/treesitter.lua <<EOF
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- add tsx and treesitter
      vim.list_extend(opts.ensure_installed, {
        "go",
      })
    end,
  },
}
EOF

echo "Setting up LSP for Neovim(https://lsp-zero.netlify.app/v3.x/getting-started.html)..."
cat >~/.config/nvim/lua/plugins/lsp.lua <<EOF
return {
  --- Uncomment the two plugins below if you want to manage the language servers from neovim
  {'williamboman/mason.nvim'},
  {'williamboman/mason-lspconfig.nvim'},

  {'VonHeikemen/lsp-zero.nvim', branch = 'v3.x'},
  {'neovim/nvim-lspconfig'},
  {'hrsh7th/cmp-nvim-lsp'},
  {'hrsh7th/nvim-cmp'},
  {'L3MON4D3/LuaSnip'},
}
EOF

echo "Setting up Go for Neovim(https://github.com/ray-x/go.nvim)..."
cat >~/.config/nvim/lua/plugins/go.lua <<EOF
return {
  {
    "ray-x/go.nvim",
    dependencies = {  -- optional packages
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("go").setup()
    end,
    event = {"CmdlineEnter"},
    ft = {"go", 'gomod'},
    build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
  },
}
EOF
# https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
echo 'require("lspconfig").gopls.setup({})' >>~/.config/nvim/init.lua
cat >>~/.config/nvim/init.lua <<EOF
-- Run gofmt on save

local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    require('go.format').gofmt()
  end,
  group = format_sync_grp,
})
EOF

echo "Setting up tab autocompletion for Neovim(https://www.lazyvim.org/configuration/examples)..."
cat >~/.config/nvim/lua/plugins/completion.lua <<EOF
return {
  -- Use <tab> for completion and snippets (supertab)
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-emoji",
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local cmp = require("cmp")

      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif vim.snippet.active({ direction = 1 }) then
            vim.schedule(function()
              vim.snippet.jump(1)
            end)
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif vim.snippet.active({ direction = -1 }) then
            vim.schedule(function()
              vim.snippet.jump(-1)
            end)
          else
            fallback()
          end
        end, { "i", "s" }),
      })
    end,
  },
}
EOF

echo "Setting up line wrapping for Neovim(https://github.com/andrewferrier/wrapping.nvim)..."
cat >~/.config/nvim/lua/plugins/wrapping.lua <<EOF
return {
  {
    "andrewferrier/wrapping.nvim",
    config = function()
      require("wrapping").setup()
    end
  },
}
EOF

echo "Setting up ~/.bashrc..."
echo "export nvim=/home/linuxbrew/.linuxbrew/bin/nvim" >>~/.bashrc
echo "eval \"$(zoxide init bash)\"" >>~/.bashrc

echo "Done..."
