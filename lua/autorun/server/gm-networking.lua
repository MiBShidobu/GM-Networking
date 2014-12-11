--[[
    GM-Networking :: Autorun Script
        by MiBShidobu
]]--

-- Queue up the serverside lua files to send to client.
AddCSLuaFile("includes/modules/gm-serialize.lua")

AddCSLuaFile("includes/modules/gm-networking.lua")
AddCSLuaFile("includes/modules/gm-networking/network_message.lua")
AddCSLuaFile("includes/modules/gm-networking/network_rpc.lua")
AddCSLuaFile("includes/modules/gm-networking/network_stream.lua")