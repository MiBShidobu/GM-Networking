--[[
    GM-Networking :: Network Namespace
        By MiBShidobu
]]--

network = network or {}

--[[
    Name: network.GetNetworkType(variable Value)
    Desc: Returns the corresponding NETWORK_TYPE_ constant to the value.
    State: SHARED
]]--

function network.GetNetworkType(value)
    local type = string.lower(type(value))
    if value == nil then
        return NETWORK_TYPE_NIL

    elseif type == "angle" then
        return NETWORK_TYPE_ANGLE

    elseif type == "boolean" then
        return NETWORK_TYPE_BOOLEAN

    elseif IsColor(value) then
        return NETWORK_TYPE_COLOR

    elseif IsEntity(value) then
        return NETWORK_TYPE_ENTITY

    elseif type == "number" then
        return NETWORK_TYPE_NUMBER

    elseif type == "string" then
        return NETWORK_TYPE_STRING

    elseif type == "vector" then
        return NETWORK_TYPE_VECTOR
    end

    return NETWORK_TYPE_ERROR
end

--[[
    Name: network.Serialize(variable Value)
    Desc: Serializes the variable into a data string.
    State: SHARED
]]--

local START = string.char(2)

function network.Serialize(value)
    local type = network.GetNetworkType(value)
    if type == NETWORK_TYPE_NIL then
        return START..value..START.."0"

    elseif type == NETWORK_TYPE_ANGLE then
        return START..type..START..tostring(value)

    elseif type == NETWORK_TYPE_BOOLEAN then
        return START..type..START..(value and 1 or 0)

    elseif type == NETWORK_TYPE_COLOR then
        return START..type..START..string.upper(string.format("%02x%02x%02x%02x", value.r, value.g, value.b, value.a or 255))

    elseif type == NETWORK_TYPE_ENTITY then
        return START..type..START..(IsValid(value) and value:EntIndex() or -1)

    elseif type == NETWORK_TYPE_NUMBER then
        return START..type..START..value

    elseif type == NETWORK_TYPE_STRING then
        return START..type..START..value

    elseif type == NETWORK_TYPE_VECTOR then
        return START..type..START..tostring(value)
    end

    error("GM-Networking: Variable is unsupported")
end

--[[
    Name: MatchesToRet(string String, string Search)
    Desc: Matches the String with Search and returns the results are function returns.
    State: SHARED/LOCAL
]]--

local function MatchesToRet(str, search)
    local tbl = {}
    for word in string.gmatch(str, search) do
        table.insert(tbl, word)
    end

    return unpack(tbl)
end

--[[
    Name: network.Deserialize(string Data String)
    Desc: Deserializes the data string into a variable proper.
    State: SHARED
]]--

function network.Deserialize(str)
    local type, raw = MatchesToRet(str, START.."([%w%s%p]+)")
    type = tonumber(type)

    if type == NETWORK_TYPE_NIL then
        return nil

    elseif type == NETWORK_TYPE_ANGLE then
        local values = string.Explode(" ", raw)
        return Angle(tonumber(values[1]), tonumber(values[2]), tonumber(values[3]))

    elseif type == NETWORK_TYPE_BOOLEAN then
        return raw == "1" and true or false

    elseif type == NETWORK_TYPE_COLOR then
        local red, green, blue, alpha = string.sub(raw, 1, 2), string.sub(raw, 3, 4), string.sub(raw, 5, 6), string.sub(raw, 7, 8)
        return Color(tonumber(red, 16), tonumber(green, 16), tonumber(blue, 16), tonumber(alpha, 16))

    elseif type == NETWORK_TYPE_ENTITY then
        return Entity(tonumber(raw))

    elseif type == NETWORK_TYPE_NUMBER then
        return tonumber(raw)

    elseif type == NETWORK_TYPE_STRING then
        return raw

    elseif type == NETWORK_TYPE_VECTOR then
        local values = string.Explode(" ", raw)
        return Vector(tonumber(values[1]), tonumber(values[2]), tonumber(values[3]))
    end

    error("GM-Networking: Variable is unsupported")
end

--[[
    Name: GetFixedType(number Bits)
    Desc: Returns the fixed bits step the bits are closest to.
    State: SHARED/LOCAL
]]--

local function GetFixedType(bits)
    if bits < 5 then
        return 4

    elseif bits < 9 then
        return 8

    elseif bits < 16 then
        return 16

    else
        return 32
    end
end

--[[
    Name: CalculateBitLength(number Number)
    Desc: Returns the length of the bits in a number.
    State: SHARED/LOCAL
]]--

local function CalculateBitLength(number)
    -- uh, I found this algorithm on a stackoverflow answer and can't find it again. whoops
    -- if anyone tells me, I'll update the file!
    local tbl = {}
    while number > 0 do
        rest = number % 2
        table.insert(tbl, 1, rest)

        number = (number - rest) / 2
    end

    return #table.concat(tbl)
end

--[[
    Name: network.WriteNumber(number Number)
    Desc: Writes a number to the net library, handles bit calculations and negative numbers for you.
    State: SHARED
]]--

function network.WriteNumber(number)
    local negative = number < 0
    local bits = GetFixedType(CalculateBitLength(negative and math.floor(number / 2) or number))

    network.WriteBit(negative)
    network.WriteUInt(bits, 4)
    if negative then
        network.WriteInt(number, bits)

    else
        network.WriteUInt(number, bits)
    end
end

--[[
    Name: network.ReadNumber()
    Desc: Returns a number from the net library using the network.WriteNumber format.
    State: SHARED
]]--

function network.ReadNumber()
    if network.ReadBit() > 0 then
        network.ReadInt(network.ReadUInt(4))

    else
        network.ReadUInt(network.ReadUInt(4))
    end
end

--[[
    Name: network.WriteVariable(variable Value)
    Desc: Writes a variable to the net library, automatically handling typing.
    State: SHARED
]]--

function network.WriteVariable(value)
    local data = network.Serialize(value)
    net.WriteUInt(#data, 16)
    net.WriteData(data, #data)
end

--[[
    Name: network.ReadVariable()
    Desc: Returns a number from the net library using the network.WriteVariable format.
    State: SHARED
]]--

function network.ReadVariable()
    return network.Deserialize(net.ReadData(net.ReadUInt(16)))
end

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