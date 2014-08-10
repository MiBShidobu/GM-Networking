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
    Name: IsNetworkBuffer(variable Value)
    Desc: Returns if the variable is a 'NetworkBuffer'.
    State: SHARED
]]--

function IsNetworkBuffer(value)
    return type(value) == "table" and getmetatable(value) == BUFFER
end

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

    return setmetatable({}, BUFFER)
end

--[[
    Name: BUFFER:Write(variable Value)
    Desc: Writes a variable to the buffer.
    State: SHARED
]]--

local SEP = string.char(23)

function BUFFER:Write(value)
    if self.data then
        error("GM-Networking: Buffer is read-only!")
    end

    if self.buffer then
        self.buffer = self.buffer..SEP..network.Serialize(value)

    else
        self.buffer = network.Serialize(value)
    end

    return self
end

--[[
    Name: BUFFER:Deserialize()
    Desc: Deserializes the buffer and returns a table of written values.
    State: SHARED
]]--

function BUFFER:Deserialize()
    if not self.data then
        error("GM-Networking: Buffer is write-only!")
    end

    if not self.tbl then
        self.tbl = {}
        for _, item in ipairs(string.Explode(SEP, self.data)) do
            table.insert(self.tbl, network.Deserialize(item))
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

    local count = #self.buffer
    if not self.compressed or count > self.compressed_c then
        self.compressed = util.Compress(self.buffer)
        self.compressed_c = count
    end

    return self.compressed
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