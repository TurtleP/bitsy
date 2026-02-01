local path = (...):gsub("array", "")
local Enums = require(path .. "enums")

local Array = {}
Array.__index = Array

function Array.new(type, name, count, data)
    count = count or 1
    local value = {}
    for _ = 1, count do
        value[#value + 1] = type:default()
    end
    return setmetatable({ type = type, name = name, count = count, value = value, data = data }, Array)
end

function Array:default()
    local data = {}
    for _ = 1, self.count do
        data[#data + 1] = self.type:default()
    end
    return Array(self.type, self.name, self.count, data)
end

function Array:getName()
    return self.name
end

function Array:getValue()
    return self.value
end

function Array:getSize()
    local size = (self.type ~= Enums.Types.Struct and self.type:getSize()) or self.data:getSize()
    return size * self.count
end

function Array:getType()
    return Enums.Types.Array
end

function Array:read(reader)
    self.value = reader:read(self.type, self.count, self.data)
    return self
end

function Array:index(i)
    return self.value[i]
end

function Array:__tostring()
    return ("<Array %s; %d>"):format(self.name, self.count)
end

return setmetatable(Array, {
    __call = function(_, type, name, count, data)
        return Array.new(type, name, count, data)
    end
})
