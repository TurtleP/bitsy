local path = (...):gsub("field", "")
local Enums = require(path .. "enums")
local Struct = require(path .. "struct")

--- @class Field
--- Represents a field in a binary data structure.
--- @field private type Enums.Types The type of the field
--- @field private name string The name of the field
--- @field private size number The size of the field in bytes
--- @field private value any The value of the field
local Field = {}
Field.__index = Field

function Field.new(type, name, value)
    local size = type ~= Enums.Types.Struct and type:getSize() or value:getSize()
    return setmetatable({ type = type, name = name or "unnamed", size = size, value = value }, Field)
end

function Field:__tostring()
    return ("<Field %s: 0x%X>"):format(self.name, self.size)
end

--- Gets the name of this Field.
--- @return string The name of the field
function Field:getName()
    return self.name
end

--- Gets the count of this Field.
--- @return number The count of the field
function Field:getCount()
    return self.count
end

--- Gets the type of this Field.
--- @return string The type of the field
function Field:getType()
    return self.type
end

--- Gets the value in this Field.
--- @return any The value of the field
function Field:getValue()
    return self.value
end

--- Gets the size of the Field, in bytes.
--- @return number The size of the Field
function Field:getSize()
    return self.size
end

function Field:read(reader)
    self.value = reader:read(self.type, 1, self.value)
    return self
end

return setmetatable(Field, {
    __call = function(_, type, name, value)
        return Field.new(type, name, value)
    end
})
