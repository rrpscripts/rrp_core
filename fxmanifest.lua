fx_version 'cerulean'
game 'gta5'

name "rrp_core"
description "..."
author "erik363"
version "1.0.0"
lua54 'yes'

shared_scripts {
	'config.lua'
}

client_scripts {
	'modules/Streaming/Streaming.lua',
	'modules/Spawn/c_spawn.lua',
	'modules/Bridge/Inventory/c_bridge_inv.lua',
	--'modules/Bridge/Banking/c_bridge_banking.lua',
	'modules/Sync/c_sync.lua',
	'modules/Bridge/Target/c_bridge_target.lua',
	'modules/Bridge/Notify/c_bridge_notify.lua',
}

server_scripts {
	'modules/Spawn/s_spawn.lua',
	'modules/Bridge/Inventory/s_bridge_inv.lua',
	'modules/Bridge/Banking/s_bridge_banking.lua',
	'modules/Sync/s_sync.lua',
	'modules/Bridge/Notify/s_bridge_notify.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
}
