local M = {}

local DEFAULT_IGNORE = {
    "^%.git$",
    "^%.gitignore$",
    "^node_modules$",
    "^%.DS_Store$",
    "^__pycache__$",
    "%.pyc$",
    "^dist$",
    "^build$",
    "^%.vscode$",
    "^%.idea$",
}

local function matches_pattern(name, patterns)
    for _, pattern in ipairs(patterns) do
        if name:match(pattern) then
            return true
        end
    end
    return false
end

local function has_extension(filename, extensions)
    if #extensions == 0 then
        return true
    end
    
    for _, ext in ipairs(extensions) do
        if filename:match(ext .. "$") then
            return true
        end
    end
    return false
end

function M.should_include(name, item_type, options)
    -- Check ignore patterns
    if not options.show_ignored and matches_pattern(name, DEFAULT_IGNORE) then
        return false
    end
    
    -- For directories, always include (filtering happens on files)
    if item_type == "dir" then
        return true
    end
    
    -- Include/exclude extensions
    if #options.include_exts > 0 then
        return has_extension(name, options.include_exts)
    end
    
    if #options.exclude_exts > 0 then
        return not has_extension(name, options.exclude_exts)
    end
    
    if #options.extensions > 0 then
        return has_extension(name, options.extensions)
    end
    
    return true
end

return M