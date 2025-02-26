-- World entities visible

local InvisibleEntities = {
    --[id] = {source = source,
    --id = id,
    --metadata
    -- coords,
    -- modelHash,
}

local function setEntityVisible(id, bool, source, coords, modelHash, metadata)
    if bool then
        if InvisibleEntities[id] then return end
        InvisibleEntities[id] = {
            id = id,
            source = source,
            coords = coords,
            modelHash = modelHash,
            metadata = metadata
        }
        TriggerClientEvent('rrp_core:sync:setEntityVisible', -1, id, bool, source, coords, modelHash, metadata)
    else
        if not InvisibleEntities[id] then return end
        InvisibleEntities[id] = nil
        TriggerClientEvent('rrp_core:sync:setEntityVisible', -1, id, bool)
    end
end

Sync = {
    setEntityVisible = setEntityVisible
}

exports('Sync', function(event, ...)
    return Sync[event](...)
end)
