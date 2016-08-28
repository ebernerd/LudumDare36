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
		fonts[name][size] = love.graphics.newFont( "assets/fonts/" .. (name or "pixel") .. ".ttf", size )
		fonts[name][size]:setFilter("nearest", "nearest")
		return fonts[name][size]
	end
end

local nightshade = { 0, 0, 0, 150 }

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
ComputerAnim = Animations.new( {
	"anim/computer/1",
	"anim/computer/2",
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

controls = {
	up = "w",
	down = "s",
	left = "a",
	right = "d",
	zoom = "q"
}

gamestate = "Game"
function love.load()
	world = bump.newWorld( 15 )
	love.graphics.setBackgroundColor( 6, 50, 10 )
	player.reset()

	--aihandler.new()
	map.generate("overworld")

end

sounds['rainloop']:setLooping(true)
sounds['rainloop']:play()

local garbageCollectTimer = 0
chordtimer = 0
chordwait = love.math.random( 10, 25 )

function love.update( dt )
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
	UI.update( dt )
	if not MessageBoxShown then
		map.update( dt )
		Animations.update( dt )
		aihandler.update( dt )
		player.update(dt)
		notif.update( dt )
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
		love.graphics.setColor(nightshade)
		love.graphics.draw( textures['g/textures/ingameoverlay'], 0, 0 )
		love.graphics.setColor( 255, 255, 255 )
		mb.drawMessage()
		UI.draw()
	end
end

function love.keyreleased( key )
	player.keyreleased( key )
	mb.keyreleased( key )
end

function love.mousereleased( x, y, button )
	aihandler.mousereleased( x, y )
	player.mousereleased( x, y )
	if not MessageBoxShown then
		map.mousereleased( x, y, button )
	end
end