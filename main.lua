local bump = require "bump"
tween = require "tween"
require "camera"
require "ser"
require "texturehandler"
require "animhandler"
require "soundmanager"
require "notify"

require "player"
require "aihandler"
require "ui"

game = { }
game.debug = false

local fonts = { }
function newFont( name, size )
	if not fonts[name] then
		fonts[name] = {}
	end
	if fonts[name][size] then
		return fonts[name][size]
	else
		fonts[name][size] = love.graphics.newFont( "assets/fonts/" .. (name or "pixel"):upper() .. ".ttf", size )
		fonts[name][size]:setFilter("nearest", "nearest")
		return fonts[name][size]
	end
end

local helppage = 1

local nightshade = { 0, 0, 0, 180 }

require "messagebox"

RelicAnim = Animations.new( {
	"anim/relic/relic1",
	"anim/relic/relic2",
	"anim/relic/relic3",
	"anim/relic/relic3",
	"anim/relic/relic4",
	"anim/relic/relic4",
	"anim/relic/relic4",
	"anim/relic/relic3",
	"anim/relic/relic3",
	"anim/relic/relic2",
	"anim/relic/relic1",
	"anim/relic/relic1",
}, 0.1, "Game" )
SSAnim = Animations.new( {
	"mg/anim/ss/ss1",
	"mg/anim/ss/ss2",
	"mg/anim/ss/ss3",
	"mg/anim/ss/ss3",
	"mg/anim/ss/ss4",
	"mg/anim/ss/ss4",
	"mg/anim/ss/ss4",
	"mg/anim/ss/ss3",
	"mg/anim/ss/ss3",
	"mg/anim/ss/ss2",
	"mg/anim/ss/ss1",
	"mg/anim/ss/ss1",
}, 0.1, "Game" )
ComputerAnim = Animations.new( {
	"m/computer/1",
	"m/computer/2",
}, 0.4, "Game")
BookAnim = Animations.new( {
	"/anim/book/book0000",
	"/anim/book/book0001",
	"/anim/book/book0002",
	"/anim/book/book0002",
	"/anim/book/book0003",
	"/anim/book/book0003",
	"/anim/book/book0003",
	"/anim/book/book0002",
	"/anim/book/book0002",
	"/anim/book/book0001",
	"/anim/book/book0000",
	"/anim/book/book0000",
}, 0.1, "Game")

require "map"
require "rain"

Curse1 = true --Rain
Curse2 = true --Darkness

controls = {
	up = "w",
	down = "s",
	left = "a",
	right = "d",
	zoom = "q"
}

gamestate = "Intro"

function love.load()
	world = bump.newWorld( 15 )
	rain.load()
	player.reset()
	--map.generate("overworld")
	--aihandler.new()

end
sounds['windloop']:setLooping(true)
sounds['rainloop']:setLooping(true)
sounds['windloop']:play()
sounds['rainloop']:play()

local intropages = {
	"Press space to read the pages.",
	"Legends told of an ancient time, where people controlled everything about their lives.",
	"They controlled the weather, and time of day. It was all up to them.",
	"The gods did not approve of this activity, and cast the world into an eternal darkness, and eternal rain.",
	"It is now up to you, to learn the language of the Kelzi people, and reclaim the relics for their honor.",
	"Generating world...",
}

local intro = {
	alpha = 0,
	page = 1,
	st = "in"
}

local introin = tween.new(1, intro, {alpha=255}, "inOutExpo")
local introout = tween.new(1, intro, {alpha=0}, "inOutExpo")


local garbageCollectTimer = 0
chordtimer = 0
chordwait = love.math.random( 10, 25 )

function love.update( dt )
	if not Curse2 then nightshade = {255, 255, 255} end
	chordtimer = chordtimer + dt
	if chordtimer > chordwait then
		chordwait = love.math.random(10,25)
		chordtimer = 0
	end
	garbageCollectTimer = garbageCollectTimer + dt
	if garbageCollectTimer > 2 then
		collectgarbage()
	end
	mb.update( dt )
	if not MessageBoxShown and gamestate == "Game" then
		rain.update( dt )
		UI.update( dt )
		map.update( dt )
		Animations.update( dt )
		aihandler.update( dt )
		player.update(dt)
		notif.update( dt )
	end
	if not Curse1 and not Curse2 then
		gamestate = "Win"
	end
	if gamestate == "Intro" then
		if intro.st == "in" then
			local complete = introin:update( dt )
			if complete then
				intro.st = "awaitkey"
			end
		elseif intro.st == "out" then
			local complete = introout:update( dt )
			if complete then
				if intro.page == 5 then
					gamestate = "Help"
				else
					intro.st = "in"
					introin:reset()
					intro.page = intro.page + 1
				end
			end
		end
	end
