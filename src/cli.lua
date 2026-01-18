local github = require('core.github')
local localfs = require('core.localfs')
local formatter = require('output.formatter')
local exporter = require('output.exporter')
local logger = require('utils.logger')
local validator = require('utils.validator')
local app = require('init')

local M = {}

local function print_help()
    print([[
cfetch - Code Fetcher and Analyzer

Usage:
    cfetch [options] [path|url]
    
Options:
    -h, --help              Show this help message
    -v, --version           Show version
    -b, --branch <branch>   Specify branch/tag/commit (GitHub only)
    -t, --tree-only         Show only file tree
    -c, --content-only      Show only file contents
    -e, --ext <ext>         Filter by extensions (comma-separated: .py,.js)
    -i, --include <ext>     Include only these extensions
    -x, --exclude <ext>     Exclude these extensions
    --show-ignored          Show ignored files in tree
    -o, --output <file>     Export to file
    -l, --local             Force local mode (default if no URL)
    --no-line-numbers       Don't show line numbers
    
Examples:
    cfetch                                  # Analyze current directory
    cfetch ./src                            # Analyze specific directory
    cfetch https://github.com/user/repo    # Fetch GitHub repo
    cfetch user/repo -b main               # Fetch specific branch
    cfetch -e .lua,.md                     # Only .lua and .md files
    cfetch -o output.txt                   # Export to file
]])
end

local function parse_args(args)
    local options = {
        path = ".",
        branch = nil,
        tree_only = false,
        content_only = false,
        extensions = {},
        include_exts = {},
        exclude_exts = {},
        show_ignored = false,
        output_file = nil,
        local_mode = false,
        line_numbers = true,
    }
    
    local i = 1
    while i <= #args do
        local arg = args[i]
        
        if arg == "-h" or arg == "--help" then
            print_help()
            os.exit(0)
        elseif arg == "-v" or arg == "--version" then
            print(app.NAME .. " v" .. app.get_version())
            os.exit(0)
        elseif arg == "-b" or arg == "--branch" then
            i = i + 1
            options.branch = args[i]
        elseif arg == "-t" or arg == "--tree-only" then
            options.tree_only = true
        elseif arg == "-c" or arg == "--content-only" then
            options.content_only = true
        elseif arg == "-e" or arg == "--ext" then
            i = i + 1
            for ext in string.gmatch(args[i], "[^,]+") do
                table.insert(options.extensions, ext)
            end
        elseif arg == "-i" or arg == "--include" then
            i = i + 1
            for ext in string.gmatch(args[i], "[^,]+") do
                table.insert(options.include_exts, ext)
            end
        elseif arg == "-x" or arg == "--exclude" then
            i = i + 1
            for ext in string.gmatch(args[i], "[^,]+") do
                table.insert(options.exclude_exts, ext)
            end
        elseif arg == "--show-ignored" then
            options.show_ignored = true
        elseif arg == "-o" or arg == "--output" then
            i = i + 1
            options.output_file = args[i]
        elseif arg == "-l" or arg == "--local" then
            options.local_mode = true
        elseif arg == "--no-line-numbers" then
            options.line_numbers = false
        elseif not arg:match("^%-") then
            options.path = arg
        end
        
        i = i + 1
    end
    
    return options
end

function M.run(args)
    local options = parse_args(args)
    
    -- Determine if GitHub or local
    local is_github = validator.is_github_url(options.path) and not options.local_mode
    
    local tree_data, contents
    
    if is_github then
        logger.info("Fetching from GitHub: " .. options.path)
        tree_data, contents = github.fetch(options.path, options)
    else
        logger.info("Analyzing local path: " .. options.path)
        tree_data, contents = localfs.fetch(options.path, options)
    end
    
    -- Format output
    local output = formatter.format(tree_data, contents, options)
    
    -- Display or export
    if options.output_file then
        exporter.export(output, options.output_file)
        logger.info("Exported to: " .. options.output_file)
    else
        print(output)
    end
end

return M