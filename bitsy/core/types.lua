local DataType = require("bitsy.core.datatype")

local Type = {}
Type.UInt8 = DataType("uint8_t", 1,
    function(reader, count)
        return reader:readUInt8(count)
    end,
    function(writer, ...)
        writer:writeUInt8(...)
    end
)
Type.Int8 = DataType("int8_t", 1,
    function(reader, count)
        return reader:readInt8(count)
    end,
    function(writer, ...)
        writer:writeInt8(...)
    end
)
Type.UInt16 = DataType("uint16_t", 2,
    function(reader, count)
        return reader:readUInt16(count)
    end,
    function(writer, ...)
        writer:writeUInt16(...)
    end
)
Type.Int16 = DataType("int16_t", 2,
    function(reader, count)
        return reader:readInt16(count)
    end,
    function(writer, ...)
        writer:writeInt16(...)
    end
)
Type.UInt32 = DataType("uint32_t", 4,
    function(reader, count)
        return reader:readUInt32(count)
    end,
    function(writer, ...)
        writer:writeUInt32(...)
    end
)
Type.Int32 = DataType("int32_t", 4,
    function(reader, count)
        return reader:readInt32(count)
    end,
    function(writer, ...)
        return writer:writeInt32(...)
    end
)
Type.Char = DataType("char", 1,
    function(reader, length)
        return reader:readString(length)
    end,
    function(writer, ...)
        writer:writeString(...)
    end
)
return Type
