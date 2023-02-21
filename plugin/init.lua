if vim.g.loaded_leetup ~= nil then
  return
end

vim.api.nvim_set_keymap('n', '<leader>pr', ':lua require("plugin.dev").reload()<cr>', {})
vim.api.nvim_set_keymap('n', '<leader>lu', ':Leetup<cr>', {})

vim.api.nvim_set_hl(0, 'LeetHeader', { link = 'Number', default = 1 })
vim.api.nvim_set_hl(0, 'LeetSubHeader', { link = 'Identifier', default = 1 })

vim.api.nvim_create_user_command('Leetup', 'lua require("leetup").load()', {})
vim.api.nvim_set_var('loaded_leetup', 1)
