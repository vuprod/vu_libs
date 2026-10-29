local debug_getinfo = debug.getinfo

function noop() end

vu = setmetatable({
    name = 'vu_libs',
    context = IsDuplicityVersion() and 'server' or 'client',
}, {
    __newindex = function(self, key, fn)
        rawset(self, key, fn)

        if debug_getinfo(2, 'S').short_src:find('@vu_libs/resource') then
            exports(key, fn)
        end
    end,

    __index = function(self, key)
        local dir = ('modules/%s'):format(key)
        local chunk = LoadResourceFile(self.name, ('%s/%s.lua'):format(dir, self.context))
        local shared = LoadResourceFile(self.name, ('%s/shared.lua'):format(dir))

        if shared then
            chunk = (chunk and ('%s\n%s'):format(shared, chunk)) or shared
        end

        if chunk then
            local fn, err = load(chunk, ('@@vu_libs/%s/%s.lua'):format(key, self.context))

            if not fn or err then
                return error(('\n^1Error importing module (%s): %s^0'):format(dir, err), 3)
            end

            rawset(self, key, fn() or noop)
            return self[key]
        end
    end,
})

cache = {
    libLoaded = false,
    resource = vu.name,
    game = GetGameName(),
}

function vu.waitLibLoading()
    while not cache.libLoaded do
        Wait(0)
    end
end

local function onReady(cb)
    vu.waitLibLoading()
    Wait(0)
    return cb and cb() or true
end

function vu.ready(cb)
    Citizen.CreateThreadNow(function()
        onReady(cb)
    end)
end

function vu.stopped(cb)
    AddEventHandler('onResourceStop', function(resource)
        if resource ~= GetCurrentResourceName() then return end
        cb()
    end)
end

function vu.hasLoaded()
    if not LoadResourceFile(vu.name, 'web/build/index.html') then
        return '^1Unable to load UI. Build vu_libs web (cd web && npm i && npm run build).^0'
    end
    return true
end

cache.libLoaded = true
