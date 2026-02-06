local BinaryStream = {}
BinaryStream.__index = BinaryStream

local path = (...):gsub("stream", "")
local SeekType = require(path .. "seek")

function BinaryStream:new(data, offset)
    self.data = data
    self.offset = offset or 0
end

function BinaryStream:getData()
    return self.data
end

function BinaryStream:getSize()
    return self.data:getSize()
end

function BinaryStream:getOffset()
    return self.offset
end

function BinaryStream:seek(offset, whence)
    assert(offset >= 0, "negative seek")
    if whence == SeekType.SEEK_CUR then
        self.offset = self.offset + offset
    elseif whence == SeekType.SEEK_SET then
        self.offset = offset
    elseif whence == SeekType.SEEK_END then
        self.offset = self:getSize() + offset
    end
    self.offset = math.max(0, math.min(self.offset, self:getSize()))
end

function BinaryStream:__tostring()
    return self.data:getString()
end

return setmetatable(BinaryStream, {
    __call = function(_, data, offset) return BinaryStream.new(data, offset) end
})
