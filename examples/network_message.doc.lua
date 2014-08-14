local message = NetworkMessage("mymessage") -- Intialize a network object.
message:Write("How are you?") -- Can write any variable.
message:Write(Player(2)) -- Including supported objects.
message:Write(Player(2):GetPos()) -- Like vectors.

message:Send() -- Send it to all players

message:Send{Player(2), Player(4)} -- Or a table of players.

message:Send(Player(2)) -- Or just the lonely one.

-- Returns the object on each :Write, so you can stack up!
NetworkMessage("mymessage"):Write("How are you?"):Write(Player(2)):Write(Player(2):GetPos()):Send() -- Like so!

NetworkMessage("mymessage") -- Or like this if it suits you!
    :Write("How are you?")
    :Write(Player(2))
    :Write(Player(2):GetPos())
:Send() -- Can choose targets all well, nil or empty broadcasts it. Or a player and it to that player, or a table of players. On client always sends to server.

-- Can also "Listen" to messages, simply get a 'NetworkMessage' and call :Listen!
local message = NetworkMessage("mymessage")
message:Listen(function (msg, ply, position)
    chat.AddText(Color(255, 255, 255), msg, " ", ply:Nick(), " at ", tostring(position), "?")
end)

-- Don't want objects? Can use plain net library functions too.
network.StartMessage("mymessage")
    network.WriteMessage("How are you?")
    network.WriteMessage(Player(2))
    network.WriteMessage(Player(2):GetPos())
network.SendMessage() -- same as :Send.

-- With even simplier functionality!
network.CallMessage("mymessage", nil, "How are you?", Player(2), Player(2):GetPos()) -- nil is the the same as :Send and .SendMessage's argument.

network.HookMessage("mymessage", function (msg, ply, position)
    chat.AddText(Color(255, 255, 255), msg, " ", ply:Nick(), " at ", tostring(position), "?")
end)

-- And even an RPC interface for calls.
network.rpc.mymessage("How are you?", Player(2), Player(2):GetPos())

-- With also being able to send to specific players.
local ply = Player(3)
ply.rpc.mymessage("How are you?", Player(2), Player(2):GetPos())

-- With hooking too.
network.rpc.mymessage = function (msg, ply, position)
    chat.AddText(Color(255, 255, 255), msg, " ", ply:Nick(), " at ", tostring(position), "?")
end