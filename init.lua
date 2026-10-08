-- ~/.config/nvim/init.lua
-- Requires Neovim 0.12+ (uses the built-in plugin manager, vim.pack).
-- External tools: git, node (for coc.nvim), ripgrep (for text search),
-- tree-sitter CLI + a C compiler (for syntax parsers).

-- =============================================================================
-- 1. Leader key
-- =============================================================================
-- Must be set before any mapping that uses <leader>.
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

-- =============================================================================
-- 2. Options
-- =============================================================================
local opt = vim.opt

-- Look
opt.number = true            -- line numbers
-- opt.relativenumber = true -- uncomment once you start using counts (5j, 3dd)
opt.cursorline = true        -- highlight the current line
opt.colorcolumn = '80'       -- guide at column 80
opt.signcolumn = 'yes'       -- always reserve the diagnostics column
opt.scrolloff = 5            -- keep 5 lines visible above/below the cursor
opt.showmode = false         -- the statusline already shows the mode
opt.title = true             -- file name in the terminal title
opt.list = true              -- make stray whitespace visible
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Editing
opt.expandtab = true         -- spaces instead of tabs
opt.shiftwidth = 2           -- 2 spaces per indent level (web convention)
opt.softtabstop = 2
opt.undofile = true          -- undo history survives closing the file
opt.clipboard = 'unnamedplus' -- yank/paste use the system clipboard
opt.mouse = 'a'
opt.confirm = true           -- ask to save instead of failing on :q

-- Search
opt.ignorecase = true        -- case-insensitive...
opt.smartcase = true         -- ...unless the pattern contains a capital
opt.inccommand = 'split'     -- live preview of :s substitutions

-- Windows
opt.splitbelow = true
opt.splitright = true

-- Recommended by coc.nvim
opt.updatetime = 300         -- faster hover highlights and diagnostics
opt.backup = false           -- some language servers break on backup files
opt.writebackup = false

-- nvim-tree replaces the built-in file browser (netrw)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- =============================================================================
-- 3. Plugins (vim.pack)
-- =============================================================================
-- Install: happens automatically on first start (asks once for confirmation).
-- Update:  :lua vim.pack.update()   then :write to accept, :quit to cancel.
-- Remove:  delete the line below, restart, :lua vim.pack.del({ 'name' })

-- Language extensions coc.nvim installs by itself on first start.
vim.g.coc_global_extensions = {
  'coc-tsserver', -- JavaScript / TypeScript
  'coc-html',
  'coc-css',
  'coc-json',
  'coc-eslint',   -- only active in projects that have an ESLint config
  'coc-prettier', -- formatter
  'coc-emmet',    -- HTML/CSS abbreviations (ul>li*3 + Tab)
  'coc-pairs',    -- auto-close brackets and quotes
}

-- Re-sync syntax parsers whenever nvim-treesitter itself is updated.
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    if ev.data.spec.name == 'nvim-treesitter' and ev.data.kind == 'update' then
      if not ev.data.active then vim.cmd.packadd('nvim-treesitter') end
      pcall(vim.cmd, 'TSUpdate')
    end
  end,
})

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add({
	{ src = gh('catppuccin/nvim'), name = 'catppuccin' }, -- colorscheme
  gh('nvim-tree/nvim-web-devicons'),                   -- file icons
  gh('nvim-lualine/lualine.nvim'),                     -- statusline + buffer bar
  gh('nvim-tree/nvim-tree.lua'),                       -- file tree
  gh('nvim-lua/plenary.nvim'),                         -- library used by telescope
  gh('nvim-telescope/telescope.nvim'),                 -- fuzzy finder
  gh('folke/which-key.nvim'),                          -- keybinding hints
  gh('nvim-treesitter/nvim-treesitter'),               -- syntax parsers
  { src = gh('neoclide/coc.nvim'), version = 'release' }, -- code intelligence
  gh('tpope/vim-fugitive'),                            -- git
})

-- =============================================================================
-- 4. Plugin setup
-- =============================================================================

