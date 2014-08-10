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

    elseif type == "table" then
        return NETWORK_TYPE_TABLE
    end

    return NETWORK_TYPE_ERROR
end

--[[
    Name: network.Serialize(variable Value)
    Desc: Serializes the variable into a data string.
    State: SHARED
]]--

local START = string.char(2)
local END = string.char(3)
local TERM = string.char(31)

function network.Serialize(variable)
    local ntype = network.GetNetworkType(variable)
    if ntype == NETWORK_TYPE_NIL then
        return START..ntype..START.."0"

    elseif ntype == NETWORK_TYPE_ANGLE then
        return START..ntype..START..variable.pitch..TERM..variable.yaw..variable.roll

    elseif ntype == NETWORK_TYPE_BOOLEAN then
        return START..ntype..START..(variable and 1 or 0)

    elseif ntype == NETWORK_TYPE_COLOR then
        return START..ntype..START..string.upper(string.format("%02x%02x%02x%02x", variable.r, variable.g, variable.b, variable.a or 255))

    elseif ntype == NETWORK_TYPE_ENTITY then
        return START..ntype..START..(IsValid(variable) and variable:EntIndex() or -1)

    elseif ntype == NETWORK_TYPE_NUMBER then
        return START..ntype..START..variable

    elseif ntype == NETWORK_TYPE_STRING then
        return START..ntype..START..variable

    elseif ntype == NETWORK_TYPE_VECTOR then
        return START..ntype..START..variable.x..TERM..variable.y..TERM..variable.z

    elseif ntype == NETWORK_TYPE_TABLE then
        local str = START..ntype
        for key, value in pairs(variable) do
            ntype = network.GetNetworkType(value)
            if ntype ~= NETWORK_TYPE_ERROR then
                str = str..network.Serialize(key)..network.Serialize(value)
            end
        end

        return str..END
    end

    error("GM-Networking: Variable is unsupported")
end

--[[
    Name: SerializedParse(string String)
    Desc: Parses a serialized string.
    State: SHARED/LOCAL
]]--

function SerializedParse(str)
    local tbl = {}
    local offset = 0

    for entry in string.gmatch(str, START.."([%w%s%p]+)") do
        local start, last = string.find(str, entry, offset)
        table.insert(tbl, {
            entry,
            start
        })

        offset = last + 1
    end

    return tbl
end

--[[
    Name: network.Deserialize(string Data String, table Parsed Table)
    Desc: Deserializes the data string into a variable proper.
    State: SHARED
]]--

function network.Deserialize(str, tbl)
    tbl = tbl or SerializedParse(str)
    local type, raw = tonumber(table.remove(tbl, 1)[1]), nil
    if type ~= NETWORK_TYPE_TABLE then
        raw = table.remove(tbl, 1)[1]
    end

    if type == NETWORK_TYPE_NIL then
        return nil

    elseif type == NETWORK_TYPE_ANGLE then
        local values = string.Explode(TERM, raw)
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
        local values = string.Explode(TERM, raw)
        return Vector(tonumber(values[1]), tonumber(values[2]), tonumber(values[3]))

    elseif type == NETWORK_TYPE_TABLE then
        local ret = {}
        while #tbl > 0 do
            local ktype = table.remove(tbl, 1)
            local kvalue = table.remove(tbl, 1)

            local key = network.Deserialize(START..ktype[1]..START..kvalue[1])
            local vtype = tonumber(table.remove(tbl, 1)[1])
            local vvalue = table.remove(tbl, 1)
            if vtype == NETWORK_TYPE_TABLE then
                table.insert(tbl, 1, vvalue)
                table.insert(tbl, 1, {vtype})
                ret[key] = network.Deserialize(str, tbl)

            else
                ret[key] = network.Deserialize(START..vtype..START..vvalue[1])
            end

            local position = vvalue[2] + #vvalue[1]
            if string.sub(str, position, position) == END then
                break
            end
        end

        return ret
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