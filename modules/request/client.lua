--[[
    Asset streaming helpers.
    vu.request.model('a_m_m_business_01')
    vu.request.animDict('amb@world_human_stand_impatient@male@no_sign@base')
]]

vu.request = {}

---@param model string|number
---@param timeout? number ms
---@return boolean
function vu.request.model(model, timeout)
    if type(model) ~= 'number' then model = joaat(model) end
    if not IsModelValid(model) and not IsModelInCdimage(model) then
        return false
    end

    if HasModelLoaded(model) then return true end

    RequestModel(model)
    timeout = GetGameTimer() + (timeout or 5000)

    while not HasModelLoaded(model) do
        if GetGameTimer() > timeout then return false end
        Wait(0)
    end

    return true
end

---@param dict string
---@param timeout? number ms
---@return boolean
function vu.request.animDict(dict, timeout)
    if HasAnimDictLoaded(dict) then return true end

    RequestAnimDict(dict)
    timeout = GetGameTimer() + (timeout or 5000)

    while not HasAnimDictLoaded(dict) do
        if GetGameTimer() > timeout then return false end
        Wait(0)
    end

    return true
end

---@param set string
---@param timeout? number ms
---@return boolean
function vu.request.animSet(set, timeout)
    if HasAnimSetLoaded(set) then return true end

    RequestAnimSet(set)
    timeout = GetGameTimer() + (timeout or 5000)

    while not HasAnimSetLoaded(set) do
        if GetGameTimer() > timeout then return false end
        Wait(0)
    end

    return true
end

---@param ptfx string
---@param timeout? number ms
---@return boolean
function vu.request.ptfx(ptfx, timeout)
    if HasNamedPtfxAssetLoaded(ptfx) then return true end

    RequestNamedPtfxAsset(ptfx)
    timeout = GetGameTimer() + (timeout or 5000)

    while not HasNamedPtfxAssetLoaded(ptfx) do
        if GetGameTimer() > timeout then return false end
        Wait(0)
    end

    return true
end

return vu.request
