local popup = require('leetup.popup')

local M = {}

M.header = 'Leet it up!'
M.help = 'Filter: <leader>f'

M.split_window = function()
  vim.cmd('vsplit')
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_win_set_buf(win, buf)
end

local function load()
  local win = popup.open_window(M)
  popup.set_mappings()
  popup.update_view(M)
  vim.api.nvim_win_set_cursor(win, { 4, 0 })
end

return {
  load = load
}
