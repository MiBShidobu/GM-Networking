--[[
    GM-Networking Library By MiBShidobu

    Description:
        This addon provides an OOP wrapper and modeling solution for the net library, for simplified usage.

    Developing For:
        To expand upon the 'NetworkMessage' object, use FindMetaTable with the parameter 'NetworkMessage' and extend it would like any
        other metatable. You can do the same with the 'NetworkBuffer' and 'NetworkModel' objects aswell.

    Credits:
        MiBShidobu - Main Developer
        In-line credits - Developers who constructed a function or single bits of code I'm using, credited in-line at their functions. ... if I can remember them...
]]--

if SERVER then
    AddCSLuaFile("gm-networking/library/gm-serialize.lua")
    AddCSLuaFile("gm-networking/network_namespace.lua")
    AddCSLuaFile("gm-networking/network_buffer.lua")
    AddCSLuaFile("gm-networking/network_message.lua")
    AddCSLuaFile("gm-networking/network_model.lua")
    AddCSLuaFile("gm-networking/network_variables.lua")
end

include("gm-networking/library/gm-serialize.lua")
include("gm-networking/network_namespace.lua")
include("gm-networking/network_buffer.lua")
include("gm-networking/network_message.lua")
include("gm-networking/network_model.lua")
include("gm-networking/network_variables.lua")