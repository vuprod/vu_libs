-- Server bootstrap for vu_libs resource

local poolNatives = {
    CPed = GetAllPeds,
    CObject = GetAllObjects,
    CVehicle = GetAllVehicles,
}

---@param poolName 'CPed' | 'CObject' | 'CVehicle'
---@return number[]
function GetGamePool(poolName)
    local fn = poolNatives[poolName]
    return fn and fn() or {}
end

---@return number[]
function GetActivePlayers()
    local playerNum = GetNumPlayerIndices()
    local players = table.create(playerNum, 0)

    for i = 1, playerNum do
        players[i] = tonumber(GetPlayerFromIndex(i - 1))
    end

    return players
end
