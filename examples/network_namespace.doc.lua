local bits = network.GetFixedType(some number) --[[ Returns the Bit Data Size the number of bits is under or equal to.
    Nibble/Semi-Octet - 4
    Byte/Octet - 8
    Word/Short - 16
    Long/Int - 32

    For the range of numbers each applies to, check out: http://en.wikipedia.org/wiki/Integer_(computer_science)#Common_integral_data_types
]]--

-- Using above function, it automates handling of bit data types when using net.*UInt and net.*Int instead you needing to manually do it.
network.WriteNumber(number)
local number = network.ReadNumber()

-- You can automate the whole reading and write process of almost all types, by using the below functions.
-- Note, this adds a small overhead, CPU-wise. Network-wise it should be negligible at worst, almost none exist at best. Compared to Garry's Mod built-in net.*Type.
-- If writing multple variables, see 'NetworkBuffer' objects.
network.WriteVariable(some variable)
local variable = network.ReadVariable()