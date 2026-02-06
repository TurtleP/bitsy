local path = (...):gsub("struct", "")
local Types = require(path .. "types")

local Struct = {}
Struct.__index = function(self, key)
    if Struct[key] then
        return Struct[key]
    end
    local member = self.members[key]
    if member then
        if member:getType() == Types.Array then
            return member
        end
        return member.value
    end
    return nil
end

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

function Struct:getName()
    return self.name
end

function Struct:default()
    local fields = {}
    for _, field in pairs(self.members) do
        fields[#fields + 1] = field
    end
    return Struct(self.name, fields)
end

function Struct:get(field)
    local member = self.members[field]
    assert(member ~= nil, ("Field '%s' not found in Struct '%s'"):format(field, self.name))
    if member:getType() == Types.Array then
        return member
    end
    return member:getValue()
end

function Struct:getType()
    return Types.Struct
end

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
    __call = function(_, name, fields) return Struct.new(name, fields) end
})
