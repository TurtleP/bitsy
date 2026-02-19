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
    local count = select("#", ...)
    self.data:setUInt8(self.offset, ...)
    self.offset = self.offset + count
end

function BinaryWriter:writeInt8(...)
    local count = select("#", ...)
    self.data:setUInt8(self.offset, ...)
    self.offset = self.offset + count
end

function BinaryWriter:writeUInt16(...)
    local count = select("#", ...)
    self.data:setUInt16(self.offset, ...)
    self.offset = self.offset + (2 * count)
end

function BinaryWriter:writeInt16(...)
    local count = select("#", ...)
    self.data:setInt16(self.offset, ...)
    self.offset = self.offset + (2 * count)
end

function BinaryWriter:writeUInt32(...)
    local count = select("#", ...)
    self.data:setUInt32(self.offset, ...)
    self.offset = self.offset + (4 * count)
end

function BinaryWriter:writeInt32(...)
    local count = select("#", ...)
    self.data:setInt32(self.offset, ...)
    self.offset = self.offset + (4 * count)
end

function BinaryWriter:writeFloat(...)
    local count = select("#", ...)
    self.data:setFloat(self.offset, ...)
    self.offset = self.offset + (4 * count)
end

function BinaryWriter:writeDouble(...)
    local count = select("#", ...)
    self.data:setDouble(self.offset, ...)
    self.offset = self.offset + (8 * count)
end

function BinaryWriter:writeString(value)
    assert(type(value) == "string", VALUE_MUST_BE_STRING)
    self.data:setString(value, self.offset)
    self.offset = self.offset + #value
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
