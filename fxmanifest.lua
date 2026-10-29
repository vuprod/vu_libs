fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'vu_libs'
author 'VU'
description 'VU shared libraries (callback, createped, notify, progress, textui)'
version '1.1.0'

ui_page 'web/build/index.html'

files {
    'init.lua',
    'modules/**/*.lua',
    'web/build/index.html',
    'web/build/**/*',
}

shared_scripts {
    'resource/init.lua',
    'resource/**/shared.lua',
}

client_scripts {
    'resource/client.lua',
    'resource/cache/client.lua',
    'resource/createped/client.lua',
    'resource/interface/client/*.lua',
}

server_scripts {
    'resource/server.lua',
    'resource/interface/server/*.lua',
}
