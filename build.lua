local tl = require('tl.tl')


------------------------------------------------
---
--- CONFIG SECTION
---
local SRC_DIR = "src"
local BUILD_DIR = "build"

local SOURCES = {
    "main.tl",
    test = {
        "test.tl"
    }
}
-------------------------------------------------

local OS_PATH_SEP = package.config:sub(1,1)
local USER_PATH_SEP = '/'

local USER_PATH_MCH = "(%w+)/"

function ReadPath(path)
    local segments = {}
    for segment in path:gmatch(USER_PATH_MCH) do
        segments[#segments+1] = segment
    end
    return segments
    
end

function Exists(path)
    return os.execute("cd " .. path) == 0
end

function CreateFolder(path)
    local command = "mkdir"

    if OS_PATH_SEP == '/' then -- unix
        command = command .. ' -p'
    end

    command = command .. ' ' .. path

    local r = os.execute(command)
    assert(r == 0 or r == true, "Command failed: " .. command .. ' (' .. tostring(r) .. ')')
end

function OpenOutput(path)
    -- Attempt to open the file in write mode
    local file, err = io.open(path, "w")

    if file then
        -- File was successfully opened (created or truncated)
        print("File opened (created/truncated): " .. path)
        return file
    else
        -- Error opening the file
        print("Error creating file: " .. path .. " - " .. err)
        return nil
    end
end

function BuildSource(path, src_file_name, src_dir, build_dir)
    local srcNameNoExt = src_file_name:match("^(.+)%.tl$")
    assert(srcNameNoExt ~= nil, "Invalid file name: " .. src_file_name)
    
    local out_file_name = srcNameNoExt .. ".lua"

    local complete_src_path
    local complete_out_path

    if not path or path == '' then
        complete_src_path = src_dir .. OS_PATH_SEP
        complete_out_path = build_dir .. OS_PATH_SEP
    else
        complete_src_path = src_dir .. OS_PATH_SEP .. path .. OS_PATH_SEP
        complete_out_path = build_dir .. OS_PATH_SEP .. path .. OS_PATH_SEP
    end

    local srcfile = io.open(complete_src_path .. src_file_name, 'r')
    assert(srcfile ~= nil, "Couldn't open source file: " .. complete_src_path .. src_file_name)

    if not Exists(complete_out_path) then
        CreateFolder(complete_out_path)
    end

    local outFile = OpenOutput(complete_out_path .. out_file_name)
    assert(outFile ~= nil, "Couldn't open output file: " .. complete_out_path .. out_file_name)

    local lua = tl.gen(srcfile:read("*a"))
    assert(lua,  "Compiler error")

    outFile:write(lua)
    outFile:close()
    srcfile:close()
end

function BuildTree(root, path, src_dir, build_dir)
    for i,v in pairs(root) do
        if type(v) == "table" then
            BuildTree(v, path .. tostring(i), src_dir, build_dir)
        elseif type(v) == "string" then
            BuildSource(path, v, src_dir, build_dir)
        end
    end
end

BuildTree(SOURCES, '', SRC_DIR, BUILD_DIR)