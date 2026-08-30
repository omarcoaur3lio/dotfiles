# Modern Modular Neovim Configuration

A clean, fast, and modular Neovim configuration built on top of the Kickstart principles, but heavily refactored for better maintainability and performance.

Unlike traditional setups, this configuration utilizes Neovim's native `vim.pack` system for plugin management, eliminating the need for external package managers like Lazy, Packer, or Plug.

## Directory Structure

The configuration has been split into small, focused modules rather than a single monolithic `init.lua` file. This makes it incredibly easy to find and adjust specific settings.

```text
~/.config/nvim/
├── init.lua                # Main entry point (loads the core modules)
├── lua/
│   ├── options.lua         # Core Neovim settings (e.g., laststatus=3)
│   ├── keymaps.lua         # General keybindings and basic autocommands
│   ├── pack.lua            # vim.pack bootstrap: build hooks + shared `gh()` url helper
│   └── plugins/            # One file per plugin (each does its own vim.pack.add + setup)
│       ├── init.lua           # Plugin loader registry
│       ├── autopairs.lua      # Auto-closing brackets
│       ├── blink-cmp.lua      # Lightning-fast autocomplete engine
│       ├── colorscheme.lua    # UI Theme setup
│       ├── conform.lua        # Formatter (Conform)
│       ├── debug.lua          # DAP configuration for debugging (opt-in, see plugins/init.lua)
│       ├── gitsigns.lua       # Git integration, diffs, and hunk keymaps
│       ├── guess-indent.lua   # Automatic indent detection
│       ├── indent-blankline.lua # Visual indentation guides
│       ├── lint.lua           # Linter (nvim-lint)
│       ├── lspconfig.lua      # Language servers via Mason
│       ├── mini.lua           # Custom statusline, surround tools, and AI text objects
│       ├── neo-tree.lua       # Sidebar file explorer
│       ├── telescope.lua      # Fuzzy finder (files, grep, buffers)
│       ├── todo-comments.lua  # Highlight TODOs and FIXMEs
│       ├── treesitter.lua     # Advanced syntax parsing and highlighting
│       ├── web-devicons.lua   # File icons (nerd font)
│       └── which-key.lua      # Keybinding cheat sheet popups
```

## Key Features & Highlights

- **Native Package Management**: Uses `vim.pack` to fetch and install every plugin -- each `lua/plugins/*.lua` file calls `vim.pack.add` for its own plugin, while `pack.lua` centralizes the shared build-hook logic (e.g. `make` steps after install/update). You can update everything by running `:lua vim.pack.update()` inside Neovim.
- **Global Statusline (`mini.statusline`)**: Configured with a clean, single global statusline (`laststatus=3`). It has been heavily customized to:
  - Display file paths relative to the current workspace.
  - Automatically truncate long Git branch names to keep the UI clean.
  - Hide redundant file size and encoding details.
  - Display modern Nerd Font icons (e.g., custom bug icons for diagnostics).
- **Hardcore Navigation (opt-in)**: A ready-to-use snippet in `keymaps.lua` disables arrow keys in Normal mode to enforce `h`, `j`, `k`, `l` -- commented out by default, uncomment it if you want to force the habit.
- **Modern Completion**: Powered by `blink.cmp`, a robust and extremely fast completion engine.
- **Smart Linting & Formatting**: Uses `conform.nvim` for auto-formatting on save (e.g., Prettier for JS/TS) and `nvim-lint` for asynchronous linting.

## Prerequisites

To get the most out of this configuration, ensure you have the following installed on your system:

1. **Neovim** (v0.12+ required -- this config uses the native `vim.pack` plugin manager)
2. **Git** (Required by `vim.pack` to clone plugins)
3. **Nerd Fonts** (Essential for icons in the statusline, Neo-tree, and Telescope. e.g., FiraCode Nerd Font)
4. **Ripgrep (`rg`)** (Required for Telescope's live grep functionality)
5. **Node.js & NPM** (Required by Mason for many Language Servers, and for `markdownlint`/`eslint` used in `plugins/lint.lua`)
6. **`unzip`** (Required by Mason to unpack most of the tools it installs)
7. **C Compiler & `make`** (For compiling `telescope-fzf-native` and running the build hooks in `pack.lua`)

## Important Custom Keymaps

Most plugins are mapped using the `<leader>` key (mapped to `Space`).
If you forget a shortcut, simply press `<Space>` and wait a moment for the `which-key` menu to appear.

*   `<leader>s...` - Search (Files, Grep, Help) via Telescope
*   `<leader>f` - Format the current buffer
*   `<leader>g...` - Git actions (via Gitsigns)
*   `za` - Toggle code folds (Native Neovim folding)

## Modifying the Config

Because the setup is fully modular, expanding it is trivial:
- **Add a new plugin**: Create `lua/plugins/my-plugin.lua` and add `require 'plugins.my-plugin'` inside `lua/plugins/init.lua`.
- **Tweak the theme**: Edit `lua/plugins/colorscheme.lua`.
- **Modify statusline icons**: Check out the custom overrides in `lua/plugins/mini.lua`.
