local M = {}

function M.load(path)
    path = path or ".cfetchrc"
    
    local f = io.open(path, "r")
    if not f then
        return {}
    end
    
    local content = f:read("*all")
    f:close()
    
    -- Simple config parser
    local config = {}
    for line in content:gmatch("[^\n]+") do
        local key, value = line:match("^([^=]+)=(.+)$")
        if key and value then
            config[key:match("^%s*(.-)%s*$")] = value:match("^%s*(.-)%s*$")
        end
    end
    
    return config
end

return M