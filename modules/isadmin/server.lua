--[[
    Server admin check (ESX AdminGroups + ACE).
    if not vu.isadmin(source) then return end
]]

local ESX = exports['es_extended']:getSharedObject()

---@param source number
---@return boolean
local function isAdmin(source)
    if type(source) ~= 'number' then
        return false
    end

    -- console
    if source == 0 then
        return true
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return false
    end

    if xPlayer.isAdmin then
        return xPlayer.isAdmin() == true
    end

    return xPlayer.getGroup and xPlayer.getGroup() == 'admin' or false
end

vu.isadmin = setmetatable({}, {
    __call = function(_, source)
        return isAdmin(source)
    end,
})

return vu.isadmin
