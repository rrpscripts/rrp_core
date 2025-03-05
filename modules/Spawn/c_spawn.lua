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

local rmObject = nil
local rmPed = nil
local rmVehicle = nil

local spawnLocalVehicle = nil
local spawnLocalPed = nil
local spawnLocalObject = nil

local reqModel = Streaming.RequestModel

spawnObject = function(hash, coords, cb, serverSideSpawn, meta, timeout, regServer)
    reqModel(hash, timeout or 10000)
    serverSideSpawn = serverSideSpawn == nil and Config.EnititySpawnServerSide or serverSideSpawn
    if serverSideSpawn then
        lib.callback('rrp_core:server:spawn', false, function(_, netObj)
            print("Spawned object: ", netObj)
            Wait(3000)
            local obj = NetToObj(netObj)
            Entities.Objects[netObj] = {
                obj = obj,
                meta = meta,
                netObj = netObj,
                serverSideSpawn = true
            }
            if cb then
                cb(obj, netObj)
            end
            return
        end, "Object", hash, coords, meta)
    else
        local obj = CreateObject(hash, coords.x, coords.y, coords.z, true, false, false)
        Wait(1000)
        local netObj = ObjToNet(obj)
        SetNetworkIdCanMigrate(netObj, true)
        SetEntityAsMissionEntity(obj, true, true)
        SetModelAsNoLongerNeeded(hash)
        Entities.Objects[netObj] = {
            obj = obj,
            meta = meta,
            netObj = netObj,
            regServer = regServer or nil
        }
        if regServer then
            TriggerServerEvent('rrp_core:server:regEntity', "Objects", Entities.Objects[netObj])
        end
        if cb then
            cb(obj, netObj)
        else
            print("hmmm")
            return obj, netObj
        end
    end
end

spawnPed = function(hash, coords, cb, serverSideSpawn, meta, timeout, regServer)
    reqModel(hash, timeout or 10000)
    serverSideSpawn = serverSideSpawn == nil and Config.EnititySpawnServerSide or serverSideSpawn
    if serverSideSpawn then
        lib.callback('rrp_core:server:spawn', false, function(netPed)
            local ped = NetToPed(netPed)
            Entities.Peds[netPed] = {
                obj = ped,
                meta = meta,
                netPed = netPed,
                serverSideSpawn = true,
            }
            if cb then
                cb(ped, netPed)
            end
        end, "Ped", hash, coords, meta)
    else
        local ped = CreatePed(4, hash, coords.x, coords.y, coords.z, 0.0, true, false)
        local netPed = PedToNet(ped)
        SetNetworkIdCanMigrate(netPed, true)
        SetEntityAsMissionEntity(ped, true, true)
        SetModelAsNoLongerNeeded(hash)
        Entities.Peds[netPed] = {
            obj = ped,
            meta = meta,
            netPed = netPed,
            regServer = regServer or nil
        }
        if regServer then
            TriggerServerEvent('rrp_core:server:regEntity', "Peds", Entities.Peds[netPed])
        end
        if cb then
            cb(ped, netPed)
        else
            return ped, netPed
        end
    end
end

spawnVehicle = function(hash, coords, cb, serverSideSpawn, meta, timeout, regServer)
    reqModel(hash, timeout or 10000)
    serverSideSpawn = serverSideSpawn == nil and Config.EnititySpawnServerSide or serverSideSpawn
    if serverSideSpawn then
        lib.callback('rrp_core:server:spawn', false, function(netVeh)
            local veh = NetToVeh(netVeh)
            Entities.Vehicles[netVeh] = {
                obj = veh,
                meta = meta,
                netVeh = netVeh,
                serverSideSpawn = true, 
            }
            if cb then
                cb(veh, netVeh)
            end
        end, "Vehicle", hash, coords, meta)
    else
        RequestCollisionAtCoord(coords.x, coords.y, coords.z)
        local veh = CreateVehicle(hash, coords.x, coords.y, coords.z, 0.0, true, false)
        local netVeh = VehToNet(veh)
        SetNetworkIdCanMigrate(netVeh, true)
        SetEntityAsMissionEntity(veh, true, true)

        SetVehicleHasBeenOwnedByPlayer(veh, true)
        SetVehicleNeedsToBeHotwired(veh, false)
        SetModelAsNoLongerNeeded(hash)
        SetVehRadioStation(veh, "OFF")
        Entities.Vehicles[netVeh] = {
            obj = veh,
            meta = meta,
            netVeh = netVeh,
            regServer = regServer or nil
            --creator = GetPlayerServerId(PlayerId())
        }
        if regServer then
            TriggerServerEvent('rrp_core:server:regEntity', "Vehicles", Entities.Vehicles[netVeh])
        end
        if cb then
            cb(veh, netVeh)
        else
            return veh, netVeh
        end
    end
