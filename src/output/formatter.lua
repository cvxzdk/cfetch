local tree = require('core.tree')
local separator = require('output.separator')

local M = {}

local function add_line_numbers(content)
    local lines = {}
    local line_num = 1
    
    for line in content:gmatch("([^\n]*)\n?") do
        if line ~= "" or content:sub(-1) == "\n" then
            table.insert(lines, string.format("%4d  %s", line_num, line))
            line_num = line_num + 1
        end
    end
    
    return table.concat(lines, "\n")
end

function M.format(tree_structure, contents, options)
    local output = {}
    
    -- Add tree
    if not options.content_only then
        local tree_lines = tree.generate_tree(tree_structure)
        table.insert(output, table.concat(tree_lines, "\n"))
        
        if contents and #contents > 0 then
            table.insert(output, "\n")
        end
    end
    
    -- Add contents
    if contents and not options.tree_only then
        for i, file in ipairs(contents) do
            table.insert(output, separator.create(file.path))
            
            if options.line_numbers then
                table.insert(output, add_line_numbers(file.content))
            else
                table.insert(output, file.content)
            end
            
            table.insert(output, separator.create_footer())
            
            if i < #contents then
                table.insert(output, "\n")
            end
        end
    end
    
    return table.concat(output, "\n")
end

return M