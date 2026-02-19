--
-- bitsy
-- Copyright (c) TurtleP
--

local bitsy = { version = "0.1.0" }

-- Quick sanity check for the environment!
local success, _ = pcall(require, "love")
assert(success, "bitsy requires LÖVE")
success = love._version_major >= 12
assert(success, "LÖVE version 12 or higher required")

local PATH = (...):gsub("[^%.]+$", "")

local function import(module)
    return require(PATH .. module)
end

local paths = love.filesystem.getRequirePath()

local function load()
    love.filesystem.setRequirePath(paths .. (";%s/?.lua"):format(PATH))

    local Stream = import("bitsy.stream")
    for stream_name, value in pairs(Stream) do
        bitsy[stream_name] = value
    end

    local Types = import("bitsy.types")
    for type_name, value in pairs(Types) do
        bitsy[type_name] = value
    end

    local Core = import("bitsy.core")
    for core_name, value in pairs(Core) do
        bitsy[core_name] = value
    end

    love.filesystem.setRequirePath(paths)

    return bitsy
end

return load()
