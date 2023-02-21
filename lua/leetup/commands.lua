local M = {}

local executable = "leetup"

M.systemlist = function(command)
  return vim.fn.systemlist(command)
end

M.list = function(query)
  query = query or ''
  return M.list(executable .. " list " .. query)
end

return M