-- Colorscheme -----------------------------------------------------------------
require('catppuccin').setup({
  flavour = 'auto',  -- latte, frappe, macchiato, mocha
  background = { light = 'latte', dark = 'macchiato' }, -- :set background=light / dark
  term_colors = true,
  styles = {
    comments = { 'italic' },
    conditionals = {},
  },
  lsp_styles = {
    underlines = {
      errors = { 'undercurl' },
      warnings = { 'undercurl' },
      hints = { 'underline' },
      information = { 'underline' },
    },
  },
})
vim.cmd.colorscheme('catppuccin')

-- Statusline and buffer bar ---------------------------------------------------
require('lualine').setup({
  options = { theme = 'auto', globalstatus = true },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', { 'diagnostics', sources = { 'coc' } } },
    lualine_c = { { 'filename', path = 1 }, 'g:coc_status' },
    lualine_x = { 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
  tabline = {
    lualine_a = { { 'buffers', symbols = { alternate_file = '' } } },
  },
  extensions = { 'nvim-tree', 'fugitive' },
})

-- File tree -------------------------------------------------------------------
require('nvim-tree').setup({
  view = { width = 32 },
  filters = { dotfiles = false },                    -- show hidden files
  actions = { open_file = { quit_on_open = true } }, -- close tree after opening
})

-- Fuzzy finder ----------------------------------------------------------------
require('telescope').setup({})

-- Keybinding hints ------------------------------------------------------------
local wk = require('which-key')
wk.setup({})
wk.add({
  { '<leader>f', group = 'find' },
  { '<leader>b', group = 'buffer' },
  { '<leader>c', group = 'code' },
  { '<leader>g', group = 'git' },
})

-- Treesitter ------------------------------------------------------------------
-- Parsers are compiled locally, which needs the tree-sitter CLI. Without it
-- this block is skipped and Neovim falls back to its regex highlighting.
if vim.fn.executable('tree-sitter') == 1 then
  require('nvim-treesitter').install({
    'javascript', 'typescript', 'tsx', 'jsdoc',
    'html', 'css', 'scss', 'json', 'yaml', 'toml',
    'markdown', 'markdown_inline',
    'lua', 'vim', 'vimdoc', 'bash',
    'gitcommit', 'diff',
  })
end

-- Use treesitter highlighting for every filetype that has a parser.
vim.api.nvim_create_autocmd('FileType', {
  callback = function() pcall(vim.treesitter.start) end,
})

-- =============================================================================
-- 5. Autocommands
-- =============================================================================

-- Spell check prose only, not code.
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'markdown', 'text', 'gitcommit' },
  callback = function() vim.opt_local.spell = true end,
})

-- Flash the text that was just yanked.
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function() vim.hl.on_yank() end,
})

-- Highlight other occurrences of the symbol under the cursor.
vim.api.nvim_create_autocmd('CursorHold', {
  command = "silent! call CocActionAsync('highlight')",
})

-- =============================================================================
-- 6. Key mappings
-- =============================================================================
local map = vim.keymap.set

-- General ---------------------------------------------------------------------
map('n', '<leader>w', '<cmd>write<cr>', { desc = 'Save file' })
map('n', '<leader>q', '<cmd>quit<cr>', { desc = 'Close window' })
map('n', '<Esc>', '<cmd>nohlsearch<cr>', { desc = 'Clear search highlight' })
map('n', '<leader>?', function() wk.show({ global = false }) end,
  { desc = 'Keys for this buffer' })

-- Windows (splits) ------------------------------------------------------------
map('n', '<C-h>', '<C-w>h', { desc = 'Window left' })
map('n', '<C-j>', '<C-w>j', { desc = 'Window down' })
map('n', '<C-k>', '<C-w>k', { desc = 'Window up' })
map('n', '<C-l>', '<C-w>l', { desc = 'Window right' })

