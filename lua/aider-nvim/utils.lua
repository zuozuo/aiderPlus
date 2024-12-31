local M = {}

function M.get_visual_selection_range()
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")

    local start_line = start_pos[2]
    local end_line = end_pos[2]

    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    vim.notify(string.format("Selected lines: %d - %d", start_line, end_line), vim.log.levels.INFO)

    return {
        start_line = start_line,
        end_line = end_line,
        content = lines
    }
end

return M
