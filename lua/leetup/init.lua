local popup = require("leetup.popup")
local default_config = require("leetup.default_config")

local list_cmd = "leetup list"

local M = {
	header = "Leet it up!",
	help = "Search: <leader>s",
	command = list_cmd,
	empty_result_msg = "Did not find any match!",
	search_key_map = "<leader>s",
	process_result = function(result)
		return result
	end,
}

M.split_window = function()
	vim.cmd("vsplit")
	local win = vim.api.nvim_get_current_win()
	local buf = vim.api.nvim_create_buf(true, true)
	vim.api.nvim_win_set_buf(win, buf)
end

local function inspect(table)
	for k, v in pairs(table) do
		print("\t", k, v)
	end
end

function M.load()
	local win, buf = popup.open_window(M)
	popup.set_mappings(M, buf)
	popup.update_view(M)
	vim.api.nvim_win_set_cursor(win, { 4, 0 })
end

function M.search()
	vim.ui.input({ prompt = "Search: " }, function(input)
		M.command = list_cmd .. " " .. input
		M.empty_result_msg = "Search returned empty"
		popup.update_view(M)
	end)
end

local function parse_leetup_test(lines)
	local start_index, end_index
	for i, line in ipairs(lines) do
		if line:find("@leetup=test") then
			if not start_index then
				start_index = i + 1
			else
				end_index = i - 1
				break
			end
		end
	end
	if start_index == nil or end_index == nil then
		return nil, "Input does not contain two occurrences of '@leetup=test'"
	end
	local content = table.concat(lines, "\\n", start_index, end_index):gsub("%* ", "")
	return content
end

function M.run_test()
	M.header = "Run test:"
	M.process_result = function(result)
		table.remove(result, 1)
		return result
	end

	local buf = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(buf, 1, -1, false)
	local _, win_buf = popup.open_window(M)
	popup.set_mappings(M, win_buf)

	local is_leetup_file = string.find(lines[1], "leetup") ~= nil
	if is_leetup_file then
		local test_data = parse_leetup_test(lines)
		M.command = "leetup test " .. vim.api.nvim_buf_get_name(buf) .. ' -t "' .. test_data .. '"'
		print(M.command)
		popup.update_view(M)
	end
end

function M.setup(opts)
	M.conf = vim.tbl_deep_extend("force", default_config, opts or {})

	vim.api.nvim_set_keymap("n", "<leader>lu", ":Leetup<cr>", {})
	vim.api.nvim_set_keymap("n", "<leader>lt", ':lua require"leetup".run_test()<cr>', {})
	vim.api.nvim_set_keymap("n", "<leader>pr", ':lua require("plugin.dev").reload()<cr>', {})
end

return M
