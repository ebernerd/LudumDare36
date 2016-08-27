--texture handler

textures = { }

--setup all da textures HERE
local function getTextures( dir )
	for i, v in pairs( love.filesystem.getDirectoryItems(dir) ) do
		if love.filesystem.isDirectory( dir .. "/" .. v ) then
			getTextures( dir .. "/" .. v )
		else
			textures[dir:sub(-10).."/"..v:sub(1,-5)] = love.graphics.newImage( dir .. "/" ..v )
			textures[dir:sub(-10).."/"..v:sub(1,-5)]:setFilter("nearest", "nearest")
			print( "[texture-handler] Loading image \"" .. v .. "\" to \"" ..dir:sub(-10).."/"..v:sub(1,-5).."\" ... [OK]")
		end
	end
end

getTextures("assets/img")