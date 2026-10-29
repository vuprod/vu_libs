---@class TextUIOptions
---@field position? 'right-center' | 'left-center' | 'top-center' | 'bottom-center'
---@field icon? string | string[]
---@field iconColor? string
---@field iconAnimation? string
---@field style? table
---@field alignIcon? 'top' | 'center'

local isOpen = false
local currentText

---@param text string
---@param options? TextUIOptions
function vu.showTextUI(text, options)
    if currentText == text then return end

    options = options or {}
    options.text = text
    currentText = text

    SendNUIMessage({
        action = 'textUi',
        data = options,
    })

    isOpen = true
end

function vu.hideTextUI()
    SendNUIMessage({
        action = 'textUiHide',
    })

    isOpen = false
    currentText = nil
end

---@return boolean, string|nil
function vu.isTextUIOpen()
    return isOpen, currentText
end
