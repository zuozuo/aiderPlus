local M = {}

M.default_config = {
    auto_start = true,
    prompt = "Send text to Aider:  ",
    code_context_window = 2,  -- 获取光标上下20行代码作为上下文
    keybindings = {
        send_code = "<leader>ac",
        send_selection = "<leader>as",
        toggle_chat = "<leader>at",
        call_aider_plus = "<leader>ap",
    },
}

function M.setup(user_config)
    M.config = vim.tbl_deep_extend("force", M.default_config, user_config or {})
    return M.config
end

function M.get()
    return M.config
end

return M
