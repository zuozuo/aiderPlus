local M = {}
local buffer = require("aider-nvim.chat.buffer")

function M.toggle()
    buffer.create()
end

function M.submit(input)
    if not input or #input == 0 then return end

    local config = require("aider-nvim.config").get()
    
    -- 检查是否存在名为 AiderPlus-Chat 的 floaterm 窗口
    local term_bufnr = vim.fn["floaterm#terminal#get_bufnr"]("AiderPlus-Chat")

    if term_bufnr ~= -1 then
        -- 如果存在则显示窗口
        vim.fn["floaterm#terminal#open_existing"](term_bufnr)
    else
        vim.notify("AiderPlus-Chat terminal not found, please create a new one", vim.log.levels.INFO)
        return
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

    -- Send the user input
    vim.fn["floaterm#terminal#send"](term_bufnr, {input})
end

return M
