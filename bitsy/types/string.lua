local DataType = require("bitsy.core.datatype")
local types = require("bitsy.core.types")

local utf8 = require("utf8")

local String = {}
String.__index = String

local INVALID_STRING_BASE_TYPE = "String base type must be UInt8 or UInt16"

function String:new(type, length)
    assert(type == types.UInt8 or type == types.UInt16, INVALID_STRING_BASE_TYPE)
    length = length or 1
    local self = DataType.new(self, tostring(type), length * type:getSize())
    self.type = type
    self.length = length
    return self
end

function String:read(reader)
    local value = self.type:read(reader, self.length)
    if type(value) == "table" then
        return utf8.char(unpack(value))
    end
    return utf8.char(value)
end

function String:write(writer, ...)
    local count, value = select("#", ...), { ... }
    if count == 1 and type(value[1]) == "string" then
        return writer:writeString(value[1])
    end
    writer:write(self.type, ...)
end

function String:__tostring()
    return ("<String %d>"):format(self.length)
end

return setmetatable(String, {
    __call = function(cls, ...)
        return cls:new(...)
    end,
    __index = DataType
})
