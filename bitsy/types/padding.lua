local DataType = require("bitsy.core.datatype")
local types = require("bitsy.core.types")

local Padding = {}
Padding.__index = Padding

function Padding:new(length)
    return DataType.new(self, "Padding", length)
end

function Padding:read(reader)
    return reader:readUInt8(self.size)
end

function Padding:write(writer)
    writer:writeUInt8(0, self.size)
end

function Padding:__tostring()
    return ("<Padding[%d]>"):format(self.size)
end

return setmetatable(Padding, {
    __call = function(cls, ...)
        return cls:new(...)
    end,
    __index = DataType
})