-- Buffers ---------------------------------------------------------------------
-- ]b and [b (next/previous buffer) are built into Neovim.
map('n', '<leader>bd', '<cmd>bdelete<cr>', { desc = 'Close buffer' })

-- File tree -------------------------------------------------------------------
map('n', '<leader>e', '<cmd>NvimTreeToggle<cr>', { desc = 'File tree' })
map('n', '<leader>E', '<cmd>NvimTreeFindFile<cr>', { desc = 'Show file in tree' })

-- Find (telescope) ------------------------------------------------------------
local tb = require('telescope.builtin')
map('n', '<leader>ff', tb.find_files, { desc = 'Files' })
map('n', '<leader>fg', tb.live_grep, { desc = 'Text in project (grep)' })
map('n', '<leader>fb', tb.buffers, { desc = 'Open buffers' })
map('n', '<leader>fr', tb.oldfiles, { desc = 'Recent files' })
map('n', '<leader>fh', tb.help_tags, { desc = 'Help' })
map('n', '<leader>fk', tb.keymaps, { desc = 'Keymaps' })

-- Git (fugitive) --------------------------------------------------------------
map('n', '<leader>gs', '<cmd>Git<cr>', { desc = 'Status' })
map('n', '<leader>gd', '<cmd>Gdiffsplit<cr>', { desc = 'Diff this file' })
map('n', '<leader>gb', '<cmd>Git blame<cr>', { desc = 'Blame' })

-- Completion menu (coc.nvim) --------------------------------------------------
function _G.check_back_space()
  local col = vim.fn.col('.') - 1
  return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

local expr = { silent = true, noremap = true, expr = true, replace_keycodes = false }
-- The first suggestion is always pre-selected. Tab or Enter accepts it,
-- Ctrl-n / Ctrl-p (or the arrow keys) move, Ctrl-e closes the menu,
-- Ctrl-Space opens it manually.
map('i', '<Tab>',
  'coc#pum#visible() ? coc#pum#confirm() : v:lua.check_back_space() ? "<Tab>" : coc#refresh()',
  expr)
map('i', '<CR>',
  [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<C-r>=coc#on_enter()\<CR>"]],
  expr)
map('i', '<C-Space>', 'coc#refresh()', { silent = true, expr = true })

-- Code navigation (coc.nvim) --------------------------------------------------
-- Same keys Neovim uses for its own LSP client (gr*, K, [d, ]d), pointed at coc.
map('n', 'gd', '<Plug>(coc-definition)', { desc = 'Go to definition' })
map('n', 'grr', '<Plug>(coc-references)', { desc = 'References' })
map('n', 'gri', '<Plug>(coc-implementation)', { desc = 'Implementation' })
map('n', 'grt', '<Plug>(coc-type-definition)', { desc = 'Type definition' })
map('n', 'grn', '<Plug>(coc-rename)', { desc = 'Rename symbol' })
map('n', 'gra', '<Plug>(coc-codeaction-cursor)', { desc = 'Code action' })
map('x', 'gra', '<Plug>(coc-codeaction-selected)', { desc = 'Code action' })
map('n', '[d', '<Plug>(coc-diagnostic-prev)', { desc = 'Previous diagnostic' })
map('n', ']d', '<Plug>(coc-diagnostic-next)', { desc = 'Next diagnostic' })

-- K: documentation for the symbol under the cursor.
map('n', 'K', function()
  if vim.tbl_contains({ 'vim', 'help' }, vim.bo.filetype) then
    vim.cmd.help(vim.fn.expand('<cword>'))
  elseif vim.fn.exists('*CocActionAsync') == 1 and vim.fn['coc#rpc#ready']() then
    vim.fn.CocActionAsync('doHover')
  else
    vim.cmd.normal({ 'K', bang = true })
  end
end, { desc = 'Show documentation' })

map('n', '<leader>cf', "<cmd>call CocActionAsync('format')<cr>", { desc = 'Format file' })
map('n', '<leader>cd', '<cmd>CocList diagnostics<cr>', { desc = 'All diagnostics' })
map('n', '<leader>co', '<cmd>CocList outline<cr>', { desc = 'File outline' })
map('n', '<leader>ci', "<cmd>call CocActionAsync('runCommand', 'editor.action.organizeImport')<cr>",
  { desc = 'Organize imports' })
