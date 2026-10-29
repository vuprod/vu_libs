---@alias NotificationPosition 'top' | 'top-right' | 'top-left' | 'bottom' | 'bottom-right' | 'bottom-left' | 'center-right' | 'center-left'
---@alias NotificationType 'info' | 'warning' | 'success' | 'error'

---@class NotifyProps
---@field id? string|number
---@field title? string
---@field description? string
---@field duration? number
---@field showDuration? boolean
---@field position? NotificationPosition
---@field type? NotificationType|string
---@field icon? string|string[]|false
---@field iconColor? string
---@field iconAnimation? string
---@field iconSize? number
---@field alignIcon? 'top'|'center'
---@field hideIcon? boolean
---@field durationColor? string
---@field backgroundColor? string
---@field color? string
---@field descriptionColor? string
---@field borderColor? string
---@field borderWidth? number|string
---@field borderRadius? number|string
---@field width? number|string
---@field padding? number|string
---@field opacity? number
---@field shadow? string|boolean
---@field fontFamily? string
---@field titleFontSize? number|string
---@field descriptionFontSize? number|string
---@field titleFontWeight? number|string
---@field style? table

local defaultPosition = GetConvar('vu:notificationposition', 'top-right')

local PASS_THROUGH = {
    'id', 'title', 'description', 'duration', 'showDuration', 'position', 'type',
    'icon', 'iconColor', 'iconAnimation', 'iconSize', 'alignIcon', 'hideIcon',
    'durationColor', 'backgroundColor', 'color', 'descriptionColor',
    'borderColor', 'borderWidth', 'borderRadius', 'width', 'padding',
    'opacity', 'shadow', 'fontFamily', 'titleFontSize', 'descriptionFontSize',
    'titleFontWeight', 'style',
}

---@param data NotifyProps
function vu.notify(data)
    if type(data) ~= 'table' then return end

    local payload = {
        duration = data.duration or 3000,
        position = data.position or defaultPosition,
        type = data.type or 'info',
    }

    for i = 1, #PASS_THROUGH do
        local key = PASS_THROUGH[i]
        if data[key] ~= nil and payload[key] == nil then
            payload[key] = data[key]
        end
    end

    -- ensure required defaults after pass-through
    payload.duration = data.duration or 3000
    payload.position = data.position or defaultPosition
    payload.type = data.type or 'info'
    if payload.type == 'inform' then
        payload.type = 'info'
    end

    SendNUIMessage({
        action = 'notify',
        data = payload,
    })
end

RegisterNetEvent('vu_libs:notify', function(data)
    vu.notify(data)
end)
