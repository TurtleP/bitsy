local DataType = require("bitsy.core.datatype")

local Magic = {}
Magic.__index = Magic

local INVALID_ARRAY_ELEMENT = "Expected element %d to be %s, got %s"
local INVALID_MAGIC_VALUE = "Expected %s, got %s"

function Magic:new(type, expected)
    assert(expected ~= nil, "Expected value cannot be nil")
    local instance = DataType.new(self, nil, type:getSize())
    instance.type = type
    instance.expected = expected
    return instance
end

function Magic:read(reader)
    local value = reader:read(self.type, self:getSize())
    if type(value) == "table" and type(self.expected) == "table" then
        for i = 1, #self.expected do
            assert(value[i] == self.expected[i], INVALID_ARRAY_ELEMENT:format(i, self.expected[i], value[i]))
        end
    else
        assert(value == self.expected, INVALID_MAGIC_VALUE:format(self.expected, value))
    end
    return value
end

function Magic:write(writer, value)
    if type(value) == "table" then
        return self.type:write(writer, unpack(value))
    end
    self.type:write(writer, value)
end

function Magic:__tostring()
    return ("<Magic %s>"):format(self.expected)
end

return setmetatable(Magic, {
    __call = function(cls, ...)
        return cls:new(...)
    end,
    __index = DataType
})
