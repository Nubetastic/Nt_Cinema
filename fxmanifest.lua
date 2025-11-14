games { 'rdr3' }

fx_version 'Nubetastic'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

shared_scripts { 'shared/config.lua', 'shared/ticketConfig.lua', 'shared/ticketAddon.lua' }

client_scripts {
	'client/config.lua',
    'client/main.lua',
	'client/vendor.lua',
	'client/sync.lua'
}

server_scripts {
	'client/config.lua',
	'server/main.lua',
	'server/core.lua',
}

exports { 'StartShow' }