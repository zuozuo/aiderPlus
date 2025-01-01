
local M = {}

local input_win =nil
local original_buf = nil
local original_cursor_pos = nil
local original_visual_selection = nil

function M.get_code_context(window_size)
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local current_line = cursor_pos[1]
    local buf = vim.api.nvim_get_current_buf()
    
    local start_line = math.max(1, current_line - window_size)
    local end_line = current_line + window_size
    
    local lines = vim.api.nvim_buf_get_lines(buf, start_line - 1, end_line, false)
    
    -- Add line numbers to each line
    local numbered_lines = {}
    for i, line in ipairs(lines) do
        table.insert(numbered_lines, string.format("%d: %s", start_line + i - 1, line))
    end
    
    return table.concat(numbered_lines, "\n")
end

function M.create()
    local config = require("aider-nvim.config").get()
    
    -- If input window is already open, close it first
    if M.is_open() then
        input_win:close()
        input_win = nil
    end
    
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
    
    -- Check if there's an actual selection (start and end positions differ)
    if start_line ~= end_line or start_pos[3] ~= end_pos[3] then
        vim.notify("Visual selection detected", vim.log.levels.INFO)
        local lines = vim.api.nvim_buf_get_lines(original_buf, start_line - 1, end_line, false)
        local numbered_lines = {}
        for i, line in ipairs(lines) do
            table.insert(numbered_lines, string.format("%d: %s", start_line + i - 1, line))
        end
        
        original_visual_selection = {
            start_line = start_line,
            end_line = end_line,
            content = numbered_lines
        }
    end

    local on_confirm = function(value)
        if value and #value > 0 then
            -- Get all context information
            local cursor_context = M.get_cursor_context()
            local code_context = M.get_code_context(5)  -- Use window_size of 5
            local visual_selection = M.get_original_visual_selection()
            
            -- Build the context message
            local context_message = "Current Cursor Line:\n"
            context_message = context_message .. string.format("Line %d, Col %d: %s\n\n", 
                cursor_context.line, cursor_context.col, cursor_context.content)

            context_message = context_message .. "Code Context:\n" .. code_context .. "\n\n"
            
            if visual_selection then
                context_message = context_message .. "User Selection:\n"
                context_message = context_message .. table.concat(visual_selection.content, "\n") .. "\n\n"
            end

            -- Combine context with user input
            local full_message = context_message .. "User Requirement:\n" .. value
            
            require("aider-nvim.chat").submit(full_message)
        end
    end

    -- Get current cursor position for window placement
    local current_cursor = vim.api.nvim_win_get_cursor(0)
    local cursor_row, cursor_col = unpack(current_cursor)
    
    dd(cursor_row, cursor_col)
    input_win = require("snacks.input").input({
        prompt = config.prompt,
        win = {
            relative = "editor",
            height = 1,
            width = 100,
            wo = {
                winhighlight = "NormalFloat:SnacksInputNormal,FloatBorder:SnacksInputBorder,FloatTitle:SnacksInputTitle",
                cursorline = false,
            },
            b = {
                completion = false, -- disable blink completions in input
            },
            anchor = "NW",
            row = cursor_row - 1,  -- Convert to 0-based row
            col = cursor_col       -- Already 0-based
        }
    }, on_confirm)
end

function M.is_open()
    return input_win ~= nil
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

function M.get_cursor_context()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local current_line = cursor_pos[1]
    local current_col = cursor_pos[2]
    local buf = vim.api.nvim_get_current_buf()
    local line_content = vim.api.nvim_buf_get_lines(buf, current_line - 1, current_line, false)[1] or ""
    
    return {
        line = current_line,
        col = current_col + 1,  -- 转换为1-based列号
        content = line_content
    }
end

return M
