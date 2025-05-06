fx_version 'cerulean'
game 'gta5'

author 'Xandrex'
description 'Mission Script'
version '1.0.0'
lua54 'yes'


shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'ox_lib',
    'ox_inventory',
    'ox_target'
}