local addCash = nil
local addBank = nil
local rmCash = nil
local rmBank = nil
local getCashBalance = nil
local getBankBalance = nil

if Config.Framework == 'qb' or Config.Framework == 'qbx' then
    addCash = function(player, amount)
       player.Functions.AddMoney('cash', amount)
    end

    addBank = function(player, amount)
        player.Functions.AddMoney('bank', amount)
    end

    rmCash = function(player, amount)
        player.Functions.RemoveMoney('cash', amount)
    end

    rmBank = function(player, amount)
        player.Functions.RemoveMoney('bank', amount)
    end

    getCashBalance = function(player)
        local ballance =  player.Functions.GetMoney('cash')
        return ballance or 0
    end

    getBankBalance = function(player)
        local ballance =  player.Functions.GetMoney('bank')
        return ballance or 0
    end

    
elseif Config.Framework == 'esx' then
    addCash = function(player, amount)
        player.addAccountMoney('money', amount)
    end

    addBank = function(player, amount)
        player.addAccountMoney('bank', amount)
    end

    rmCash = function(player, amount)
        player.removeAccountMoney('money', amount)
    end

    rmBank = function(player, amount)
        player.removeAccountMoney('bank', amount)
    end

    getCashBalance = function(player)
        local ballance =  player.getAccount('money').money
        return ballance or 0
    end

    getBankBalance = function(player)
        local ballance =  player.getAccount('bank').money
        return ballance or 0
    end
end

Banking = {
    AddCash = addCash,
    AddBank = addBank,
    RemoveCash = rmCash,
    RemoveBank = rmBank,
    GetCashBalance = getCashBalance,
    GetBankBalance = getBankBalance
}

exports('Banking', function(event, ...)
    return Banking[event](...)
end)

