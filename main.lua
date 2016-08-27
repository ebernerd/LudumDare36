local bump = require "bump"
tween = require "tween"
require "camera"
require "ser"
require "tween"
require "texturehandler"
require "animhandler"

local fonts = { }
function newFont( name, size )
	if not fonts[name] then
		fonts[name] = {}
	end
	if fonts[name][size] then
		return fonts[name][size]
	else
		fonts[name][size] = love.graphics.newFont( "assets/fonts/" .. (name or "pixel") .. ".ttf", size )
		return fonts[name][size]
	end
end


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

require "player"
require "map"

controls = {
	up = "w",
	down = "s",
	left = "a",
	right = "d",
}

gamestate = "Game"
function love.load()
	world = bump.newWorld( 15 )

	player.reset()

end


local garbageCollectTimer = 0
function love.update( dt )

	garbageCollectTimer = garbageCollectTimer + dt
	if garbageCollectTimer > 2 then
		collectgarbage()
	end
	if not MessageBoxShown then
		map.update( dt )
		Animations.update( dt )
		player.update(dt)
	end
end

function love.draw( )
	if gamestate == "Game" then
		camera:set()
		love.graphics.scale( player.zoom or 4, player.zoom or 4 )
		map.draw()
		player.draw()
		camera:unset()
		mb.drawMessage()
	end
end

function love.keyreleased( key )
	player.keyreleased( key )
	mb.keyreleased( key )
end

function love.mousereleased( x, y, button )
	if not MessageBoxShown then
		map.mousereleased( x, y, button )
	end
end