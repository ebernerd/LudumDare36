--sound manager

sounds = { }
print("[sound-manager] Loading sounds...")
for i, v in pairs( love.filesystem.getDirectoryItems("assets/sound/") ) do
	print( "[sound-manager] Loading sound \"" .. v:sub(1,-5) .. "\"")
	sounds[v:sub(1,-5)] = love.audio.newSource( "assets/sound/" .. v )
end
print("[sound-manager] Sounds loaded!")