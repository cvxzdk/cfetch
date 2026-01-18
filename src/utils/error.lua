local M = {}

function M.throw(message)
    error(message, 2)
end

return M