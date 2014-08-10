local nettype = network.GetNetworkType("some variable") --[[ Determines 'NetworkType' of the variable, returning a variable coresponding to a global constant:
    NETWORK_TYPE_ERROR - Unsupported Variable Type
    NETWORK_TYPE_NIL - nil
    NETWORK_TYPE_ANGLE - Angle(P, Y, Z)
    NETWORK_TYPE_BOOLEAN - true/false 
    NETWORK_TYPE_COLOR = Color(R, G, B, A)
    NETWORK_TYPE_ENTITY = Enriry(EntIndex)
    NETWORK_TYPE_NUMBER = number
    NETWORK_TYPE_STRING = "string"
    NETWORK_TYPE_VECTOR = Vector(X, Y, Z)
    NETWORK_TYPE_TABLE = {Element1, Element2, X=Element3, Y={Z=Element6}}
]]--

local bits = network.GetFixedType(some number) --[[ Returns the Bit Data Size the number of bits is under or equal to.
    Nibble/Semi-Octet - 4
    Byte/Octet - 8
    Word/Short - 16
    Long/Int - 32

    For the range of numbers each applies to, check out: http://en.wikipedia.org/wiki/Integer_(computer_science)#Common_integral_data_types
]]--

-- Using these two functions and an internal one, you can use these functions to automated handling of data types and net.*UInt and net.*Int
network.WriteNumber(number)
local number = network.ReadNumber()

-- You can automate the whole reading and write process with typing by using the below functions if they're a defined constant shown at the top of this file.
-- Note, this adds a small overhead, CPU-wise. Network-wise it should be negligible at worst, almost none exist at best. Compared to Garry's Mod built-in net.*Type.
network.WriteVariable(some variable)
local variable = network.ReadVariable()