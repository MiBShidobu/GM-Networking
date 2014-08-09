 -- Note, the networking id of a model is generated via a CRC of the name and arguments. So you can use generic ids if you so wish. This also means that clients and servers have to have the same model to communiate and hook with each other.
local MyModel = NetworkSchema("HelpMessage", { -- Define the 'NetworkSchema' and get a 'NetworkModel' object in return.
    Message = { -- Define the 'Message' argument.
        Default = "Oh no, %s is attacking you!", -- Set our default value for networking.
        Type = NETWORK_TYPE_STRING -- And our type.
    },

    Player = NETWORK_TYPE_PLAYER, -- If we don't need other data, we can just define arguments by their type.
    Position = {
        Default = nil -- Set as nil, means by default it wont be handled.
        Type = NETWORK_TYPE_VECTOR
    }
})

local message = MyModel:GetMessage() -- Get an instance of the model to send a message.
    message:WritePlayer(Player(2)) -- Skip the defaulted stuff, since we only need to send the message.
message:Send(Player(3)) -- And send it to the player.

local message = MyModel:GetMessage() -- This time let's define our other arguments.
    message:WriteMessage("Wait no, %s is at %d, %d, %d instead!") -- Send a different string.
    message:WritePlayer(Player(2))
    message:WritePosition(Player(2):GetPos()) -- And sending a Vector.
message:Send(Player(3))

-- And on the recieving side with hooking into the message!

MyModel:HookMessage(function (message)
    local str = message:ReadMessage() -- Get the Message argument.
    local ply = message:ReadPlayer() -- And our Player.
    local position = message:ReadPosition() -- With the position.
    if position then -- Check if we were sent the Vector.
        chat.AddText(string.format(
            str,
            ply:Nick(),
            position.x,
            position.y,
            position.z
        )) -- Send the message with the Vector formated in.

    else
        chat.AddText(string.format(str, ply:Nick())) -- If 'position' is nil, means we didn't we one.
    end
end)