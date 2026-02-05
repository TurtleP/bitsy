local Type = {}
Type.__index = Type

function Type.new(name, size, default)
    return setmetatable({ name = name, size = size or 0, defaultValue = default or 0 }, Type)
end

function Type:__tostring()
    return self.name
end

function Type:__eq(other)
    return getmetatable(other) == Type and self.name == other.name and self:getSize() == other:getSize()
end

function Type:default()
    return Type(self.defaultValue)
end

function Type:getSize()
    return self.size
end

setmetatable(Type, {
    __call = function(_, name, size, default)
        return Type.new(name, size, default)
    end
})

return {
    UInt8 = Type("uint8_t", 1),
    Int8 = Type("int8_t", 1),
    UInt16 = Type("uint16_t", 2),
    Int16 = Type("int16_t", 2),
    UInt32 = Type("uint32_t", 4),
    Int32 = Type("int32_t", 4),
    Float = Type("float", 4),
    Double = Type("double", 8),
    String = Type("string", 1, ""),
    U16String = Type("u16string", 2, ""),
    Struct = Type("struct"),
    Array = Type("array"),
}
