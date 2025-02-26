local notifies = {
    ['esx'] = function(title, msg, t, ...)
        local time = ...
        TriggerEvent('esx:showNotification', msg, t or "info", time or 4000)
    end,
    ['qb'] = function(title, msg, t, ...)
        TriggerEvent("QBCore:Notify", msg, t)
    end,
    ['okok'] = function(title, msg, t, ...)
        TriggerEvent('okokNotify:Alert', title, msg, 6000, t)
    end,
    ['ox'] = function(title, msg, t, ...)
        TriggerEvent('ox_lib:notify', {title = title, description = msg, type = t or "success"})
    end,
}

Notify = function(notifyType, title, msg, t, ...)
    if notifies[notifyType] then
        notifies[notifyType](title, msg, t, ...)
    end
end

exports('Notify', Notify)