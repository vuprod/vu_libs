--[[
    Proximity NPC manager (chunk grid).
    Exports: AddNPCPed / RemoveNPCPed
]]

local Peds = {}

local GRID_BITSHIFT = 13
local GRID_SIZE = 64.0

local deltas = {
    vector2(-1, -1), vector2(-1, 0), vector2(-1, 1),
    vector2(0, -1), vector2(0, 1),
    vector2(1, -1), vector2(1, 0), vector2(1, 1),
}

local function getGridChunk(x)
    return math.floor((x + 8192.0) / GRID_SIZE)
end

local function getChunkId(v)
    return (v.x << GRID_BITSHIFT) | v.y
end

local function chunkFromVec3(pos)
    return getChunkId(vector2(getGridChunk(pos.x), getGridChunk(pos.y)))
end

local function nearbyChunkIds(pos)
    local list, seen = {}, {}
    local base = vector2(getGridChunk(pos.x), getGridChunk(pos.y))

    local function add(v)
        local id = getChunkId(v)
        if not seen[id] then
            seen[id] = true
            list[#list + 1] = id
        end
    end

    add(base)
    for i = 1, #deltas do
        add(base + deltas[i])
    end

    return list
end

local Grid = {}

local function gridAdd(chunkId, name)
    local bucket = Grid[chunkId]
    if not bucket then
        bucket = {}
        Grid[chunkId] = bucket
    end
    bucket[name] = true
end

local function gridRemove(chunkId, name)
    local bucket = Grid[chunkId]
    if not bucket then return end
    bucket[name] = nil
    if not next(bucket) then
        Grid[chunkId] = nil
    end
end

local function isSpawnAllowed(entry, playerCoords, dist)
    local canSpawn = entry.data and entry.data.canSpawn
    if canSpawn == nil then return true end

    local ok, result = pcall(canSpawn, entry, playerCoords, dist)
    if not ok then
        print(("[vu_libs:createped] canSpawn errored for '%s': %s"):format(
            tostring(entry.data and entry.data.name or 'unknown'),
            tostring(result)
        ))
        return false
    end

    return result and true or false
end

local function spawnPed(entry)
    if not entry then return end
    if entry.spawnedPed and DoesEntityExist(entry.spawnedPed) then return end

    if type(entry.model) ~= 'number' then
        entry.model = joaat(entry.model)
    end

    if not IsModelValid(entry.model) and not IsModelInCdimage(entry.model) then
        print(("[vu_libs:createped] invalid model '%s'"):format(entry.model))
        return
    end

    if not HasModelLoaded(entry.model) then
        RequestModel(entry.model)
        local timeout = GetGameTimer() + 5000
        while not HasModelLoaded(entry.model) do
            if GetGameTimer() > timeout then
                print(("[vu_libs:createped] model load timeout '%s'"):format(entry.model))
                return
            end
            Wait(10)
        end
    end

    local coords = entry.spawnCoords
    local ped = CreatePed(4, entry.model, coords.x, coords.y, coords.z, entry.spawnHeading, false, true)

    SetEntityHeading(ped, entry.spawnHeading)
    SetEntityAsMissionEntity(ped, true, true)
    SetPedHearingRange(ped, 0.0)
    SetPedSeeingRange(ped, 0.0)
    SetPedAlertness(ped, 0.0)
    SetPedFleeAttributes(ped, 0, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCombatAttributes(ped, 46, true)
    SetModelAsNoLongerNeeded(entry.model)

    entry.spawnedPed = ped

    if entry.data and entry.data.onSpawn then
        pcall(entry.data.onSpawn, ped)
    end
end

local function despawnPed(entry)
    if entry.data and entry.data.onDespawn and entry.spawnedPed then
        pcall(entry.data.onDespawn, entry.spawnedPed)
    end

    if entry.spawnedPed and DoesEntityExist(entry.spawnedPed) then
        DeleteEntity(entry.spawnedPed)
    end

    entry.spawnedPed = nil
end

local RemoveNPCPed

---@param name string
---@param npcModel string|number
---@param spawnCoords vector3|vector4|table
---@param options? table
local function AddNPCPed(name, npcModel, spawnCoords, options)
    assert(type(name) == 'string' and name ~= '', 'AddNPCPed: name must be a non-empty string')

    local coords = spawnCoords
    local heading = (options and options.spawnHeading) or 0.0

    if type(spawnCoords) == 'vector4' then
        coords = vector3(spawnCoords.x, spawnCoords.y, spawnCoords.z)
        heading = spawnCoords.w
    elseif type(spawnCoords) == 'table' and spawnCoords.x then
        coords = vector3(spawnCoords.x + 0.0, spawnCoords.y + 0.0, spawnCoords.z + 0.0)
        if spawnCoords.w then heading = spawnCoords.w + 0.0 end
    end

    local entry = {
        model = npcModel,
        spawnCoords = coords,
        spawnHeading = heading,
        distance = (options and options.distance) or 20.0,
        resource = GetInvokingResource() or GetCurrentResourceName(),
        data = options or {},
        _chunkId = chunkFromVec3(coords),
    }

    entry.data.name = name

    if Peds[name] then
        RemoveNPCPed(name)
    end

    Peds[name] = entry
    gridAdd(entry._chunkId, name)

    return true
end

RemoveNPCPed = function(name)
    local entry = Peds[name]
    if not entry then return false end

    despawnPed(entry)
    if entry._chunkId then
        gridRemove(entry._chunkId, name)
    end
    Peds[name] = nil
    return true
end

---@param name string
---@return number|nil ped entity
local function GetNPCPed(name)
    local entry = Peds[name]
    if not entry then return nil end
    if entry.spawnedPed and DoesEntityExist(entry.spawnedPed) then
        return entry.spawnedPed
    end
    return nil
end

exports('AddNPCPed', AddNPCPed)
exports('RemoveNPCPed', RemoveNPCPed)
exports('GetNPCPed', GetNPCPed)

CreateThread(function()
    while true do
        Wait(2000)

        local playerCoords = GetEntityCoords(PlayerPedId())
        local chunks = nearbyChunkIds(playerCoords)
        local candidates = {}

        for i = 1, #chunks do
            local bucket = Grid[chunks[i]]
            if bucket then
                for name in pairs(bucket) do
                    candidates[name] = true
                end
            end
        end

        for name, entry in pairs(Peds) do
            local dist = #(entry.spawnCoords - playerCoords)
            local within = dist <= entry.distance
            local allowed = within and isSpawnAllowed(entry, playerCoords, dist)

            if allowed then
                if candidates[name] or within then
                    spawnPed(entry)
                end
            elseif entry.spawnedPed then
                despawnPed(entry)
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for _, entry in pairs(Peds) do
            if entry.spawnedPed and DoesEntityExist(entry.spawnedPed) then
                DeleteEntity(entry.spawnedPed)
            end
        end
        Peds = {}
        Grid = {}
        return
    end

    for name, entry in pairs(Peds) do
        if entry.resource == resourceName then
            despawnPed(entry)
            if entry._chunkId then
                gridRemove(entry._chunkId, name)
            end
            Peds[name] = nil
        end
    end
end)
