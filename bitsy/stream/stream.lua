local SeekType = require("bitsy.core.seek")

local BinaryStream = {}
BinaryStream.__index = BinaryStream

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

function BinaryStream:tell()
    return self.offset
end

function BinaryStream:seek(offset, whence)
    if whence == SeekType.SEEK_CUR then
        self.offset = self.offset + offset
    elseif whence == SeekType.SEEK_SET then
        self.offset = offset
    elseif whence == SeekType.SEEK_END then
        self.offset = self:getSize() + offset
    end
    self.offset = math.max(0, math.min(self.offset, self:getSize()))
end

function BinaryStream:rewind()
    self.offset = 0
end

function BinaryStream:advance(count)
    self.offset = self.offset + count
end

function BinaryStream:__tostring()
    return self.data:getString()
end

return BinaryStream
