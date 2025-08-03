fx_version 'cerulean'
game 'gta5'

author 'Goner'
description 'Disnaker Price Adjustment System'
version '1.0.0'

shared_scripts {
    'shared/config.lua',
    'shared/utils.lua'
}

client_scripts {
    'client/client.lua',
    'client/ui.lua'
}

server_scripts {
    'server/server.lua',
    'server/database.lua',
    'server/price_adjustment.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/img/*.png'
}
