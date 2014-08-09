--[[
    GM-Networking :: Network Buffer
        By MiBShidobu
]]--

local BUFFER = {}
BUFFER.__index = BUFFER

--[[
	Registering 'NetworkBuffer' metatable.
]]--

debug.getregistry().NetworkBuffer = BUFFER

--[[
    Name: NetworkBuffer(string Serialized Buffer)
    Desc: Returns a write-only buffer if no string is passed. If a string is passed using the serialization format, returns a read-only buffer.
    State: SHARED
]]--

function NetworkBuffer(data)
    if data then
        return setmetatable({
            data = util.Decompress(data)
        }, BUFFER)

    end

    return setmetatable({
        buffer = ""
    }, BUFFER)
end

--[[
    Name: BUFFER:Write(variable Value)
    Desc: Writes a variable to the buffer.
    State: SHARED
]]--

function BUFFER:Write(value)
    if self.data then
        error("GM-Networking: Buffer is read-only!")
    end

    self.buffer = self.buffer..network.Serialize(value)
    return self
end

--[[
    Name: BUFFER:Deserialize()
    Desc: Deserializes the buffer and returns a table of written values.
    State: SHARED
]]--

function BUFFER:Deserialize()
    if self.buffer then
        error("GM-Networking: Buffer is write-only!")
    end

    if not self.tbl then
        self.tbl = {}
        local extracted = {}

        for match in string.gmatch(self.data, START.."([%w%s%p]+)") do
            table.insert(extracted, match)
        end

        while #extracted > 0 do
            table.insert(self.tbl, network.Deserialize(START..table.remove(extracted, 1)..START..table.remove(extracted, 1)))
        end
    end

    return self.tbl
end

--[[
    Name: BUFFER:Serialize()
    Desc: Serializes the buffer and returns the string.
    State: SHARED
]]--

function BUFFER:Serialize()
    if self.data then
        error("GM-Networking: Buffer is read-only!")
    end

    return util.Compress(self.buffer)
end

--[[
    Name: network.WriteBuffer(buffer Buffer)
    Desc: Writes the buffer to the net library.
    State: SHARED
]]--

function network.WriteBuffer(buffer)
    local data = buffer:Serialize()
    net.WriteUInt(#data, 16)
    net.WriteData(data, #data)
end

--[[
    Name: network.ReadBuffer(boolean Parse Buffer)
    Desc: Reads the buffer from the net library, automatically deserializes the data if a true boolean is passed.
    State: SHARED
]]--

function network.ReadBuffer(parse)
    local buffer = NetworkBuffer(net.ReadData(net.ReadUInt(16)))
    if parse then
        return buffer:Deserialize()
    end

    return buffer
end