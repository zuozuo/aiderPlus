local M = {}

-- Chat window state
local chat_buf = nil
local chat_win = nil
local last_window_config = nil  -- Store last window position and size

local config = {
    -- Default configuration options
    auto_start = true,
    prompt = "Send text to Aider:  ",
    keybindings = {
        send_code = "<leader>ac",
        send_selection = "<leader>as",
        toggle_chat = "<leader>at",
        call_aider_plus = "<leader>ap",
    },
}

function M.setup(user_config)
    config = vim.tbl_deep_extend("force", config, user_config or {})
    M.setup_keybindings()
    M.setup_commands()

    if config.auto_start then
        M.start_aider()
    end
end

function M.setup_commands()
    vim.api.nvim_create_user_command("AiderPlus", function(opts)
        local action = opts.fargs[1]
        if action == "send_code" then
            M.send_code()
        elseif action == "send_selection" then
            M.send_selection()
        elseif action == "toggle_chat" then
            M.toggle_chat()
        elseif action == "call_aider_plus" then
            M.call_aider_plus()
        else
            vim.notify(
                "Invalid action for AiderPlus. Available actions: send_code, send_selection, toggle_chat, call_aider_plus",
                vim.log.levels.ERROR)
        end
    end, {
        nargs = 1,
        range = true,
        complete = function()
            return { "send_code", "send_selection", "toggle_chat", "call_aider_plus" }
        end,
        desc = "Call Aider Plus functionality with specific action"
    })
end

function M.setup_keybindings()
    vim.keymap.set("n", config.keybindings.send_code, M.send_code, { desc = "Send code to Aider" })
    vim.keymap.set("v", config.keybindings.send_selection, M.send_selection, { desc = "Send selection to Aider" })
    vim.keymap.set("n", config.keybindings.toggle_chat, M.toggle_chat, { desc = "Toggle Aider chat" })
    vim.keymap.set("n", config.keybindings.call_aider_plus, M.call_aider_plus, { desc = "Call Aider Plus" })
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

-- 获取可视模式选择区域的范围
local function get_visual_selection_range()
    -- 获取可视模式的开始标记 '<
    local start_pos = vim.fn.getpos("'<")
    -- 获取可视模式的结束标记 '>
    local end_pos = vim.fn.getpos("'>")

    -- 提取行号
    local start_line = start_pos[2]
    local end_line = end_pos[2]

    -- 获取选中的文本内容
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

    return {
        start_line = start_line,
        end_line = end_line,
        content = lines
    }
end

function M.send_selection()
    local buf = vim.api.nvim_get_current_buf()
    if not vim.api.nvim_buf_is_valid(buf) then
        vim.notify("Invalid buffer", vim.log.levels.ERROR)
        return
    end

    -- vim.cmd("'<,'>FloatermSend")
    -- return

    local content = ""
    local mode = vim.fn.mode()

    local selection = get_visual_selection_range()
    -- 打印选择范围信息，用于调试
    print(string.format("Selection range: %d-%d", selection.start_line, selection.end_line))

    -- 这里可以添加处理选中内容的逻辑
    -- 例如:打印选中的内容
    for i, line in ipairs(selection.content) do
        print(string.format("Line %d: %s", selection.start_line + i - 1, line))
    end

    local line1 = selection.start_line
    local line2 = selection.end_line

    -- If we have a range (from command mode) and it's valid
    if line1 > 0 and line2 > 0 and line1 ~= line2 then
        local lines = vim.api.nvim_buf_get_lines(buf, line1 - 1, line2, false)
        content = table.concat(lines, "\n")
        -- vim.notify("Selected code:\n" .. content, vim.log.levels.INFO)
        vim.notify("=========================================")
        local cmd = line1 .. "," .. line2 .. "FloatermSend"
        vim.cmd(cmd)
        -- send_to_aider(content)
        return
    end

    -- Handle visual mode selection (from keybinding)
    if mode == "v" or mode == "V" or mode == "\22" then -- visual, linewise visual, blockwise visual
        local start_pos = vim.api.nvim_buf_get_mark(buf, "<")
        local end_pos = vim.api.nvim_buf_get_mark(buf, ">")
        if start_pos and end_pos then
            local lines = vim.api.nvim_buf_get_lines(buf, start_pos[1] - 1, end_pos[1], false)
            content = table.concat(lines, "\n")
            vim.notify("Selected code:\n" .. content, vim.log.levels.DEBUG)
            send_to_aider(content)
            return
        end
    end

    -- Handle normal mode (single line)
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local line = vim.api.nvim_buf_get_lines(buf, cursor_pos[1] - 1, cursor_pos[1], false)[1]
    content = line
    -- vim.notify("Selected code:\n" .. content, vim.log.levels.INFO)
    send_to_aider(content)
end

