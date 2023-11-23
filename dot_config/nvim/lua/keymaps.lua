-- [[ Basic Keymaps ]]

-- Remap jk and kj to <Esc> to exit insert mode
-- additionally, move cursor to the right, since by default it is moved to the left, which is hella annoying
-- also adjust the normal <Esc> keymap to move cursor to the right
-- does come with a quirk if you're at the beginning of a line, it will move the cursor to the right
-- but that's a small tradeoff IMO (and there may be a way to adjust this behavior)
vim.keymap.set('i', 'jk', '<Esc>l')
vim.keymap.set('i', 'kj', '<Esc>l')
vim.keymap.set('i', '<Esc>', '<Esc>l')

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
