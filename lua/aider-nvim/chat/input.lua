local M = {}

-- 用于存储当前打开的窗口和缓冲区
local current_window = nil
local current_buffer = nil

function M.close()
    if current_window and vim.api.nvim_win_is_valid(current_window) then
        vim.api.nvim_win_close(current_window, true)
    end
    if current_buffer and vim.api.nvim_buf_is_valid(current_buffer) then
        vim.api.nvim_buf_delete(current_buffer, { force = true })
    end
    current_window = nil
    current_buffer = nil
end

function M.window_center(input_width)
	return {
		relative = "win",
		row = vim.api.nvim_win_get_height(0) / 2 - 1,
		col = vim.api.nvim_win_get_width(0) / 2 - input_width / 2,
	}
end

function M.under_cursor(_)
	return {
		relative = "cursor",
		row = 1,
		col = 0,
	}
end

function M.input(opts, on_confirm, win_config)
	local prompt = opts.prompt or "Input: "
	local default = opts.default or ""
	local win_position = opts.win_position or "center"
	local input_width = opts.input_width or 100
	on_confirm = on_confirm or function() end

	-- Calculate a minimal width with a bit buffer
	local default_width = vim.str_utfindex(default) + 10
	local prompt_width = vim.str_utfindex(prompt) + 10
	-- local input_width = default_width > prompt_width and default_width or prompt_width

	local default_win_config = {
		focusable = true,
		style = "minimal",
		border = "rounded",
		width = input_width,
		height = 1,
		title = prompt,
	}

	-- Apply user's window config.
	win_config = win_config or {}
	win_config = vim.tbl_deep_extend("force", default_win_config, win_config)

	-- Place the window near cursor or at the center of the window.
	if win_position == "cursor" then
		win_config = vim.tbl_deep_extend("force", win_config, M.under_cursor(win_config.width))
	else
		win_config = vim.tbl_deep_extend("force", win_config, M.window_center(win_config.width))
	end

	-- 如果已经有打开的窗口，先关闭它
	M.close()

	-- Create floating window.
	current_buffer = vim.api.nvim_create_buf(false, true)
	current_window = vim.api.nvim_open_win(current_buffer, true, win_config)
	vim.api.nvim_buf_set_text(buffer, 0, 0, 0, 0, { default })

	-- Put cursor at the end of the default value
	vim.cmd("startinsert")
	vim.api.nvim_win_set_cursor(window, { 1, vim.str_utfindex(default) + 1 })

	-- Enter to confirm
	vim.keymap.set({ "n", "i", "v" }, "<cr>", function()
		local lines = vim.api.nvim_buf_get_lines(buffer, 0, 1, false)
		vim.cmd("stopinsert")
		on_confirm(lines[1])
		M.close()
	end, { buffer = buffer })

	-- Esc or q to close
	vim.keymap.set("n", "<esc>", function()
		on_confirm(nil)
		vim.cmd("stopinsert")
		M.close()
	end, { buffer = buffer })
	vim.keymap.set("n", "q", function()
		on_confirm(nil)
		vim.cmd("stopinsert")
		M.close()
	end, { buffer = buffer })
end

return M
