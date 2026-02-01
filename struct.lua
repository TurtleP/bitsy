local path = (...):gsub("struct", "")
local Enums = require(path .. "enums")

--- @class Struct
--- Represents a binary data structure.
--- @field private name string The name of the structure.
--- @field private fields Enums.Types[] The fields of the structure.
--- @field private members { [string]: Field }
local Struct = {}
Struct.__index = Struct

--- Creates a new Struct.
--- @param name string The name of this Struct.
--- @param fields Enums.Types[] The fields for this Struct.
function Struct.new(name, fields)
    local size, members = 0, {}
    for _, field in ipairs(fields) do
        size = size + field:getSize()
        members[field:getName()] = field
    end
    return setmetatable({ name = name or "unnamed", fields = fields, size = size, members = members }, Struct)
end

function Struct:__tostring()
    return ("<Struct %s: 0x%X>"):format(self.name, self.size)
end

--- Gets the name of this Struct.
--- @return string The name of this Struct.
function Struct:getName()
    return self.name
end

--- Gets the members in this Struct.
--- @return Field[] The fields of this Struct.
function Struct:default()
    local fields = {}
    for _, field in pairs(self.members) do
        fields[#fields + 1] = field
    end
    return Struct(self.name, fields)
end

--- Gets the field in this Struct.
--- @param field string The name of the field to get.
--- @return Field The field with the given name.
function Struct:get(field)
    local member = self.members[field]
    assert(member, ("Field '%s' not found in Struct '%s'"):format(field, self.name))
    if member:getType() == Enums.Types.Array then
        return member
    end
    return member:getValue()
end

function Struct:getType()
    return Enums.Type.Struct
end

--- Gets the size of this Struct, in bytes.
--- @return number The size of this Struct.
function Struct:getSize()
    return self.size
end

function Struct:read(reader, size)
    local total_size = 0
    for _, field in ipairs(self.fields) do
        field:read(reader)
        total_size = total_size + field:getSize()
    end
    if size then assert(total_size == size, ("Expected size of 0x%X, got 0x%X"):format(size, total_size)) end
    return self
end

return setmetatable(Struct, {
    __call = function(_, name, fields)
        return Struct.new(name, fields)
    end
})
