--anim handler

Animations = { }

local anim_store = { }

function Animations.new( keys, interval, state )
	if type( keys ) == "table" then

		local state = state or "_ALL"

		local interval = interval or 0.1

		local a = {
			keys = keys,
			int = interval,
			frame = 1,
			timer = 0,
			state = state
		}
		table.insert( anim_store, a )
		print( "[animation-handler] Making animation... [OK]" )
		return a
	else

	end
end

function Animations.draw( anim, x, y )
	for i, v in pairs( anim_store ) do
		if anim == v and (v.state == gamestate or v.state == "_ALL") then
			love.graphics.draw( textures[v.keys[v.frame]], x, y )
		end
	end
end

function Animations.update( dt )

	for i, v in pairs( anim_store ) do
		if v.state == gamestate or v.state == "_ALL" then
			v.timer = v.timer + dt
			if v.timer > v.int then
				v.timer = 0
				v.frame = v.frame + 1
				if v.frame > #v.keys then
					v.frame = 1
				end
			end
		end
	end

end