--[[
    Cancellable timeout helper.
    local id = vu.timeout(5000, function() ... end)
    vu.timeout.clear(id)
]]

local timeouts = {}
local nextId = 0

local function setTimeout(ms, cb, ...)
    assert(type(ms) == 'number', 'timeout ms must be a number')
    assert(type(cb) == 'function', 'timeout callback must be a function')

    nextId += 1
    local id = nextId
    local args = { ... }

    timeouts[id] = true

    SetTimeout(ms, function()
        if not timeouts[id] then return end
        timeouts[id] = nil
        cb(table.unpack(args))
    end)

    return id
end

local function clearTimeout(id)
    if not timeouts[id] then return false end
    timeouts[id] = nil
    return true
end

vu.timeout = setmetatable({
    clear = clearTimeout,
    count = function()
        local n = 0
        for _ in pairs(timeouts) do n += 1 end
        return n
    end,
}, {
    __call = function(_, ms, cb, ...)
        return setTimeout(ms, cb, ...)
    end,
})

return vu.timeout
