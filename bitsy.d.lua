---@meta

---@class bitsy
local bitsy = {}

---Represents a field type in a binary data structure.
---@class Type
---@field private name string The name of the field type.
---@field private size integer The size of the field type in bytes.
---@field private default any The initial default value
local Type = {}

---Defines a new field type.
---@param name string The name of the field type.
---@param size integer The size of the field type in bytes.
---@param default any The default value for this Type.
---@return Type The new field type.
function Type.new(name, size, default) end

--- A type representing a type in cstdlib
---@enum bitsy.Type
local Types     = {}
Types.UInt8     = Type.new("uint8_t", 1)  -- uint8_t
Types.Int8      = Type.new("int8_t", 1)   -- int8_t
Types.UInt16    = Type.new("uint16_t", 2) -- uint16_t
Types.Int16     = Type.new("int16_t", 2)  -- int16_t
Types.UInt32    = Type.new("uint32_t", 4) -- uint32_t
Types.Int32     = Type.new("int32_t", 4)  -- int32_t
Types.Float     = Type.new("float", 4)    -- float
Types.Double    = Type.new("double", 8)   -- double
Types.String    = Type.new("string")      -- string
Types.U16String = Type.new("u16string_t") -- u16_string
Types.Struct    = Type.new("struct")      -- struct
Types.Array     = Type.new("array")       -- array


---A contiguous data field
---@class bitsy.Array
---@field private type bitsy.Type
---@field private name string
---@field private count integer
---@field private data any
---@overload fun(type: bitsy.Type, name: string, count: integer, data?: any): bitsy.Array
local Array = {}

---Creates a new array.
---@param type bitsy.Type The type of array.
---@param name string The name of the array.
---@param count integer The number of items in the array.
---@param data? any
---@return bitsy.Array array
function Array.new(type, name, count, data) end

---Gets the size of the array.
---@return integer size The size of the array.
function Array:getSize() end

---Gets the type of the array.
---@return bitsy.Type
function Array:getType() end

---Creates a clone of this array with default values.
---@return bitsy.Array
function Array:default() end

---Gets the name of the array
---@return string name The name of the array.
function Array:getName() end

---Gets the values in the array, as a table.
---@return table value The values in the array, as a table.
function Array:getValue() end

---Reads an array using a reader.
---@param reader bitsy.BinaryReader The reader to use.
---@return bitsy.Array array The array, modified
function Array:read(reader) end

---Returns an value at index `i`.
---@param i integer The index to fetch.
---@return bitsy.Struct | bitsy.Type | bitsy.Array
function Array:index(i) end

---Compare if two arrays are equal in contents.
---@return boolean equal Whether the arrays are equal in contents.
function Array:__eq(other) end

---Gets the string format of the array.
---@return string
function Array:__tostring() end

---A magic value field for validation
---@class bitsy.Magic
---@field private type bitsy.Type The type of the magic field.
---@field private name string The name of this magic field.
---@field private value any The value of the magic field, for validation.
---@overload fun(type: bitsy.Type, name: string, value: any): bitsy.Magic
local Magic = {}

---Creates a new magic value field.
---@param type bitsy.Type The type of the magic field.
---@param name string The name of the magic field.
---@param value any The value of the magic field, for validation.
---@return bitsy.Magic magic
function Magic.new(type, name, value) end

---Gets the size of the magic value field.
---@return integer size The size of the magic value field.
function Magic:getSize() end

---Reads a magic value from a reader.
---@param reader bitsy.BinaryReader The reader to read from.
---@return bitsy.Magic magic The instance
function Magic:read(reader) end

---@class bitsy.Field
---@field private type bitsy.Type
---@field private name string
---@field private size integer
---@field private value bitsy.Struct | bitsy.Type
---@overload fun(type: bitsy.Type, name: string, value: any): bitsy.Field
local Field = {}

