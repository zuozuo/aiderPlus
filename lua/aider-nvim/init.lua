local M = {}

local config = {
    -- Default configuration options
    auto_start = true,
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
    vim.notify("Aider started", vim.log.levels.INFO)
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

    vim.cmd("'<,'>FloatermSend")
    return

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

function M.toggle_chat()
    -- Toggle Aider chat window
    vim.notify("Chat toggled", vim.log.levels.INFO)
end

function M.call_aider_plus()
    -- Call Aider Plus functionality
    vim.notify("Aider Plus called", vim.log.levels.INFO)
    -- TODO: Implement Aider Plus specific logic here
end

return M
