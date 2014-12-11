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

    function PLAYER:PacketRate()
        return CeilDecimal(1 / math.Clamp(self:GetInfoNum("cl_updaterate", 30), GetConVarNumber("sv_minupdaterate"), GetConVarNumber("sv_maxupdaterate")))
    end

    function PLAYER:CallStream(name, ...)
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

    function PLAYER:IsStreamQueued(name)
        if self.m_UploadQueue then
            for _, upload in ipairs(self.m_UploadQueue) do
                if upload.Name == name then
                    return true
                end
            end
        end

        return false
    end

    function PLAYER:IsStreaming(name)
        return name == self.m_UploadName
    end

    net.Receive("network_stream_trans", function (length, ply)
        if IsValid(ply) then
            if not ply.m_DownloadSize then
                ply.m_DownloadBuffer = ""
                ply.m_DownloadName = net.ReadString()
                ply.m_DownloadSize = net.ReadUInt(32)
            end

            ply.m_DownloadBuffer = ply.m_DownloadBuffer..net.ReadData(net.ReadUInt(16))
            if #ply.m_DownloadBuffer == ply.m_DownloadSize then
                if network.MessageHooks[ply.m_DownloadName] then
                    local variables = serialize.Decode(util.Decompress(ply.m_DownloadBuffer))
                    network.MessageHooks[ply.m_DownloadName](length, ply, unpack(variables))

                    ply.m_DownloadSize = nil
                end
            end
        end
    end)   

else
    function network.PacketRate()
        return CeilDecimal(1 / math.Clamp(GetConVarNumber("cl_updaterate"), GetConVarNumber("sv_minupdaterate"), GetConVarNumber("sv_maxupdaterate")))
    end

    local g_UploadName = ""
    local g_UploadQueue = nil
    function network.QueueStream(name, ...)
        local start = false
        if not g_UploadQueue then
            g_UploadQueue = {}
            start = true
        end

        table.insert(g_UploadQueue, {
            Name = name,
            Buffer = serialize.Encode{...}
        })

        if start then
            timer.Start("gm-networking_upload")
        end
    end

    function network.IsStreamQueued(name)
        if g_UploadQueue then
            for _, upload in ipairs(g_UploadQueue) do
                if upload.Name == name then
                    return true
                end
            end
        end

        return false
    end

    function network.IsStreaming(name)
        return g_UploadName == name
    end

    local g_UploadBuffer = ""
    local g_UploadCursor = nil
    timer.Create("gm-networking_upload", network.PacketRate(), 0, function ()
        if g_UploadName then
            local last = g_UploadCursor + math.min(NETWORK_CHUNK_SIZE, #g_UploadData)
            local chunk = string.sub(g_UploadBuffer, g_UploadCursor, last)

            g_UploadCursor = g_UploadCursor + 1

            net.Start("network_stream_trans")
                net.WriteUInt(#chunk, 16)
                net.WriteData(chunk, #chunk)
            net.SendToServer()

            if g_UploadCursor > #g_UploadBuffer then
                g_UploadName = nil
            end

        else
            if g_UploadQueue then
                local upload = table.remove(g_UploadQueue, 1)
                g_UploadName, g_UploadBuffer = upload.Name, upload.Buffer

                local size = math.min(NETWORK_CHUNK_SIZE, #g_UploadData)
                local chunk = string.sub(g_UploadBuffer, 1, size)

                net.Start("network_stream_trans")
                    net.WriteString(g_UploadName)
                    net.WriteUInt(#g_UploadData, 32)

                    net.WriteUInt(size, 16)
                    net.WriteData(chunk, size)
                net.SendToServer()

                g_UploadCursor = size + 1
                if g_UploadCursor > #g_UploadBuffer then
                    g_UploadName = nil
                end

                if #g_UploadQueue == 0 then
                    g_UploadQueue = nil
                end

            else
                timer.Pause("gm-networking_upload")
            end
        end
    end)

    local g_DownloadBuffer = ""
    local g_DownloadName = ""
    local g_DownloadSize = nil
    net.Receive("network_stream_trans", function (length, ply)
        if not g_DownloadSize then
            g_DownloadBuffer = ""
            g_DownloadName = net.ReadString()
            g_DownloadSize = net.ReadUInt(32)
        end

        g_DownloadBuffer = g_DownloadBuffer..net.ReadData(net.ReadUInt(16))
        if #g_DownloadBuffer == g_DownloadSize then
            if network.MessageHooks[g_DownloadName] then
                local variables = serialize.Decode(util.Decompress(g_DownloadBuffer))
                network.MessageHooks[g_DownloadName](length, ply, unpack(variables))

                g_DownloadSize = nil
            end
        end
    end)
end
