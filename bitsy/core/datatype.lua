local DataType = {}
DataType.__index = DataType

local READ_NOT_IMPLEMENTED = "Read not implemented for %s"
local WRITE_NOT_IMPLEMENTED = "Write not implemented for %s"

function DataType:new(name, size, read_fn, write_fn)
    local instance = setmetatable({}, self)
    instance.name = name
    instance.size = size or 0
    if type(read_fn) == "function" then
        instance._read = read_fn
    end
    if type(write_fn) == "function" then
        instance._write = write_fn
    end
    return instance
end

function DataType:getName()
    return self.name
end

function DataType:getSize()
    return self.size
end

function DataType:read(reader, count)
    if self._read then
        local count = count or 1
        local value = self._read(reader, count)
        reader:advance(count * self.size)
        return value
    end
    error(READ_NOT_IMPLEMENTED:format(self.name))
end

function DataType:write(writer, ...)
    if self._write then
        local count = select("#", ...)
        self._write(writer, ...)
        writer:advance(count * self.size)
        return count
    end
    error(WRITE_NOT_IMPLEMENTED:format(self.name))
end

function DataType.isSubtype(object, base)
    base = base or DataType
    local mt = getmetatable(object)
    while mt do
        local index = mt.__index
        if index == base then
            return true
        end
        mt = getmetatable(index)
    end
    return false
end

function DataType:__tostring()
    return self.name
end

return setmetatable(DataType, {
    __call = function(cls, ...)
        return cls:new(...)
    end
})
