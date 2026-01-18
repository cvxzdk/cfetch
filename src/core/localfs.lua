local tree = require('core.tree')
local filter = require('core.filter')
local error_handler = require('utils.error')

local M = {}

local function is_directory(path)
    -- Handle current directory
    if path == "." or path == ".." then
        return true
    end
    
    -- Use dir command with /AD to check if it's a directory
    local handle = io.popen('dir /AD /B "' .. path .. '" 2>nul')
    if handle then
        local result = handle:read("*a")
        handle:close()
        -- If dir /AD returns nothing for the path itself, it's not a directory
        -- Instead, check attributes
    end
    
    -- Alternative: try to open as directory
    local test_handle = io.popen('dir /B "' .. path .. '" 2>nul')
    if test_handle then
        local content = test_handle:read("*a")
        test_handle:close()
        return content ~= ""
    end
    
    return false
end

local function file_exists(path)
    -- Handle current directory
    if path == "." or path == ".." then
        return true
    end
    
    local f = io.open(path, "r")
    if f then
        f:close()
        return true
    end
    
    -- Try as directory
    return is_directory(path)
end

local function scan_directory(path, options, prefix)
    prefix = prefix or ""
    local structure = {}
    
    -- Get directories first
    local dir_handle = io.popen('dir /AD /B "' .. path .. '" 2>nul')
    local directories = {}
    if dir_handle then
        for dirname in dir_handle:lines() do
            if dirname ~= "." and dirname ~= ".." then
                directories[dirname] = true
            end
        end
        dir_handle:close()
    end
    
    -- Get all items
    local handle = io.popen('dir /B "' .. path .. '" 2>nul')
    if not handle then
        return structure
    end
    
    for filename in handle:lines() do
        if filename ~= "." and filename ~= ".." then
            local full_path = path .. "\\" .. filename
            local item_type = directories[filename] and "dir" or "file"
            
            if filter.should_include(filename, item_type, options) then
                local node = {
                    name = filename,
                    type = item_type,
                    path = full_path:gsub("^%.\\", ""),
                }
                
                if item_type == "dir" then
                    node.children = scan_directory(full_path, options, prefix .. "  ")
                end
                
                table.insert(structure, node)
            end
        end
    end
    
    handle:close()
    
    -- Sort: directories first, then files
    table.sort(structure, function(a, b)
        if a.type ~= b.type then
            return a.type == "dir"
        end
        return a.name < b.name
    end)
    
    return structure
end

local function read_file_contents(tree_structure, options)
    local contents = {}
    
    local function traverse(nodes)
        for _, node in ipairs(nodes) do
            if node.type == "file" then
                local f = io.open(node.path, "r")
                if f then
                    local content = f:read("*all")
                    f:close()
                    table.insert(contents, {
                        path = node.path,
                        content = content
                    })
                end
            elseif node.children then
                traverse(node.children)
            end
        end
    end
    
    traverse(tree_structure)
    return contents
end

function M.fetch(path, options)
    if not file_exists(path) then
        error_handler.throw("Path does not exist: " .. path)
    end
    
    local tree_structure
    
    if is_directory(path) then
        tree_structure = scan_directory(path, options)
    else
        -- Single file
        tree_structure = {{
            name = path:match("([^/\\]+)$"),
            type = "file",
            path = path
        }}
    end
    
    local contents = nil
    if not options.tree_only then
        contents = read_file_contents(tree_structure, options)
    end
    
    return tree_structure, contents
end

return M