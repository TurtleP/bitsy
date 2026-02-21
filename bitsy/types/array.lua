local DataType = require("bitsy.core.datatype")
local Struct = require("bitsy.types.struct")

local Array = {}
Array.__index = Array

local ARRAY_REQUIRES_DATATYPE = "Array requires a DataType."
local INVALID_ARRAY_WRITE_COUNT = "Array write requires exactly %d values, got %d."

function Array:new(type, count)
    assert(type and DataType.isSubtype(type), ARRAY_REQUIRES_DATATYPE)
    count = count or 1
    local size = type:getSize() * count
    local instance = DataType.new(self, tostring(type), size)
    instance.type = type
    instance.count = count
    return instance
end

function Array:read(reader)
    if DataType.isSubtype(self.type, Struct) then
        local values = {}
        for i = 1, self.count do
            values[i] = self.type:read(reader)
        end
        return values
    end
    return self.type:read(reader, self.count)
end

function Array:write(writer, ...)
    local length = select("#", ...)
    assert(length == self.count, INVALID_ARRAY_WRITE_COUNT:format(self.count, length))
    writer:write(self.type, ...)
end

function Array:__tostring()
    return ("<Array<%s>[%d]>"):format(self.type, self.count)
end

return setmetatable(Array, {
    __call = function(cls, ...)
        return cls:new(...)
    end,
    __index = DataType
})
