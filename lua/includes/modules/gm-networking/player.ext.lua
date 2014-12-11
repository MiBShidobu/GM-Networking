--[[
    GM-Networking :: 'player' Namespace Extension
        By MiBShidobu
]]--

--[[
    Name: player.GetByPVS(vector Position or entity Entity)
    Desc: Gets all players in the same PVS as the position/entity.
    State: SHARED
]]--

function player.GetByPVS(value)
    local players = {}

    local func = type(value) == "Vector" and "VisibleVec" or "Visible"
    for _, ply in ipairs(player.GetHumans()) do
        if ply[func](value) then
            table.insert(players, ply)
        end
    end

    return players
end