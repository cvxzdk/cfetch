package.path = package.path .. ';.\\src\\?.lua;.\\src\\?\\init.lua'

local app = require('init')
local cli = require('cli')

-- Get command line arguments
local args = arg

local success, err = pcall(function()
    cli.run(args)
end)

if not success then
    io.stderr:write("Error: " .. tostring(err) .. "\n")
    os.exit(1)
end