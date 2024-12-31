local M = {}

local config = require("aider-nvim.config")
local keymaps = require("aider-nvim.keymaps")
local commands = require("aider-nvim.commands")
local chat = require("aider-nvim.chat")
local utils = require("aider-nvim.utils")

function M.setup(user_config)
    config.setup(user_config)
    keymaps.setup()
    commands.setup()

    if config.get().auto_start then
        M.start_aider()
    end
end

function M.start_aider()
    -- Start Aider process
    -- vim.notify("Aider started", vim.log.levels.INFO)
end

function M.send_code()
    local buf = vim.api.nvim_get_current_buf()
    if vim.api.nvim_buf_is_valid(buf) then
        local content = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
        -- TODO: Send to Aider
        vim.notify("Code sent to Aider", vim.log.levels.INFO)
    else
        vim.notify("Invalid buffer", vim.log.levels.ERROR)
    end
end

function M.send_selection()
    local buf = vim.api.nvim_get_current_buf()
    if not vim.api.nvim_buf_is_valid(buf) then
        vim.notify("Invalid buffer", vim.log.levels.ERROR)
        return
    end

    local selection = utils.get_visual_selection_range()
    local content = table.concat(selection.content, "\n")
    
    if content and #content > 0 then
        vim.notify("Selected code sent to Aider", vim.log.levels.INFO)
    else
        vim.notify("No selection provided", vim.log.levels.WARN)
    end
end

function M.toggle_chat()
    chat.toggle()
end

function M.get_current_line()
    local buffer = require("aider-nvim.chat.buffer")
    local original_buf = buffer.get_original_buf()
    local original_cursor_pos = buffer.get_original_cursor_pos()
    
    if not original_buf or not original_cursor_pos then
        return "", 0
    end
    
    local line_num = original_cursor_pos[1]
    local line = vim.api.nvim_buf_get_lines(original_buf, line_num - 1, line_num, false)[1] or ""
    
    return line, line_num
end

function M.get_code_context()
    local config = require("aider-nvim.config").get()
    local buffer = require("aider-nvim.chat.buffer")
    
    -- Get original buffer and cursor position
    local original_buf = buffer.get_original_buf()
    local original_cursor_pos = buffer.get_original_cursor_pos()
    
    if not original_buf or not original_cursor_pos then
        return ""
    end
    
    local current_line = original_cursor_pos[1]
    
    -- 计算上下行范围
    local start_line = math.max(1, current_line - config.code_context_window)
    local end_line = current_line + config.code_context_window
    
    -- 获取代码并添加行号
    local lines = vim.api.nvim_buf_get_lines(original_buf, start_line - 1, end_line, false)
    local numbered_lines = {}
    for i, line in ipairs(lines) do
        table.insert(numbered_lines, string.format("%d: %s", start_line + i - 1, line))
    end
    return table.concat(numbered_lines, "\n")
end

function M.submit_and_close()
    local line, line_num = M.get_current_line()
    local context = M.get_code_context()
    
    local combined = ""
    if line and #line > 0 then
        combined = string.format("Current line (%d): %s\n", line_num, line)
    end
    if context and #context > 0 then
        combined = combined .. "Code context:\n" .. context
    end
    
    if #combined > 0 then
        chat.submit(combined)
    else
        vim.notify("No code context found", vim.log.levels.WARN)
    end
end

function M.call_aider_plus()
    -- Call Aider Plus functionality
    vim.notify("Aider Plus called", vim.log.levels.INFO)
    -- TODO: Implement Aider Plus specific logic here
end

return M
