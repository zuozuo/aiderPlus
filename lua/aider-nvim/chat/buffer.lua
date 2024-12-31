local M = {}

local chat_buf = nil
local chat_win = nil
local last_window_config = nil
local original_buf = nil
local original_cursor_pos = nil

function M.create()
    local config = require("aider-nvim.config").get()
    
    -- Save original buffer and cursor position
    original_buf = vim.api.nvim_get_current_buf()
    original_cursor_pos = vim.api.nvim_win_get_cursor(0)

    -- Check if buffer with same name exists and delete it
    local existing_buf = vim.fn.bufnr("AiderPlus Chat")
    if existing_buf ~= -1 and vim.api.nvim_buf_is_valid(existing_buf) then
        vim.api.nvim_buf_delete(existing_buf, { force = true })
    end

    -- Create new buffer
    chat_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(chat_buf, "AiderPlus Chat")
    vim.api.nvim_buf_set_option(chat_buf, "filetype", "markdown")

    -- Use last window config if available, otherwise create new one
    local opts = last_window_config or {
        relative = "win",
        width = math.floor(vim.o.columns * 0.6),
        height = 3,  -- Show 3 lines
        col = 0,
        row = 0,
        style = "minimal",
        border = "rounded",
    }

    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    opts.col = vim.fn.indent(cursor_pos[1])  -- Align with buffer's text start
    opts.row = cursor_pos[1] - vim.fn.line('w0') + 1  -- Calculate relative row position

    if not chat_win or not vim.api.nvim_win_is_valid(chat_win) then
        chat_win = vim.api.nvim_open_win(chat_buf, true, opts)
    else
        vim.api.nvim_win_set_config(chat_win, opts)
        vim.api.nvim_set_current_win(chat_win)
    end

    -- Set window options
    vim.api.nvim_win_set_option(chat_win, "number", false)
    vim.api.nvim_win_set_option(chat_win, "relativenumber", false)
    vim.api.nvim_win_set_option(chat_win, "wrap", true)
    vim.api.nvim_win_set_option(chat_win, "scrolloff", 2)
    vim.api.nvim_buf_set_option(chat_buf, "buftype", "")
    vim.api.nvim_buf_set_option(chat_buf, "modifiable", true)
    vim.api.nvim_buf_set_option(chat_buf, "readonly", false)

    -- Add prompt and enter insert mode
    vim.api.nvim_buf_set_lines(chat_buf, 0, -1, false, {config.prompt})
    
    -- Mark prompt as read-only
    vim.api.nvim_buf_add_highlight(chat_buf, -1, "Comment", 0, 0, #config.prompt)
    
    -- Set up autocmd to protect prompt text
    vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI", "TextChangedP"}, {
        buffer = chat_buf,
        callback = function()
            local lines = vim.api.nvim_buf_get_lines(chat_buf, 0, 1, false)
            if not lines[1] or not lines[1]:find("^" .. vim.pesc(config.prompt)) then
                vim.api.nvim_buf_set_lines(chat_buf, 0, 1, false, {config.prompt})
                vim.api.nvim_win_set_cursor(chat_win, {1, #config.prompt + 1})
            end
        end
    })
    
    -- Set up keymap for Enter key to submit
    vim.api.nvim_buf_set_keymap(chat_buf, "i", "<CR>", "<cmd>lua require('aider-nvim').submit_and_close()<CR>", {noremap = true, silent = true})
    vim.api.nvim_buf_set_keymap(chat_buf, "n", "<CR>", "<cmd>lua require('aider-nvim').submit_and_close()<CR>", {noremap = true, silent = true})
    
    -- Add 'q' key to close window in normal mode
    vim.api.nvim_buf_set_keymap(chat_buf, "n", "q", "<cmd>lua require('aider-nvim.chat.buffer').close()<CR>", {noremap = true, silent = true})
    
    vim.cmd("startinsert")
    vim.api.nvim_win_set_cursor(chat_win, {1, #config.prompt})
end

function M.close()
    if chat_win and vim.api.nvim_win_is_valid(chat_win) then
        -- Clear saved positions
        original_buf = nil
        original_cursor_pos = nil
        last_window_config = vim.api.nvim_win_get_config(chat_win)
        vim.api.nvim_win_close(chat_win, true)
        if chat_buf and vim.api.nvim_buf_is_valid(chat_buf) then
            -- Remove the Enter key mapping before closing
            vim.api.nvim_buf_del_keymap(chat_buf, "i", "<CR>")
            vim.api.nvim_buf_delete(chat_buf, { force = true })
        end
        chat_win = nil
        chat_buf = nil
        vim.cmd("stopinsert")
    end
end

function M.is_open()
    return chat_win and vim.api.nvim_win_is_valid(chat_win)
end

function M.get_win()
    return chat_win
end

function M.get_buf()
    return chat_buf
end

function M.get_original_buf()
    return original_buf
end

function M.get_original_cursor_pos()
    return original_cursor_pos
end

return M
