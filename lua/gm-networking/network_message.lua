--[[
    GM-Networking :: Network Messages
        By MiBShidobu
]]--

if SERVER then
    util.AddNetworkString("network_message_trans")
end

local NETWORK = {}
NETWORK.__index = NETWORK

network.MessageHooks = network.MessageHooks or {}

--[[
	Registering 'NetworkMessage' metatable.
]]--

debug.getregistry().NetworkMessage = NETWORK

--[[
    Name: NetworkMessage(string Message Name)
    Desc: Returns a 'NetworkMessage' object pretaining to the message name.
    State: SHARED
]]--

function NetworkMessage(name)
    return setmetatable({
        name = name
    }, NETWORK)
end

--[[
    Name: NETWORK:Write(variable Value)
    Desc: Writes the value to the object's buffer.
    State: SHARED
]]--

function NETWORK:Write(value)
    if not self.buffer then
        self.buffer = NetworkBuffer()
    end

    self.buffer:Write(value)
    return self
end

--[[
    Name: NETWORK:Send(table Players or entity Player or nil All Players)
    Desc: Writes the buffer to the network and sends the 'NetworkMessage'.
    State: SHARED
]]--

function NETWORK:Send(target)
    net.Start("network_message_trans")
        net.WriteString(self.name)
        net.WriteBit(self.buffer and true or false)
        if self.buffer then
            network.WriteBuffer(self.buffer)
        end

    if CLIENT then
        net.SendToServer()
    else
        if value == nil then
            net.Broadcast()

        else
            net.Send(target)
        end
    end

    self.buffer = nil
end

--[[
    Name: NETWORK:Listen(function Function)
    Desc: Hooks your function into the 'NetworkMessage'.
    State: SHARED
]]--

function NETWORK:Listen(func)
    network.MessageHooks[self.name] = func
end

local message = nil

--[[
    Name: network.StartMessage(name)
    Desc: Intializes a 'NetworkMessage' object pretaining to the message name.
    State: SHARED
]]--

function network.StartMessage(name)
    message = NetworkMessage(name)
end

--[[
    Name: network.WriteMessage(variable Value)
    Desc: Writes the value to the global buffer.
    State: SHARED
]]--

function network.WriteMessage(...)
    if message then
        message:Write(unpack({...}))

    else
        error("GM-Networking: No 'NetworkMessage' intialized")
    end
end

--[[
    Name: network.SendMessage(table Players or entity Player or nil All Players)
    Desc: Writes the buffer to the network and sends the 'NetworkMessage'.
    State: SHARED
]]--

function network.SendMessage(...)
    if message then
        message:Send(unpack({...}))
        message = nil

    else
        error("GM-Networking: No 'NetworkMessage' intialized")
    end
end

--[[
    Name: network.CallMessage(table Players or entity Player or nil All Players)
    Desc: Writes the buffer to the network and sends the 'NetworkMessage'.
    State: SHARED
]]--

function network.CallMessage(name, target, ...)
    local message = NetworkMessage(name)
        for _, value in ipairs({...}) do
            message:Write(value)
        end
    message:Send(target)
end

--[[
    Name: NETWORK:HookMessage(string Name, function Function)
    Desc: Hooks your function into the 'NetworkMessage'.
    State: SHARED
]]--

function network.HookMessage(name, func)
    network.MessageHooks[name] = func
end

--[[
    Registering network receivers.
]]--

net.Receive("network_message_trans", function (length, ply)
    local name = net.ReadString()
    if network.MessageHooks[name] then
        local variables = {}
        if net.ReadBit() == 1 then
            variables = network.ReadBuffer(true)
        end

        network.MessageHooks[name](length, ply, unpack(variables))
    end
end)