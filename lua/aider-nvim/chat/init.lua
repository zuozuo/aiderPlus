local M = {}
local buffer = require("aider-nvim.chat.buffer")

function M.toggle()
    if buffer.is_open() then
        buffer.close()
        vim.notify("Chat closed", vim.log.levels.INFO)
    else
        buffer.create()
        vim.notify("Chat opened", vim.log.levels.INFO)
    end
end

function M.submit(context)
    if not buffer.is_open() then return end

    local config = require("aider-nvim.config").get()
    local win = buffer.get_win()
    local buf = buffer.get_buf()

    -- 如果有上下文，先显示它
    if context and #context > 0 then
        vim.notify("Code context:\n" .. context, vim.log.levels.INFO)
    end
    
    if not win or not vim.api.nvim_win_is_valid(win) or not buf or not vim.api.nvim_buf_is_valid(buf) then
        vim.notify("Chat window is not valid", vim.log.levels.ERROR)
        return
    end
    
    local cursor_pos = vim.api.nvim_win_get_cursor(win)
    local line = vim.api.nvim_buf_get_lines(buf, cursor_pos[1] - 1, cursor_pos[1], false)[1] or ""
    
    local input = string.sub(line, #config.prompt + 1)
    
    if input and #input > 0 then
        vim.notify("Input submitted: " .. input, vim.log.levels.INFO)
    else
        vim.notify("No input provided", vim.log.levels.WARN)
    end
    
    M.toggle()
end

return M
