local path                 = (...):gsub("writer", "")
local Stream               = require(path .. "stream")

local VALUE_MUST_BE_STRING = "Value must be a string"

local BinaryWriter         = {}
BinaryWriter.__index       = BinaryWriter
BinaryWriter.__tostring    = Stream.__tostring

function BinaryWriter.new(size)
    local data = love.data.newByteData(size)
    return BinaryWriter.from(data)
end

function BinaryWriter.from(data, offset)
    local self = setmetatable({}, BinaryWriter)
    data = type(data) == "string" and love.data.newByteData(data) or data
    Stream.new(self, data, offset)
    return self
end

function BinaryWriter:writeUInt8(...)
    self.data:setUInt8(self.offset, ...)
end

function BinaryWriter:writeInt8(...)
    self.data:setUInt8(self.offset, ...)
end

function BinaryWriter:writeUInt16(...)
    self.data:setUInt16(self.offset, ...)
end

function BinaryWriter:writeInt16(...)
    self.data:setInt16(self.offset, ...)
end

function BinaryWriter:writeUInt32(...)
    self.data:setUInt32(self.offset, ...)
end

function BinaryWriter:writeInt32(...)
    self.data:setInt32(self.offset, ...)
end

function BinaryWriter:writeFloat(...)
    self.data:setFloat(self.offset, ...)
end

function BinaryWriter:writeDouble(...)
    self.data:setDouble(self.offset, ...)
end

function BinaryWriter:writeString(value)
    assert(type(value) == "string", VALUE_MUST_BE_STRING)
    self.data:setString(value, self.offset)
end

function BinaryWriter:write(type, ...)
    return type:write(self, ...)
end

return setmetatable(BinaryWriter, {
    __call = function(_, size)
        return BinaryWriter.new(size)
    end,
    __index = Stream
})
