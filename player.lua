player = {
	x = 0,
	y = 0,
	dy = 0,
	h = 20,
	w = 8,
	hp = 100,
	xvel = 0,
	yvel = 0,
	speed = 10,
	filter = function( item, other )
		return "slide"
	end,
	zoom = 4,
}

local zoomin = tween.new( 0.3, player, {zoom=6}, "inOutExpo")
local zooming = false
local maskColour = {255, 255, 255}

function player.reset()
	player.x = 0
	player.y = 0
	player.hp = 100
	player.yvel = 0
	player.xvel = 0

	if world:hasItem(player) then
		world:remove( player )
	end
	world:add(player, player.x, player.y, player.w, player.h)
	print( "[player] Player reset called... [OK]" )
end

function player.update( dt )

	if gamestate == "Game" then
		local ddx = 0
		local ddy = 0

		if zooming then
			local complete = zoomin:update( dt )
			if complete then
				zooming = false
				if player.zoom == 4 then
					zoomin = tween.new( 0.3, player, {zoom=6}, "inOutExpo")
				elseif player.zoom == 6 then
					zoomin = tween.new( 0.3, player, {zoom=2}, "inOutExpo")
				elseif player.zoom == 2 then
					zoomin = tween.new( 0.3, player, {zoom=4}, "inOutExpo")
				end
			end
		end

		if love.keyboard.isDown( controls.up ) then
			ddy = -player.speed
		elseif love.keyboard.isDown( controls.down ) then
			ddy = player.speed
		end
		if love.keyboard.isDown( controls.left ) then
			ddx = -player.speed
		elseif love.keyboard.isDown( controls.right ) then
			ddx = player.speed
		end

		player.xvel = (player.xvel + ddx) * 0.8
		player.yvel = (player.yvel + ddy) * 0.8

		if world:hasItem( player ) then

			player.x, player.y, cols, len = world:move( player, (player.x + player.xvel*dt), (player.y + player.yvel*dt) )

		end

		camera.x = player.x*player.zoom - love.graphics.getWidth()/2 + (player.w*player.zoom)/2
		camera.y = player.y*player.zoom - love.graphics.getHeight()/2 + (player.h*player.zoom)/2

		

	end

end

function player.draw()
	--[=[local mx, my = love.mouse.getPosition()
	if mx >= player.x*player.zoom - camera.x and mx <= player.x*player.zoom + player.w*player.zoom - camera.x and my >= player.y*player.zoom-camera.y and my <= player.y*player.zoom+player.h*player.zoom-camera.y then
		love.graphics.setColor( 0, 0, 255 )
		love.graphics.rectangle( "line", player.x-2, player.y-2, player.w+4, player.h+4 )
		love.graphics.setColor( 255, 255, 255 )
	end--]=]
	love.graphics.draw( textures["g/textures/player"], player.x, player.y )
	love.graphics.setColor( 255, 255, 255 )
end

function player.keyreleased( key )
	if key == "z" then
		zooming = true
	end
end