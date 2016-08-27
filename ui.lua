--ui manager
UI = { }
UI.alpha = 0
local fadingin = false
local fadingout = false
local wait = false
local waitt = 0
UI.fadein = tween.new(1, UI, {alpha=150}, "inOutExpo" )
UI.fadeout = tween.new(1, UI, {alpha=0}, "inOutExpo" )
local function drawHotbar()
	local centerx = love.graphics.getWidth()/2
	local bigbox = 100
	local smallbox = 76
	love.graphics.setFont( newFont( "pixel", 48 ) )
	love.graphics.setColor( 55, 60, 70, UI.alpha )
	love.graphics.rectangle( "fill", centerx-(bigbox/2)-smallbox-5, 10+(bigbox/8), smallbox, smallbox )
	love.graphics.rectangle( "fill", centerx+(bigbox/2)+5, 10+(bigbox/8), smallbox, smallbox )
	love.graphics.rectangle( "fill", centerx-(bigbox/2), 10, bigbox, bigbox )
	love.graphics.setColor( 255, 255, 255, UI.alpha )
	love.graphics.rectangle( "line", centerx-(bigbox/2)-smallbox-5, 10+(bigbox/8), smallbox, smallbox )
	love.graphics.rectangle( "line", centerx+(bigbox/2)+5, 10+(bigbox/8), smallbox, smallbox )
	love.graphics.rectangle( "line", centerx-(bigbox/2), 10, bigbox, bigbox )
	love.graphics.printf( "Coins: " .. player.coins, 0, 0, love.graphics.getWidth(), "right" )
end

function UI.update( dt )

	if wait then
		waitt = waitt + dt
		if waitt > 2 then
			wait = false
			fadingout = true
			waitt = 0
		end
	end
	if fadingin then
		local complete = UI.fadein:update( dt )
		if complete then
			wait = true
			fadingin = false
		end
	end
	if fadingout then
		local complete = UI.fadeout:update( dt )
		if complete then
			fadingout = false
			wait = false
			fadingin = false
			UI.fadeout:reset()
			UI.fadein:reset()
		end
	end

end

function UI.show()
	fadingin = true
end

function UI.draw()
	drawHotbar()
end