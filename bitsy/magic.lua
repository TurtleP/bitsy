local path = (...):gsub("magic", "")
local DataType = require(path .. "datatype")

local Magic = {}
Magic.__index = Magic

function Magic:new(name, type, expected)
    assert(expected ~= nil, "Expected value cannot be nil")
    local instance = DataType.new(self, name, type:getSize())
    instance.type = type
    instance.expected = expected
    return instance
end

function Magic:read(reader)
    local value = reader:read(self.type, self:getSize())
    if type(value) == "table" and type(self.expected) == "table" then
        for i = 1, #self.expected do
            assert(value[i] == self.expected[i],
                ("Expected element %d to be %s, got %s"):format(i, self.expected[i], value[i]))
        end
    else
        assert(value == self.expected, ("Expected %s, got %s"):format(self.expected, value))
    end
    return value
end

function Magic:write(writer, value)
    if type(value) == "table" then
        return writer:write(self.type, unpack(value))
    end
    writer:write(self.type, value)
end

function Magic:__tostring()
    return ("<Magic %s: %s>"):format(self.name, self.type)
end

return setmetatable(Magic, {
    __call = function(cls, ...)
        return cls:new(...)
    end,
    __index = DataType
})
