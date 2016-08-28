--MAP!

map = { } -- for map functions

map.world = {
	bg = { },
	fg = { },
	mg = { }
} --for world items


local commonloot = {
	"Short Sword",
	"Healing Potion",
	"Healing Potion",
	"Coins",
	"Coins",
}
local uncommonloot = {
	"Coins",
	"Revive",
	"Coins"
}
local rareloot = {
	"Ancient Axe of Destruction",
	"Coins",
}
gameitems = {
	["Short Sword"] = {
		texture = "g/textures/item-sword-hand",
		tooltip = "g/textures/item-sword",
		weapon = {
			range = 6,
			damage = 4,
			cooldown = 0.4,
			texture = "g/textures/item-sword-hand",
		},
		type = "weapon",
	},
	["Ancient Axe of Destruction"] = {
		texture = "g/textures/item-axeofdest-hand",
		tooltip = "g/textures/unidentified",
		weapon = {
			range = 15,
			damage = 9,
			cooldown = 1,
		},
		type = "weapon",
	}
}

local messages = {
	[1] = {
		found = false,
		m = "Inside this box is a tale from long, long ago in a language you don't quite understand. Symbols and pictures sprawl across the pages, and you come to realize that the author is speaking of the eternal downpour your ancestors rambled on about before.\n\nYou will now understand some the language on the Rain Stone."
	}
}

Vocab = { }
Vocab.unknown = {
	["kwerzcyka"] = "light",
	["amorella"] = "beam",
	["grentabulaa"] = "sky",
	
	["fendikila"] = "wet",
	["Kellczya"] = "Kelzian",
	["Kellczyi"] = "Kelzi",
	["onovello"] = "dark",
	["buro"] = "fall",
	["andobikulo"] = "alone"
}
Vocab.known = {  }
Vocab.pages = {
	["kwerzcyka"] = "Stories go on and on about a forever dimming 'kwerzycka', whatever that was. You read on and find that the world was removed of it's 'kwerzycka', where no one was able to see themselves, or their future.\n\n\nYou've learned the Kelzi word for 'light'.\n\n\nPress return or escape",
	["amorella"] = "The tattered pages explain a world of hope, dreams, and adventure, before... well, the page is ripped past there. We'll have to find that out another day.\n\n\nYou've learned the Kelzi word for 'beam'.\n\n\nPress return or escape",
	["grentabulaa"] = "This book goes on and on about this... thing, opening up peoples lives, until it itself opened up and ruined everyone's hopes and dreams. Lives were destroyed.\n\n\nYou've learned the Kelzi word for 'sky'.\n\n\nPress return or escape",
	["onovello"] = "Fables go on about, how, in small doses, 'onovello' is good for the soul. This does not include, however, the terrible darkness that the world has been plagued into.\n\n\nYou've learned the Kelzi word for 'dark'.\n\n\nPress return or escape",
	["other"] = "I stare upon the pages and read about an ancient people, and their fantastic world. Fantastic, that is, until the day it all changed, where stories go from happy to incredibly dark. One can only imagine their torment.\n\n\nYou've learned the Kelzi word for ",
}



local worlditem = {
	x = 0,
	y = 0,
	w = 16,
	h = 16,
	col = {
		y = 0,
		x = 0,
		w = 16,
		h = 16,
	},
	hascolliders = false,
	layer = "mg",
	name = "unidentified",
	animated = false,
	img = "g/textures/unidentified",
	draw = function( self )
		if gamestate == "Game" then
			if self.onclick then
				local mx, my = love.mouse.getPosition()
				if (not MessageBoxShown) and mx >= self.x*player.zoom - camera.x and mx <= self.x*player.zoom + self.w*player.zoom - camera.x and my >= self.y*player.zoom-camera.y and my <= self.y*player.zoom+self.h*player.zoom-camera.y then
					love.graphics.setColor( 81, 255, 5 )
					love.graphics.rectangle( "line", self.x-2, self.y-2, self.w+4, self.h+4 )
					love.graphics.setColor( 240, 255, 240 )
				end
			end
			if self.animated then
				Animations.draw( self.anim, self.x, self.y )
			else
				love.graphics.draw( textures[self.img], self.x, self.y )
				if self.name == "tree" then
				end
			end
			if game.debug and self.hascolliders and world:hasItem( self ) then
				love.graphics.setColor( 255, 0, 0 )
				local x, y, w, h = world:getRect( self )
				love.graphics.rectangle("line", x, y, w, h )
				love.graphics.setColor( 255, 255, 255 )
			end
			love.graphics.setColor( 255, 255, 255 )
		end
	end,
	mousereleased = function( self, mx, my )
		if mx >= self.x*player.zoom - camera.x and mx <= self.x*player.zoom + self.w*player.zoom - camera.x and my >= self.y*player.zoom-camera.y and my <= self.y*player.zoom+self.h*player.zoom-camera.y then
			if self.onclick then self:onclick() end
		end
	end,

}
worlditem.__index = worlditem

