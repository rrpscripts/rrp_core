local notifies = {
    ['esx'] = function(source, msg, _, t, ...)
        local time = ... or 4000
        TriggerClientEvent('esx:showNotification', source, msg, t or "info", time)
    end,
    ['qb'] = function(source, msg, _, t, ...)
        print(source, msg, _, t, ...)
        TriggerClientEvent("QBCore:Notify", source, msg, t)
    end,
    ['okok'] = function(source, msg, title, t, ...)
        local time = ... or 4000
        TriggerClientEvent('okokNotify:Alert', source, title, msg, time, t)
    end,
    ['ox'] = function(source, msg, title, t, ...)
        TriggerClientEvent('ox_lib:notify', source, { 
            title = title,
            description = msg,
            type = t or "success", 
        })
    end,
}

Notify = function(notifyType, source, msg, title, t, ...)
    if notifies[notifyType] then
        notifies[notifyType](source, msg, title, t, ...)
    end
end

exports('Notify', Notify)