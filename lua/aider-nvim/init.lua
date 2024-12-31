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

function M.submit_and_close()
    chat.submit()
end

function M.call_aider_plus()
    -- Call Aider Plus functionality
    vim.notify("Aider Plus called", vim.log.levels.INFO)
    -- TODO: Implement Aider Plus specific logic here
end

return M
