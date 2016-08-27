--notification!
notif = { }
local notifs = { }
function notif.new(x, y, text, color, size )
	local a = {x=x or 0,y=y or 0, text=text or "Some text", time=time or 1, alpha=255, color=color or {255, 255, 255}, size=size or 8}
	a.tween = tween.new(a.time, a, {y = a.y-5, alpha=0}, "inOutExpo")
	notifs[#notifs+1] = a
end

function notif.update(dt)
	for i, v in pairs( notifs ) do
		if v.tween then
			local complete = v.tween:update( dt )
			if complete then
				notif[i] = nil
			end
		end
	end
end

function notif.draw()
	for i, v in pairs( notifs ) do
		love.graphics.setFont( newFont( "pixel", v.size ) )
		local r, g, b = unpack(v.color)
		love.graphics.setColor( r, g, b, v.alpha )
		love.graphics.print( v.text, v.x, v.y )
	end
end