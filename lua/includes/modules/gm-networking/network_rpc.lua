--[[
    GM-Networking :: Network RPC
        By MiBShidobu
]]--

local RPC_NETWORK = {
    --[[
        Name: network.rpc.*message name*(any Variable1, any Variable2, ...)
        Desc: Calls aliased form of network.CallMessage that sends the message to all clients/server when called. e.g. network.rpc.my_message_name("hello", "Joe")
        State: SHARED
    ]]--

    __index = function (self, key)
        return function (...)
            network.CallMessage(key, nil, ...)
        end
    end,

    --[[
        Name: network.rpc.*message name* = function (any Variable1, any Variable2, ...) end
        Desc: Calls aliased form of network.HookMessage that sends the function to the message.
        State: SHARED
    ]]--

    __newindex = function (self, key, value)
        if type(value) ~= "function" then
            error("GM-Networking: Invalid type, requires 'function'")
        end

        network.HookMessage(key, value)
    end,

    __metatable = false
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
            end,

            __metatable = false
        }

        ply.rpc = setmetatable({}, RPC_PLAYER)
    end)
end