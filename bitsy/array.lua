local path = (...):gsub("array", "")
local DataType = require(path .. "datatype")
local Types = require(path .. "types")

local Array = {}
Array.__index = Array

function Array:new(type, count)
    assert(type and getmetatable(type) == DataType, "Array requires a DataType.")
    count = count or 1
    local size = type:getSize() * count
    local instance = DataType.new(self, tostring(type), size)
    instance.type = type
    instance.count = count
    return instance
end

function Array:read(reader)
    return self.type:read(reader, self.count)
end

function Array:write(writer, ...)
    local length = select("#", ...)
    local value = ...
    if type(value) == "string" then
        -- expand with zeroes
        local s = value .. string.rep("\0", (self.type:getSize() * self.count) - #value)
        return writer:write(self.type, s)
    end
    assert(length == self.count, ("Array write requires exactly %d values, got %d."):format(self.count, length))
    writer:write(self.type, ...)
end

function Array:__tostring()
    return ("<Array %s; %d>"):format(self.name, self.count)
end

return setmetatable(Array, {
    __call = function(cls, ...)
        return cls:new(...)
    end,
    __index = DataType
})
