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

function M.submit()
    if not buffer.is_open() then return end

    local config = require("aider-nvim.config").get()
    local cursor_pos = vim.api.nvim_win_get_cursor(buffer.get_win())
    local line = vim.api.nvim_buf_get_lines(buffer.get_buf(), cursor_pos[1] - 1, cursor_pos[1], false)[1]
    
    local input = string.sub(line, #config.prompt + 1)
    
    if input and #input > 0 then
        vim.notify("Input submitted: " .. input, vim.log.levels.INFO)
    else
        vim.notify("No input provided", vim.log.levels.WARN)
    end
    
    M.toggle()
end

return M
