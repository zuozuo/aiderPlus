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
        -- 检查是否存在名为 AiderPlus-Chat 的 floaterm 窗口
        local term_bufnr = vim.fn["floaterm#terminal#get_bufnr"]("AiderPlus-Chat")

        if term_bufnr ~= -1 then
            -- 如果存在则显示窗口
            vim.fn["floaterm#terminal#open_existing"](term_bufnr)
        else
            -- 检查 floaterm 是否加载
            if vim.fn.exists("*floaterm#terminal#open") == 0 then
                vim.notify("Floaterm plugin not loaded", vim.log.levels.ERROR)
                return
            end

            -- 如果不存在则创建新的 floaterm 窗口
            local success, result = pcall(function()
                return vim.fn["floaterm#terminal#open"](-1, "zsh", {}, {
                    name = "AiderPlus-Chat",
                    wintype = "split",
                    width = 0.5,
                    height = 0.5,
                    position = "bottom",
                    autoclose = 0,
                    title = "AiderPlus-Chat"
                })
            end)

            if not success then
                vim.notify("Floaterm error: " .. tostring(result), vim.log.levels.ERROR)
                return
            end

            term_bufnr = result
            
            if term_bufnr == -1 then
                vim.notify("Failed to create AiderPlus-Chat terminal (returned -1)", vim.log.levels.ERROR)
                return
            end

            -- 验证终端是否创建成功
            if not vim.api.nvim_buf_is_valid(term_bufnr) then
                vim.notify("Created terminal buffer is invalid", vim.log.levels.ERROR)
                return
            end
        end

        -- 将输入发送到 floaterm
        if input and #input > 0 then
            vim.fn["floaterm#terminal#send"](term_bufnr, {input})
            vim.notify("Input submitted: " .. input, vim.log.levels.INFO)
        else
            vim.notify("Empty input, nothing to send", vim.log.levels.WARN)
        end
    end
    M.toggle()
end

return M
