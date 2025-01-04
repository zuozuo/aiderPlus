local M = {}

local config = require("aider-nvim.config")
local keymaps = require("aider-nvim.keymaps")
local commands = require("aider-nvim.commands")
local chat = require("aider-nvim.chat")
local utils = require("aider-nvim.utils")

function M.setup(user_config)
    -- Initialize plugin configuration with user provided settings
    config.setup(user_config)
    
    -- Set up key mappings based on configuration
    keymaps.setup()
    
    -- Register user commands for AiderPlus functionality
    commands.setup()

    -- Automatically start Aider if configured to do so
    if config.get().auto_start then
        M.start_aider()
    end
end

function M.start_aider()
    -- Start Aider process
    -- TODO: Implement actual Aider process startup
    -- Currently just a placeholder for future implementation
    -- vim.notify("hello", vim.log.levels.INFO)
end

function M.start()
    -- Initialize AiderPlus chat interface
    -- Checks if floaterm is available using multiple methods
    local floaterm_available = false
    local floaterm_error = nil
    
    -- Try multiple ways to check for floaterm
    local success, result = pcall(function()
        if vim.fn.exists("*floaterm#terminal#get_bufnr") == 1 then
            floaterm_available = true
        elseif vim.fn.exists(":FloatermNew") == 2 then
            floaterm_available = true
        else
            -- Try loading floaterm
            vim.cmd("packadd floaterm")
            if vim.fn.exists("*floaterm#terminal#get_bufnr") == 1 then
                floaterm_available = true
            end
        end
    end)
    
    if not success then
        floaterm_error = result
    end
    
    if not floaterm_available then
        local msg = "Floaterm plugin is not available"
        if floaterm_error then
            msg = msg .. ": " .. tostring(floaterm_error)
        end
        vim.notify(msg, vim.log.levels.ERROR)
        return
    end
    
    -- Add hello notification
    vim.notify("hello", vim.log.levels.INFO)

    -- Check if terminal already exists
    local term_bufnr = vim.fn["floaterm#terminal#get_bufnr"]("AiderPlus-Chat")
    if term_bufnr ~= -1 then
        vim.notify("AiderPlus-Chat terminal already exists", vim.log.levels.INFO)
        return
    end

    -- Create new floaterm window
    local create_success, create_result = pcall(function()
        vim.cmd(config.get().floaterm_command)
    end)

    if not create_success then
        vim.notify("Failed to create AiderPlus-Chat terminal: " .. tostring(create_result), vim.log.levels.ERROR)
        return
    end

    vim.notify("AiderPlus-Chat terminal created successfully", vim.log.levels.INFO)
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

function M.get_visual_selection()
    local buffer = require("aider-nvim.chat.buffer")
    local selection = buffer.get_original_visual_selection()
    
    if not selection then
        return ""
    end
    
    -- Add line numbers to each line
    local numbered_lines = {}
    for i, line in ipairs(selection.content) do
        table.insert(numbered_lines, string.format("%d: %s", selection.start_line + i - 1, line))
    end
    
    return table.concat(numbered_lines, "\n")
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
    local selection = M.get_visual_selection()
    
    local combined = ""
    if line and #line > 0 then
        combined = string.format("Current line (%d): %s\n", line_num, line)
    end
    if selection and #selection > 0 then
        combined = combined .. "Selected code:\n" .. selection .. "\n"
    end
    if context and #context > 0 then
        combined = combined .. "Code context:\n" .. context
    end
    
    -- Get user input from chat buffer
    local chat_buf = require("aider-nvim.chat.buffer").get_buf()
    local input = ""
    if chat_buf and vim.api.nvim_buf_is_valid(chat_buf) then
        local lines = vim.api.nvim_buf_get_lines(chat_buf, 0, -1, false)
        local config = require("aider-nvim.config").get()
        -- Remove prompt and get user input
        if lines[1] and lines[1]:find("^" .. vim.pesc(config.prompt)) then
            input = string.sub(lines[1], #config.prompt + 1)
        end
    end

    if #combined > 0 or #input > 0 then
        if #input > 0 then
            combined = combined .. "\nUser Requirement: " .. input
        end
        chat.submit(combined)
    else
        vim.notify("No code context or input found", vim.log.levels.WARN)
    end
end

function M.call_aider_plus()
    -- Call Aider Plus functionality
    vim.notify("Aider Plus called", vim.log.levels.INFO)
    -- TODO: Implement Aider Plus specific logic here
end

return M
