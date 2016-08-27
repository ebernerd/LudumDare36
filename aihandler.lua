--ai?

aihandler = { }
local ais = { }
local ai = {
	x = 100,
	y = 100,
	goals = {
		"follow",
	},
	w = 6,
	h = 7,
	speed = 14,
	xvel = 0,
	yvel = 0,
	name = "soldier",
	hp = 50,
	maxhp = 50,
	dir = "right"
}
ai.__index = ai

function ai:new( data )
	local data = data or { }
	local self = setmetatable( data, ai )
	self.sx = self.x
	self.sy = self.y
	self.__index = self
	self.jumptimer = 0
	self.anim = 0
	self.direction = "right"
	table.insert( ais, self )
	world:add(self, self.x, self.y, self.w, self.h)
	return self
end

function ai:update( dt )
	if player.canMove then
		for i = 1, #self.goals do
			if self.goals[i] == "follow" then
				local dist = math.abs(math.sqrt((self.x-player.x)^2 + (self.y-player.y)^2))
				if dist < 100 then
					local angle = math.atan2((player.y - self.y), (player.x - self.x))
					self.xvel = self.speed * math.cos(angle)
					self.yvel = self.speed * math.sin(angle)
				end
			elseif self.goals[i] == "attack" then

			end
		end
		if self.xvel > 0 then
			self.dir = "right"
		else
			self.dir = "left"
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