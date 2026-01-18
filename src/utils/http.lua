local M = {}

function M.get(url)
    local handle = io.popen('curl -s -L "' .. url .. '" 2>nul')
    if not handle then
        return nil, "Failed to execute curl"
    end
    
    local result = handle:read("*all")
    handle:close()
    
    -- Try to decode JSON if it looks like JSON
    if result:match("^%s*[%[{]") then
        return M.decode_json(result)
    end
    
    return result
end

function M.decode_json(str)
    -- Simple JSON decoder (you might want to use a proper library like dkjson)
    -- This is a basic implementation
    local json = str:gsub("%s+", " ")
    
    -- Very basic array parsing for GitHub API
    if json:match("^%s*%[") then
        local items = {}
        for item in json:gmatch("{(.-)}") do
            local obj = {}
            for key, value in item:gmatch('"([^"]+)"%s*:%s*"([^"]*)"') do
                obj[key] = value
            end
            for key, value in item:gmatch('"([^"]+)"%s*:%s*([^,}]+)') do
                if value ~= "null" and not value:match('"') then
                    obj[key] = value
                end
            end
            table.insert(items, obj)
        end
        return items
    end
    
    return str
end

return M