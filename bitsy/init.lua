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

local path = (...)

-- Imports a lua file, relative to this file's path
-- https://github.com/1bardesign/batteries/blob/master/init.lua#L7-L10
local function import(filepath)
    return require(table.concat({ path, filepath }, "."))
end

bitsy.SeekType = import("seek")
bitsy.Type     = import("types")
bitsy.Reader   = import("reader")
bitsy.Writer   = import("writer")
bitsy.Struct   = import("struct")
bitsy.Magic    = import("magic")
bitsy.Field    = import("field")
bitsy.Array    = import("array")

return bitsy