function M.create_chat_window()
    -- Check if buffer with same name exists and delete it
    local existing_buf = vim.fn.bufnr("AiderPlus Chat")
    if existing_buf ~= -1 and vim.api.nvim_buf_is_valid(existing_buf) then
        vim.api.nvim_buf_delete(existing_buf, { force = true })
    end

    -- Create new buffer
    chat_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(chat_buf, "AiderPlus Chat")
    vim.api.nvim_buf_set_option(chat_buf, "filetype", "markdown")

    -- Use last window config if available, otherwise create new one
    local opts = last_window_config or {
        relative = "win",
        width = math.floor(vim.o.columns * 0.6),
        height = 3,  -- Show 3 lines
        col = 0,
        row = 0,
        style = "minimal",
        border = "rounded",
    }

    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    opts.col = vim.fn.indent(cursor_pos[1])  -- Align with buffer's text start
    opts.row = cursor_pos[1] - vim.fn.line('w0') + 1  -- Calculate relative row position

    if not chat_win or not vim.api.nvim_win_is_valid(chat_win) then
        chat_win = vim.api.nvim_open_win(chat_buf, true, opts)
    else
        vim.api.nvim_win_set_config(chat_win, opts)
        vim.api.nvim_set_current_win(chat_win)
    end

    -- Set window options for scrollable chat
    vim.api.nvim_win_set_option(chat_win, "number", false)
    vim.api.nvim_win_set_option(chat_win, "relativenumber", false)
    vim.api.nvim_win_set_option(chat_win, "wrap", true)
    vim.api.nvim_win_set_option(chat_win, "scrolloff", 2)  -- Keep 2 lines margin when scrolling
    vim.api.nvim_buf_set_option(chat_buf, "buftype", "")
    vim.api.nvim_buf_set_option(chat_buf, "modifiable", true)
    vim.api.nvim_buf_set_option(chat_buf, "readonly", false)

    -- Set keymaps for the chat window
    vim.api.nvim_buf_set_keymap(chat_buf, "n", "q", "<cmd>lua require('aider-nvim').toggle_chat()<CR>", {noremap = true, silent = true})
    vim.api.nvim_buf_set_keymap(chat_buf, "n", "<ESC>", "<cmd>lua require('aider-nvim').toggle_chat()<CR>", {noremap = true, silent = true})
    vim.api.nvim_buf_set_keymap(chat_buf, "i", "<CR>", "<cmd>lua require('aider-nvim').submit_and_close()<CR>", {noremap = true, silent = true})
    vim.api.nvim_buf_set_keymap(chat_buf, "n", "<CR>", "<cmd>lua require('aider-nvim').submit_and_close()<CR>", {noremap = true, silent = true})
    
    -- Add prompt and enter insert mode
    vim.api.nvim_buf_set_lines(chat_buf, 0, -1, false, {config.prompt})
    
    -- Mark prompt as read-only
    vim.api.nvim_buf_add_highlight(chat_buf, -1, "Comment", 0, 0, #config.prompt)
    vim.api.nvim_buf_set_option(chat_buf, "modifiable", true)
    
    -- Set up autocmd to protect prompt text
    vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI", "TextChangedP"}, {
        buffer = chat_buf,
        callback = function()
            local lines = vim.api.nvim_buf_get_lines(chat_buf, 0, 1, false)
            if not lines[1] or not lines[1]:find("^" .. vim.pesc(config.prompt)) then
                vim.api.nvim_buf_set_lines(chat_buf, 0, 1, false, {config.prompt})
                vim.api.nvim_win_set_cursor(chat_win, {1, #config.prompt + 1})
            end
        end
    })
    
    vim.cmd("startinsert")
    vim.api.nvim_win_set_cursor(chat_win, {1, #config.prompt})  -- 将光标放在提示后
end

function M.toggle_chat()
    if chat_win and vim.api.nvim_win_is_valid(chat_win) then
        -- Save window config before closing
        last_window_config = vim.api.nvim_win_get_config(chat_win)
        vim.api.nvim_win_close(chat_win, true)
        if chat_buf and vim.api.nvim_buf_is_valid(chat_buf) then
            vim.api.nvim_buf_delete(chat_buf, { force = true })
        end
        chat_win = nil
        chat_buf = nil
        vim.cmd("stopinsert")  -- 确保关闭窗口后进入 normal 模式
        vim.notify("Chat closed", vim.log.levels.INFO)
        return
    end
    M.create_chat_window()
    vim.notify("Chat opened", vim.log.levels.INFO)
end

function M.submit_and_close()
    if chat_buf and vim.api.nvim_buf_is_valid(chat_buf) then
        -- Get the current line
        local cursor_pos = vim.api.nvim_win_get_cursor(chat_win)
        local line = vim.api.nvim_buf_get_lines(chat_buf, cursor_pos[1] - 1, cursor_pos[1], false)[1]
        
        -- Extract input after the prompt
        local input = string.sub(line, #config.prompt + 1)
        
        -- TODO: Process the input (send to Aider, etc.)
        if input and #input > 0 then
            vim.notify("Input submitted: " .. input, vim.log.levels.INFO)
        else
            vim.notify("No input provided", vim.log.levels.WARN)
        end
        
        -- Close the chat window
        M.toggle_chat()
    end
end

function M.call_aider_plus()
    -- Call Aider Plus functionality
    vim.notify("Aider Plus called", vim.log.levels.INFO)
    -- TODO: Implement Aider Plus specific logic here
end

return M
