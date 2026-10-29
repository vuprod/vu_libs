--[[
    VU Libraries initiator — include in consuming resources:

    shared_scripts {
        '@vu_libs/init.lua',
    }

    vu_libs {
        'callback',
        'print',
        'table',
    }
]]

if not _VERSION:find('5.4') then
    error('Lua 5.4 must be enabled in the resource manifest!', 2)
end

local resourceName = GetCurrentResourceName()
local libName = 'vu_libs'

if resourceName == libName then
    return
end

if vu and vu.name == libName then
    error(("Cannot load vu_libs more than once.\n\tRemove duplicate '@%s/fxmanifest.lua' entries"):format(resourceName))
end

if GetResourceState(libName) ~= 'started' then
    error('^1vu_libs must be started before this resource.^0', 0)
end

local export = exports[libName]
local status = export.hasLoaded()

if status ~= true then
    error(status, 2)
end

msgpack.setoption('ignore_invalid', true)

local LoadResourceFile = LoadResourceFile
local context = IsDuplicityVersion() and 'server' or 'client'

function noop() end

local function loadModule(self, module)
    local dir = ('modules/%s'):format(module)
    local chunk = LoadResourceFile(libName, ('%s/%s.lua'):format(dir, context))
    local shared = LoadResourceFile(libName, ('%s/shared.lua'):format(dir))

    if shared then
        chunk = (chunk and ('%s\n%s'):format(shared, chunk)) or shared
    end

    if chunk then
        local fn, err = load(chunk, ('@@vu_libs/modules/%s/%s.lua'):format(module, context))
        if not fn or err then
            return error(('\n^1Error importing module (%s): %s^0'):format(dir, err), 3)
        end

        local result = fn()
        self[module] = result or noop
        return self[module]
    end
end

local function call(self, index, ...)
    local module = rawget(self, index)

    if not module then
        self[index] = noop
        module = loadModule(self, index)

        if not module then
            local function method(...)
                return export[index](nil, ...)
            end

            if not ... then
                self[index] = method
            end

            return method
        end
    end

    return module
end

local vu = setmetatable({
    name = libName,
    context = context,
}, {
    __index = call,
    __call = call,
})

-----------------------------------------------------------------------------------------------
-- Intervals
-----------------------------------------------------------------------------------------------

local intervals = {}

---@param callback function|number
---@param interval? number
---@param ... any
function SetInterval(callback, interval, ...)
    interval = interval or 0

    if type(interval) ~= 'number' then
        return error(('Interval must be a number. Received %s'):format(json.encode(interval)))
    end

    local cbType = type(callback)

    if cbType == 'number' and intervals[callback] then
        intervals[callback] = interval or 0
        return
    end

    if cbType ~= 'function' then
        return error(('Callback must be a function. Received %s'):format(cbType))
    end

    local args, id = { ... }

    Citizen.CreateThreadNow(function(ref)
        id = ref
        intervals[id] = interval or 0
        repeat
            interval = intervals[id]
            Wait(interval)
            if interval < 0 then break end
            callback(table.unpack(args))
        until false
        intervals[id] = nil
    end)

    return id
end

---@param id number
function ClearInterval(id)
    if type(id) ~= 'number' then
        return error(('Interval id must be a number. Received %s'):format(json.encode(id)))
    end

    if not intervals[id] then
        return error(('No interval exists with id %s'):format(id))
    end

    intervals[id] = -1
end

-----------------------------------------------------------------------------------------------
-- Cache
-----------------------------------------------------------------------------------------------

local cacheEvents = {}

local cache = setmetatable({
    game = GetGameName(),
    resource = resourceName,
}, {
    __index = function(self, key)
        cacheEvents[key] = {}

        AddEventHandler(('vu_libs:cache:%s'):format(key), function(value)
            local oldValue = self[key]
            local events = cacheEvents[key]

            for i = 1, #events do
                Citizen.CreateThreadNow(function()
                    events[i](value, oldValue)
                end)
            end

            self[key] = value
        end)

        local value = false
        local ok, result = pcall(function()
            return export.cache(nil, key)
        end)
        if ok and result ~= nil then
            value = result
        end

        return rawset(self, key, value)[key]
    end,

    __call = function(self, key, func, timeout)
        local value = rawget(self, key)

        if value == nil then
            value = func()
            rawset(self, key, value)

            if timeout then
                SetTimeout(timeout, function()
                    self[key] = nil
                end)
            end
        end

        return value
    end,
})

function vu.onCache(key, cb)
    if not cacheEvents[key] then
        getmetatable(cache).__index(cache, key)
    end

    table.insert(cacheEvents[key], cb)
end

-----------------------------------------------------------------------------------------------
-- Ready / stopped
-----------------------------------------------------------------------------------------------

function vu.ready(cb)
    Citizen.CreateThreadNow(function()
        while GetResourceState(libName) ~= 'started' do
            Wait(0)
        end
        if cb then cb() end
    end)
end

function vu.stopped(cb)
    AddEventHandler('onResourceStop', function(resource)
        if resource ~= resourceName then return end
        cb()
    end)
end

_ENV.vu = vu
_ENV.cache = cache

if context == 'client' then
    cache.playerId = PlayerId()
    cache.serverId = GetPlayerServerId(cache.playerId)
else
    local poolNatives = {
        CPed = GetAllPeds,
        CObject = GetAllObjects,
        CVehicle = GetAllVehicles,
    }

    function GetGamePool(poolName)
        local fn = poolNatives[poolName]
        return fn and fn() or {}
    end

    function GetActivePlayers()
        local playerNum = GetNumPlayerIndices()
        local players = table.create(playerNum, 0)

        for i = 1, playerNum do
            players[i] = tonumber(GetPlayerFromIndex(i - 1))
        end

        return players
    end
end

-- Eager-load modules listed in fxmanifest: vu_libs { 'callback', 'print', ... }
for i = 1, GetNumResourceMetadata(cache.resource, 'vu_libs') do
    local name = GetResourceMetadata(cache.resource, 'vu_libs', i - 1)

    if not rawget(vu, name) then
        local module = loadModule(vu, name)

        if type(module) == 'function' then
            pcall(module)
        end
    end
end
