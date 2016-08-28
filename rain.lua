rain = {}

function rain.load()
	rain.refreshRate = 0.015
	rain.angle = 3
	rain.length = 10
	rain.minAmount = 50
	rain.maxAmount = 100

	rain.amount = math.random(rain.minAmount,rain.maxAmount)


	rain.timer = 0

	rain.x1 = {}
	rain.y1 = {}

	for i=1,rain.amount do
		rain.x1[i] = math.random(0,love.graphics.getWidth())
		rain.y1[i] = math.random(0,love.graphics.getHeight())
	end



	rain.droppletCount = 0
	rain.droppletMax = 30
	rain.droppletTimer = 0
	rain.droppletRefreshRate = 0.7

end


function rain.update(dt)
	SPAWN_DROPPLETS(dt)
	rain.timer = rain.timer + dt
	if rain.timer > rain.refreshRate then
		rain.timer = 0
		rain.amount = math.random(rain.minAmount,rain.maxAmount)
		for i=1,rain.amount do
			rain.x1[i] = math.random(0,love.graphics.getWidth())
			rain.y1[i] = math.random(0,love.graphics.getHeight())
		end
	end
end


function SPAWN_DROPPLETS(dt)
	rain.droppletTimer = rain.droppletTimer + dt
	if rain.droppletTimer > rain.droppletRefreshRate then
		rain.droppletTimer = 0
		--CREATE_DROPPLET()
	end
end


local function raindraw()
	for i=1,rain.amount do
		love.graphics.line(rain.x1[i], rain.y1[i], rain.x1[i] + rain.angle, rain.y1[i] + rain.length)
	end
end

function rain.draw()
	love.graphics.setColor(205,205,205,100)
	raindraw()
end