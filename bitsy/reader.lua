local path = (...):gsub("reader", "")

local Stream = require(path .. "stream")
local Types = require(path .. "types")
local utf8 = require("utf8")


local BinaryReader      = {}
BinaryReader.__index    = BinaryReader
BinaryReader.__tostring = Stream.__tostring

function BinaryReader.new(data, offset)
    local self = setmetatable({}, BinaryReader)
    Stream.new(self, data, offset)
    return self
end

function BinaryReader.open(filename, offset)
    local self = setmetatable({}, BinaryReader)
    Stream.new(self, love.filesystem.newFileData(filename), offset)
    return self
end

function BinaryReader:readUInt8(count)
    count = count or 1
    local bytes = { self.data:getUInt8(self.offset, count) }
    self.offset = self.offset + count
    return #bytes == 1 and bytes[1] or bytes
end

function BinaryReader:readInt8(count)
    count = count or 1
    local bytes = { self.data:getInt8(self.offset, count) }
    self.offset = self.offset + count
    return #bytes == 1 and bytes[1] or bytes
end

function BinaryReader:readUInt16(count)
    count = count or 1
    local bytes = { self.data:getUInt16(self.offset, count) }
    self.offset = self.offset + (2 * count)
    return #bytes == 1 and bytes[1] or bytes
end

function BinaryReader:readInt16(count)
    count = count or 1
    local bytes = { self.data:getInt16(self.offset, count) }
    self.offset = self.offset + (2 * count)
    return #bytes == 1 and bytes[1] or bytes
end

function BinaryReader:readUInt32(count)
    count = count or 1
    local bytes = { self.data:getUInt32(self.offset, count) }
    self.offset = self.offset + (4 * count)
    return #bytes == 1 and bytes[1] or bytes
end

function BinaryReader:readInt32(count)
    count = count or 1
    local bytes = { self.data:getInt32(self.offset, count) }
    self.offset = self.offset + (4 * count)
    return #bytes == 1 and bytes[1] or bytes
end

function BinaryReader:readFloat(count)
    count = count or 1
    local bytes = { self.data:getFloat(self.offset, count) }
    self.offset = self.offset + (4 * count)
    return #bytes == 1 and bytes[1] or bytes
end

function BinaryReader:readDouble(count)
    count = count or 1
    local bytes = { self.data:getDouble(self.offset, count) }
    self.offset = self.offset + (8 * count)
    return #bytes == 1 and bytes[1] or bytes
end

function BinaryReader:readString(length)
    local s = self.data:getString(self.offset, length)
    self.offset = self.offset + length
    return s
end

function BinaryReader:read(type, count)
    return type:read(self, count)
end

function BinaryReader:peek(type, count)
    local current_offset = self.offset
    local data = type:read(self, count)
    self.offset = current_offset
    return data
end

return setmetatable(BinaryReader, {
    __call = function(_, data) return BinaryReader.new(data) end,
    __index = Stream
})