end

spawnLocalObject = function(hash, coords, cb, meta, timeout)
    reqModel(hash, timeout or 10000)
    local obj = CreateObject(hash, coords.x, coords.y, coords.z, false, false, false)
    meta = meta or {}
    meta.obj = obj
    LocalEntities.Objects[obj] = {
        obj = obj,
        meta = meta
    }
    if cb then
        cb(obj)
    else
        return obj
    end
end

spawnLocalPed = function(hash, coords, cb, meta)
    local ped = CreatePed(4, hash, coords.x, coords.y, coords.z, 0.0, false, false)
    meta = meta or {}
    meta.ped = ped
    LocalEntities.Peds[ped] = {
        obj = ped,
        meta = meta
    }
    if cb then
        cb(ped)
    else
        return ped
    end
end

spawnLocalVehicle = function(hash, coords, cb, meta)
    local veh = CreateVehicle(hash, coords.x, coords.y, coords.z, 0.0, true, false)
    meta = meta or {}
    meta.veh = veh
    LocalEntities.Vehicles[veh] = {
        obj = veh,
        meta = meta
    }
    if cb then
        cb(veh)
    else
        return veh
    end
end

rmObjectById = function(netId)
    local entity = Entities.Objects[netId]
    if entity then
        DeleteEntity(entity.obj)
        if entity.serverSideSpawn or entity.regServer then
            TriggerServerEvent('rrp_core:server:rmEntity', "Objects", netId)
        end
        Entities.Objects[netId] = nil
    end
end

rmPedById = function(netId)
    local entity = Entities.Peds[netId]
    if entity then
        DeleteEntity(entity.obj)
        if entity.serverSideSpawn or entity.regServer then
            TriggerServerEvent('rrp_core:server:rmEntity', "Peds", netId)
        end
        Entities.Peds[netId] = nil
    end
end

rmVehicleById = function(netId)
    local entity = Entities.Vehicles[netId]
    if entity then
        DeleteEntity(entity.obj)
        if entity.serverSideSpawn or entity.regServer then
            TriggerServerEvent('rrp_core:server:rmEntity', "Vehicles", netId)
        end
        Entities.Vehicles[netId] = nil
    end
end

RegisterNetEvent('rrp_core:client:rmOwnerSync', function(entityType, netId)
    if Entities[entityType] then
        if Entities[entityType][netId] then
            Entities[entityType][netId] = nil
        end
    end
end)


Spawn = {
    Object = spawnObject,
    Ped = spawnPed,
    Vehicle = spawnVehicle,
    Local = {
        Object = spawnLocalObject,
        Ped = spawnLocalPed,
        Vehicle = spawnLocalVehicle
    },
    RmLocalObject = function(obj)
        LocalEntities.Objects[obj] = nil
        DeleteEntity(obj)
    end,
    RmLocalPed = function(ped)
        LocalEntities.Peds[ped] = nil
        DeleteEntity(ped)
    end,
    RmLocalVehicle = function(veh)
        LocalEntities.Vehicles[veh] = nil
        DeleteEntity(veh)
    end,
    RmObjectById = rmObjectById,
    RmPedById = rmPedById,
    RmVehicleById = rmVehicleById

}

exports('Spawn', function(eventName, ...)
    if Spawn[eventName] then
        return Spawn[eventName](...)
    end
end)

return Spawn

