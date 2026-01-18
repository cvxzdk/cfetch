local M = {}

local SEPARATOR_LINE = string.rep("=", 100)

function M.create(path)
    return string.format("\n%s\n%s\n%s", SEPARATOR_LINE, path, SEPARATOR_LINE)
end

function M.create_footer()
    return SEPARATOR_LINE
end

return M