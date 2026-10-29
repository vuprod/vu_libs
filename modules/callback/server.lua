local pendingCallbacks = {}
local cbEvent = '__vu_cb_%s'
local callbackTimeout = GetConvarInt('vu:callbackTimeout', 300000)

RegisterNetEvent(cbEvent:format(cache.resource), function(key, ...)
    local cb = pendingCallbacks[key]
    if not cb then return end

    local keyPlayerId = key:match(':(%d+)$')
    if not keyPlayerId or tonumber(keyPlayerId) ~= source then
        return warn(("Player %d triggered callback with invalid key '%s'."):format(source, key))
    end

    pendingCallbacks[key] = nil
    cb(...)
end)

local function triggerClientCallback(_, event, playerId, cb, ...)
    assert(DoesPlayerExist(playerId --[[@as string]]), ("playerId '%s' does not exist"):format(playerId))

    local key
    repeat
        key = ('%s:%s:%s'):format(event, math.random(0, 100000), playerId)
    until not pendingCallbacks[key]

    TriggerClientEvent('vu_libs:validateCallback', playerId, event, cache.resource, key)
    TriggerClientEvent(cbEvent:format(event), playerId, cache.resource, key, ...)

    local promise = not cb and promise.new()

    pendingCallbacks[key] = function(response, ...)
        if response == 'cb_invalid' then
            response = ("callback '%s' does not exist"):format(event)
            return promise and promise:reject(response) or error(response)
        end

        response = { response, ... }

        if promise then
            return promise:resolve(response)
        end

        if cb then
            cb(table.unpack(response))
        end
    end

    if promise then
        SetTimeout(callbackTimeout, function()
            promise:reject(("callback event '%s' timed out"):format(key))
        end)

        return table.unpack(Citizen.Await(promise))
    end
end

vu.callback = setmetatable({}, {
    __call = function(_, event, playerId, cb, ...)
        if not cb then
            warn(("callback '%s' has no handler — use vu.callback.await"):format(event))
        else
            local cbType = type(cb)
            if cbType == 'table' and getmetatable(cb)?.__call then
                cbType = 'function'
            end
            assert(cbType == 'function', ("expected function, got %s"):format(cbType))
        end

        return triggerClientCallback(_, event, playerId, cb, ...)
    end,
})

function vu.callback.await(event, playerId, ...)
    return triggerClientCallback(nil, event, playerId, false, ...)
end

local function callbackResponse(success, result, ...)
    if not success then
        if result then
            return print(('^1SCRIPT ERROR: %s^0\n%s'):format(
                result,
                Citizen.InvokeNative(`FORMAT_STACK_TRACE` & 0xFFFFFFFF, nil, 0, Citizen.ResultAsString()) or ''
            ))
        end
        return false
    end

    return result, ...
end

function vu.callback.register(name, cb)
    local event = cbEvent:format(name)

    vu.setValidCallback(name, true)

    RegisterNetEvent(event, function(resource, key, ...)
        TriggerClientEvent(cbEvent:format(resource), source, key, callbackResponse(pcall(cb, source, ...)))
    end)
end

return vu.callback
