local baleia = require("baleia").setup({})
local api = vim.api
local buf, win

local function center(str)
	local width = api.nvim_win_get_width(0)
	local shift = math.floor(width / 2) - math.floor(string.len(str) / 2)
	return string.rep(" ", shift) .. str
end

local function open_window(M)
	buf = api.nvim_create_buf(false, true)
	local border_buf = api.nvim_create_buf(false, true)

	api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	api.nvim_buf_set_option(buf, "filetype", "leet")

	local width = api.nvim_get_option("columns")
	local height = api.nvim_get_option("lines")

	local win_height = math.ceil(height * 0.8 - 4)
	local win_width = math.ceil(width * 0.8)
	local row = math.ceil((height - win_height) / 2 - 1)
	local col = math.ceil((width - win_width) / 2)

	local border_opts = {
		style = "minimal",
		relative = "editor",
		width = win_width + 2,
		height = win_height + 2,
		row = row - 1,
		col = col - 1,
	}

	local opts = {
		style = "minimal",
		relative = "editor",
		width = win_width,
		height = win_height,
		row = row,
		col = col,
	}
  local bc = M.conf.floating_window.borderchars

	local border_lines = { bc.ul .. string.rep(bc.r, win_width) .. bc.ur }
	local middle_line = bc.l .. string.rep(" ", win_width) .. bc.l
	for i = 1, win_height do
		table.insert(border_lines, middle_line)
	end
	table.insert(border_lines, bc.dl .. string.rep(bc.r, win_width) .. bc.dr)
	api.nvim_buf_set_lines(border_buf, 0, -1, false, border_lines)

	api.nvim_open_win(border_buf, true, border_opts)
	win = api.nvim_open_win(buf, true, opts)
	api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "' .. border_buf)

	api.nvim_win_set_option(win, "cursorline", true) -- it highlight line with the cursor on it

	-- we can add title already here, because first line will never change
	api.nvim_buf_set_lines(buf, 0, -1, false, { center(M.header), "", "" })
  api.nvim_buf_add_highlight(buf, -1, 'LeetHeader', 0, 0, -1)

	return win, buf
end

local function update_view(M)
	api.nvim_buf_set_option(buf, "modifiable", true)

	local result = vim.fn.systemlist(M.command)
	if #result == 0 then
		table.insert(result, M.empty_result_msg)
	end -- add  an empty line to preserve layout if there is no results

	api.nvim_buf_set_lines(buf, 1, 2, false, { center(M.help) })
	baleia.buf_set_lines(buf, 3, -1, false, M.process_result(result))

	api.nvim_buf_add_highlight(buf, -1, "LeetSubHeader", 1, 0, -1)
	api.nvim_buf_set_option(buf, "modifiable", false)
end

local function close_window()
	api.nvim_win_close(win, true)
end

local function get_number_in_brackets(row)
	return tonumber(row:match("%[(%s*%d+%s*)%]"))
end
local function get_name_in_brackets(str)
	local c
	if str:find("Easy") then
		c = "Easy"
	elseif str:find("Medium") then
		c = "Medium"
	else
		c = "Hard"
	end
	local res = str:match("%](.-)" .. c):gsub("^[%s]*(.-)[%s]*$", "%1")
	return res
end

local function get_filename_from_path(path)
	local filename = string.match(path, "/([^/]+)$")
	return filename
end

local function get_filepath(path)
	return string.match(path, "Generated: (%S+)")
end

local function strip_ansi_escapes(str)
	return str:gsub("[\27\155][][()#;?%d]*[A-PRZcf-ntqry=><~]", "")
end

local function open_file(M)
	local str = api.nvim_get_current_line()

	close_window()

	local problem_id = get_number_in_brackets(str)
	local generated_file = vim.fn.system("leetup pick -gl " .. M.conf.language .. " " .. problem_id)
	local filepath = get_filepath(strip_ansi_escapes(generated_file))

	api.nvim_command("edit " .. filepath)
end

local function move_cursor()
	local new_pos = math.max(4, api.nvim_win_get_cursor(win)[1] - 1)
	api.nvim_win_set_cursor(win, { new_pos, 0 })
end

local function set_mappings(M, buf)
	api.nvim_buf_set_keymap(buf, "n", M.search_key_map, ':lua require"leetup".search()<cr>', {
		nowait = true,
		noremap = true,
		silent = true,
	})
	-- local mappings = {
	-- 	["<cr>"] = "open_file(M)",
	-- 	q = "close_window()",
	-- 	k = "move_cursor()",
	-- }
	api.nvim_buf_set_keymap(buf, "n", "<cr>", "", {
		nowait = true,
		noremap = true,
		callback = function()
			open_file(M)
		end,
	})
	api.nvim_buf_set_keymap(buf, "n", "q", "", {
		nowait = true,
		noremap = true,
		callback = function()
			close_window()
		end,
	})
	api.nvim_buf_set_keymap(buf, "n", "k", "", {
		nowait = true,
		noremap = true,
		callback = function()
			move_cursor()
		end,
	})
	local other_chars = {
		"a",
		"b",
		"c",
		"d",
		"e",
		"g",
		"i",
		"n",
		"o",
		"p",
		"r",
		"t",
		"u",
		"v",
		"w",
		"x",
		"y",
		"z",
	}
	for k, v in ipairs(other_chars) do
		api.nvim_buf_set_keymap(buf, "n", v, "", { nowait = true, noremap = true, silent = true })
		api.nvim_buf_set_keymap(buf, "n", v:upper(), "", { nowait = true, noremap = true, silent = true })
		api.nvim_buf_set_keymap(buf, "n", "<c-" .. v .. ">", "", { nowait = true, noremap = true, silent = true })
	end
end

return {
	buf = buf,
	win = win,
	center = center,
	set_mappings = set_mappings,
	update_view = update_view,
	open_window = open_window,
	open_file = open_file,
	move_cursor = move_cursor,
	close_window = close_window,
}
