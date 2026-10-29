---@param playerId number|number[]
---@param data table
function vu.notify(playerId, data)
    if type(playerId) == 'table' then
        for i = 1, #playerId do
            TriggerClientEvent('vu_libs:notify', playerId[i], data)
        end
        return
    end

    TriggerClientEvent('vu_libs:notify', playerId, data)
end
