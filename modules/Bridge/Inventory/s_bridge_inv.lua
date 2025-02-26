local inventoryType = Config.Inventory
local inventoryName = Config.InventoryName

local inventories = {
    ['qb-inventory'] = 'qb',
    ['ox_inventory'] = 'ox',
    ['qs-inventory'] = 'qs',
    ['codem-inventory'] = 'codem'
}

if not inventoryType then
    for k, v in pairs(inventories) do
        if GetResourceState(k) == 'started' then
            Config.Inventory = v
            if not Config.InventoryName then
                Config.InventoryName = k
            end
            break
        end
    end
end

if Config.Inventory then
    if not Config.InventoryName then
        for k, v in pairs(inventories) do
            if Config.Inventory == v then
                Config.InventoryName = k
                break
            end
        end
    end
end

if not Config.Inventory then
    error('No Inventory found!')
end

if not Config.InventoryName then
    error('No Inventory name found!')
end

inventories = nil

inventoryType = Config.Inventory
inventoryName = Config.InventoryName

local hasItem = nil -- 
local getItemBySlot = nil
local canCarryItem = nil -- 
local addItem = nil -- 
local rmItem = nil --
local regUsableItem = nil -- 
local getItemMeta = nil
local searchItemByName = nil
local searchItemById = nil

-- qb --
-- https://docs.qbcore.org/qbcore-documentation/qbcore-resources/qb-inventory
if inventoryType == 'qb' then
    hasItem = function(source, itemName, amount)
       return exports[inventoryName]:HasItem(source, itemName, amount)
    end

    canCarryItem = function(source, itemName, amount)
        return exports[inventoryName]:CanAddItem(source, itemName, amount)
    end

    addItem = function(source, itemName, amount, slot, metadata, cb) -- TODO: cb
        return exports[inventoryName]:AddItem(source, itemName, amount, slot, metadata or false, "rrp_core")
    end

    rmItem = function(source, itemName, amount, slot, metadata) -- TODO: metadata
        return exports[inventoryName]:RemoveItem(source, itemName, amount, slot or false, "rrp_core")
    end
end

-- ox --
-- https://overextended.dev/ox_inventory/Functions/

if inventoryType == 'ox' then
    hasItem = function(source, itemName, amount)
        local count = exports[inventoryName]:Search(source, 'count', itemName)
        if amount then
            return count >= amount
        else
            return count > 0
        end
    end

    canCarryItem = function(source, itemName, amount)
        return exports[inventoryName]:CanCarryItem(source, itemName, amount)
    end

    addItem = function(source, itemName, amount, slot, metadata, cb)
        return exports[inventoryName]:AddItem(source, itemName, amount, metadata, slot, cb, cb)
    end

    rmItem = function(source, itemName, amount, slot, metadata)
        return exports[inventoryName]:RemoveItem(source, itemName, amount, metadata, slot)
    end
end

-- qs --
-- https://docs.quasar-store.com/assets-and-usage/inventory/exports-and-commands/server-side-exports/

if inventoryType == 'qs' then
    hasItem = function(source, itemName, amount)
        local itemData = exports[inventoryName]:GetItemByName(source, itemName)
        if not itemData then return false end
        if amount then
            return itemData.amount >= amount
        else
            return itemData.amount > 0
        end
    end

    canCarryItem = function(source, itemName, amount)
        return exports[inventoryName]:CanCarryItem(source, itemName, amount)
    end

    addItem = function(source, itemName, amount, slot, metadata, cb)
        return exports[inventoryName]:AddItem(source, itemName, amount, slot, metadata, cb)
    end

    rmItem = function(source, itemName, amount, slot, metadata)
        return exports[inventoryName]:RemoveItem(source, itemName, amount, slot, metadata)
    end
end

-- codem --
-- https://codem.gitbook.io/codem-documentation/m-series/minventory-remake/exports-and-commands/server-exports#additem

if inventoryType == 'codem' then
    hasItem = function(source, itemName, amount)
        local count = exports[inventoryName]:GetItemsTotalAmount(source, itemName)
        if amount then
            return count >= amount
        else
            return count > 0
        end
    end

    canCarryItem = function(source, itemName, amount)
        ---
    end

    addItem = function(source, itemName, amount, slot, metadata, cb)
        return exports[inventoryName]:AddItem(source, itemName, amount, slot or false, metadata or false)
    end

    rmItem = function(source, itemName, amount, slot, metadata)
        return exports[inventoryName]:RemoveItem(source, itemName, amount, slot or false)
    end
end

if Config.Framework == "qb" or Config.Framework == "qbx" then
    regUsableItem = function(itemName, cb)
        return FW.Functions.CreateUseableItem(itemName, cb)
    end
elseif Config.Framework == "esx" then
    regUsableItem = function(itemName, cb)
        return FW.RegisterUsableItem(itemName, cb)
    end
end

Inventory = {
    HasItem = hasItem,
    --GetItemBySlot = getItemBySlot,
    CanCarryItem = canCarryItem,
    AddItem = addItem,
    RemoveItem = rmItem,
    RegisterUsableItem = regUsableItem,
    --GetItemMeta = getItemMeta,
    --SearchItemByName = searchItemByName,
    --SearchItemById = searchItemById
}

exports('Inventory', function(event, ...)
    if Inventory[event] then
        return Inventory[event](...)
    end
end)




