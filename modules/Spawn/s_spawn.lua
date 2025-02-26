local Entities = {
    Vehicles = {},
    Peds = {},
    Objects = {}
}
local CreateVehicleServerSetter, DoesEntityExist, SetEntityOrphanMode = CreateVehicleServerSetter, DoesEntityExist, SetEntityOrphanMode
local function spawnVehicle(hash, coords, meta)
    local vehType = "automobile"
    local vehicle = CreateVehicleServerSetter(hash, vehType, coords.xyz, coords.w)
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
    return netId
end

local function spawnPed(hash, coords, meta)

end

local function spawnObject(hash, coords, meta)
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
    SetEntityHeading(obj, coords.w)
    local netId = NetworkGetNetworkIdFromEntity(obj)
    return netId
end

Spawn = {
    Object = spawnObject,
    Ped = spawnPed,
    Vehicle = spawnVehicle
}

lib.callback.register('rrp_core:server:spawn', function(eventName, hash, coords, meta)
    if Spawn[eventName] then
        Spawn[eventName](hash, coords, meta)
    end
end)

exports('Spawn', function(event, ...)
    return Spawn[event](...)
end)