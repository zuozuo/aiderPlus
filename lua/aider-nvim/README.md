# aider.nvim

A Neovim plugin to enhance the Aider experience.

## Features

- Easy keybindings for sending code and selections
- Toggleable chat window
- Automatic Aider process management

## Installation

Using packer.nvim:

```lua
use {
  'your-username/aider.nvim',
  config = function()
    require('aider-nvim').setup({
      -- Configuration options
    })
  end,
  -- Ensure the plugin is loaded
  after = "nvim-lspconfig"
}

-- Note: Do not call setup() directly in the plugin code
-- The setup() function should only be called once in your configuration

Using lazy.nvim:

```lua
{
  "your-username/aider.nvim",
  dependencies = {
    "nvim-lspconfig"
  },
  config = function()
    require("aider-nvim").setup({
      -- Configuration options
    })
  end,
}

-- Note: Do not call setup() directly in the plugin code
-- The setup() function should only be called once in your configuration

## Configuration

```lua
require('aider-nvim').setup({
  auto_start = true,
  prompt = "Send text to Aider:  ",  -- 自定义提示符
  code_context_window = 2,          -- 获取光标上下2行代码作为上下文
  quick_commands = {                -- 自定义快速命令
    "/explain this",
    "/fix that", 
    "/refactor this",
    "/add comments"
  },
  keybindings = {
    send_code = "<leader>ac",       -- 发送当前buffer内容
    send_selection = "<leader>as",  -- 发送选中内容
    toggle_chat = "<leader>at",     -- 切换聊天窗口
    call_aider_plus = "<leader>ap", -- 调用Aider Plus功能
  }
})
```

### 快速命令
在聊天窗口中输入`/`可以触发快速命令补全，默认包含：
- `/explain this` - 解释代码
- `/fix that` - 修复代码
- `/refactor this` - 重构代码
- `/add comments` - 添加注释

你可以通过`quick_commands`配置项自定义快速命令列表。

### 窗口布局
聊天窗口会自动对齐到代码的缩进位置，并留有4字符的左边距，确保与代码保持视觉一致性。

## Keybindings

- `<leader>ac` - Send current buffer content to Aider
- `<leader>as` - Send visual selection to Aider
- `<leader>at` - Toggle Aider chat window
- `<leader>ap` - Call Aider Plus functionality

## Aider Plus

The `call_aider_plus` function provides extended Aider capabilities. You can call it via:

1. Default keybinding: `<leader>ap`
2. Vim command with specific action:
```vim
:AiderPlus send_code
:AiderPlus send_selection
:AiderPlus toggle_chat
:AiderPlus call_aider_plus
```
3. Direct Lua call:
```lua
require('aider-nvim').call_aider_plus()
```

To customize the keybinding:
```lua
require('aider-nvim').setup({
  keybindings = {
    call_aider_plus = "<your-preferred-keybinding>"
  }
})
```
