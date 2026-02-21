local DataType = require("bitsy.core.datatype")

local Struct = {}
Struct.__index = Struct

function Struct:new(name, fields)
    local size, members = 0, {}
    for _, field in ipairs(fields) do
        size = size + field:getSize()
        members[field:getName()] = field
    end
    local instance = DataType.new(self, name, size)
    instance.fields = fields
    instance.members = members
    return instance
end

function Struct:__tostring()
    return ("<Struct %s [0x%X]>"):format(self.name, self.size)
end

local StructInstance = {}
StructInstance.__index = StructInstance

function StructInstance:__tostring()
    return tostring(self.__schema)
end

function Struct:read(reader)
    local instance = setmetatable({}, StructInstance)
    instance.__schema = self
    for _, field in ipairs(self.fields) do
        instance[field.name] = field:read(reader)
    end
    return instance
end

function Struct:write(writer, values)
    for index, field in ipairs(self.fields) do
        if not values[index] then break end
        field:write(writer, values[index] or 0)
    end
end

return setmetatable(Struct, {
    __call = function(cls, ...)
        return cls:new(...)
    end,
    __index = DataType
})
