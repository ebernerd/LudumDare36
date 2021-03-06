--message box
mb = { }
local hasshown = false
local mbC = love.graphics.newCanvas(love.graphics.getWidth() * 2/3, love.graphics.getHeight()/2)
mb.alpha = 0
mb.tween = tween.new(0.8, mb, {alpha=255}, "inOutExpo")
mbC:setFilter( "nearest", "nearest" )
local titleF = newFont( "pixel", 32 )
local bodyF = newFont( "pixel", 25 )
MessageBoxShown = false
function mb.showMessage( title, message, options, optkeys )
	hasshown = true
	love.graphics.setCanvas( mbC )
		love.graphics.setLineWidth( 2 )
		love.graphics.setColor( 70, 90, 107 )
		love.graphics.rectangle( "fill", 0, titleF:getHeight()/2+10, mbC:getWidth(), mbC:getHeight() )
		love.graphics.rectangle( "fill", 20, 0, titleF:getWidth( title )+20, titleF:getHeight() + 5 )
		love.graphics.setColor( 255, 255, 255 )	
		love.graphics.setFont( titleF )
		love.graphics.print( title, 30, 0 )
		love.graphics.setFont( bodyF )
		love.graphics.printf( message, 5, titleF:getHeight()+15, mbC:getWidth()-10, "left" )
		love.graphics.setLineWidth( 1 )
	love.graphics.setCanvas()
	MessageBoxShown = true

end

function mb.drawMessage()
	if MessageBoxShown then
		love.graphics.setColor( 255, 255, 255, mb.alpha )
		love.graphics.draw( mbC, 35, love.graphics.getHeight()* 1/4 )
		love.graphics.setColor( 255, 255, 255 )
	end
end

function mb.update( dt )
	if MessageBoxShown then
		local c = mb.tween:update( dt )
	end
end

function mb.keyreleased( key )
	if key == "return" or key == "escape" then
		MessageBoxShown = false
		if hasshown then
			mb.tween:reset()
		end
	end
end