end

function love.draw( )
	if gamestate == "Game" then
		
		camera:set()
		love.graphics.scale( player.zoom or 4, player.zoom or 4 )
		--Draw player behind objects
		map.draw()	
		aihandler.draw()
		player.draw()	
		map.fixdraw()
		notif.draw()
		camera:unset()
		if Curse2 then
			love.graphics.setColor(nightshade)
			love.graphics.draw( textures['g/textures/ingameoverlay'], 0, 0 )
			love.graphics.setColor( 255, 255, 255 )
		end
		if Curse1 then
			rain.draw()
		end
		mb.drawMessage()
		UI.draw()
		love.graphics.setBackgroundColor( 6, 50, 10 )
	elseif gamestate == "Win" then
		love.graphics.setBackgroundColor( 67, 160, 71 )
		love.graphics.setFont( newFont( "pixel", 50 ) )
		love.graphics.printf("You have undone the eternal curses.", 0, 220, love.graphics.getWidth(), "center" )
		love.graphics.setFont( newFont( "pixel", 35 ) )
		love.graphics.printf( "You have done the Kelzi proud. They will surely honour you if this becomes a full game, or something like that!", love.graphics.getWidth()/4, 285, love.graphics.getWidth()/2, "center")
		love.graphics.printf( "Thanks for playing. If you'd like to play again, restart the game.", love.graphics.getWidth()/4, 460, love.graphics.getWidth()/2, "center" )
	elseif gamestate == "Dead" then
		love.graphics.setBackgroundColor( 200, 40, 40 )
		love.graphics.setFont( newFont( "pixel", 50 ) )
		love.graphics.printf("You have died", 0, 220, love.graphics.getWidth(), "center" )
		love.graphics.setFont( newFont( "pixel", 35 ) )
		love.graphics.printf( "You have dishonoured the Kelzi people. You could always try again.",love.graphics.getWidth()/4, 285, love.graphics.getWidth()/2, "center")
		love.graphics.printf( "Thanks for playing. If you'd like to play again, restart the game.",love.graphics.getWidth()/4, 450, love.graphics.getWidth()/2, "center" )
	elseif gamestate == "Buy" then
		love.graphics.setBackgroundColor( 33, 33, 33 )
		love.graphics.setFont( newFont( "pixel", 50 ) )
		love.graphics.printf("Buy Menu", 0, 0, love.graphics.getWidth(), "center")
	elseif gamestate == "Intro" then
		love.graphics.setBackgroundColor( 25, 140, 210 )
		love.graphics.setColor( 255, 255, 255, intro.alpha )
		love.graphics.setFont(newFont("pixel", 60))
		love.graphics.printf( intropages[intro.page], 50, love.graphics.getHeight()/3, love.graphics.getWidth()-100, "center" )
	elseif gamestate == "Help" then
		love.graphics.setColor( 255, 255, 255 )
		love.graphics.draw( textures["s/img/help/"..tostring(helppage)], 0, 0 )
	end
end

function love.keyreleased( key )
	if gamestate == "Game" then
		player.keyreleased( key )
		mb.keyreleased( key )
	elseif gamestate == "Intro" then
		if key == "space" and intro.st == "awaitkey" then
			intro.st = "out"
			if intro.page > 1 then
				introout:reset()
			end
		end
	elseif gamestate == "Help" then
		helppage = helppage + 1
		if helppage > 4 then
			map.generate('overworld')
			gamestate = "Game"
		end
	end
end

function love.mousereleased( x, y, button )
	aihandler.mousereleased( x, y )
	player.mousereleased( x, y )
	if not MessageBoxShown then
		map.mousereleased( x, y, button )
	end
end