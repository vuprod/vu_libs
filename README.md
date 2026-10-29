# vu_libs

Shared Lua helpers for VU resources — callbacks, utils, proximity NPCs, and a small NUI layer (notify / progress / textui). API shape is close to ox_lib where it made sense.

Requires **Lua 5.4**. `isadmin` talks to ESX; skip that module if you don't use it.

Version `1.1.0`

---

## Install

1. Drop `vu_libs` in your resources folder (e.g. `[libs]`).
2. Start it **before** anything that depends on it:

```cfg
ensure vu_libs
ensure [vuprod]
```

3. UI ships prebuilt under `web/build`. Rebuild only if you change the frontend:

```bash
cd web
npm i
npm run build
```

---

## Setup in a resource

```lua
-- fxmanifest.lua
shared_scripts {
    '@vu_libs/init.lua',
}

vu_libs {
    'callback',
    'print',
    'table',
    'timeout',
    'request',
    'math',
    'string',
    'blips',
    'random',
    'cooldown', -- server only
    'isadmin',  -- needs ESX
}
```

Only list what you need. Globals after load: `vu` and `cache`.

```lua
vu.ready(function()
    -- modules available
end)

vu.stopped(function()
    print(GetCurrentResourceName() .. ' stopped')
end)
```

---

## Callback

```lua
-- server
vu.callback.register('myres:getData', function(source, id)
    return true, { id = id }
end)

-- client
local ok, data = vu.callback.await('myres:getData', false, 1)
```

---

## isadmin

```lua
-- server
if not vu.isadmin(source) then return end

-- client (hits the server)
if not vu.isadmin() then return end
```

---

## Notify / Progress / TextUI

Always available once `vu_libs` is started (no module entry needed). Look is ox_lib-ish (React + Mantine).

### Notify

```lua
vu.notify({
    title = 'Success',
    description = 'Item received',
    type = 'success', -- info | success | error | warning
    duration = 5000,
    position = 'top-right',
})

-- from server
vu.notify(source, { title = 'Hello', type = 'info' })
```

Optional styling (all of these can be left out):

| Field | Notes |
|-------|--------|
| `icon` | FA name, `{ 'fas', 'gem' }`, or `false` |
| `iconColor` / `iconAnimation` / `iconSize` | e.g. `beat`, `spin`, `pulse` |
| `hideIcon` / `alignIcon` | |
| `showDuration` / `durationColor` | progress strip on the toast |
| `backgroundColor` / `color` / `descriptionColor` | |
| `borderColor` / `borderWidth` / `borderRadius` | |
| `width` / `padding` / `opacity` / `shadow` | `shadow = false` to disable |
| `fontFamily` / `titleFontSize` / `descriptionFontSize` / `titleFontWeight` | |
| `style` | raw CSS table — wins over the rest |

### Progress

```lua
if vu.progressBar({
    label = 'Searching...',
    duration = 5000,
    canCancel = true,
    disable = { move = true },
}) then
    -- finished
end

vu.progressCircle({ label = 'Lockpicking', duration = 3000, position = 'middle' })

vu.cancelProgress()
vu.progressActive() -- bool
```

### TextUI

```lua
vu.showTextUI('[E] Open door', { position = 'right-center', icon = 'hand' })
vu.hideTextUI()
vu.isTextUIOpen()
```

---

## CreatePed

Resource exports (not a `vu_libs { }` module):

```lua
exports.vu_libs:AddNPCPed('shop_npc', 'a_m_m_business_01', vector3(0.0, 0.0, 0.0), {
    spawnHeading = 90.0,
    distance = 30.0,
    onSpawn = function(ped)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
    end,
})

exports.vu_libs:RemoveNPCPed('shop_npc')
exports.vu_libs:GetNPCPed('shop_npc')
```

Spawns/despawns by proximity (chunk grid). Optional `canSpawn` callback if you need extra gates.

---

## Other modules

### print

```lua
vu.print.info('loaded')
vu.print.warn('something off')
vu.print.error('failed', err)
vu.print.debug({ a = 1 }) -- tables get json-encoded
```

Convars: `vu:printlevel` or `vu:printlevel:<resource>` → `error` | `warn` | `info` | `verbose` | `debug` (default `info`).

### table / math / string

These extend the globals when loaded (`table.*`, `math.*`, `string.*`), also mirrored on `vu`.

```lua
table.contains(t, value)
table.merge(a, b)
table.deepclone(t)
table.count(t)

math.clamp(n, min, max)
math.lerp(a, b, t)
math.round(n, 2)

string.split(s, ',')
string.trim(s)
string.interpolate('Hi {name}', { name = 'Vex' })
```

### timeout

```lua
local id = vu.timeout(5000, function()
    -- ...
end)

vu.timeout.clear(id)
```

### cooldown (server)

```lua
vu.cooldown.set(source, 'robbery', 60)
if vu.cooldown.has(source, 'robbery') then return end
local left = vu.cooldown.remaining(source, 'robbery')
vu.cooldown.clear(source, 'robbery')
```

### request (client)

```lua
vu.request.model(`adder`)
vu.request.animDict('amb@world_human_hang_out_street@male_c@idle_a')
vu.request.ptfx('core')
```

### blips (client)

```lua
local blip = vu.blips.add({
    coords = vector3(0.0, 0.0, 0.0),
    sprite = 1,
    color = 1,
    scale = 0.8,
    label = 'Spot',
})

vu.blips.remove(blip)
vu.blips.clear()
```

### random

```lua
vu.random.int(1, 10)
vu.random.choice({ 'a', 'b', 'c' })
vu.random.weighted({ { item = 'common', weight = 70 }, { item = 'rare', weight = 30 } })
vu.random.shuffle(list)
```

### cache (client)

Updated every tick-ish: `ped`, `vehicle`, `seat`, `weapon`, plus `playerId` / `serverId`.

```lua
local ped = cache.ped
-- or
local vehicle = vu.cache('vehicle')
```

---

## Module map

| Module | Side | Notes |
|--------|------|--------|
| `callback` | both | client ↔ server RPC |
| `print` | shared | leveled console output |
| `table` | shared | contains, merge, deepclone, … |
| `timeout` | shared | cancellable `SetTimeout` |
| `cooldown` | server | per-player action locks |
| `isadmin` | both | ESX admin check |
| `request` | client | model / anim / ptfx loaders |
| `math` | shared | clamp, lerp, round, … |
| `string` | shared | split, trim, interpolate, … |
| `blips` | client | add / remove map blips |
| `random` | shared | choice, weighted, shuffle |
| createped | export | proximity NPC grid |
| notify | client + server | toasts |
| progress | client | bar + circle |
| textui | client | key hint overlay |

---

## Notes

- Don't `@vu_libs/init.lua` twice in the same resource.
- `vu_libs` must already be `started` when a consumer boots, or init will error.
- NUI build (`web/build/index.html`) is required at runtime — missing it = lib won't report loaded.
