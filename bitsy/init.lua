--
-- bitsy
-- Copyright (c) TurtleP
--

local bitsy = { version = "0.1.0" }
local path = (...)

-- Imports a lua file, relative to this file's path
-- https://github.com/1bardesign/batteries/blob/master/init.lua#L7-L10
local function import(filepath)
    return require(table.concat({ path, filepath }, "."))
end

bitsy.SeekType = import("seek")
bitsy.Types    = import("types")
bitsy.Reader   = import("reader")
bitsy.Writer   = import("writer")
bitsy.Struct   = import("struct")
bitsy.Magic    = import("magic")
bitsy.Field    = import("field")
bitsy.Array    = import("array")

return bitsy
