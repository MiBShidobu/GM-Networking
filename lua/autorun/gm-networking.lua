--[[
    GM-Networking By MiBShidobu

    Description:
        This addon provides an OOP wrapper and modeling solution for the net library, for simplified usage.

    Developing For:
        To expand upon the 'NetworkMessage' object, use FindMetaTable with the parameter 'NetworkMessage' and extend it would like any
        other metatable. You can do the same with the 'NetworkBuffer' and 'NetworkModel' objects aswell.

    Credits:
        MiBShidobu - Main Developer
        In-line credits - Developers who constructed a function or single bits of code I'm using, credited in-line at their functions. ... if I can remember
]]--

if SERVER then
    AddCSLuaFile("gm-networking/network_const.lua")
    AddCSLuaFile("gm-networking/network_namespace.lua")
    AddCSLuaFile("gm-networking/network_model.lua")
    AddCSLuaFile("gm-networking/network_message.lua")
end

include("gm-networking/network_const.lua")
include("gm-networking/network_namespace.lua")
include("gm-networking/network_model.lua")
include("gm-networking/network_message.lua")