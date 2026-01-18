local error_handler = require('utils.error')

local M = {}

function M.export(content, filename)
    local f, err = io.open(filename, "w")
    if not f then
        error_handler.throw("Failed to write to file: " .. tostring(err))
    end
    
    f:write(content)
    f:close()
end

return M