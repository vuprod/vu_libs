--[[
    Periodically refresh common client cache values.
    Consuming resources read via exports.vu_libs:cache(key) (see init.lua).
]]

local cache = _ENV.cache

cache.playerId = PlayerId()
cache.serverId = GetPlayerServerId(cache.playerId)

function cache:set(key, value)
    if value ~= self[key] then
        TriggerEvent(('vu_libs:cache:%s'):format(key), value, self[key])
        self[key] = value
        return true
    end
end

local GetVehiclePedIsIn = GetVehiclePedIsIn
local GetPedInVehicleSeat = GetPedInVehicleSeat
local GetVehicleMaxNumberOfPassengers = GetVehicleMaxNumberOfPassengers
local GetCurrentPedWeapon = GetCurrentPedWeapon

CreateThread(function()
    while true do
        local ped = PlayerPedId()

        if ped ~= 0 then
            cache:set('ped', ped)

            local vehicle = GetVehiclePedIsIn(ped, false)

            if vehicle > 0 then
                if vehicle ~= cache.vehicle then
                    cache:set('seat', false)
                end

                cache:set('vehicle', vehicle)

                if not cache.seat or GetPedInVehicleSeat(vehicle, cache.seat) ~= ped then
                    for i = -1, GetVehicleMaxNumberOfPassengers(vehicle) - 1 do
                        if GetPedInVehicleSeat(vehicle, i) == ped then
                            cache:set('seat', i)
                            break
                        end
                    end
                end
            else
                cache:set('vehicle', false)
                cache:set('seat', false)
            end

            local hasWeapon, currentWeapon = GetCurrentPedWeapon(ped, true)
            cache:set('weapon', (hasWeapon and currentWeapon ~= 0) and currentWeapon or false)
        end

        Wait(100)
    end
end)

--- Used by consuming resources via init.lua cache __index
function vu.cache(key)
    return cache[key]
end
