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
  end
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
