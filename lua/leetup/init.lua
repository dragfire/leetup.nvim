local popup = require('leetup.popup')

local list_cmd = 'leetup list'

local M = {
  header = 'Leet it up!',
  help = 'Search: <leader>s',
  command = list_cmd,
  empty_result_msg = 'Did not find any match!',
  search_key_map = '<leader>s',
  default_language = 'rust'
}

M.split_window = function()
  vim.cmd('vsplit')
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_win_set_buf(win, buf)
end

local function load()
  local win = popup.open_window(M)
  popup.set_mappings(M)
  popup.update_view(M)
  vim.api.nvim_win_set_cursor(win, { 4, 0 })
end

local function search()
  vim.ui.input({ prompt = "Search: " }, function(input)
    M.command = list_cmd .. ' ' .. input
    M.empty_result_msg = 'Search returned empty'
    popup.update_view(M)
  end)
end

return {
  load = load,
  search = search
}
