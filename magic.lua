local Magic = {}
Magic.__index = Magic

--- Creates a new Magic validator.
--- @param type Enum.Types The type of magic to validate.
--- @param name string The name of the magic.
--- @param value string | integer | integer[] The value to validate.
function Magic.new(type, name, value)
    return setmetatable({ type = type, name = name, value = value }, Magic)
end

function Magic:getName()
    return self.name
end

function Magic:read(reader)
    local value = reader:read(self.type, self:getSize())
    assert(value == self.value, ("Expected %s, got %s"):format(self.value, value))
    return self
end

function Magic:getSize()
    if type(self.value) == "table" then
        return #self.value * self.type:getSize()
    elseif type(self.value) == "string" then
        return self.type:getSize() * #self.value
    end
    return self.type:getSize()
end

return setmetatable(Magic, {
    __call = function(_, type, name, value)
        return Magic.new(type, name, value)
    end
})
