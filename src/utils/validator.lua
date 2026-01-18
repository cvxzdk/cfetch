local M = {}

function M.is_github_url(str)
    return str:match("github%.com") ~= nil or str:match("^[^/]+/[^/]+$") ~= nil
end

function M.is_valid_path(path)
    return path and path ~= ""
end

return M