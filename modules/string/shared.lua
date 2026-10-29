vu.string = string

---@param str string
---@param sep? string
---@return string[]
function string.split(str, sep)
    sep = sep or '%s'
    local result = {}

    for part in string.gmatch(str, '([^' .. sep .. ']+)') do
        result[#result + 1] = part
    end

    return result
end

---@param str string
---@return string
function string.trim(str)
    return (str:gsub('^%s+', ''):gsub('%s+$', ''))
end

---@param str string
---@return string
function string.capitalize(str)
    return (str:gsub('^%l', string.upper))
end

---@param template string
---@param vars table
---@return string
function string.interpolate(template, vars)
    return (template:gsub('%${(.-)}', function(key)
        local value = vars[key]
        return value ~= nil and tostring(value) or ''
    end))
end

return vu.string
