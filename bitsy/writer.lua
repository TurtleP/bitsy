local path = (...):gsub("writer", "")

local Stream = require(path .. "stream")
local SeekType = require(path .. "seek")
local Types = require(path .. "types")


local BinaryWriter   = {}
BinaryWriter.__index = BinaryWriter

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

local Writers = {
    [Types.UInt8] = function(self, ...)
        return self:writeUInt8(...)
    end,
    [Types.Int8] = function(self, ...)
        return self:writeInt8(...)
    end,
    [Types.UInt16] = function(self, ...)
        return self:writeUInt16(...)
    end,
    [Types.Int16] = function(self, ...)
        return self:writeInt16(...)
    end,
    [Types.UInt32] = function(self, ...)
        return self:writeUInt32(...)
    end,
    [Types.Int32] = function(self, ...)
        return self:writeInt32(...)
    end,
    [Types.Float] = function(self, ...)
        return self:writeFloat(...)
    end,
    [Types.Double] = function(self, ...)
        return self:writeDouble(...)
    end,
    [Types.String] = function(self, value)
        return self:writeString(value)
    end,
}

function BinaryWriter:write(type, ...)
    local reader = Writers[type]
    assert(reader ~= nil, ("Writing '%s' is not supported"):format(type))
    return reader(self, ...)
end

return setmetatable(BinaryWriter, {
    __call = function(_, size)
        return BinaryWriter.new(size)
    end,
    __index = Stream
})
