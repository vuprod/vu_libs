-- NUI focus is never forced for notify / textui / progress overlays.
RegisterNUICallback('init', function(_, cb)
    cb(1)
end)
