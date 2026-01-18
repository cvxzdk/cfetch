local http = require('utils.http')
local tree = require('core.tree')
local filter = require('core.filter')
local error_handler = require('utils.error')

local M = {}

local function parse_github_url(url)
    -- Match: https://github.com/user/repo or user/repo
    local user, repo = url:match("github%.com/([^/]+)/([^/]+)")
    if not user then
        user, repo = url:match("^([^/]+)/([^/]+)$")
    end
    
    if repo then
        repo = repo:gsub("%.git$", "")
    end
    
    return user, repo
end

local function fetch_tree_from_api(user, repo, branch, path)
    path = path or ""
    local api_url = string.format(
        "https://api.github.com/repos/%s/%s/contents/%s",
        user, repo, path
    )
    
    if branch then
        api_url = api_url .. "?ref=" .. branch
    end
    
    local response, err = http.get(api_url)
    if not response then
        error_handler.throw("Failed to fetch from GitHub: " .. tostring(err))
    end
    
    return response
end

local function build_tree_structure(items, options, user, repo, branch, prefix)
    prefix = prefix or ""
    local structure = {}
    
    for _, item in ipairs(items) do
        if filter.should_include(item.name, item.type, options) then
            local node = {
                name = item.name,
                type = item.type,
                path = item.path,
                url = item.download_url,
            }
            
            if item.type == "dir" then
                local subitems = fetch_tree_from_api(user, repo, branch, item.path)
                node.children = build_tree_structure(subitems, options, user, repo, branch, prefix .. "  ")
            end
            
            table.insert(structure, node)
        end
    end
    
    return structure
end

local function fetch_file_contents(tree_structure, options)
    local contents = {}
    
    local function traverse(nodes)
        for _, node in ipairs(nodes) do
            if node.type == "file" and node.url then
                local content, err = http.get(node.url)
                if content then
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

function M.fetch(url, options)
    local user, repo = parse_github_url(url)
    
    if not user or not repo then
        error_handler.throw("Invalid GitHub URL: " .. url)
    end
    
    local items = fetch_tree_from_api(user, repo, options.branch, "")
    local tree_structure = build_tree_structure(items, options, user, repo, options.branch)
    
    local contents = nil
    if not options.tree_only then
        contents = fetch_file_contents(tree_structure, options)
    end
    
    return tree_structure, contents
end

return M