local targetScripts = {
    ['qb-target'] = 'qb-target',
    ['ox_target'] = 'ox_target'
}

local targetType = Config.Target.ThirdEyeScript
local targetName = Config.Target.ThirdEyeScriptName

if Config.Target then
    if not targetType then
        for k, v in pairs(targetScripts) do
            if GetResourceState(k) == 'started' then
                Config.Target.ThirdEyeScript = v
                if not targetName then
                    Config.Target.ThirdEyeScriptName = k
                end
                break
            end
        end
        if not Config.Target.ThirdEyeScript then
            print('No ThirdEyeScript found!')
        end
    end
else
    return
end

if Config.Target.ThirdEyeScript then
    if not Config.Target.ThirdEyeScriptName then
       print("No ThirdEyeScriptName found!")
    end
end

targetScripts = nil

targetType = Config.Target.ThirdEyeScript
targetName = Config.Target.ThirdEyeScriptName

print(targetType, targetName)

--https://overextended.dev/ox_target/Functions/Client
local disableTarget = nil
local addGlobalePed = nil
local removeGlobalePed = nil
local addGlobalPlayer = nil
local removeGlobalPlayer = nil
local addGlobalVehicle = nil
local removeGlobalVehicle = nil
local addModel = nil
local removeModel = nil
local addEntity = nil
local removeEntity = nil
local addLocalEntity = nil
local removeLocalEntity = nil
local convertOptions = nil



if targetType == 'ox_target' then
    disableTarget = function(state)
        exports[targetName]:disableTarget(state)
    end

    addGlobalePed = function(options)
        exports[targetName]:addGlobalePed(options)
    end

    removeGlobalePed = function(optionNames)
        exports[targetName]:removeGlobalePed(optionNames)
    end

    addGlobalPlayer = function(options)
        exports[targetName]:addGlobalPlayer(options)
    end

    removeGlobalPlayer = function(optionNames)
        exports[targetName]:removeGlobalPlayer(optionNames)
    end

    addGlobalVehicle = function(options)
        exports[targetName]:addGlobalVehicle(options)
    end

    removeGlobalVehicle = function(optionNames)
        exports[targetName]:removeGlobalVehicle(optionNames)
    end

    addModel = function(models, options)
        exports[targetName]:addModel(models, options)
    end

    removeModel = function(models, optionNames)
        exports[targetName]:removeModel(models, optionNames)
    end

    addEntity = function(netIds, options)
        exports[targetName]:addEntity(netIds, options)
    end

    removeEntity = function(netIds, optionNames)
        exports[targetName]:removeEntity(netIds, optionNames)
    end

    addLocalEntity = function(entities, options)
        exports[targetName]:addLocalEntity(entities, options)
    end

    removeLocalEntity = function(entities, optionNames)
        exports[targetName]:removeLocalEntity(entities, optionNames)
    end

    print('Loaded OX Target')
