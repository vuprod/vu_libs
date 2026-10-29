local pendingCallbacks = {}
local timers = {}
local cbEvent = '__vu_cb_%s'
local callbackTimeout = GetConvarInt('vu:callbackTimeout', 300000)

RegisterNetEvent(cbEvent:format(cache.resource), function(key, ...)
    if source == '' then return end

    local cb = pendingCallbacks[key]
    if not cb then return end

    pendingCallbacks[key] = nil
    cb(...)
end)

---@param event string
---@param delay? number|false
local function eventTimer(event, delay)
    if delay and type(delay) == 'number' and delay > 0 then
        local time = GetGameTimer()

        if (timers[event] or 0) > time then
            return false
        end

        timers[event] = time + delay
    end

    return true
end

local function triggerServerCallback(_, event, delay, cb, ...)
    if not eventTimer(event, delay) then return end

    local key
    repeat
        key = ('%s:%s'):format(event, math.random(0, 100000))
    until not pendingCallbacks[key]

    TriggerServerEvent('vu_libs:validateCallback', event, cache.resource, key)
    TriggerServerEvent(cbEvent:format(event), cache.resource, key, ...)

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
    __call = function(_, event, delay, cb, ...)
        if not cb then
            warn(("callback '%s' has no handler — use vu.callback.await"):format(event))
        else
            local cbType = type(cb)
            if cbType == 'table' and getmetatable(cb)?.__call then
                cbType = 'function'
            end
            assert(cbType == 'function', ("expected function, got %s"):format(cbType))
        end

        return triggerServerCallback(_, event, delay, cb, ...)
    end,
})

function vu.callback.await(event, delay, ...)
    return triggerServerCallback(nil, event, delay, false, ...)
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
        TriggerServerEvent(cbEvent:format(resource), key, callbackResponse(pcall(cb, ...)))
    end)
end

return vu.callback
