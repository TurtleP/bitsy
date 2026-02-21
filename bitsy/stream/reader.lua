local Stream            = require("bitsy.stream.stream")

local BinaryReader      = {}
BinaryReader.__index    = BinaryReader
BinaryReader.__tostring = Stream.__tostring

function BinaryReader.new(data, offset)
    local self = setmetatable({}, BinaryReader)
    Stream.new(self, data, offset)
    return self
end

function BinaryReader.open(filename, offset)
    local data, err = love.filesystem.newFileData(filename)
    if not data then return nil, err end
    return BinaryReader.new(data, offset)
end

function BinaryReader:readUInt8(count)
    count = count or 1
    local bytes = { self.data:getUInt8(self.offset, count) }
    return #bytes == 1 and bytes[1] or bytes
end

function BinaryReader:readInt8(count)
    count = count or 1
    local bytes = { self.data:getInt8(self.offset, count) }
    return #bytes == 1 and bytes[1] or bytes
end

function BinaryReader:readUInt16(count)
    count = count or 1
    local bytes = { self.data:getUInt16(self.offset, count) }
    return #bytes == 1 and bytes[1] or bytes
end

function BinaryReader:readInt16(count)
    count = count or 1
    local bytes = { self.data:getInt16(self.offset, count) }
    return #bytes == 1 and bytes[1] or bytes
end

function BinaryReader:readUInt32(count)
    count = count or 1
    local bytes = { self.data:getUInt32(self.offset, count) }
    return #bytes == 1 and bytes[1] or bytes
end

function BinaryReader:readInt32(count)
    count = count or 1
    local bytes = { self.data:getInt32(self.offset, count) }
    return #bytes == 1 and bytes[1] or bytes
end

function BinaryReader:readFloat(count)
    count = count or 1
    local bytes = { self.data:getFloat(self.offset, count) }
    return #bytes == 1 and bytes[1] or bytes
end

function BinaryReader:readDouble(count)
    count = count or 1
    local bytes = { self.data:getDouble(self.offset, count) }
    return #bytes == 1 and bytes[1] or bytes
end

function BinaryReader:readString(length)
    length = length or 1
    return self.data:getString(self.offset, length)
end

function BinaryReader:read(type, count)
    if not type then
        local size = self:getSize() - self.offset
        local offset = self.offset
        self:advance(size)
        return love.data.newDataView(self.data, offset, size)
    end
    count = count or 1
    return type:read(self, count)
end

function BinaryReader:peek(type, count)
    local current_offset = self.offset
    local data = type:read(self, count)
    self.offset = current_offset
    return data
end

return setmetatable(BinaryReader, {
    __call = function(_, data, offset) return BinaryReader.new(data, offset) end,
    __index = Stream
})
