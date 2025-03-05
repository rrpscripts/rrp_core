local Entities = {
    Vehicles = {},
    Peds = {},
    Objects = {}
}
local CreateVehicleServerSetter, DoesEntityExist, SetEntityOrphanMode = CreateVehicleServerSetter, DoesEntityExist, SetEntityOrphanMode
local function spawnVehicle(hash, coords, meta, cb, source, needRmOwnerSync)
    local vehType = "automobile"
    local vehicle = CreateVehicleServerSetter(hash, vehType, coords.xyz, coords.w or 0.0)
    Wait(20)
    if vehicle == 0 then
        return
    end
    local attemt = 40
    while not DoesEntityExist(vehicle) do
        Wait(50)
        attemt = attemt - 1
        if attemt < 0 then
            return
        end
    end
    SetEntityOrphanMode(vehicle, 2) 
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    Entities.Vehicles[netId] = {
        obj = vehicle,
        meta = meta,
        netId = netId,
        creator = source or -1,
        needRmOwnerSync = needRmOwnerSync
    }
    if cb then
        cb(vehicle, netId)
    end
    return vehicle, netId
end

local function spawnPed(hash, coords, meta, cb, source, needRmOwnerSync)

end

local function spawnObject(hash, coords, meta, cb, source, needRmOwnerSync)
    local obj = CreateObjectNoOffset(hash, coords.x, coords.y, coords.z, true, true, false)
    local attemt = 40
    while not DoesEntityExist(obj) do
        Wait(50)
        attemt = attemt - 1
        if attemt < 0 then
            return
        end
    end
    SetEntityOrphanMode(obj, 2)
    if coords.w then
        SetEntityHeading(obj, coords.w)
    end
    local netId = NetworkGetNetworkIdFromEntity(obj)
    Entities.Objects[netId] = {
        obj = obj,
        meta = meta,
        netId = netId,
        creator = source or -1,
        needRmOwnerSync = needRmOwnerSync
    }
    if cb then
        cb(obj, netId)
    end
    return obj, netId
end

local rmObject = function(netId)
    local entity = Entities.Objects[netId]
    if entity then
        DeleteEntity(entity.obj)
        if entity.needRmOwnerSync then
            TriggerClientEvent('rrp_core:client:rmOwnerSync', entity.creator, "Objects", netId)
        end
        Entities.Objects[netId] = nil
    end
end

local rmPed = function(netId)
    local entity = Entities.Peds[netId]
    if entity then
        DeleteEntity(entity.obj)
        if entity.needRmOwnerSync then
            TriggerClientEvent('rrp_core:client:rmOwnerSync', entity.creator, "Peds", netId)
        end
        Entities.Peds[netId] = nil
    end
end

local rmVehicle = function(netId)
    local entity = Entities.Vehicles[netId]
    if entity then
        DeleteEntity(entity.obj)
        if entity.needRmOwnerSync then
           TriggerClientEvent('rrp_core:client:rmOwnerSync', entity.creator, "Vehicles", netId)
        end
        Entities.Vehicles[netId] = nil
    end
end

RegisterNetEvent('rrp_core:server:regEntity', function(entityType, EntityData)
    EntityData.creator = source
    if Entities[entityType] then
        Entities[entityType][EntityData.netId] = EntityData
    end
end)

RegisterNetEvent('rrp_core:server:rmEntity', function(entityType, netId)
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
    RmObject = rmObject,
    RmPed = rmPed,
    RmVehicle = rmVehicle
}

lib.callback.register('rrp_core:server:spawn', function(source, eventName, hash, coords, meta)
    if Spawn[eventName] then
        return Spawn[eventName](hash, coords, meta, nil, source, true)
    end
end)

exports('Spawn', function(event, ...)
    return Spawn[event](...)
end)