local DataType = require("bitsy.core.datatype")
local types = require("bitsy.core.types")

local Writer = require("bitsy.stream.writer")
local utf8 = require("utf8")

local String = {}
String.__index = String

local INVALID_STRING_BASE_TYPE = "String base type must be uint8_t, uint16_t, or uint32_t, got %s"

String.ValidTypes = {
    [types.UInt8] = true,
    [types.UInt16] = true,
    [types.UInt32] = true
}

function String:new(type, length)
    assert(String.ValidTypes[type], INVALID_STRING_BASE_TYPE:format(type))
    length = length or 1
    local self = DataType.new(self, tostring(type), length * type:getSize())
    self.type = type
    self.length = length
    return self
end

local function get_codepoints(value)
    local codepoints = {}
    for _, codepoint in utf8.codes(value) do
        table.insert(codepoints, codepoint)
    end
    return codepoints
end

function String:read(reader)
    local value = self.type:read(reader, self.length)
    if type(value) == "table" then
        local characters = {}
        for index = 1, #value do
            table.insert(characters, utf8.char(value[index]))
        end
        return table.concat(characters)
    end
    return utf8.char(value)
end

function String:write(writer, ...)
    local first = select(1, ...)
    if type(first) == "string" then
        local codepoints = get_codepoints(first)
        return writer:write(self.type, codepoints)
    end
    writer:write(self.type, ...)
end

function String:__tostring()
    return ("<String[%d]>"):format(self.length)
end

return setmetatable(String, {
    __call = function(cls, ...)
        return cls:new(...)
    end,
    __index = DataType
})
