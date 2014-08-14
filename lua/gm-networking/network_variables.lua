--[[
    GM-Networking :: Network Variables
        By MiBShidobu
]]--

network.VariableCache = network.VariableCache or {}

if SERVER then
    network.VariableFuncs = network.VariableFuncs or {}

    --[[
        Name: network.SetVariable(string Name, variable Value)
        Desc: Sets a networked global variable to the value.
        State: SERVER
    ]]--

    function network.SetVariable(name, value)
        network.VariableCache[name] = value
        if network.VariableFuncs[name] then
            local players = {}
            for _, ply in ipairs(player.GetAll()) do
                if not network.VariableFuncs[name](ply) then
                    table.insert(players, ply)
                end
            end

            if #players > 0 then
                network.CallMessage("network_variable_glob_trans", players, name, value)
            end

        else
            network.CallMessage("network_variable_glob_trans", nil, name, value)
        end
    end

    --[[
        Name: network.SetVariableFilter(string Name, function Function)
        Desc: Sets a function filter for the provided variable.
        State: SERVER
    ]]--
    function network.SetVariableFilter(name, func)
        network.VariableFuncs[name] = func
    end
end

--[[
    Name: network.GetVariable(string Name)
    Desc: Returns a networked global variable to the value.
    State: SHARED
]]--

function network.GetVariable(name)
    return network.VariableCache[name]
end

local ENT = FindMetaTable("Entity")

--[[
    Name: ENT:NetworkVariable(string Name[, variable Value)
    Desc: Returns a networked variable attached to the entity, and on server only, sets it if a vaiable it provided.
    State: SHARED/SERVER
]]--

function ENT:NetworkVariable(name, value)
    if IsValid(self) then
        if value ~= nil then
            if SERVER then
                if not self._gmn then
                    self._gmn = {}
                end

                self._gmn[name] = value
                if self._gmn_f and self._gmn_f[name] then
                    local players = {}
                    for _, ply in ipairs(player.GetAll()) do
                        if not self._gmn_f[name](ply) then
                            table.insert(players, ply)
                        end
                    end

                    if #players > 0 then
                        network.CallMessage("network_variable_ent_trans", players, self, name, value)
                    end

                else
                    network.CallMessage("network_variable_ent_trans", nil, self, name, value)
                end

            else
                error("GM-Networking: Cannot set on Client")
            end

        else
            if self._gmn then
                return self._gmn[name]
            end
        end

    else
        error("GM-Networking: Tried to network invalid entity")
    end
end

if SERVER then
    --[[
        Name: ENT:NetworkVariableFilter(string Name, function Function)
        Desc: Sets a function filter for the provided variable. Same format as network.SetVariableFilter.
        State: SERVER
    ]]--

    function ENT:NetworkVariableFilter(name, func)
        if IsValid(self) then
            self._gmn_f = self._gmn_f or {}
            self._gmn_f[name] = func

        else
            error("GM-Networking: Tried to network invalid entity")
        end
    end
end

--[[
    Registering server net receivers.
]]--

if SERVER then
    network.HookMessage("network_variable_dump_trans", function (length, ply)
        if IsValid(ply) then
            local message = NetworkMessage("network_variable_dump_trans")
                local metadata = {}
                for _, ent in ipairs(ents.GetAll()) do
                    if ent._gmn then
                        local data = {}
                        for name, value in pairs(ent._gmn) do
                            if ent._gmn_f and ent._gmn_f[name] then
                                if ent._gmn_f[name](ply) then
                                    continue
                                end
                            end

                            data[name] = value
                        end

                        if #data > 0 then
                            table.insert(metadata, {
                                ent = ent,
                                data = data
                            })
                        end
                    end
                end

                message:Write(metadata)
                metadata = {}
                for name, value in pairs(network.VariableCache) do
                    if network.VariableFuncs[name] and network.VariableFuncs[name](ply) then
                        continue
                    end

                    metadata[name] = value
                end

                message:Write(metadata)
            message:Send(ply)
        end
    end)
end

--[[
    Registering client net receivers and gamemode hooks.
]]--

if CLIENT then
    hook.Add("InitPostEntity", "gm-networking_entinit", function ()
        network.CallMessage("network_variable_dump_trans")
    end)

    network.HookMessage("network_variable_glob_trans", function (length, ply, name, value)
        network.VariableCache[name] = value
    end)
    
    network.HookMessage("network_variable_ent_trans", function (length, ply, ent, name, value)
        if IsValid(ent) then
            if not ent._gmn then
                ent._gmn = {}
            end

            ent._gmn[name] = value
        end
    end)

    network.HookMessage("network_variable_dump_trans", function (length, ply, variables, metadata)
        network.VariableCache = variables
        for _, data in ipairs(metadata) do
            if IsValid(data.ent) then
                data.ent._gmn = data.data
            end
        end
    end)
end