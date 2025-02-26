local InvisibleEntities = {
    --[id] = {source = source,
    --id = id,
    --metadata
    -- coords,
    -- modelHash,
    -- entityHandler
}
local threadStarted = false
local activate = false
local GetClosestObjectOfType = GetClosestObjectOfType
local EntityCounter = 0

local startThread = function()
    if threadStarted then return end
    threadStarted = true
    Citizen.CreateThread(function()
        while activate do
            Wait(500)
            for k, v in pairs(InvisibleEntities) do
                local entity = GetClosestObjectOfType(v.coords, 0.1, v.modelHash, false, false, false)
                if entity then
                    v.entityHandler = entity
                    SetEntityVisible(entity, false, 0)
                end
            end
        end
        threadStarted = false
    end)
end

local function setEntityVisible(id, bool, source, coords, modelHash, metadata, radius)
    if bool then
        if InvisibleEntities[id] then return end
        local entity = GetClosestObjectOfType(coords, radius or 0.1, modelHash, false, false, false)
        if entity then
            InvisibleEntities[id] = {
                id = id,
                source = source,
                coords = coords,
                modelHash = modelHash,
                metadata = metadata,
                entityHandler = entity
            }
            SetEntityVisible(entity, false, 0)
            if EntityCounter == 0 then
                activate = true
                startThread()
            end
            EntityCounter = EntityCounter + 1
        end
    else
        if InvisibleEntities[id] then
            SetEntityVisible(InvisibleEntities[id].entityHandler, true, 0)
            InvisibleEntities[id] = nil
            EntityCounter = EntityCounter - 1
            if EntityCounter == 0 then
                activate = false
            end
        end
    end
end

RegisterNetEvent('rrp_core:sync:setEntityVisible', setEntityVisible)