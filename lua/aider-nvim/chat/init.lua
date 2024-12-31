local M = {}
local buffer = require("aider-nvim.chat.buffer")

function M.toggle()
    if buffer.is_open() then
        buffer.close()
    else
        buffer.create()
    end
end

function M.submit(context)
    if not buffer.is_open() then return end

    local config = require("aider-nvim.config").get()
    local win = buffer.get_win()
    local buf = buffer.get_buf()

    
    if not win or not vim.api.nvim_win_is_valid(win) or not buf or not vim.api.nvim_buf_is_valid(buf) then
        vim.notify("Chat window is not valid", vim.log.levels.ERROR)
        return
    end
    
    local cursor_pos = vim.api.nvim_win_get_cursor(win)
    local line = vim.api.nvim_buf_get_lines(buf, cursor_pos[1] - 1, cursor_pos[1], false)[1] or ""
    
    local input = string.sub(line, #config.prompt + 1)
    
    if input and #input > 0 then
        -- 检查是否存在名为 AiderPlus-Chat 的 floaterm 窗口
        local term_bufnr = vim.fn["floaterm#terminal#get_bufnr"]("AiderPlus-Chat")

        if term_bufnr ~= -1 then
            -- 如果存在则显示窗口
            vim.fn["floaterm#terminal#open_existing"](term_bufnr)
        else
            vim.notify("AiderPlus-Chat terminal not found, please create a new one", vim.log.levels.INFO)
        end

        -- 将输入发送到 floaterm
        -- Get original buffer's file path and send it first
        local original_buf = require("aider-nvim.chat.buffer").get_original_buf()
        if original_buf and vim.api.nvim_buf_is_valid(original_buf) then
            local full_path = vim.api.nvim_buf_get_name(original_buf)
            if full_path and #full_path > 0 and not full_path:match("^term://") then
                -- Get relative path from current working directory
                local cwd = vim.fn.getcwd()
                local rel_path = full_path:gsub("^" .. cwd .. "/", "")
                vim.fn["floaterm#terminal#send"](term_bufnr, {"/add " .. rel_path})
            end
        end

        -- Then send context if it exists
        if context and #context > 0 then
            vim.fn["floaterm#terminal#send"](term_bufnr, {context})
        end
    end
    
    -- Switch back to original window using ctrl-w w and close chat window
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-w>h", true, false, true), "n", true)
    buffer.close()
end

return M
