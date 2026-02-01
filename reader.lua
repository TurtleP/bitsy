local path     = (...):gsub("reader", "")

local Enums    = require(path .. "enums")
local SeekType = Enums.SeekType
local Struct   = require(path .. "struct")

local utf8     = require("utf8")


--- @class BinaryReader
--- @field data love.Data
--- @field offset integer
local BinaryReader   = {}
BinaryReader.__index = BinaryReader

--- Creates a new BinaryReader instance
--- @param data love.Data The data to parse
function BinaryReader.new(data)
    return setmetatable({ data = data, offset = 0 }, BinaryReader)
end

--- Gets the size of the data
--- @return integer size Size of the data
function BinaryReader:getSize()
    return self.data:getSize()
end

--- Gets the offset in the data
--- @return integer offset Offset in the data
function BinaryReader:getOffset()
    return self.offset
end

--- Gets the love.Data
--- @return love.Data data The data in the BinaryReader
function BinaryReader:getData()
    return self.data
end

--- Reads an unsigned 8-bit integer from the data
--- @param count integer The count of uint8_t to read
--- @return integer | table value The read value
function BinaryReader:readUInt8(count)
    count = count or 1
    local bytes = { self.data:getUInt8(self.offset, count) }
    self.offset = self.offset + count
    return #bytes == 1 and bytes[1] or bytes
end

--- Reads a signed 8-bit integer from the data
--- @param count integer The count of int8_t to read
--- @return integer | table value The read value
function BinaryReader:readInt8(count)
    count = count or 1
    local bytes = { self.data:getInt8(self.offset, count) }
    self.offset = self.offset + count
    return #bytes == 1 and bytes[1] or bytes
end

--- Reads an unsigned 16-bit integer from the data
--- @param count integer The count of uint16_t to read
--- @return integer | table value The read value
function BinaryReader:readUInt16(count)
    count = count or 1
    local bytes = { self.data:getUInt16(self.offset, count) }
    self.offset = self.offset + (2 * count)
    return #bytes == 1 and bytes[1] or bytes
end

--- Reads a signed 16-bit integer from the data
--- @param count integer The count of int16_t to read
--- @return integer | table value The read value
function BinaryReader:readInt16(count)
    count = count or 1
    local bytes = { self.data:getInt16(self.offset, count) }
    self.offset = self.offset + (2 * count)
    return #bytes == 1 and bytes[1] or bytes
end

--- Reads an unsigned 32-bit integer from the data
--- @param count integer The count of uint32_t to read
--- @return integer | table value The read value
function BinaryReader:readUInt32(count)
    count = count or 1
    local bytes = { self.data:getUInt32(self.offset, count) }
    self.offset = self.offset + (4 * count)
    return #bytes == 1 and bytes[1] or bytes
end

--- Reads a float from the data
--- @param count integer The count of float to read
--- @return number | table value The read value
function BinaryReader:readFloat(count)
    count = count or 1
    local bytes = { self.data:getFloat(self.offset, count) }
    self.offset = self.offset + (4 * count)
    return #bytes == 1 and bytes[1] or bytes
end

--- Reads a double from the data
--- @param count integer The count of double to read
--- @return number | table value The read value
function BinaryReader:readDouble(count)
    count = count or 1
    local bytes = { self.data:getDouble(self.offset, count) }
    self.offset = self.offset + (8 * count)
    return #bytes == 1 and bytes[1] or bytes
end

--- Reads a signed 32-bit integer from the data
--- @param count integer The count of int32_t to read
--- @return integer | table value The read value
function BinaryReader:readInt32(count)
    count = count or 1
    local bytes = { self.data:getInt32(self.offset, count) }
    self.offset = self.offset + (4 * count)
    return #bytes == 1 and bytes[1] or bytes
end

--- Reads a string from the data
--- @param length integer The length of the string
--- @return string value The read value
function BinaryReader:readString(length)
    length = length or 1
    local bytes = self:readUInt8(length)
    if type(bytes) == "number" then
        return string.char(bytes)
    end
    return string.char(unpack(bytes))
end

--- Reads a UTF-16 string
--- @param length integer Number of 16-bit code units
--- @return string value The read string, as UTF-8
function BinaryReader:readU16String(length)
    length = length or 1
    local bytes = self:readUInt16(length)
    if type(bytes) == "number" then
        return utf8.char(bytes)
    end
    return utf8.char(unpack(bytes))
end

--- Reads a structure
--- @param count integer How many structs to read
--- @param struct Struct The Struct to read into
function BinaryReader:readStruct(count, struct)
    count = count or 1
    local structs = {}
    for _ = 1, count do
        structs[#structs + 1] = struct:read(self)
    end
    return #structs == 1 and structs[1] or structs
end

local Readers = {
    [Enums.Types.UInt8] = function(self, count)
        return self:readUInt8(count)
    end,
    [Enums.Types.Int8] = function(self, count)
        return self:readInt8(count)
    end,
    [Enums.Types.UInt16] = function(self, count)
        return self:readUInt16(count)
    end,
    [Enums.Types.Int16] = function(self, count)
        return self:readInt16(count)
    end,
    [Enums.Types.UInt32] = function(self, count)
        return self:readUInt32(count)
    end,
    [Enums.Types.Int32] = function(self, count)
        return self:readInt32(count)
    end,
    [Enums.Types.Float] = function(self, count)
        return self:readFloat(count)
    end,
    [Enums.Types.Double] = function(self, count)
        return self:readDouble(count)
    end,
    [Enums.Types.String] = function(self, count)
        return self:readString(count)
    end,
    [Enums.Types.U16String] = function(self, count)
        local string = self:readU16String(count)
        return string:gsub("%z", "")
    end,
    [Enums.Types.Struct] = function(self, count, s)
        local structs = {}
        for _ = 1, count do
            structs[#structs + 1] = s:read(self)
        end
        return structs
    end
}

--- Reads a value
--- @param type Enums.Types The type of value to read
--- @param count integer The number of values to read
--- @return any The read value(s)
function BinaryReader:read(type, count, value)
    local reader = Readers[type]
    assert(reader, ("Reading '%s' is not supported"):format(type))
    return reader(self, count, value)
end

--- Seeks to a position
--- @param offset integer The offset to seek to
--- @param whence SeekType Seek type
function BinaryReader:seek(offset, whence)
    if whence == SeekType.SEEK_CUR then
        self.offset = self.offset + offset
    elseif whence == SeekType.SEEK_SET then
        self.offset = offset
    elseif whence == SeekType.SEEK_END then
        self.offset = self:getSize() + offset
    end
    self.offset = math.max(0, math.min(self.offset, self:getSize()))
end

function BinaryReader:__tostring()
    return self.data:getString()
end

return setmetatable(BinaryReader, {
    __call = function(_, data) return BinaryReader.new(data) end
})
