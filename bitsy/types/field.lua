local DataType = require("bitsy.core.datatype")

local Field = {}
Field.__index = Field

function Field:new(name, type)
    local instance = DataType.new(self, name, type:getSize())
    instance.type = type
    return instance
end

function Field:read(reader)
    return self.type:read(reader)
end

function Field:write(writer, value)
    self.type:write(writer, value)
end

function Field:__tostring()
    return ("<Field %s (%s)>"):format(self.name, self.type)
end

return setmetatable(Field, {
    __call = function(cls, ...)
        return cls:new(...)
    end,
    __index = DataType
})
