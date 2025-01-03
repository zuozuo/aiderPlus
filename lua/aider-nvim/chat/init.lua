local M = {}
local buffer = require("aider-nvim.chat.buffer")

function M.toggle()
  buffer.create()
end

-- Cache for sent file paths
local sent_files = {}

function M.submit(full_message)
  -- Print the full message for debugging
  -- vim.notify("Submitting full message:\n" .. full_message)
  dd(full_message)

  if not full_message or #full_message == 0 then return end

  local config = require("aider-nvim.config").get()

  -- -- 检查是否存在名为 AiderPlus-Chat 的 floaterm 窗口
  -- local term_bufnr = vim.fn["floaterm#terminal#get_bufnr"]("AiderPlus-Chat")
  --
  -- if term_bufnr ~= -1 then
  --   -- 如果存在则显示窗口
  --   vim.fn["floaterm#terminal#open_existing"](term_bufnr)
  -- else
  --   vim.notify("AiderPlus-Chat terminal not found, please create a new one", vim.log.levels.INFO)
  --   return
  -- end

  -- 将输入发送到 floaterm

  -- Get original buffer's file path and send it first
  local original_buf = require("aider-nvim.chat.buffer").get_original_buf()
  -- dd(vim.api.nvim_buf_is_valid(original_buf))
  dd(original_buf)
  if original_buf and vim.api.nvim_buf_is_valid(original_buf) then
    local full_path = vim.api.nvim_buf_get_name(original_buf)
    dd("full_path"..full_path)
    if full_path and #full_path > 0 and not full_path:match("^term://") then
      -- Get relative path from current working directory
      local cwd = vim.fn.getcwd()
      local rel_path = full_path:gsub("^" .. cwd .. "/", "")
      dd(cwd)

      -- Only send if we haven't sent this file before
      if not sent_files[rel_path] then
        dd('================================')
        -- vim.fn["floaterm#terminal#send"](term_bufnr, {"/add " .. rel_path})
        sent_files[rel_path] = true  -- Mark as sent
      end
    end
  end
  dd(sent_files)

  -- Send the user input with context info
  vim.fn["floaterm#terminal#send"](term_bufnr, {full_message})
end

return M
