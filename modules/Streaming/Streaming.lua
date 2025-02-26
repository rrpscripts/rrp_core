local reqModel = nil
local rmModel = nil

local rmAnimDict = nil
local reqAnimDict = nil

local SetModelAsNoLongerNeeded, RemoveAnimDict, rM, rAD = SetModelAsNoLongerNeeded, RemoveAnimDict, lib.requestModel, lib.requestAnimDict

reqModel = function(hash, time)
    if time < 0 then
        if not IsModelValid(hash) then
            print('RRP_CORE: Invalid model hash: '..hash)
            return
        end
        RequestModel(hash)
        if not HasModelLoaded(hash) then
            RequestModel(hash)
            while not HasModelLoaded(hash) do
                Wait(0)
            end
            return true
        end
    else
        return rM(hash, time)
    end
end

reqAnimDict = function(dict, time)
    if time < 0 then
        if not DoesAnimDictExist(dict) then
            print('RRP_CORE: Invalid anim dict: '..dict)
            return
        end
        RequestAnimDict(dict)
        if not HasAnimDictLoaded(dict) then
            RequestAnimDict(dict)
            while not HasAnimDictLoaded(dict) do
                Wait(0)
            end
            return true
        end  
    else
        return rAD(dict, time)
    end
end

rmModel = function(hash)
    SetModelAsNoLongerNeeded(hash)
end

rmAnimDict = function(dict)
    RemoveAnimDict(dict)
end

Streaming = {
    RequestModel = reqModel,
    RemoveModel = rmModel,
    RequestAnimDict = reqAnimDict,
    RemoveAnimDict = rmAnimDict
}

return Streaming