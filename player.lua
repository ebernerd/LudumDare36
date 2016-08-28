player = {
	x = 0,
	y = 0,
	dy = 0,
	h = 7,
	w = 6,
	hp = 100,
	stamina = 100,
	xvel = 0,
	yvel = 0,
	speed = 6,
	filter = function( item, other )
		return "slide"
	end,
	zoom = 8,
	dir = "right",
	canMove = true,
	animtimer = 0,
	anim = 0,
	inv = { },
	weapon = {
		name="hand",
		range = 6,
		damage = 2,
		cooldown = 0.5,
	},
	attackCooldown = 0,
	canAttack = true,
	coins = 0,
}

local zoomin = tween.new( 0.3, player, {zoom=6}, "inOutExpo")
local zooming = false
local maskColour = {255, 255, 255}

local findto
local findback
local findingto = false
local findingback = false
local findingwait = 0
local findingt = false
local canzoom = true

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

		if player.inv[1] and player.inv[1].type == "weapon" then
			player.weapon = player.inv[1].weapon
		end

		if zooming and canzoom then
			local complete = zoomin:update( dt )
			if complete then
				zooming = false
				if player.zoom == 6 then
					zoomin = tween.new( 0.3, player, {zoom=8}, "inOutExpo")
				elseif player.zoom == 8 then
					zoomin = tween.new( 0.3, player, {zoom=6}, "inOutExpo")
				end
			end
		end

		if not player.canAttack then
			player.attackCooldown = player.attackCooldown + dt
			if player.attackCooldown > player.weapon.cooldown then
				player.canAttack = true
				player.attackCooldown = 0
			end
		end

		if love.keyboard.isDown( controls.left, controls.right, controls.up, controls.down ) and player.canMove then
			player.animtimer = player.animtimer + dt
			if player.animtimer > 0.2 then
				if player.anim > 0 then
					player.anim = 0
				else
					player.anim = 1
				end
				player.animtimer = 0
			end
		else
			player.anim = 0
			player.animtimer = 0
		end

		if player.canMove then
			if love.keyboard.isDown( controls.up ) then
				ddy = -player.speed
			elseif love.keyboard.isDown( controls.down ) then
				ddy = player.speed
			end
			if love.keyboard.isDown( controls.left ) then
				ddx = -player.speed
				player.dir = "left"
			elseif love.keyboard.isDown( controls.right ) then
				ddx = player.speed
				player.dir = "right"
			end
		end

		player.xvel = (player.xvel + ddx) * 0.8
		player.yvel = (player.yvel + ddy) * 0.8

		if world:hasItem( player ) then

			player.x, player.y, cols, len = world:move( player, (player.x + player.xvel*dt), (player.y + player.yvel*dt) )

		end

		if player.canMove then
			camera.x = player.x*player.zoom - love.graphics.getWidth()/2 + (player.w*player.zoom)/2
			camera.y = player.y*player.zoom - love.graphics.getHeight()/2 + (player.h*player.zoom)/2
		end
		if findingto then
			canzoom = false
			local complete = findto:update( dt )
			if complete then
				findingt = true
				findingto = false
				sounds['found-item']:play()
			end
		end
		if findingt then
			canzoom = false
			findingwait = findingwait + dt
			if findingwait > 2 then
				findingback = true
				findingt = false
				findingwait = 0
			end
		end
		if findingback then
			canzoom = false
			local complete = findback:update( dt )
			if complete then
				findingback = false
				player.canMove = true
				findback:reset()
				findto:reset()
				canzoom = true
			end
		end
		

	end

end

function player.find( obj )
	local x = obj.x
	local y = obj.y
	findingto = true
	obj.found = true
	findto = tween.new( 2, camera, {x=x*player.zoom-love.graphics.getWidth()/2 + (obj.w*player.zoom)/2, y=y*player.zoom-love.graphics.getHeight()/2+(obj.h*player.zoom)/2}, "inOutExpo")
	findback = tween.new( 2, camera, {x=player.x*player.zoom - love.graphics.getWidth()/2 + (player.w*player.zoom)/2, y= player.y*player.zoom - love.graphics.getHeight()/2 + (player.h*player.zoom)/2}, "inOutExpo")
end