elseif targetType == 'qb-target' then
    convertOptions = function(options)
        local converted = {}
        for _, opt in ipairs(options) do
            local convertedOpt = {
                label = opt.label,
                icon = opt.icon,
                targeticon = opt.targeticon or opt.icon,
                item = opt.item,
                job = opt.job,
                gang = opt.gang,
                citizenid = opt.citizenid
            }
    
            -- onSelect -> action paraméter átalakítás
            if opt.onSelect then
                convertedOpt.action = function(entity)
                    local coords = GetEntityCoords(entity)
                    local distance = #(coords - GetEntityCoords(PlayerPedId()))
                    opt.onSelect({
                        entity = entity,
                        coords = coords,
                        distance = distance
                    })
                end
            end
    
            -- canInteract paraméter adaptáció
            if opt.canInteract then
                convertedOpt.canInteract = function(entity, distance, data)
                    local coords = GetEntityCoords(entity)
                    return opt.canInteract(entity, distance, coords, {})
                end
            end
    
            -- Esemény típusok feldolgozása (client:eventName -> type + event)
            if opt.event then
                local eventType, eventName = opt.event:match('^(%w+):(.+)$')
                if eventType then
                    convertedOpt.type = eventType
                    convertedOpt.event = eventName
                else
                    convertedOpt.type = 'client'
                    convertedOpt.event = opt.event
                end
            end
    
            table.insert(converted, convertedOpt)
        end
        return converted
    end

    disableTarget = function(state)
        exports[targetName]:AllowTargeting(not state)
    end

    -- Globális ped kezelés
    addGlobalePed = function(options)
        exports[targetName]:AddGlobalPed({
            options = convertOptions(options),
            distance = options.distance or Config.Target.Distance
        })
    end

    removeGlobalePed = function(optionNames)
        exports[targetName]:RemoveGlobalPed(optionNames)
    end

    -- Játékos célpontok
    addGlobalPlayer = function(options)
        exports[targetName]:AddGlobalPlayer({
            options = convertOptions(options),
            distance = options.distance or Config.Target.Distance
        })
    end

    removeGlobalPlayer = function(optionNames)
        exports[targetName]:RemoveGlobalPlayer(optionNames)
    end

    -- Jármű célpontok
    addGlobalVehicle = function(options)
        exports[targetName]:AddGlobalVehicle({
            options = convertOptions(options),
            distance = options.distance or Config.Target.Distance
        })
    end

    removeGlobalVehicle = function(optionNames)
        exports[targetName]:RemoveGlobalVehicle(optionNames)
    end

    -- Model alapú célpontok
    addModel = function(models, options)
        exports[targetName]:AddTargetModel(models, {
            options = convertOptions(options),
            distance = options.distance or Config.Target.Distance
        })
    end

    removeModel = function(models, optionNames)
        exports[targetName]:RemoveTargetModel(models, optionNames)
    end

    -- Hálózati entitások kezelése
    addEntity = function(netIds, options)
        for _, netId in ipairs(netIds) do
            local entity = NetworkGetEntityFromNetworkId(netId)
            if DoesEntityExist(entity) then
                exports[targetName]:AddTargetEntity(entity, {
                    options = convertOptions(options),
                    distance = options.distance or Config.Target.Distance
                })
            end
        end
    end

    removeEntity = function(netIds, optionNames)
        for _, netId in ipairs(netIds) do
            local entity = NetworkGetEntityFromNetworkId(netId)
            if DoesEntityExist(entity) then
                exports[targetName]:RemoveTargetEntity(entity, optionNames)
            end
        end
    end

    -- Lokális entitások kezelése
    addLocalEntity = function(entities, options)
        for _, entity in ipairs(entities) do
            if DoesEntityExist(entity) then
                exports[targetName]:AddTargetEntity(entity, {
                    options = convertOptions(options),
                    distance = options.distance or Config.Target.Distance
                })
            end
        end
    end

    removeLocalEntity = function(entities, optionNames)
        for _, entity in ipairs(entities) do
            if DoesEntityExist(entity) then
                exports[targetName]:RemoveTargetEntity(entity, optionNames)
            end
        end
    end

    print('QB-Target kompatibilitás aktiválva')

end

Target = {
    disableTarget = disableTarget,
    addGlobalePed = addGlobalePed,
    removeGlobalePed = removeGlobalePed,
    addGlobalPlayer = addGlobalPlayer,
    removeGlobalPlayer = removeGlobalPlayer,
    addGlobalVehicle = addGlobalVehicle,
    removeGlobalVehicle = removeGlobalVehicle,
    addModel = addModel,
    removeModel = removeModel,
    addEntity = addEntity,
    removeEntity = removeEntity,
    addLocalEntity = addLocalEntity,
    removeLocalEntity = removeLocalEntity
}

exports('Target', function(event, ...)
    return Target[event](...)
end)
