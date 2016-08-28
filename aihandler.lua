--ai?

aihandler = { }
local ais = { }
local ai = {
	x = 100,
	y = 100,
	goals = {
		"follow",
		"attack",
	},
	w = 6,
	h = 7,
	speed = 14,
	xvel = 0,
	yvel = 0,
	name = "soldier",
	hp = 50,
	maxhp = 50,
	dir = "right",
	canattack = true,
	attackcooldown = 0,
	wgx = 0,
	wgy = 0,
	wgw = 0,
	wgh = 0,
}
ai.__index = ai

function ai:new( data )
	local data = data or { }
	local self = setmetatable( data, ai )
	self.sx = self.x
	self.sy = self.y
	if love.math.random(1,4) == 1 then
		self.weapon = gameitems["Short Sword"].weapon
	else
		self.weapon = {
			name="hand",
			range = 4,
			damage = 2,
			cooldown = 0.5,
		}
	end
	self.__index = self
	self.jumptimer = 0
	self.anim = 0
	self.direction = "right"
	table.insert( ais, self )
	world:add(self, self.x, self.y, self.w, self.h)
	return self
end

function ai:attack( dir )
	if self.canattack then
		self.canattack = false
		self.wgx, self.wgy, self.wgw, self.wgh = 0,0,0,0
		self.wgw, self.wgh = self.weapon.range, self.weapon.range
		if dir == "top" then
			self.wgx = self.x + self.w/2 - self.weapon.range/2
			self.wgy = self.y-self.weapon.range-3-self.anim
		elseif dir == "bottom" then
			self.wgx = self.x + self.w/2 - self.weapon.range/2
			self.wgy = self.y + self.h
		elseif dir == "topleft" then
			self.wgx = (self.x + self.w/2 - self.weapon.range/2) - self.weapon.range
			self.wgy =  self.y-self.weapon.range-3-self.anim
		elseif dir == "topright" then
			self.wgx = (self.x + self.w/2 - self.weapon.range/2) + self.weapon.range
			self.wgy =  self.y-self.weapon.range-3-self.anim
		elseif dir == "bottomleft" then
			self.wgx = (self.x + self.w/2 - self.weapon.range/2) - self.weapon.range
			self.wgy = self.y + self.h
		elseif dir == "bottomright" then
			self.wgx = (self.x + self.w/2 - self.weapon.range/2) + self.weapon.range
			self.wgy = self.y + self.h
		elseif dir == "left" then
			self.wgx = self.x - self.weapon.range
			self.wgy = self.y
		elseif dir == "right" then
			self.wgx = self.x + self.w + self.weapon.range
			self.wgy = self.y
		end

		local items, len = world:queryRect(self.wgx, self.wgy, self.wgw, self.wgh, function() return "slide" end )
		if len > 0 then
			for i, v in pairs( items ) do
				if v == player then
					local dm = (love.math.random(2,3)*self.weapon.damage)
					player.hp = player.hp - dm
					notif.new(player.x, player.y, "-" .. dm, { 255, 0, 0 })
					sounds['hurt']:stop()
					sounds['hurt']:play()
					UI.show()
				end
			end
		end
	end
end



function ai:update( dt )
	if player.canMove then
		for i = 1, #self.goals do
			if self.goals[i] == "follow" then
				local dist = math.abs(math.sqrt((self.x-player.x)^2 + (self.y-player.y)^2))
				if dist < 100 and self.x and self.y then
					local angle = math.atan2((player.y - self.y), (player.x - self.x))
					self.xvel = self.speed * math.cos(angle)
					self.yvel = self.speed * math.sin(angle)
				end
			elseif self.goals[i] == "attack" then
				local dist = math.abs(math.sqrt((self.x-player.x)^2 + (self.y-player.y)^2))
				if dist <= self.weapon.range*(player.zoom/2) then
					local angle = math.atan2( player.x - self.x, player.y - self.y )
					angle = angle * (180/math.pi) + 180
					if angle < 22.5 or angle > 337.5 then
						self:attack("top")
					elseif angle < 337.5 and angle > 292.5 then
						self:attack("topright")
					elseif angle < 292.5 and angle > 247.5 then
						self:attack("right")
					elseif angle < 247.5 and angle > 202.5 then
						self:attack("bottomright")
					elseif angle < 202.5 and angle > 157.5 then
						self:attack("bottom")
					elseif angle < 157.5 and angle > 112.5 then
						self:attack("bottomleft")
					elseif angle < 112.5 and angle > 67.5 then
						self:attack('left')
					elseif angle < 67.5 and angle > 22.5 then
						self:attack("topleft")
					end
				end
			end
		end
		if self.xvel > 0 then
			self.dir = "right"
		else
			self.dir = "left"
		end
		if not self.canattack then
			self.attackcooldown = self.attackcooldown + dt
			if self.attackcooldown > self.weapon.cooldown then
				self.canattack = true
				self.attackcooldown = 0
			end
		end

		if math.abs(self.xvel) > 0.1 or math.abs(self.xvel) > 0.1 then
			if self.jumptimer then
				self.jumptimer = self.jumptimer + dt
				if self.jumptimer > 0.2 then
					if self.anim == 1 then
						self.anim = 0
					else
						self.anim = 1
					end
					self.jumptimer = 0
				end
			end
		end

		if self.hp <= 0 then
			for i, v in pairs( ais ) do
				if v == self then
					local c = love.math.random( 13, 88 )
					player.coins = player.coins + c
					notif.new( self.x, self.y, "+" .. c .. " coins!", { 255, 255, 0 })
					UI.show()
					table.remove( ais, i )
					world:remove(self)
					self = nil
				end
			end
		end

		if world and world:hasItem(self) then
			self.x, self.y, cols, len = world:move( self, self.x + self.xvel*dt, self.y + self.yvel*dt )
		end
	end
end

function ai:draw()
	love.graphics.draw( textures["g/textures/"..self.name .. "-" .. self.dir], self.x, self.y-3-self.anim )
	love.graphics.setColor( 255, 0, 0 )
	love.graphics.rectangle("fill", self.x - self.w/4, self.y-9, 10*(self.hp/self.maxhp), 2)
	love.graphics.setColor( 255, 255, 255 )
	if game.debug then
		love.graphics.setColor( 255, 0, 0 ) 
		if world:hasItem( self ) then
			local x, y, w, h = world:getRect( self )
			love.graphics.rectangle("line", x, y, w, h )
			love.graphics.setColor( 255, 255, 255 )
		end
	end
	if self.weapon then
		if self.weapon.name == "hand" then
			--
		else
			love.graphics.draw( textures[self.weapon.texture], self.x+3, self.y-2-self.anim )
		end
	end
	--love.graphics.rectangle( "line", self.wgx, self.wgy, self.wgw, self.wgh )
end

function ai:mousereleased( x, y )

end

function aihandler.update( dt )
	for i, v in pairs( ais ) do
		if v.update then v:update( dt ) end
	end
end

function aihandler.draw()
	for i, v in pairs( ais ) do
		if v.draw then v:draw() end
	end
end

function aihandler.new( data )
	return ai:new( data )
end

function aihandler.mousereleased( x, y )
	for i, v in pairs( ais ) do
		if v.mousereleased then v:mousereleased( x, y ) end
	end
end

function aihandler.getAI()
	return ais
end