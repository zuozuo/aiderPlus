local M = {}

function M.get_visual_selection_range()
    local buffer = require("aider-nvim.chat.buffer")
    local selection = buffer.get_original_visual_selection()
    
    if not selection then
        return {
            start_line = 0,
            end_line = 0,
            content = {}
        }
    end
    
    vim.notify(string.format("Selected lines: %d - %d", selection.start_line, selection.end_line), vim.log.levels.INFO)
    
    return selection
end

return M
