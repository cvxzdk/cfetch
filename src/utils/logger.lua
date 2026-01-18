local M = {}

M.LEVEL = {
    DEBUG = 1,
    INFO = 2,
    ERROR = 3,
}

M.current_level = M.LEVEL.INFO

function M.debug(message)
    if M.current_level <= M.LEVEL.DEBUG then
        io.stderr:write("[DEBUG] " .. message .. "\n")
    end
end

function M.info(message)
    if M.current_level <= M.LEVEL.INFO then
        io.stderr:write("[INFO] " .. message .. "\n")
    end
end

function M.error(message)
    if M.current_level <= M.LEVEL.ERROR then
        io.stderr:write("[ERROR] " .. message .. "\n")
    end
end

return M