local draworder = { }

function worlditem:new( data )
	local data = data or { }
	local self = setmetatable( data, worlditem )
	self.__index = self
	table.insert( map.world[self.layer], self )
	if self.hascolliders then
		world:add( self, self.x+self.col.x, self.y+self.col.y, self.col.w, self.col.h )
	end
	return self
end

local function makedraworder()
	table.sort( map.world.mg, function(a, b) return a.y < b.y end)
end

function getPos(x,y,l,np)
	local x = x or love.math.random( -50, 50 )*16
	local y = y or love.math.random( -50, 50 )*16
	local layer = l or "mg"
	local dist = math.abs(math.sqrt((y-player.y)^2 + (x-player.x)^2))
	if dist < 100 and np then
		x, y = getPos()
	else
		for _, l in pairs( map.world ) do
			for i, v in pairs( l ) do
				if v then
					--print( v.x == x and v.y == y )
					if layer == v.layer and v.x == x and v.y == y then
						x, y = getPos()
					end
				end
			end
		end
	end
	return x, y
end

local function genBackdrop()
	--[=[local img = img or "g/textures/grass"
	if not map.backdrop then map.backdrop = love.graphics.newCanvas( 10000, 10000 ) end
	map.backdrop:setFilter("nearest", "nearest")
	love.graphics.setCanvas(map.backdrop)
	for y = 1, 100 do
		for x = 1, 100 do
			love.graphics.draw( textures[img], (x-51)*16, (y-51)*16 )
		end
	end
	love.graphics.setCanvas()--]=]
	for y = 1, 101 do
		for x = 1, 101 do
			worlditem:new( {
				x = (x-51)*16,
				y = (y-51)*16,
				img = "g/textures/grass",
				layer="bg"
			} )
		end
	end
end


