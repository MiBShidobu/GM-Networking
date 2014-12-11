--[[
    GM-Networking :: Library Script
        by MiBShidobu
]]--

--[[
    Prerequisites
]]--

require("gm-serialize")

--[[
    GM-Networking :: Utilities
]]--

include("includes/modules/gm-networking/player.ext.lua")

--[[
    GM-Networking Core
]]--

network = network or {}

include("includes/modules/gm-networking/network_message.lua")
include("includes/modules/gm-networking/network_variables.lua")
include("includes/modules/gm-networking/network_rpc.lua")
include("includes/modules/gm-networking/network_stream.lua")