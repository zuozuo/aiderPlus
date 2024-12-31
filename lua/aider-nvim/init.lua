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
  
  -- 设置 autocmd 在保存 Lua 文件时调用 Lazy
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.lua",
    callback = function()
      if Lazy then
        Lazy()
      end
    end,
    desc = "Call Lazy after saving Lua files"
  })

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
  vim.notify("==============111=======================", vim.log.levels.INFO)
  local buf = vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buf) then
    vim.notify("Invalid buffer", vim.log.levels.ERROR)
    return
  end

  local content = ""
  local mode = vim.fn.mode()
  
  -- Check if we have a range from command mode
  local line1 = vim.v.lnum1 or 0
  local line2 = vim.v.lnum2 or 0
  
  vim.notify("Line1: " .. line1 .. ", Line2: " .. line2, vim.log.levels.INFO)
  -- If we have a range (from command mode) and it's valid
  if line1 > 0 and line2 > 0 and line1 ~= line2 then
    local lines = vim.api.nvim_buf_get_lines(buf, line1 - 1, line2, false)
    content = table.concat(lines, "\n")
    vim.notify("Selected code:\n" .. content, vim.log.levels.INFO)
    -- TODO: Send to Aider
    vim.notify("Selection sent to Aider", vim.log.levels.INFO)
    return
  end
  
  -- Handle visual mode selection (from keybinding)
  if mode == "v" or mode == "V" or mode == "\22" then  -- visual, linewise visual, blockwise visual
    local start_pos = vim.api.nvim_buf_get_mark(buf, "<")
    local end_pos = vim.api.nvim_buf_get_mark(buf, ">")
    if start_pos and end_pos then
      local lines = vim.api.nvim_buf_get_lines(buf, start_pos[1] - 1, end_pos[1], false)
      content = table.concat(lines, "\n")
      vim.notify("Selected code:\n" .. content, vim.log.levels.INFO)
      -- TODO: Send to Aider
      vim.notify("Selection sent to Aider", vim.log.levels.INFO)
      return
    end
  end

  -- Handle normal mode (single line)
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_buf_get_lines(buf, cursor_pos[1] - 1, cursor_pos[1], false)[1]
  content = line
  vim.notify("Selected code:\n" .. content, vim.log.levels.INFO)
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
