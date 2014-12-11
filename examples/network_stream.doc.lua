--[[
    Please note, this section of GM-Networking is meant for advanced users only. And should be used in replacement of the normal 'NetworkMessage' API.
    The only purpose of this library is to send large amounts of data greater than the 64kb size limit of the net library in an efficient and as less impact as possible way on clients via multiple packets.
    Such as large txt files or a render from a client. Also note, due to the nature of streaming, this section impacts networking more than normal conventions.
]]--

-- For this lengthy messages that's higher than the 64kb max transfer size of a single normal message, it can be transfered easily using the 'NetworkStream' API.
ply:QueueStream("mymessage", "some amount of data that's bigger than 64kb")

-- And on client just hook it like a normal 'NetworkMessage', see network_message.doc.lua for more info.
network.HookMessage("mymessage", function (msg, mydata)
    print(mydata)
end)

-- Client has similar functions, but instead exist inside the network namespace instead of a Player object.
network.QueueStream("mymessage", "some amount of data that's bigger than 64kb")

-- Ability to send multiple variable of course.
ply:QueueStream("mymessage", "some amount of data that's bigger than 64kb", Entity(1), false, {mytable="yus"})

-- The rate that the chunks of a 'NetworkBuffer' are transferred are dependent on the client's cl_updaterate convar.
-- This happens to prevent overloading the client, if you want to get how often a client sends/receives a chunk in seconds, you can use:
local rate = ply:PacketRate()

-- With it in the network namespace for clients.
local rate = network.PacketRate()

-- To also prevent overloading clients, streams are queued. Which means, not only is your hook not called instanteous due to chunking over seconds. It's also has to be sent in order with other streams.
-- To help you manage this, you get two other functions.
local is = ply:IsStreaming("mymessage")

-- or on client
local is = network.IsStreaming("mymessage")

-- server, note if it is streaming, this returns false
local is = ply:IsStreamQueued("mymessage")

-- and client
local is = network.IsStreamQueued("mymessage")

--[[
    Note, using streams, you can not queue up a stream more than once. Meaning, you can't queue up another
    stream of your message til the previous queue of that message was streamed.