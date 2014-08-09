if SERVER then
    concommand.Add("gm_net_test1", function (ply, command, args, str)
        network.CallMessage("testmessage", nil, 1, "hi", Entity(1), true, false, Vector(165494987, 98497/7, 654984984), Angle(320, 20, 20), Color(213, 50, 60, 255))
    end)

else
    local message = NetworkMessage("testmessage")
    message:Listen(function (length, ply, ...)
        print(unpack{...})
    end)
end