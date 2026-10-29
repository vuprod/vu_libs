vu.math = math

---@param value number
---@param min number
---@param max number
---@return number
function math.clamp(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

---@param a number
---@param b number
---@param t number
---@return number
function math.lerp(a, b, t)
    return a + (b - a) * t
end

---@param value number
---@param fromMin number
---@param fromMax number
---@param toMin number
---@param toMax number
---@return number
function math.remap(value, fromMin, fromMax, toMin, toMax)
    if fromMax == fromMin then return toMin end
    local t = (value - fromMin) / (fromMax - fromMin)
    return toMin + t * (toMax - toMin)
end

---@param n number
---@param digits? integer
---@return number
function math.round(n, digits)
    local mult = 10 ^ (digits or 0)
    return math.floor(n * mult + 0.5) / mult
end

return vu.math
