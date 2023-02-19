if vim.g.loaded_leetup ~= nil then
  return
end

vim.api.nvim_create_user_command('Leetup', 'lua require"leetup.popup".whid()', {})
vim.api.nvim_set_var('loaded_leetup', 1)

print("leetup.nvim plugin loaded...")
