vu.table = table

---@param tbl table
---@param value any
---@return boolean
function table.contains(tbl, value)
    if type(value) ~= 'table' then
        for _, v in pairs(tbl) do
            if v == value then return true end
        end
        return false
    end

    local set = {}
    for _, v in pairs(tbl) do
        set[v] = true
    end

    for _, v in pairs(value) do
        if not set[v] then return false end
    end

    return true
end

---@param t1 any
---@param t2 any
---@return boolean
function table.matches(t1, t2)
    local type1 = type(t1)
    if type1 ~= 'table' then return t1 == t2 end
    if type(t2) ~= 'table' then return false end

    for k, v1 in pairs(t1) do
        if not table.matches(v1, t2[k]) then return false end
    end

    for k in pairs(t2) do
        if t1[k] == nil then return false end
    end

    return true
end

---@generic T
---@param tbl T
---@return T
function table.deepclone(tbl)
    if type(tbl) ~= 'table' then return tbl end

    local copy = {}
    for k, v in pairs(tbl) do
        copy[table.deepclone(k)] = table.deepclone(v)
    end

    return setmetatable(copy, getmetatable(tbl))
end

---@param t1 table
---@param t2 table
---@param addDuplicateNumbers? boolean
---@return table
function table.merge(t1, t2, addDuplicateNumbers)
    addDuplicateNumbers = addDuplicateNumbers == nil or addDuplicateNumbers

    for k, v2 in pairs(t2) do
        local v1 = t1[k]
        local type1, type2 = type(v1), type(v2)

        if type1 == 'table' and type2 == 'table' then
            table.merge(v1, v2, addDuplicateNumbers)
        elseif addDuplicateNumbers and type1 == 'number' and type2 == 'number' then
            t1[k] = v1 + v2
        else
            t1[k] = v2
        end
    end

    return t1
end

---@param tbl table
---@return integer
function table.count(tbl)
    local n = 0
    for _ in pairs(tbl or {}) do
        n += 1
    end
    return n
end

---@param tbl table
---@return boolean
function table.isEmpty(tbl)
    return next(tbl or {}) == nil
end

---@param tbl table
function table.print_r(tbl)
    local seen = {}

    local function walk(t, indent)
        if seen[t] then
            print(indent .. '*recursive*')
            return
        end

        seen[t] = true

        for k, v in pairs(t) do
            if type(v) == 'table' then
                print(('%s[%s] => {'):format(indent, tostring(k)))
                walk(v, indent .. '  ')
                print(indent .. '}')
            else
                print(('%s[%s] => %s'):format(indent, tostring(k), tostring(v)))
            end
        end
    end

    walk(tbl, ' ')
end

return vu.table
