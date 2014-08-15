--[[
    GM-Networking :: Network Stream
        By MiBShidobu
]]--

if SERVER then
    util.AddNetworkString("network_stream_trans")
end

local NETWORK_CHUNK_SIZE = 1024 * 20

function math.TruncateDecimal(number, places)
    local interp = math.pow(10, places)
    return math.floor(number * interp) / interp
end

local function CeilDecimal(number)
    local fixed = math.TruncateDecimal(number, 2)
    if fixed > number then
        return fixed + 0.01
    end

    return fixed
end

if SERVER then
    local PLAYER = FindMetaTable("Player")

    function PLAYER:StreamPacketRate()
        return CeilDecimal(1 / math.Clamp(self:GetInfoNum("cl_updaterate", 30), GetConVarNumber("sv_minupdaterate"), GetConVarNumber("sv_maxupdaterate")))
    end

    function PLAYER:StreamBuffer(name, buffer)
        if ply._gmn_upload_name == name then
            error("GM-Networking: Stream in progress")
        end

        if ply._gmn_upload_queue then
            for _, upload in ipairs(ply._gmn_upload_queue) do
                if upload.Name == name then
                    error("GM-Networking: Streams cannot have multiple queues")
                end
            end
        end

        local start = false
        if not self._gmn_upload_queue then
            self._gmn_upload_queue = {}
            start = true
        end

        table.insert(self._gmn_upload_queue, {
            Name = name,
            Data = buffer:Serialize()
        })

        if start then
            local ply = self
            local id = "gm-networking_upload_"..ply:EntIndex()
            timer.Create(id, ply:StreamPacketRate(), 0, function ()
                if IsValid(ply) then
                    if ply._gmn_upload_name then
                        local chunk = string.sub(ply._gmn_upload_data, 1, math.min(NETWORK_CHUNK_SIZE, #ply._gmn_upload_data))
                        ply._gmn_upload_data = string.sub(#chunk + 1, #ply._gmn_upload_data)
                        local finished = #ply._gmn_upload_data == 0
                        net.Start("network_stream_trans")
                            net.WriteUInt(#chunk, 16)
                            net.WriteData(chunk, #chunk)
                            net.WriteBit(finished)
                            if finished then
                                net.WriteString(ply._gmn_upload_name)
                            end
                        net.Send(ply)

                        if finished then
                            ply._gmn_upload_name = nil
                            ply._gmn_upload_data = nil
                        end

                    elseif ply._gmn_upload_queue then
                        local upload = table.remove(ply._gmn_upload_queue, 1)
                        ply._gmn_upload_name, ply._gmn_upload_data = upload.Name, upload.Data
                        if #ply._gmn_upload_queue == 0 then
                            ply._gmn_upload_queue = nil
                        end

                    else
                        timer.Destroy(id)
                    end

                else
                    timer.Destroy(id)
                end
            end)

            timer.Start(id)
        end
    end

    function PLAYER:StreamIsQueued(name)
        if self._gmn_upload_queue then
            for _, upload in ipairs(self._gmn_upload_queue) do
                if upload.Name == name then
                    return true
                end
            end
        end

        return false
    end

    function PLAYER:StreamIsStreaming(name)
        return name == self._gmn_upload_name
    end

    net.Receive("network_stream_trans", function (length, ply)
        if IsValid(ply) then
            ply._gmn_download_data = (ply._gmn_download_data or "")..net.ReadData(net.ReadUInt(16))
            if net.ReadBit() == 1 then
                local name = net.ReadString()
                if network.MessageHooks[name] then
                    local variables = NetworkBuffer(ply._gmn_download_data):Deserialize()
                    network.MessageHooks[name](length, ply, unpack(variables))
                    ply._gmn_download_data = nil
                end
            end
        end
    end)

else
    function network.PacketRate()
        return CeilDecimal(1 / math.Clamp(GetConVarNumber("cl_updaterate"), GetConVarNumber("sv_minupdaterate"), GetConVarNumber("sv_maxupdaterate")))
    end

    local upload_queue = nil
    local upload_name = nil
    function network.StreamBuffer(name, buffer)
        if upload_name == name then
            error("GM-Networking: Stream in progress")
        end

        if upload_queue then
            for _, upload in ipairs(upload_queue) do
                if upload.Name == name then
                    error("GM-Networking: Streams cannot have multiple queues")
                end
            end
        end

        local start = false
        if not upload_queue then
            upload_queue = {}
            start = true
        end

        table.insert(upload_queue, {
            Name = name,
            Data = buffer:Serialize()
        })

        if start then
            timer.Start("gm-networking_upload")
        end
    end

    function network.IsQueued(name)
        if upload_queue then
            for _, upload in ipairs(upload_queue) do
                if upload.Name == name then
                    return true
                end
            end
        end

        return false
    end

    function network.IsStreaming(name)
        return name == upload_name
    end

    local upload_data = nil
    timer.Create("gm-networking_upload", network.PacketRate(), 0, function ()
        if upload_name then
            local chunk = string.sub(upload_data, 1, math.min(NETWORK_CHUNK_SIZE, #upload_data))
            upload_data = string.sub(#chunk + 1, #upload_data)
            local finished = #upload_data == 0
            net.Start("network_stream_trans")
                net.WriteUInt(#chunk, 16)
                net.WriteData(chunk, #chunk)
                net.WriteBit(finished)
                if finished then
                    net.WriteString(upload_name)
                end
            net.SendToServer()

            if finished then
                upload_name = nil
                upload_data = nil
            end

        elseif upload_queue then
            local upload = table.remove(upload_queue, 1)
            upload_name, upload_data = upload.Name, upload.Data
            if #upload_queue == 0 then
                upload_queue = nil
            end

        else
            timer.Pause("gm-networking_upload")
        end
    end)

    local download_data = nil
    net.Receive("network_stream_trans", function (length, ply)
        download_data = (download_data or "")..net.ReadData(net.ReadUInt(16))
        if net.ReadBit() == 1 then
            local name = net.ReadString()
            if network.MessageHooks[name] then
                local variables = NetworkBuffer(download_data):Deserialize()
                network.MessageHooks[name](length, ply, unpack(variables))
                download_data = nil
            end
        end
    end)
end