---Creates a new Field
---@param type bitsy.Type The type for this field.
---@param name string The name of this field.
---@param value? # The default value
---@return bitsy.Field field
function Field.new(type, name, value) end

---Gets the name of the field.
---@return string name The name of the field.
function Field:getName() end

---Gets the type of the field.
---@return bitsy.Type type The type of field.
function Field:getType() end

---Gets the value of the field.
---@return bitsy.Type | bitsy.Struct
function Field:getValue() end

---Gets the size of the field.
---@return integer size The size of the field.
function Field:getSize() end

---Reads a value from a reader into the field value.
---@return bitsy.Field field The field instance
function Field:read(reader) end

---@class bitsy.Struct
---@field private name string The name of this struct.
---@field private fields bitsy.Field[] The fields of this struct.
---@overload fun(name: string, fields: bitsy.Field[]): bitsy.Struct
local Struct = {}

---Creates a new Struct
---@param name string The name of the struct.
---@param fields bitsy.Field[] | bitsy.Struct[]
---@return bitsy.Struct struct A new struct.
function Struct.new(name, fields) end

---Gets the name for this struct.
---@return string name The name of the struct.
function Struct:getName() end

---Gets the size
---@return integer size The size of the struct.
function Struct:getSize() end

---Clones the struct with default (empty) values.
---@return bitsy.Struct clone The cloned struct
function Struct:default() end

---Gets the type of struct.
---@return bitsy.Type type The type of struct.
function Struct:getType() end

---Reads a struct using a BinaryReader.
---@param reader bitsy.BinaryReader The binary reader to use.
---@return bitsy.Struct self The read struct.
function Struct:read(reader) end

---Gets a field within the struct.
---@param fieldname string The name of the field.
---@return bitsy.Field | bitsy.Struct | bitsy.Array
function Struct:get(fieldname) end

---@enum bitsy.SeekType
local SeekType = {}
SeekType.SEEK_CUR = 0 -- Seek from the current position in the stream.
SeekType.SEEK_SET = 1 -- Seek to the absolute position in the stream.
SeekType.SEEK_END = 2 -- Seek relative to the end of the stream.

---Represents a binary stream
---@class bitsy.BinaryStream
---@field protected data love.Data
---@field protected offset integer
---@overload fun(data: love.Data, offset?: integer): bitsy.BinaryStream
local BinaryStream = {}

---Creates a new BinaryStream with data.
---@param data love.Data The data to read.
---@param offset? integer The offset to start at.
---@return bitsy.BinaryStream stream
function BinaryStream.new(data, offset) end

---Gets the data associated with this stream.
---@return love.Data data
function BinaryStream:getData() end

---Gets the size of the data associated with this stream.
---@return integer size
function BinaryStream:getSize() end

---Gets the offset of the data associated with this stream.
---@return integer size
function BinaryStream:getOffset() end

---Seeks to the offset within the data associated with this stream.
---@param offset integer The offset to seek to.
---@param whence bitsy.SeekType The position to seek to.
function BinaryStream:seek(offset, whence) end

---Gets the string representation of this Stream.
---@return string value The string representation of the Stream.
function BinaryStream:__tostring() end

---Represents a binary stream reader
---@class bitsy.BinaryReader: bitsy.BinaryStream
---@overload fun(data: love.Data, offset?: integer): bitsy.BinaryReader
local BinaryReader = {}

---Creates a new BinaryReader with data.
---@param data love.Data The data to read.
---@param offset? integer The offset to start at.
---@return bitsy.BinaryReader reader
function BinaryReader.new(data, offset) end

---Reads an unsigned 8-bit integer from the BinaryReader.
---@param count? integer The total number of `uint8_t` to read (default 1).
---@return integer | integer[] bytes The `uint8_t` read from the BinaryReader.
function BinaryReader:readUInt8(count) end

---Reads a signed 8-bit integer from the BinaryReader.
---@param count? integer The total number of `int8_t` to read (default 1).
---@return integer | integer[] bytes The `int8_t` read from the BinaryReader.
function BinaryReader:readInt8(count) end