local function gen( area )
	if area == "overworld" then
		--genBackdrop()
		print( "[map] Generating level \"" .. area .. "\"..." )
		for i = 1, love.math.random( 2500, 2800 ) do
			local haspos = false
			local x, y = getPos()
			worlditem:new( {x=x,y=y,name="tree", img="g/textures/tree"..tostring(love.math.random(1,2)), hascolliders = true, col={
				x = 4,
				y = 10,
				w = 8,
				h = 6,
			}})
		end



		for i = 1, love.math.random( 5, 7 ) do
			local x, y = getPos()
			worlditem:new( {cost=10,x=x,y=y,name="summonstone", anim=SSAnim, animated=true,
				onclick = function(self)
					if player.coins >=  self.cost then
						player.coins = player.coins - self.cost
						self.cost = self.cost + 5
						sounds["coin"]:stop()
						sounds["coin"]:play()
						aihandler.new( {name="soldier"..love.math.random(1,2),x = self.x + love.math.random(-2,2)*player.zoom, y=self.y + love.math.random(-2,2)*player.zoom})
						notif.new(self.x-30, self.y, "Summoning...", {255, 255, 255}, 8)
					else
						notif.new(self.x-45, self.y, "Not enough money", {255, 255, 255}, 8)
						sounds['nomoney']:stop()
						sounds['nomoney']:play()
					end
				end
			})
		end


		--Spawn Rain Stone first
		local x, y = getPos()
		for i = 1, love.math.random( 10, 14 ) do
			aihandler.new( {name="soldier"..love.math.random(1,2),x=x+love.math.random(-4, 4)*16, y = y+love.math.random(-4,4)*16})
		end
		worlditem:new( {x=x,y=y, name="relic", anim=RelicAnim, animated = true, found=false,
		update = function( self, dt )
			if player.x < self.x + self.w + 100 and player.x + player.w > self.x - 100 and player.y < self.y + self.h + 100 and player.y + player.h > self.y - 100 then
				if not self.found then
					self.found = true
					player.find( self )
					chordtimer = 0
					chordwait = love.math.random( 15, 30 )
					player.canMove = false
				end
			end
		end,
		onclick = function( self )
			local str = ""
			local words = {
				"buro",
				"fendikila",
				"onovello",
				"andobikulo",
				"Kellczya",
			}
			local l = 0
			for i, v in pairs( words ) do
				if Vocab.known[v] then
					l = l + 1
					str = str .. Vocab.known[v]:upper() .. "\n"
				else
					str = str .. v .. "\n"
				end
			end
			if l ~= #words then
				str = str.."\n\nYou have not learned enough to unlock this stone yet. Go learn more.\n\nPress return or esacpe"

			mb.showMessage( "Words learned: " .. l .. "/" .. #words, str )
			else
				mb.showMessage( "Curse lifted!", "A loud rumble of thunder rolls through, and then suddenly, it stops. You've undone one of the eternal curses!\n\n\nPress return or escape" )
				Curse1 = false
				sounds["rainloop"]:stop()
				sounds["windloop"]:stop()
			end
		end
		})
		x, y = getPos()
		for i = 1, love.math.random( 10, 14 ) do
			aihandler.new( {name="soldier"..love.math.random(1,2),x=x+love.math.random(-4, 4)*16, y = y+love.math.random(-4,4)*16})
		end
		worlditem:new( {x=x,y=y, name="relic", anim=RelicAnim, animated = true, found=false,
		update = function( self, dt )
			if player.x < self.x + self.w + 100 and player.x + player.w > self.x - 100 and player.y < self.y + self.h + 100 and player.y + player.h > self.y - 100 then
				if not self.found then
					self.found = true
					player.find( self )
					chordtimer = 0
					chordwait = love.math.random( 15, 30 )
					player.canMove = false
				end
			end
		end,
		onclick = function( self )
			local str = ""
			local words = {
				"onovello",
				"kwerzcyka",
				"grentabulaa",
				"Kellczyi",
				"Kellczya",
			}
			local l = 0
			for i, v in pairs( words ) do
				if Vocab.known[v] then
					l = l + 1
					str = str .. Vocab.known[v]:upper() .. "\n"
				else
					str = str .. v .. "\n"
				end
			end
			if l ~= #words then
				str = str.."\n\nYou have not learned enough to unlock this stone yet. Go learn more.\n\nPress return or esacpe"

				mb.showMessage( "Words learned: " .. l .. "/" .. #words, str )
			else
				mb.showMessage( "Curse lifted!", "Something you've not seen in YEARS - a sunrise. You've undone one of the eternal curses!\n\n\nPress return or escape" )
				Curse2 = false
			end
		end
		})

		for i = 1, love.math.random(9,12) do
			local haspos = false
			local x, y = getPos(nil,nil,nil,true)
			worlditem:new( {cost=100,x=x,y=y, name="book", anim=BookAnim, animated = true, found=false,
			onclick = function( self )

				if player.coins >= self.cost then
					player.coins = player.coins - self.cost
					self.cost = self.cost + 50
					sounds["coin"]:stop()
					sounds["coin"]:play()
					local r = love.math.random(1,#Vocab.unknown)
					local c = 0
					for i, v in pairs(Vocab.unknown) do
						c = c + 1
						if c == r then
							Vocab.unknown[i] = nil
							Vocab.known[i] = v
							print( table.serialize( Vocab.known ) )
							local info = Vocab.pages[i] or Vocab.pages["other"]
							if info == Vocab.pages['other'] then
								info = info .. "'" .. v .. "'.\n\n\nPress return or escape"
							end
							mb.showMessage( "You read the ancient book...", info )
							break
						end
					end
					--What word are we learning?

					UI.show()
				else
					notif.new(self.x-45, self.y, "Not enough money", {255, 255, 255}, 8)
					sounds['nomoney']:stop()
					sounds['nomoney']:play()
				end
			end,
			update = function( self, dt )
				if player.x < self.x + self.w + 100 and player.x + player.w > self.x - 100 and player.y < self.y + self.h + 100 and player.y + player.h > self.y - 100 then
					if not self.found then
						self.found = true
						player.find( self )
						chordtimer = 0
						chordwait = love.math.random( 15, 30 )
						player.canMove = false
					end
				end
			end
			})
		end
		for i = 1, love.math.random(80, 100) do 
			local x, y = getPos()
			worlditem:new( {x=x,y=y, name="crate", img="g/textures/crate", w=11,h=11,found=false,
			update = function( self, dt )
			end,
			onclick = function( self )
				for i, v in pairs( map.world[self.layer] ) do
					if v == self then
						local value = love.math.random(1,100)
						local col = { 255, 255, 255 }
						local coinage
						local loot
						if value < 50 then
							loot = commonloot[love.math.random(1,#commonloot)]
							if loot == "Coins" then
								coinage =  love.math.random(25,40)
								player.coins = player.coins + coinage
							end
							if loot == "Healing Potion" then
								local buff = love.math.random( 25, 35 )
								player.hp = player.hp + buff
								notif.new(player.x, player.y, "+" .. buff, { 0, 255, 0 } )
								if player.hp > 100 then player.hp = 100 end
							end
						elseif value > 50 and value < 95 then
							loot = uncommonloot[love.math.random(1,#uncommonloot)]
							if loot == "Coins" then
								coinage = love.math.random(75, 100)
								player.coins = player.coins + coinage
							end
							if loot == "Revive" then
								player.hp = 100
							end
							col = { 39, 196, 227 }
						else

							loot = rareloot[love.math.random(1,#rareloot)]
							if loot == "Coins" then
								coinage = love.math.random(150, 300)
								player.coins = player.coins + coinage
							end
							col = { 180, 40, 230 }
						end
						if coinage then
							notif.new( self.x, self.y, "+" .. coinage .. " coins!", col )
						else
							notif.new( self.x, self.y, "+" .. loot, col )
						end
						sounds["pickup"]:play()
						if gameitems[loot] then
							table.insert( player.inv, gameitems[loot] )
						end
						table.remove( map.world[self.layer], i )
						UI.show()
						if self.hascolliders then
							world:remove( self )
						end
						self = nil
					end
				end
			end
			})
		end
		makedraworder()
		print( "[map] Generation done! [OK]" )
	end
end

function map.update( dt )
	for i, v in pairs( map.world ) do
		for k, s in pairs( v ) do
			if s.update then s:update( dt ) end
		end
	end
end

function map.draw( dt )
	love.graphics.setColor( 255, 255, 255 )
	if map.backdrop then love.graphics.draw( map.backdrop, -(50*16), -(50*16) ) end
	for i, v in pairs( map.world ) do
		for k, s in pairs( v ) do
			if s.draw then s:draw() end
		end
	end
end

function map.fixdraw()
	for i, v in pairs( map.world.mg ) do
		if player.x + player.w > v.x and player.x < v.x + v.w and player.y + player.h > v.y and player.y+7 < v.y + v.h then
			if v.draw then v:draw() end
		end
		for k, d in pairs( aihandler.getAI() ) do
			if d.x + d.w > v.x and d.x < v.x + v.w and d.y + d.h > v.y and d.y < v.y + v.h then
				if v.draw then v:draw() end
			end
		end
	end
	for i, v in pairs( map.world.fg ) do
		if v.draw then v:draw() end
	end
end

function map.mousereleased( x, y, button )
	for i, v in pairs( map.world.mg ) do
		if not player.zooming then
			if v.mousereleased then v:mousereleased( x, y, button ) end
		end
	end
end

function map.generate(area)
	gen(area)
end