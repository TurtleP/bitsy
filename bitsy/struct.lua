local path = (...):gsub("struct", "")
local DataType = require(path .. "datatype")

local Struct = {}
Struct.__index = function(self, key)
    if Struct[key] then
        return Struct[key]
    end
    if self.members[key] then
        return self.members[key]
    end
    return DataType.__index(self, key)
end

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
    return ("<Struct %s: 0x%X>"):format(self.name, self.size)
end

function Struct:read(reader)
    local data = {}
    for _, field in ipairs(self.fields) do
        data[field:getName()] = field:read(reader)
    end
    return data
end

local log = require("log")

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
