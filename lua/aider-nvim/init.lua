local M = {}

local config = {
  -- Default configuration options
  auto_start = true,
  keybindings = {
    send_code = "<leader>ac",
    send_selection = "<leader>as",
    toggle_chat = "<leader>at",
  },
}

function M.setup(user_config)
  config = vim.tbl_deep_extend("force", config, user_config or {})
  M.setup_keybindings()
  if config.auto_start then
    M.start_aider()
  end
end

function M.setup_keybindings()
  vim.keymap.set("n", config.keybindings.send_code, M.send_code, { desc = "Send code to Aider" })
  vim.keymap.set("v", config.keybindings.send_selection, M.send_selection, { desc = "Send selection to Aider" })
  vim.keymap.set("n", config.keybindings.toggle_chat, M.toggle_chat, { desc = "Toggle Aider chat" })
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

return M
