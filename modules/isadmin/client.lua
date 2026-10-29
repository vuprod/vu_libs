--[[
    Client admin check (asks server via ESX).
    if not vu.isadmin() then return end
]]

local ESX = exports['es_extended']:getSharedObject()

---@return boolean
local function isAdmin()
    local p = promise.new()

    ESX.TriggerServerCallback('esx:isUserAdmin', function(admin)
        p:resolve(admin == true)
    end)

    return Citizen.Await(p)
end

vu.isadmin = setmetatable({}, {
    __call = function()
        return isAdmin()
    end,
})

return vu.isadmin
