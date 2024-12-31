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
    else
      vim.notify("Invalid action for AiderPlus. Available actions: send_code, send_selection", vim.log.levels.ERROR)
    end
  end, {
    nargs = 1,
    complete = function()
      return { "send_code", "send_selection" }
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
  -- Send current buffer content to Aider
  local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  -- TODO: Send to Aider
  vim.notify("Code sent to Aider", vim.log.levels.INFO)
end

function M.send_selection()
  -- Send visual selection to Aider
  local start_pos = vim.api.nvim_buf_get_mark(0, "<")
  local end_pos = vim.api.nvim_buf_get_mark(0, ">")
  local lines = vim.api.nvim_buf_get_lines(0, start_pos[1] - 1, end_pos[1], false)
  local content = table.concat(lines, "\n")
  -- TODO: Send to Aider
  vim.notify("Selection sent to Aider", vim.log.levels.INFO)
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
