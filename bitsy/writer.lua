local path = (...):gsub("writer", "")
local Stream = require(path .. "stream")


local BinaryWriter      = {}
BinaryWriter.__index    = BinaryWriter
BinaryWriter.__tostring = Stream.__tostring

function BinaryWriter.new(size)
    Stream.new(BinaryWriter, love.data.newByteData(size), 0)
    return setmetatable({}, BinaryWriter)
end

function BinaryWriter.from(data)
    data = type(data) == "string" and love.data.newByteData(data) or data
    Stream.new(BinaryWriter, data, 0)
    return setmetatable({}, BinaryWriter)
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
    assert(type(value) == "string", "value must be a string")
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
