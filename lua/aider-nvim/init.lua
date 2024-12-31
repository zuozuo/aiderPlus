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
      -- Handle visual selection range
      local start_line = opts.line1
      local end_line = opts.line2
      if start_line ~= end_line then
        local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
        local content = table.concat(lines, "\n")
        -- TODO: Send to Aider
        vim.notify("Selection sent to Aider111", vim.log.levels.INFO)
      else
        M.send_selection()
      end
    elseif action == "toggle_chat" then
      M.toggle_chat()
    elseif action == "call_aider_plus" then
      M.call_aider_plus()
    else
      vim.notify("Invalid action for AiderPlus. Available actions: send_code, send_selection, toggle_chat, call_aider_plus", vim.log.levels.ERROR)
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

function M.send_selection()
  local buf = vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buf) then
    vim.notify("Invalid buffer", vim.log.levels.ERROR)
    return
  end

  -- Check if in visual mode
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then  -- visual, linewise visual, blockwise visual
    local start_pos = vim.api.nvim_buf_get_mark(buf, "<")
    local end_pos = vim.api.nvim_buf_get_mark(buf, ">")
    if start_pos and end_pos then
      local lines = vim.api.nvim_buf_get_lines(buf, start_pos[1] - 1, end_pos[1], false)
      local content = table.concat(lines, "\n")
      vim.notify("Selected code:\n" .. content, vim.log.levels.INFO)
      -- TODO: Send to Aider
      vim.notify("Selection sent to Aider", vim.log.levels.INFO)
      return
    end
  end

  -- If not in visual mode, send current line
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_buf_get_lines(buf, cursor_pos[1] - 1, cursor_pos[1], false)[1]
  vim.notify("Selected code:\n" .. line, vim.log.levels.INFO)
  -- TODO: Send to Aider
  vim.notify("Current line sent to Aider", vim.log.levels.INFO)
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
