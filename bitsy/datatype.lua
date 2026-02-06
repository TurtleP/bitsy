local DataType = {}
DataType.__index = DataType

function DataType:new(name, size, read_fn, write_fn)
    local instance = setmetatable({}, self)
    instance.name = name
    instance.size = size or 0
    if type(read_fn) == "function" and read_fn then
        instance._read = read_fn
    end
    if type(write_fn) == "function" and write_fn then
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
        return self._read(reader, count)
    end
    error(("Read not implemented for %s"):format(self.name))
end

function DataType:write(writer, ...)
    if self._write then
        return self._write(writer, ...)
    end
    error(("Write not implemented for %s"):format(self.name))
end

function DataType:__tostring()
    return self.name
end

return setmetatable(DataType, {
    __call = function(cls, ...)
        return cls:new(...)
    end
})
