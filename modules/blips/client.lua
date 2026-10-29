--[[
    Simple blip helpers.
    local id = vu.blips.add({ coords = vec3(...), sprite = 1, color = 1, label = 'Shop' })
    vu.blips.remove(id)
]]

local blips = {}

vu.blips = {}

---@param data { coords: vector3|vector4, sprite?: number, color?: number, scale?: number, label?: string, shortRange?: boolean, route?: boolean }
---@return number blipId
function vu.blips.add(data)
    assert(data and data.coords, 'vu.blips.add requires coords')

    local c = data.coords
    local blip = AddBlipForCoord(c.x, c.y, c.z)

    SetBlipSprite(blip, data.sprite or 1)
    SetBlipColour(blip, data.color or 0)
    SetBlipScale(blip, data.scale or 0.8)
    SetBlipAsShortRange(blip, data.shortRange ~= false)

    if data.route then
        SetBlipRoute(blip, true)
    end

    if data.label then
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(data.label)
        EndTextCommandSetBlipName(blip)
    end

    blips[blip] = true
    return blip
end

---@param blip number
---@return boolean
function vu.blips.remove(blip)
    if not blips[blip] then
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
        return false
    end

    if DoesBlipExist(blip) then
        RemoveBlip(blip)
    end

    blips[blip] = nil
    return true
end

function vu.blips.clear()
    for blip in pairs(blips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    blips = {}
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end
    vu.blips.clear()
end)

return vu.blips
