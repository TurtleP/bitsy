local path = (...):gsub("reader", "")

local Stream = require(path .. "stream")
local Types = require(path .. "types")
local utf8 = require("utf8")


local BinaryReader = {}
BinaryReader.__index = BinaryReader

function BinaryReader.new(data, offset)
    Stream.new(BinaryReader, data, offset)
    return setmetatable({}, BinaryReader)
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

function BinaryReader:readInt32(count)
    count = count or 1
    local bytes = { self.data:getInt32(self.offset, count) }
    self.offset = self.offset + (4 * count)
    return #bytes == 1 and bytes[1] or bytes
end

function BinaryReader:readString(length)
    length = length or 1
    local bytes = self:readUInt8(length)
    if type(bytes) == "number" then
        return string.char(bytes)
    end
    return string.char(unpack(bytes))
end

function BinaryReader:readU16String(length)
    length = length or 1
    local bytes = self:readUInt16(length)
    if type(bytes) == "number" then
        return utf8.char(bytes)
    end
    return utf8.char(unpack(bytes))
end

function BinaryReader:readStruct(count, struct)
    count = count or 1
    local structs = {}
    for _ = 1, count do
        structs[#structs + 1] = struct:read(self)
    end
    return #structs == 1 and structs[1] or structs
end

local Readers = {
    [Types.UInt8] = function(self, count)
        return self:readUInt8(count)
    end,
    [Types.Int8] = function(self, count)
        return self:readInt8(count)
    end,
    [Types.UInt16] = function(self, count)
        return self:readUInt16(count)
    end,
    [Types.Int16] = function(self, count)
        return self:readInt16(count)
    end,
    [Types.UInt32] = function(self, count)
        return self:readUInt32(count)
    end,
    [Types.Int32] = function(self, count)
        return self:readInt32(count)
    end,
    [Types.Float] = function(self, count)
        return self:readFloat(count)
    end,
    [Types.Double] = function(self, count)
        return self:readDouble(count)
    end,
    [Types.String] = function(self, count)
        return self:readString(count)
    end,
    [Types.U16String] = function(self, count)
        local string = self:readU16String(count)
        return string:gsub("%z", "")
    end,
    [Types.Struct] = function(self, count, s)
        local structs = {}
        for _ = 1, count do
            structs[#structs + 1] = s:read(self)
        end
        return structs
    end
}

function BinaryReader:read(type, count, value)
    local reader = Readers[type]
    assert(reader ~= nil, ("Reading '%s' is not supported"):format(type))
    return reader(self, count, value)
end

return setmetatable(BinaryReader, {
    __call = function(_, data) return BinaryReader.new(data) end,
    __index = Stream
})
