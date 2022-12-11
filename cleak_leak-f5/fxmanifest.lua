fx_version 'cerulean'

games { 'gta5' }

shared_script {
    'shared.lua'
}

client_scripts {
    'RUIv3/RageUI.lua',
    'RUIv3/Menu.lua',
    'RUIv3/MenuController.lua',
    'RUIv3/components/*.lua',
    'RUIv3/elements/*.lua',
    'RUIv3/items/*.lua',
    'client.lua',
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server.lua'
}