function player.draw()
	--[=[local mx, my = love.mouse.getPosition()
	if mx >= player.x*player.zoom - camera.x and mx <= player.x*player.zoom + player.w*player.zoom - camera.x and my >= player.y*player.zoom-camera.y and my <= player.y*player.zoom+player.h*player.zoom-camera.y then
		love.graphics.setColor( 0, 0, 255 )
		love.graphics.rectangle( "line", player.x-2, player.y-2, player.w+4, player.h+4 )
		love.graphics.setColor( 255, 255, 255 )
	end--]=]
	if player.inv[1] and player.inv[1].texture then
		love.graphics.draw( textures[player.inv[1].texture], player.x+3, player.y-2-player.anim )
	end
	love.graphics.draw( textures["g/textures/player-"..player.dir], player.x, player.y-3-player.anim )
	if game.debug then
		love.graphics.setColor( 255, 0, 0 )
		love.graphics.rectangle('line', wgx, wgy, wgw, wgh )
		local x, y, w, h = world:getRect( player )
		love.graphics.rectangle("line", x, y, w, h )
		love.graphics.setColor( 255, 255, 255 )
	end
	love.graphics.setColor( 255, 255, 255 )
end

function player.keyreleased( key )
	if key == controls.zoom then
		zooming = true
	elseif key == "space" then
		--aihandler.new( {x=player.x + math.random(-100, 100), y=player.y + math.random(-100, 100)})
	end
end
wgx, wgy, wgw, wgh = 0,0,0,0
function player.attack( dir )
	if player.canAttack then
		player.canAttack = false
		wgw, wgh = player.weapon.range, player.weapon.range
		if dir == "top" then
			wgx = player.x + player.w/2 - player.weapon.range/2
			wgy = player.y-player.weapon.range-3-player.anim
		elseif dir == "bottom" then
			wgx = player.x + player.w/2 - player.weapon.range/2
			wgy = player.y + player.h
		elseif dir == "topleft" then
			wgx = (player.x + player.w/2 - player.weapon.range/2) - player.weapon.range
			wgy =  player.y-player.weapon.range-3-player.anim
		elseif dir == "topright" then
			wgx = (player.x + player.w/2 - player.weapon.range/2) + player.weapon.range
			wgy =  player.y-player.weapon.range-3-player.anim
		elseif dir == "bottomleft" then
			wgx = (player.x + player.w/2 - player.weapon.range/2) - player.weapon.range
			wgy = player.y + player.h
		elseif dir == "bottomright" then
			wgx = (player.x + player.w/2 - player.weapon.range/2) + player.weapon.range
			wgy = player.y + player.h
		elseif dir == "left" then
			wgx = player.x - player.weapon.range
			wgy = player.y
		elseif dir == "right" then
			wgx = player.x + player.w + player.weapon.range
			wgy = player.y
		end

		local items, len = world:queryRect(wgx, wgy, wgw, wgh, function() return "slide" end )
		if len > 0 then
			for i, v in pairs( items ) do
				if v.hp and v ~= self then
					local dm = (love.math.random(2,3)*player.weapon.damage)
					v.hp = v.hp - dm
					sounds["hurt"]:stop()
					sounds['hurt']:play()
					notif.new(v.x, v.y, "-" .. tostring(dm), { 255, 0, 0 }, 8)
				end
			end
		end
	end
end


function player.mousereleased( x, y )
	local sx = love.graphics.getWidth()/2
	local sy = love.graphics.getHeight()/2
	local angle = math.atan2( x - sx, y - sy )
	angle = angle * (180/math.pi) + 180
	if angle < 22.5 or angle > 337.5 then
		player.attack("top")
	elseif angle < 337.5 and angle > 292.5 then
		player.attack("topright")
	elseif angle < 292.5 and angle > 247.5 then
		player.attack("right")
	elseif angle < 247.5 and angle > 202.5 then
		player.attack("bottomright")
	elseif angle < 202.5 and angle > 157.5 then
		player.attack("bottom")
	elseif angle < 157.5 and angle > 112.5 then
		player.attack("bottomleft")
	elseif angle < 112.5 and angle > 67.5 then
		player.attack('left')
	elseif angle < 67.5 and angle > 22.5 then
		player.attack("topleft")
	end
end