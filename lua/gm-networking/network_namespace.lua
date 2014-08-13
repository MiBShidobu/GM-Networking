--[[
    GM-Networking :: Network Namespace
        By MiBShidobu
]]--

network = network or {}

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
    local data = util.Compress(serialize.Encode(value))
    net.WriteUInt(#data, 16)
    net.WriteData(data, #data)
end

--[[
    Name: network.ReadVariable()
    Desc: Returns a number from the net library using the network.WriteVariable format.
    State: SHARED
]]--

function network.ReadVariable()
    return serialize.Decode(util.Decompress(net.ReadData(net.ReadUInt(16))))
end

--[[
    Name: network.rpc.*message name*(any Variable1, any Variable2, ...)
    Desc: Calls aliased form of network.CallMessage that sends the message to all clients/server when called. e.g. network.rpc.my_message_name("hello", "Joe")
    State: SHARED
]]--

local RPC_NETWORK = {
    __index = function (self, key)
        return function (...)
            network.CallMessage(key, nil, ...)
        end
    end
}

network.rpc = setmetatable({}, RPC_NETWORK)

--[[
    Name: PLAYER.rpc.*message name*(any Variable1, any Variable2, ...)
    Desc: Calls aliased form of network.CallMessage that sends the message to all clients/server when called. e.g. ply.rpc.my_message_name("hello", "Joe")
    State: SHARED
]]--

if SERVER then
    hook.Add("PlayerInitialSpawn", "gm-networking_plyinit", function (ply)
        local RPC_PLAYER = {
            __index = function (self, key)
                return function (...)
                    network.CallMessage(key, ply, ...)
                end
            end
        }

        ply.rpc = setmetatable({}, RPC_PLAYER)
    end)
end