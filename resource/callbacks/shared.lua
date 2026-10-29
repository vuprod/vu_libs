local registeredCallbacks = {}

AddEventHandler('onResourceStop', function(resourceName)
    if cache.resource == resourceName then return end

    for callbackName, resource in pairs(registeredCallbacks) do
        if resource == resourceName then
            registeredCallbacks[callbackName] = nil
        end
    end
end)

---@param callbackName string
---@param isValid boolean
function vu.setValidCallback(callbackName, isValid)
    local resourceName = GetInvokingResource() or cache.resource
    local callbackResource = registeredCallbacks[callbackName]

    if callbackResource then
        if not isValid then
            registeredCallbacks[callbackName] = nil
            return
        end

        if callbackResource == resourceName then return end

        return print(("^1SCRIPT ERROR: resource '%s' attempted to overwrite callback '%s' owned by '%s'^0")
            :format(resourceName, callbackName, callbackResource))
    end

    registeredCallbacks[callbackName] = resourceName
end

function vu.isCallbackValid(callbackName)
    return registeredCallbacks[callbackName] == (GetInvokingResource() or cache.resource)
end

local cbEvent = '__vu_cb_%s'

RegisterNetEvent('vu_libs:validateCallback', function(callbackName, invokingResource, key)
    if registeredCallbacks[callbackName] then return end

    local event = cbEvent:format(invokingResource)

    if IsDuplicityVersion() then
        return TriggerClientEvent(event, source, key, 'cb_invalid')
    end

    TriggerServerEvent(event, key, 'cb_invalid')
end)
