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
```

## Configuration

```lua
require('aider-nvim').setup({
  auto_start = true,
  keybindings = {
    send_code = "<leader>ac",
    send_selection = "<leader>as",
    toggle_chat = "<leader>at",
  }
})
```

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
