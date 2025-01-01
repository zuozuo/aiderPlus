
local M = {}

local input_win =nil
local original_buf = nil
local original_cursor_pos = nil
local original_visual_selection = nil

function M.create()
    local config = require("aider-nvim.config").get()
    
    -- If input window is already open, close it first
    if M.is_open() then
        input_win:close()
        input_win = nil
        return
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
        original_visual_selection = {
            start_line = start_line,
            end_line = end_line,
            content = vim.api.nvim_buf_get_lines(original_buf, start_line - 1, end_line, false)
        }
    end

    local on_confirm = function(value)
        if value and #value > 0 then
            require("aider-nvim.chat").submit(value)
        end
    end

    input_win = require("snacks.input").input({
        prompt = config.prompt,
        win = {
            relative = "cursor",
            row = 0,
            col = 0,
            height = 1,
            width = 100,
            wo = {
                winhighlight = "NormalFloat:SnacksInputNormal,FloatBorder:SnacksInputBorder,FloatTitle:SnacksInputTitle",
                cursorline = false,
            },
            b = {
                completion = false, -- disable blink completions in input
            },
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

return M
