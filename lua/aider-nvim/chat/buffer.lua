local M = {}

local chat_buf = nil
local chat_win = nil
local last_window_config = nil
local original_buf = nil
local original_cursor_pos = nil
local original_visual_selection = nil
local ghost_text_ns = vim.api.nvim_create_namespace("aider_ghost_text")

-- Define highlight group for ghost text that appears after the prompt
-- This text provides guidance about available commands and uses a subtle style
vim.api.nvim_set_hl(0, "AiderGhostText", {
    link = "Comment",  -- Inherit color scheme from editor's comment style
    italic = true,     -- Use italic font for a softer, less intrusive appearance
    default = true     -- Ensure this style is used by default
})

-- This highlight group is used for the ghost text that appears after the prompt
-- to guide users about available commands. It uses a subtle, italic style that
-- matches the editor's comment style to be non-intrusive yet visible.

function M.create()
    local config = require("aider-nvim.config").get()
    
    -- Save original buffer and cursor position
    original_buf = vim.api.nvim_get_current_buf()
    original_cursor_pos = vim.api.nvim_win_get_cursor(0)
    
    -- Clear previous selection
    original_visual_selection = nil
    
    -- Save visual selection before mode changes
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local start_line = start_pos[2]
    local end_line = end_pos[2]
    vim.cmd('normal! v')
    
    -- Check if there's an actual selection (start and end positions differ)
    if start_line ~= end_line or start_pos[3] ~= end_pos[3] then
        original_visual_selection = {
            start_line = start_line,
            end_line = end_line,
            content = vim.api.nvim_buf_get_lines(original_buf, start_line - 1, end_line, false)
        }
    end

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
        height = 2,  -- Show 3 lines
        col = 0,
        row = 0,
        style = "minimal",
        border = "rounded",
    }

    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    opts.col = vim.fn.indent(cursor_pos[1]) + 4  -- Align with buffer's text start plus 4 chars margin
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
            
            -- Only clear ghost text if user has actually typed something
            local content = vim.api.nvim_buf_get_lines(chat_buf, 0, -1, false)
            if #content > 1 or (#content == 1 and #content[1] > #config.prompt) then
                vim.api.nvim_buf_clear_namespace(chat_buf, ghost_text_ns, 0, -1)
            elseif #content == 1 and #content[1] == #config.prompt then
                -- Re-add ghost text when input is cleared
                local toggle_key = require("aider-nvim.config").get().keybindings.toggle_chat
                vim.api.nvim_buf_set_extmark(chat_buf, ghost_text_ns, 0, #config.prompt, {
                    virt_text = {{string.format("use / for quick commands, %s to toggle this, enter to submit", toggle_key), "AiderGhostText"}},
                    virt_text_pos = "eol",
                    hl_mode = "combine",
                    priority = 10
                })
            end
        end
    })
    
    -- Set up keymap for Enter key to submit
    vim.api.nvim_buf_set_keymap(chat_buf, "i", "<CR>", "<cmd>lua require('aider-nvim').submit_and_close()<CR>", {noremap = true, silent = true})
    vim.api.nvim_buf_set_keymap(chat_buf, "n", "<CR>", "<cmd>lua require('aider-nvim').submit_and_close()<CR>", {noremap = true, silent = true})
    
    -- Add 'q' key to close window in normal mode
    vim.api.nvim_buf_set_keymap(chat_buf, "n", "q", "<cmd>lua require('aider-nvim.chat.buffer').close()<CR>", {noremap = true, silent = true})
    vim.api.nvim_buf_set_keymap(chat_buf, "n", "<ESC>", "<cmd>lua require('aider-nvim.chat.buffer').close()<CR>", {noremap = true, silent = true})
    
    vim.cmd("startinsert")
    vim.api.nvim_win_set_cursor(chat_win, {1, #config.prompt})
    

    -- 设置自动补全
    vim.api.nvim_buf_set_option(chat_buf, "completefunc", "v:lua.require'aider-nvim.chat.buffer'.complete_quick_commands")
    
    -- 监听/键输入
    vim.api.nvim_buf_set_keymap(chat_buf, "i", "/", "<cmd>call complete(col('.'), v:lua.require'aider-nvim.chat.buffer'.complete_quick_commands())<CR>", {noremap = true, silent = true})
end

function M.close()
    if chat_win and vim.api.nvim_win_is_valid(chat_win) then
        -- Clear saved positions and selection
        original_buf = nil
        original_cursor_pos = nil
        original_visual_selection = nil
        last_window_config = vim.api.nvim_win_get_config(chat_win)
        
        -- Force close the window
        vim.api.nvim_win_close(chat_win, true)
        
        if chat_buf and vim.api.nvim_buf_is_valid(chat_buf) then
            -- Remove the Enter key mapping before closing
            vim.api.nvim_buf_del_keymap(chat_buf, "i", "<CR>")
            
            -- Force delete the buffer without saving
            vim.api.nvim_buf_set_option(chat_buf, "buftype", "nofile")
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

function M.get_original_visual_selection()
    return original_visual_selection
end

-- 自动补全函数
function M.complete_quick_commands()
    local line = vim.api.nvim_get_current_line()
    local prefix = line:match(".*/(.*)") or ""
    
    local config = require("aider-nvim.config").get()
    local matches = {}
    for _, cmd in ipairs(config.quick_commands) do
        if cmd:lower():find(prefix:lower(), 1, true) then
            table.insert(matches, {word = cmd, kind = "Quick Command"})
        end
    end
    
    return matches
end

return M
