--[[
    Server-side cooldowns keyed by player + action.
    vu.cooldown.set(source, 'robbery', 300) -- seconds
    vu.cooldown.has(source, 'robbery')
    vu.cooldown.remaining(source, 'robbery')
]]

local cooldowns = {} -- [source][key] = expireAt (os.time)

local function ensurePlayer(source)
    if not cooldowns[source] then
        cooldowns[source] = {}
    end
    return cooldowns[source]
end

vu.cooldown = {}

---@param source number
---@param key string
---@param seconds number
function vu.cooldown.set(source, key, seconds)
    local bag = ensurePlayer(source)
    bag[key] = os.time() + math.max(0, math.floor(seconds))
end

---@param source number
---@param key string
---@return boolean
function vu.cooldown.has(source, key)
    local bag = cooldowns[source]
    if not bag or not bag[key] then return false end

    if bag[key] <= os.time() then
        bag[key] = nil
        return false
    end

    return true
end

---@param source number
---@param key string
---@return number seconds remaining
function vu.cooldown.remaining(source, key)
    local bag = cooldowns[source]
    if not bag or not bag[key] then return 0 end

    local left = bag[key] - os.time()
    if left <= 0 then
        bag[key] = nil
        return 0
    end

    return left
end

---@param source number
---@param key? string
function vu.cooldown.clear(source, key)
    if not cooldowns[source] then return end

    if key then
        cooldowns[source][key] = nil
    else
        cooldowns[source] = nil
    end
end

AddEventHandler('playerDropped', function()
    cooldowns[source] = nil
end)

return vu.cooldown
