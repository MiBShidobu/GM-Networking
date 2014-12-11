--[[
    GM-Networking :: Library Script
        by MiBShidobu
]]--

--[[
    GM-Networking :: Prerequisites
]]--

require("gm-serialize")

--[[
    GM-Networking :: Core
]]--

network = network or {}

include("includes/modules/gm-networking/network_message.lua")
include("includes/modules/gm-networking/network_rpc.lua")
include("includes/modules/gm-networking/network_stream.lua")