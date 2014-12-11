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
        m_Name = name
    }, NETWORK)
end

--[[
    Name: NETWORK:Write(variable Value)
    Desc: Writes the value to the object's buffer.
    State: SHARED
]]--

function NETWORK:Write(value)
    if not self.m_Buffer then
        self.m_Buffer = {}
    end

    table.insert(self.m_Buffer, value)
    return self
end

--[[
    Name: SendMessage(string Name, table Players or entity Player or nil All Players, table Buffer)
    Desc: Writes the buffer to the network and sends the 'NetworkMessage'.
    State: SHARED/LOCAL
]]--

local function SendMessage(name, target, buffer)
    net.Start("network_message_trans")
        net.WriteString(name)
        net.WriteBit(buffer and true or false)
        if buffer then
            local encoded = serialize.Encode(buffer)
            local length = #encoded

            net.WriteUInt(length, 16)
            net.WriteData(encoded, length)
        end

    if CLIENT then
        net.SendToServer()

    else
        if target == nil then
            net.Broadcast()

        else
            net.Send(target)
        end
    end
end

--[[
    Name: NETWORK:Send(table Players or entity Player or nil All Players)
    Desc: Writes the buffer to the network and sends the 'NetworkMessage'.
    State: SHARED
]]--

function NETWORK:Send(target)
    SendMessage(self.m_Name, target, self.m_Buffer)
    self.m_Buffer = nil
end

--[[
    Name: NETWORK:Listen(function Function)
    Desc: Hooks your function into the 'NetworkMessage'.
    State: SHARED
]]--

function NETWORK:Listen(func)
    network.MessageHooks[self.m_Name] = func
end

local g_Name = nil
local g_Buffer = nil

--[[
    Name: network.StartMessage(name)
    Desc: Intializes a 'NetworkMessage' object pretaining to the message name.
    State: SHARED
]]--

function network.StartMessage(name)
    g_Name = name
end

--[[
    Name: network.WriteMessage(variable Value)
    Desc: Writes the value to the global buffer.
    State: SHARED
]]--

function network.WriteMessage(value)
    if g_Name then
        if not g_Name then
            g_Buffer = {}
        end

        table.insert(g_Buffer, value)

    else
        error("GM-Networking: 'network.StartMessage' wasn't called")
    end
end

--[[
    Name: network.SendMessage(table Players or entity Player or nil All Players)
    Desc: Writes the buffer to the network and sends the 'NetworkMessage'.
    State: SHARED
]]--

function network.SendMessage(target)
    if g_Name then
        SendMessage(g_Name, target, g_Buffer)

        g_Name = nil
        g_Buffer = nil

    else
        error("GM-Networking: 'network.StartMessage' wasn't called")
    end
end

--[[
    Name: network.CallMessage(string Name, table Players or entity Player or nil All Players, any Variable1, any Variable2, ...)
    Desc: Writes the buffer to the network and sends the 'NetworkMessage'.
    State: SHARED
]]--

function network.CallMessage(name, target, ...)
    local args = {...}
    local buffer = nil
    if #args > 0 then
        buffer = {}
        for _, value in ipairs(args) do
            table.insert(buffer, value)
        end
    end

    SendMessage(name, target, buffer)
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
            local data = net.ReadData(net.ReadUInt(16))
            variables = serialize.Decode(data)
        end

        network.MessageHooks[name](length, ply, unpack(variables))
    end
end)