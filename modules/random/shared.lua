vu.random = {}

---@param min number
---@param max number
---@return number
function vu.random.int(min, max)
    return math.random(min, max)
end

---@param min number
---@param max number
---@return number
function vu.random.float(min, max)
    return min + math.random() * (max - min)
end

---@generic T
---@param list T[]
---@return T|nil
function vu.random.choice(list)
    if type(list) ~= 'table' or #list == 0 then return nil end
    return list[math.random(1, #list)]
end

--- Weighted pick: { { item = 'cash', weight = 70 }, { item = 'gold', weight = 30 } }
---@param entries { item: any, weight: number }[]
---@return any|nil
function vu.random.weighted(entries)
    if type(entries) ~= 'table' or #entries == 0 then return nil end

    local total = 0
    for i = 1, #entries do
        total += entries[i].weight or 0
    end

    if total <= 0 then return nil end

    local roll = math.random() * total
    local acc = 0

    for i = 1, #entries do
        acc += entries[i].weight or 0
        if roll <= acc then
            return entries[i].item
        end
    end

    return entries[#entries].item
end

---@generic T
---@param list T[]
---@return T[]
function vu.random.shuffle(list)
    local copy = { table.unpack(list) }
    for i = #copy, 2, -1 do
        local j = math.random(i)
        copy[i], copy[j] = copy[j], copy[i]
    end
    return copy
end

return vu.random
