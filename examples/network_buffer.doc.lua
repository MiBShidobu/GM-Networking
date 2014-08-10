-- If wanting simplier experience or just more uniform, you can use the 'NetworkBuffer' object. Easy way to send an array of variables via networking, more efficient than writing tables with net.*Variable().
-- This does much of the same as network.*Variable, but a little less overhead since a written buffer sends everything at once. Does not accept tables or other 'NetworkBuffer' objects.
local buffer = NetworkBuffer()
buffer:Write("My cool string!") -- While it uses a different and more efficient method of writing variables, still needs to be supported by the variable constants like network.*Variable.
buffer:Write(Player(2))
buffer:Write(Vector(2, 4, 1))

-- Which you can then write to your normal net library networking like so!
network.WriteBuffer(buffer)

-- And retrieving the written values is pretty simple.
local buffer = network.ReadBuffer()
local arguments = buffer:Deserialize()
print(arguments[1], arguments[2], arguments[3]) -- prints "My cool string! [Player 1][MiBShidobu] 2, 4, 1"

-- Can simplify by having the written buffer automatically deserialized.
local arguments = network.ReadBuffer(true)
print(arguments[1], arguments[2], arguments[3])

-- And can easily test if variables are 'NetworkBuffer's.
print(IsNetworkBuffer(myvar)) -- prints true/false