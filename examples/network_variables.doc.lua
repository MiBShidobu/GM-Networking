network.SetVariable("myvar", "hello!") -- Can set global networked variables server side...
print(network.GetVariable("myvar")) -- And retrieve on both states! prints hello!

network.SetVariableFilter("myvar", function (ply) -- Can also filter out players it updates to.
    if ply:Team() == TEAM_TRAITOR then -- Let's not tell traitors, hehe.
        return true -- True prevents, false allows.
    end
end)

network.SetVariable("myvar", "ehh?") -- Let's set again!

--[[ on the Client state of a traitor... ]]--
print(network.GetVariable("myvar")) -- prints hello!

--[[ on non-traitors... ]]--
print(network.GetVariable("myvar")) -- prints ehh?

-- Works with any type that GM-Networking supports too.
network.SetVariable("myvar", {12312313, x="testing!"}) -- Like tables!

-- Entities also have similar API!
ent:NetworkVariable("mynumb", 12) -- Setting it
print(ent:NetworkVariable("mynumb")) -- And getting it!

ent:NetworkVariableFilter("mynumb", function (ply) -- With filtering too.
    return true -- No if statements since just showing API.
end)

-- Filters can be reset by simply passing nil
network.SetVariableFilter(nil)

--[[
    All variables are persistent until map change/server boot!
    Meaning, set them once, and stay forever(p.much). With filtering applying to newly joined players too.
]]--
