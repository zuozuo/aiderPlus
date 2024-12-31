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

function M.get_code_context()
    local config = require("aider-nvim.config").get()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    vim.notify("cursor_pos: " .. cursor_pos[1] .. " " .. cursor_pos[2], vim.log.levels.INFO)
    local current_line = cursor_pos[1]
    local buf = vim.api.nvim_get_current_buf()
    
    -- 计算上下行范围
    local start_line = math.max(1, current_line - config.code_context_window)
    local end_line = current_line + config.code_context_window
    
    -- 获取代码
    local lines = vim.api.nvim_buf_get_lines(buf, start_line - 1, end_line, false)
    return table.concat(lines, "\n")
end

function M.submit_and_close()
    local context = M.get_code_context()
    if context and #context > 0 then
        -- 将上下文传递给 chat.submit()
        chat.submit(context)
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
