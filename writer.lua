--- @class BinaryWriter
--- @field private data love.Data
local BinaryWriter = {}
BinaryWriter.__index = BinaryWriter

--- Creates a new BinaryWriter
--- @param size integer The size of the data, in bytes.
--- @return BinaryWriter
function BinaryWriter.new(size)
    return setmetatable({ data = love.data.newByteData(size), offset = 0, BinaryWriter })
end

--- Creates a new BinaryWriter
--- @param data love.Data | string The data to use
--- @return BinaryWriter
function BinaryWriter.from(data)
    data = type(data) == "string" and love.data.newByteData(data) or data
    return setmetatable({ data = data, offset = 0 }, BinaryWriter)
end

--- Gets the data in the BinaryWriter
--- @return love.Data data The data in the BinaryWriter
function BinaryWriter:getData()
    return self.data
end

function BinaryWriter:__tostring()
    return self.data:getString()
end

return setmetatable(BinaryWriter, {
    __call = function(_, size)
        return BinaryWriter.new(size)
    end
})
