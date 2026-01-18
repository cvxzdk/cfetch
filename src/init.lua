local M = {}

M.VERSION = "1.0.0"
M.NAME = "cfetch"

function M.get_version()
    local f = io.open("VERSION", "r")
    if f then
        local version = f:read("*line")
        f:close()
        return version or M.VERSION
    end
    return M.VERSION
end

return M