---Reads an usigned 16-bit integer from the BinaryReader.
---@param count? integer The total number of `uint16_t` to read (default 1).
---@return integer | integer[] bytes The `uint16_t` read from the BinaryReader.
function BinaryReader:readUInt16(count) end

---Reads a signed 16-bit integer from the BinaryReader.
---@param count? integer The total number of `int16_t` to read (default 1).
---@return integer | integer[] bytes The `int16_t` read from the BinaryReader.
function BinaryReader:readInt16(count) end

---Reads an unsigned 32-bit integer from the BinaryReader.
---@param count? integer The total number of `uint32_t` to read (default 1).
---@return integer | integer[] bytes The `uint32_t` read from the BinaryReader.
function BinaryReader:readUInt32(count) end

---Reads a float from the BinaryReader.
---@param count? integer The total number of `float` to read (default 1).
---@return number | number[] bytes The values read from the BinaryReader.
function BinaryReader:readFloat(count) end

---Reads a double from the BinaryReader.
---@param count? integer The total number of `double` to read (default 1).
---@return number | number[] bytes The values read from the BinaryReader.
function BinaryReader:readDouble(count) end

---Reads a string from the BinaryReader.
---@param length? integer The length of the string to read.
---@return string value The value read from the BinaryReader.
function BinaryReader:readString(length) end

---Reads a u16 string from the BinaryReader.
---@param length? integer The length of the string to read.
---@return string value The value read from the BinaryReader.
function BinaryReader:readU16String(length) end

---Reads a struct from the BinaryReader.
---@param count? integer The number of structs to read.
---@param struct bitsy.Struct The struct to read.
---@return bitsy.Struct | bitsy.Struct[] structs The values read from the BinaryReader.
function BinaryReader:readStruct(count, struct) end

---Represents a binary stream writer
---@class bitsy.BinaryWriter: bitsy.BinaryStream
---@overload fun(size: integer): bitsy.BinaryWriter
local BinaryWriter = {}

---Creates a new binary writer
---@param size integer The size of the data
---@return bitsy.BinaryWriter
function BinaryWriter.new(size) end

---Creates a new binary writer from existing data
---@param data love.Data The data to use
---@return bitsy.BinaryWriter
function BinaryWriter.from(data) end

---Write unsigned 8-bit integers into the data.
---@param ... integer The integers to write into the data.
function BinaryWriter:writeUInt8(...) end

---Write signed 8-bit integers into the data.
---@param ... integer The integers to write into the data.
function BinaryWriter:writeInt8(...) end

---Write unsigned 16-bit integers into the data.
---@param ... integer The integers to write into the data.
function BinaryWriter:writeUInt16(...) end

---Write signed 16-bit integers into the data.
---@param ... integer The integers to write into the data.
function BinaryWriter:writeInt16(...) end

---Write unsigned 32-bit integers into the data.
---@param ... integer The integers to write into the data.
function BinaryWriter:writeUInt32(...) end

---Write signed 32-bit integers into the data.
---@param ... integer The integers to write into the data.
function BinaryWriter:writeInt32(...) end

---Write floats into the data.
---@param ... number The numbers to write into the data.
function BinaryWriter:writeFloat(...) end

---Write doubles into the data.
---@param ... number The numbers to write into the data.
function BinaryWriter:writeDouble(...) end

---Writes a string into the data.
---@param value string The string to write into the data.
function BinaryWriter:writeString(value) end

---Writes values into the data.
---@param type bitsy.Type The type of data
---@param ... integer | number| string The data to write
function BinaryWriter:write(type, ...) end

bitsy.Array = Array
bitsy.Field = Field
bitsy.Magic = Magic
bitsy.Reader = BinaryReader
bitsy.SeekType = SeekType
bitsy.Struct = Struct
bitsy.Types = Types
bitsy.Writer = BinaryWriter

return bitsy
