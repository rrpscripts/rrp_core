local Entities = {
    Vehicles = {},
    Peds = {},
    Objects = {}
}

local LocalEntities = {
    Vehicles = {},
    Peds = {},
    Objects = {}
}

local SyncedLocalEntities = {
    Vehicles = {},
    Peds = {},
    Objects = {}
}

local spawnVehicle = nil
local spawnPed = nil
local spawnObject = nil

local reqModel = Streaming.RequestModel

spawnObject = function(hash, coords, cb, isLocal, isMission, serverSideSpawn, meta, timeout)
    reqModel(hash, timeout or 10000)
    isLocal = isLocal or false
    if isLocal then
        local obj = CreateObject(hash, coords.x, coords.y, coords.z, false, false, false)
        meta = meta or {}
        meta.obj = obj
        LocalEntities.Objects[obj] = meta
        if cb then
            cb(obj)
        else
            return obj
        end
    else
        serverSideSpawn = serverSideSpawn or Config.EnititySpawnServerSide
        if serverSideSpawn then
            lib.callback('rrp_core:server:spawn', function(netObj)
                local obj = NetToObj(netObj)
                if cb then
                    cb(obj)
                end
                return
               
            end, "Object", hash, coords, meta)
        else
            local obj = CreateObject(hash, coords.x, coords.y, coords.z, false, false, false)
            local netObj = ObjToNet(obj)
            meta = meta or {}
            meta.obj = obj
            meta.netObj = netObj
            --meta.creator = GetPlayerServerId(PlayerId())
            Entities[netObj] = meta
            if cb then
                cb(obj)
            else
                return obj
            end
        end

    end
end

spawnPed = function(model, coords, cb, isLocal, isMission, serverSideSpawn, meta, timeout)
    reqModel(model, timeout or 10000)
    isLocal = isLocal or false
    if isLocal then
        local ped = CreatePed(4, model, coords.x, coords.y, coords.z, 0.0, false, false)
        meta = meta or {}
        meta.ped = ped
        LocalEntities.Peds[ped] = meta
        if cb then
            cb(ped)
        else
            return ped
        end
    else
        serverSideSpawn = serverSideSpawn or Config.EnititySpawnServerSide
        if serverSideSpawn then
            lib.callback('rrp_core:server:spawn', function(netPed)
                local ped = NetToPed(netPed)
                if cb then
                    cb(ped)
                end
            end, "Ped", model, coords, meta)
        else
            local ped = CreatePed(4, model, coords.x, coords.y, coords.z, 0.0, false, false)
            local netPed = PedToNet(ped)
            meta = meta or {}
            meta.ped = ped
            meta.netPed = netPed
            --meta.creator = GetPlayerServerId(PlayerId())
            Entities[netPed] = meta
            if cb then
                cb(ped)
            else
                return ped
            end
        end
    end
end

spawnVehicle = function(model, coords, cb, isLocal, isMission, serverSideSpawn, meta, timeout)
    reqModel(model, timeout or 10000)
    isLocal = isLocal or false
    if isLocal then
        local veh = CreateVehicle(model, coords.x, coords.y, coords.z, 0.0, true, false)
        meta = meta or {}
        meta.veh = veh
        LocalEntities.Vehicles[veh] = meta
        if cb then
            cb(veh)
        else
            return veh
        end
    else
        serverSideSpawn = serverSideSpawn or Config.EnititySpawnServerSide
        if serverSideSpawn then
            lib.callback('rrp_core:server:spawn', function(netVeh)
                local veh = NetToVeh(netVeh)
                if cb then
                    cb(veh)
                end
            end, "Vehicle", model, coords, meta)
        else
            local veh = CreateVehicle(model, coords.x, coords.y, coords.z, 0.0, true, false)
            local netVeh = VehToNet(veh)
            meta = meta or {}
            meta.veh = veh
            meta.netVeh = netVeh
            --meta.creator = GetPlayerServerId(PlayerId())
            Entities[netVeh] = meta
            if cb then
                cb(veh)
            else
                return veh
            end
        end
    end
end

Spawn = {
    Object = spawnObject,
    Ped = spawnPed,
    Vehicle = spawnVehicle
}

return Spawn

