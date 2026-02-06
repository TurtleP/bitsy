---@meta

---@class bitsy
local bitsy = {}

---Represents a field type in a binary data structure.
---@class bitsy.DataType
---@field private name string The name of the field type.
---@field private size integer The size of the field type in bytes.
---@field private read_fn? function The read function
local DataType = {}

---Defines a new field type.
---@param name string The name of the field type.
---@param size integer The size of the field type in bytes.
---@param read_fn? fun(reader: bitsy.BinaryReader, count: integer) The read callback
---@param write_fn? fun(writer: bitsy.BinaryWriter, values: ...)
---@return bitsy.DataType type The new data type.
function DataType:new(name, size, read_fn, write_fn) end

---Gets the name of this data type.
---@return string name The name of this data type.
function DataType:getName() end

---Gets the size of this data type.
---@return integer size The size of this data type.
function DataType:getSize() end

---Reads data from a reader.
---@param reader bitsy.BinaryReader The reader to read from.
---@param count integer The number of items to read.
function DataType:read(reader, count) end

---Writes data into a writer.
---@param writer bitsy.BinaryWriter The writer to write into.
---@param ... any The values to write.
function DataType:write(writer, ...) end

--- A type representing a type in cstdlib
---@class bitsy.Type: bitsy.DataType
---@field UInt8 bitsy.DataType uint8_t
---@field Int8 bitsy.DataType int8_t
---@field UInt16 bitsy.DataType uint16_t
---@field Int16 bitsy.DataType int16_t
---@field UInt32 bitsy.DataType uint32_t
---@field Int32 bitsy.DataType int32_t
---@field Char bitsy.DataType char
local Type = {}

---A contiguous data field
---@class bitsy.Array: bitsy.DataType
---@field private type bitsy.Type
---@field private count integer
---@overload fun(type: bitsy.Type, count: integer): bitsy.Array
local Array = {}

---Creates a new array.
---@param type bitsy.Type The type of array.
---@param count integer The number of items in the array.
---@return bitsy.Array array
function Array:new(type, count) end

---Reads an array using a reader.
---@param reader bitsy.BinaryReader The reader to use.
---@return bitsy.Array array The array, modified
function Array:read(reader) end

---Writes an array into a writer.
---@param writer bitsy.BinaryWriter
---@param ... integer | number| string
function Array:write(writer, ...) end

---Gets the string format of the array.
---@return string
function Array:__tostring() end

---A magic value field for validation
---@class bitsy.Magic: bitsy.DataType
---@field private type bitsy.Array | bitsy.Type The type of the magic field.
---@field private name string The name of this magic field.
---@field private expected any The value of the magic field, for validation.
---@overload fun(name: string, type: bitsy.Type | bitsy.Array, expected: any): bitsy.Magic
local Magic = {}

---Creates a new magic value field.
---@param name string The name of the magic field.
---@param type bitsy.Array | bitsy.Type The type of the magic field.
---@param expected any The value of the magic field, for validation.
---@return bitsy.Magic magic
function Magic:new(name, type, value) end

---Reads a magic value from a reader.
---@param reader bitsy.BinaryReader The reader to read from.
---@return bitsy.Magic magic The instance
function Magic:read(reader) end

---Writes a magic value into a writer.
---@param writer bitsy.BinaryWriter The writer to write into.
---@param value any The value to write into the magic.
function Magic:write(writer, value) end

---Gets the string format of the magic.
---@return string format
function Magic:__tostring() end

---@class bitsy.Field: bitsy.DataType
---@field private name string
---@field private type bitsy.Type
---@overload fun(name: string, type: bitsy.Type): bitsy.Field
local Field = {}

---Creates a new Field
---@param name string The name of this field.
---@param type bitsy.Type The type for this field.
---@return bitsy.Field field
function Field:new(type, name) end

---Reads a value from a reader into the field value.
---@param reader bitsy.BinaryReader The reader to read from.
---@return bitsy.Field field The field instance.
function Field:read(reader) end

---Writes a value into a writer.
---@param writer bitsy.BinaryWriter The writer to write into.
---@param value any The value to write
function Field:write(writer, value) end

---@class bitsy.Struct: bitsy.DataType
---@field private name string The name of this struct.
---@field private fields bitsy.DataType[] The fields of this struct (can include Field, Array, or Magic).
---@overload fun(name: string, fields: bitsy.DataType[]): bitsy.Struct
local Struct = {}

---Creates a new Struct
---@param name string The name of the struct.
---@param fields bitsy.DataType[] List of fields (Field, Array, or Magic)
---@return bitsy.Struct struct A new struct
function Struct:new(name, fields) end

---Reads a struct using a reader.
---@param reader bitsy.BinaryReader The binary reader to use.
---@return table data The read struct as a lua table.
function Struct:read(reader) end

---Writes a struct using a writer.
---@param writer bitsy.BinaryWriter The writer to write into.
---@param values table The values to write into the struct
function Struct:write(writer, values) end

---Gets the string format of this struct.
---@return string format
function Struct:__tostring() end

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

---Creates a new BinaryReader from a file.
---@param filepath string The filepath to read.
---@param offset? integer The offset to start at.
---@return bitsy.BinaryReader reader
function BinaryReader.open(filepath, offset) end

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

---Returns the underlying data as a string
---@return string data The string in the data
function BinaryReader:__tostring() end

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

---Returns the underlying data as a string
---@return string data The string in the data
function BinaryWriter:__tostring() end

bitsy.Array = Array
bitsy.Field = Field
bitsy.Magic = Magic
bitsy.Type = Type
bitsy.Reader = BinaryReader
bitsy.SeekType = SeekType
bitsy.Struct = Struct
bitsy.Writer = BinaryWriter

return bitsy
