--MAP!

map = { } -- for map functions

map.world = { } --for world items

local worlditem = {
	x = 0,
	y = 0,
	w = 16,
	h = 16,
	name = "unidentified",
	animated = false,
	img = "g/textures/unidentified",
	onclick = function(self)
		mb.showMessage( "Ancient Relic Found.", "You come across a stone with an eerie blue glow. It has a language foreign you sprawled all across it, with some of the symbols looking somewhat familiar - a possible cloud, and lightning bolt")
	end,
	update = function ( self, dt )

	end,
	draw = function( self )
		if gamestate == "Game" then
			local mx, my = love.mouse.getPosition()
			if (not MessageBoxShown) and mx >= self.x*player.zoom - camera.x and mx <= self.x*player.zoom + self.w*player.zoom - camera.x and my >= self.y*player.zoom-camera.y and my <= self.y*player.zoom+self.h*player.zoom-camera.y then
				love.graphics.setColor( 81, 255, 5 )
				love.graphics.rectangle( "line", self.x-2, self.y-2, self.w+4, self.h+4 )
				love.graphics.setColor( 240, 255, 240 )
			end
			if self.animated then
				Animations.draw( self.anim, self.x, self.y )
			else
				love.graphics.draw( textures[self.img], self.x, self.y )
			end
			love.graphics.setColor( 255, 255, 255 )
		end
	end,
	mousereleased = function( self, mx, my )
		if mx >= self.x*player.zoom - camera.x and mx <= self.x*player.zoom + self.w*player.zoom - camera.x and my >= self.y*player.zoom-camera.y and my <= self.y*player.zoom+self.h*player.zoom-camera.y then
			if self.onclick then self.onclick() end
		end
	end,

}
worlditem.__index = worlditem

function worlditem:new( data )
	local data = data or { }
	local self = setmetatable( data, worlditem )
	self.__index = self
	table.insert( map.world, self )
	return self
end

local function gen( area )
	if area == "overworld" then
		print( "[map] Generating level \"" .. area .. "\"..." )
		worlditem:new( {x=10,y=10, animated=true, anim=RelicAnim })


		print( "[map] Generation done! [OK]" )
	end
end

function map.update( dt )
	for i, v in pairs( map.world ) do
		if v.update then v:update( dt ) end
	end
end

function map.draw( dt )
	for i, v in pairs( map.world ) do
		if v.draw then v:draw() end
	end
end

function map.mousereleased( x, y, button )
	for i, v in pairs( map.world ) do
		if v.mousereleased then v:mousereleased( x, y, button ) end
	end
end


gen("overworld")
