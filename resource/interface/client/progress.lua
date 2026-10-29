local progress
local DisableControlAction = DisableControlAction
local DisablePlayerFiring = DisablePlayerFiring

---@class ProgressPropProps
---@field model string
---@field bone? number
---@field pos vector3
---@field rot vector3
---@field rotOrder? number

---@class ProgressProps
---@field label? string
---@field duration number
---@field position? 'middle' | 'bottom'
---@field useWhileDead? boolean
---@field allowRagdoll? boolean
---@field allowCuffed? boolean
---@field allowFalling? boolean
---@field allowSwimming? boolean
---@field canCancel? boolean
---@field anim? table
---@field prop? ProgressPropProps | ProgressPropProps[]
---@field disable? { move?: boolean, sprint?: boolean, car?: boolean, combat?: boolean, mouse?: boolean }

local controls = {
    INPUT_LOOK_LR = 1,
    INPUT_LOOK_UD = 2,
    INPUT_SPRINT = 21,
    INPUT_AIM = 25,
    INPUT_MOVE_LR = 30,
    INPUT_MOVE_UD = 31,
    INPUT_DUCK = 36,
    INPUT_VEH_MOVE_LEFT_ONLY = 63,
    INPUT_VEH_MOVE_RIGHT_ONLY = 64,
    INPUT_VEH_ACCELERATE = 71,
    INPUT_VEH_BRAKE = 72,
    INPUT_VEH_EXIT = 75,
    INPUT_VEH_MOUSE_CONTROL_OVERRIDE = 106,
}

local function interruptProgress(data)
    local ped = cache.ped or PlayerPedId()
    if not data.useWhileDead and IsEntityDead(ped) then return true end
    if not data.allowRagdoll and IsPedRagdoll(ped) then return true end
    if not data.allowCuffed and IsPedCuffed(ped) then return true end
    if not data.allowFalling and IsPedFalling(ped) then return true end
    if not data.allowSwimming and IsPedSwimming(ped) then return true end
end

local function createLocalProp(ped, prop)
    local model = prop.model
    if type(model) ~= 'number' then model = joaat(model) end

    if not IsModelValid(model) and not IsModelInCdimage(model) then
        return print(("[vu_libs] invalid progress prop model '%s'"):format(prop.model))
    end

    RequestModel(model)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) do
        if GetGameTimer() > timeout then return end
        Wait(0)
    end

    local coords = GetEntityCoords(ped)
    local object = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)
    AttachEntityToEntity(
        object, ped, GetPedBoneIndex(ped, prop.bone or 60309),
        prop.pos.x, prop.pos.y, prop.pos.z,
        prop.rot.x, prop.rot.y, prop.rot.z,
        true, true, false, true, prop.rotOrder or 0, true
    )
    SetModelAsNoLongerNeeded(model)
    return object
end

---@param data ProgressProps
---@param nuiMessage table
local function startProgress(data, nuiMessage)
    progress = data
    local ped = cache.ped or PlayerPedId()
    local props = {}

    if data.prop then
        local list = data.prop.model and { data.prop } or data.prop
        for i = 1, #list do
            local obj = createLocalProp(ped, list[i])
            if obj then props[#props + 1] = obj end
        end
    end

    local anim = data.anim
    if anim then
        if anim.dict then
            RequestAnimDict(anim.dict)
            while not HasAnimDictLoaded(anim.dict) do Wait(0) end
            TaskPlayAnim(
                ped, anim.dict, anim.clip,
                anim.blendIn or 3.0, anim.blendOut or 1.0,
                anim.duration or -1, anim.flag or 49,
                anim.playbackRate or 0,
                anim.lockX, anim.lockY, anim.lockZ
            )
            RemoveAnimDict(anim.dict)
        elseif anim.scenario then
            TaskStartScenarioInPlace(ped, anim.scenario, 0, anim.playEnter ~= false)
        end
    end

    local disable = data.disable
    local startTime = GetGameTimer()

    SendNUIMessage(nuiMessage)

    while progress do
        if disable then
            if disable.mouse then
                DisableControlAction(0, controls.INPUT_LOOK_LR, true)
                DisableControlAction(0, controls.INPUT_LOOK_UD, true)
                DisableControlAction(0, controls.INPUT_VEH_MOUSE_CONTROL_OVERRIDE, true)
            end
            if disable.move then
                DisableControlAction(0, controls.INPUT_SPRINT, true)
                DisableControlAction(0, controls.INPUT_MOVE_LR, true)
                DisableControlAction(0, controls.INPUT_MOVE_UD, true)
                DisableControlAction(0, controls.INPUT_DUCK, true)
            end
            if disable.sprint and not disable.move then
                DisableControlAction(0, controls.INPUT_SPRINT, true)
            end
            if disable.car then
                DisableControlAction(0, controls.INPUT_VEH_MOVE_LEFT_ONLY, true)
                DisableControlAction(0, controls.INPUT_VEH_MOVE_RIGHT_ONLY, true)
                DisableControlAction(0, controls.INPUT_VEH_ACCELERATE, true)
                DisableControlAction(0, controls.INPUT_VEH_BRAKE, true)
                DisableControlAction(0, controls.INPUT_VEH_EXIT, true)
            end
            if disable.combat then
                DisableControlAction(0, controls.INPUT_AIM, true)
                DisablePlayerFiring(cache.playerId or PlayerId(), true)
            end
        end

        if interruptProgress(progress) then
            progress = false
        end

        Wait(0)
    end

    for i = 1, #props do
        if DoesEntityExist(props[i]) then DeleteEntity(props[i]) end
    end

    if anim then
        if anim.dict then
            StopAnimTask(ped, anim.dict, anim.clip, 1.0)
            Wait(0)
        else
            ClearPedTasks(ped)
        end
    end

    local elapsed = progress ~= false and GetGameTimer() - startTime + 100

    if progress == false or not elapsed or elapsed <= data.duration then
        SendNUIMessage({ action = 'progressCancel' })
        return false
    end

    return true
end

---@param data ProgressProps
---@return boolean?
function vu.progressBar(data)
    while progress ~= nil do Wait(0) end

    if not interruptProgress(data) then
        return startProgress(data, {
            action = 'progress',
            data = {
                label = data.label or '',
                duration = data.duration,
            },
        })
    end
end

---@param data ProgressProps
---@return boolean?
function vu.progressCircle(data)
    while progress ~= nil do Wait(0) end

    if not interruptProgress(data) then
        return startProgress(data, {
            action = 'circleProgress',
            data = {
                duration = data.duration,
                position = data.position,
                label = data.label,
            },
        })
    end
end

function vu.cancelProgress()
    if not progress then
        error('No progress bar is active')
    end
    progress = false
end

---@return boolean
function vu.progressActive()
    return progress and true or false
end

RegisterNUICallback('progressComplete', function(_, cb)
    cb(1)
    progress = nil
end)

RegisterCommand('cancelprogress', function()
    if progress and progress.canCancel then
        progress = false
    end
end, false)

RegisterKeyMapping('cancelprogress', 'Cancel Progress', 'keyboard', 'x')
