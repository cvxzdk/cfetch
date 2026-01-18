local M = {}

function M.generate_tree(structure, prefix, is_last)
    prefix = prefix or ""
    local lines = {}
    
    for i, node in ipairs(structure) do
        local is_last_item = (i == #structure)
        local connector = is_last_item and "+-- " or "|-- "
        local name = node.type == "dir" and (node.name .. "/") or node.name
        
        table.insert(lines, prefix .. connector .. name)
        
        if node.children then
            local new_prefix = prefix .. (is_last_item and "    " or "|   ")
            local child_lines = M.generate_tree(node.children, new_prefix, is_last_item)
            for _, line in ipairs(child_lines) do
                table.insert(lines, line)
            end
        end
    end
    
    return lines
end

return M