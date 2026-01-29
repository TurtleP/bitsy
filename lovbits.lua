local lovbits = { version = "0.1.0" }

local success, love = pcall(require, "love")
if not success or love._version_major < 12 then
    error("LÖVE >= 12.0 required")
end

local utf8 = require("utf8")


--- @enum FieldType
local FieldType      =
{
    UInt8     = "UInt8",
    UInt16    = "UInt16",
    UInt32    = "UInt32",
    String    = "String",
    U16String = "U16String",
    Struct    = "Struct"
}

--- @enum FieldSize
local FieldSize      =
{
    UInt8     = 1,
    String    = 1,
    UInt16    = 2,
    U16String = 2,
    UInt32    = 4,
    UInt64    = 8,
}

--- @enum SeekType
local SeekType       = {
    SEEK_CUR = 0,
    SEEK_SET = 1,
    SEEK_END = 2
}

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

--- Reads an unsigned 8-bit integer from the data
--- @param count integer The count of uint8_t to read
--- @return integer | table value The read value
function BinaryReader:readUInt8(count)
    count = count or 1
    local bytes = { self.data:getUInt8(self.offset, count) }
    self.offset = self.offset + (FieldSize.UInt8 * count)
    return #bytes == 1 and bytes[1] or bytes
end

--- Reads an unsigned 16-bit integer from the data
--- --- @param count integer The count of uint16_t to read
--- @return integer | table value The read value
function BinaryReader:readUInt16(count)
    count = count or 1
    local bytes = { self.data:getUInt16(self.offset, count) }
    self.offset = self.offset + (FieldSize.UInt16 * count)
    return #bytes == 1 and bytes[1] or bytes
end

--- Reads an unsigned 32-bit integer from the data
--- @param count integer The count of uint32_t to read
--- @return integer | table value The read value
function BinaryReader:readUInt32(count)
    count = count or 1
    local bytes = { self.data:getUInt32(self.offset, count) }
    self.offset = self.offset + (FieldSize.UInt32 * count)
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

setmetatable(BinaryReader, { __call = function(_, data) return BinaryReader.new(data) end })

--- @class Field
--- @field name string
--- @field value any
--- @field type FieldType
--- @field count integer
--- @field size integer
local Field    = {}
Field.__index  = Field

--- @class Struct
--- @field private size integer
--- @field private fields table
--- @field private name string
local Struct   = {}
Struct.__index = Struct

local function isField(value)
    return type(value) == "table" and getmetatable(value) == Field
end

local function isStruct(value)
    return type(value) == "table" and getmetatable(value) == Struct
end

function Field.new(type, name, count, value)
    assert(FieldType[type], "Unknown type " .. tostring(type))
    count = count or 1

    local size = 0
    if type == FieldType.Struct then
        for _, field in ipairs(value:getFields()) do
            size = size + field:getSize()
        end
    else
        size = FieldSize[type]
    end

    return setmetatable({
        type = type,
        name = name or "<unnamed>",
        count = count,
        value = value,
        size = size * count
    }, Field)
end

function Field:getSize()
    return self.size
end

function Field:setValue(value)
    self.value = value
end

function Field:getType()
    return self.type
end

function Field:__tostring()
    local value = self.value
    if type(value) == "number" then value = ("0x%X"):format(self.value) end
    if self.count > 1 then value = ("[%s; 0x%X]"):format(self.type, self.count) end
    return ("Field(%s %s): %s"):format(self.type, self.name, value)
end

setmetatable(Field, {
    __call = function(_, ...) return Field.new(...) end
})

--- Create a new Struct
--- @param name string The name of the struct
--- @param fields Field[] | [ FieldType, string, integer, any ][] The definition fields
--- @return Struct struct A new Struct
function Struct.new(name, fields)
    local self = { name = name, size = 0, fields = {} }
    for _, entry in ipairs(fields) do
        local size, field = 0, nil
        if isField(entry) then
            field, size = entry, entry:getSize()
        else
            local field_type, field_name, count, value = unpack(entry)
            field = Field(field_type, field_name, count, value)
            size = isStruct(field) and field:getSize() or FieldSize[field_type]
        end
        table.insert(self.fields, field)
        self.size = self.size + size
    end
    return setmetatable(self, Struct)
end

function Struct:clone()
    local fields = {}
    for _, field in ipairs(self.fields) do
        fields[#fields + 1] = Field(field.type, field.name, field.count, field.value)
    end
    return Struct(self.name, fields)
end

function Struct:__tostring()
    local result = { ("Struct(%s: 0x%X)"):format(self.name, self.size) }
    for _, field in ipairs(self.fields) do
        result[#result + 1] = "  " .. tostring(field)
    end
    return table.concat(result, "\n")
end

--- Gets the type of this Struct
--- @return string type The type of struct
function Struct:type()
    return FieldType.Struct
end

--- Returns the fields in this Struct
--- @return table fields The fields of the struct
function Struct:getFields()
    return self.fields
end

function Struct:find(name)
    for _, field in ipairs(self.fields) do
        if name == field.name then
            return field
        end
    end
    error(("No such field %s"):format(name))
end

--- Gets a value from the struct
--- @return any value The field value
function Struct:get(name)
    local field = self:find(name)
    return field.value
end

local Readers = {
    [FieldType.UInt8]     = BinaryReader.readUInt8,
    [FieldType.UInt16]    = BinaryReader.readUInt16,
    [FieldType.UInt32]    = BinaryReader.readUInt32,
    [FieldType.String]    = BinaryReader.readString,
    [FieldType.U16String] = BinaryReader.readU16String,
}

--- Reads data from a BinaryReader into this Struct
--- Optionally assert that the BinaryReader read `size` bytes.
--- @param reader BinaryReader The BinaryReader instance
--- @param size? integer (Optional) The bytes to expect to be read, total
function Struct:read(reader, size)
    local total_size = 0
    local instance = self:clone()
    for _, field in ipairs(instance:getFields()) do
        local field_type, count = field.type, field.count
        if field_type == FieldType.Struct then
            field:setValue(reader:readStruct(count, field.value))
        else
            local fn = Readers[field_type]
            field:setValue(fn(reader, count))
        end
        total_size = total_size + field:getSize()
    end
    if size then assert(total_size == size) end
    return instance
end

--- Gets the size of a Struct
--- @return integer size The size in bytes
function Struct:getSize()
    return self.size
end

setmetatable(Struct, {
    __call = function(_, ...) return Struct.new(...) end,
})

lovbits.Struct = Struct
lovbits.Field = Field
lovbits.FieldType = FieldType
lovbits.FieldSize = FieldSize
lovbits.BinaryReader = BinaryReader
lovbits.SeekType = SeekType

return lovbits
