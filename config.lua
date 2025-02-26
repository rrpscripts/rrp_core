Config = {
    Framework = nil, -- leave it nil, exept you have a framework that uses a different name for the framework
    FrameworkName = nil,
    Inventory = nil, -- leave it nil, exept you have a inventory system that uses a different name for the inventory
    InventoryName = nil,
    EnititySpawnServerSide = {
        Object = true,
        Ped = true,
        Vehicle = true
    },
    Target = {
        ThirdEyeScript = nil,
        ThirdEyeScriptName = nil
    }
}

FW = nil

if not Config.Framework then
    if GetResourceState('qb-core') == 'started' then
        Config.Framework = 'qb'
    elseif GetResourceState('es_extended') == 'started' then
        Config.Framework = 'esx'
    elseif GetResourceState('qbx_core') == 'started' then
        Config.Framework = 'qbx'
    end
end

if Config.Framework then
    if not Config.FrameworkName then
        if Config.Framework == 'qb' then
            Config.FrameworkName = 'qb-core'
        elseif Config.Framework == 'esx' then
            Config.FrameworkName = 'es_extended'
        elseif Config.Framework == 'qbx' then
            Config.FrameworkName = 'qbx_core'
        end
    end

    if Config.Framework == 'qb' or Config.Framework == 'qbx' then
        FW = exports[Config.FrameworkName]:GetCoreObject()
    elseif Config.Framework == 'esx' then
        FW = exports[Config.FrameworkName]:getSharedObject()
    end

    if not FW then
        error('Framework object not found! Please check the framework name!')
    end
else
    error('No Framework found!')
end


