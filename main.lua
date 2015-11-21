require 'scripts/shape'
require 'scripts/logic'
require 'scripts/utility'
colors = require 'scripts/colors'
menu = require 'scripts/menu'
game = require 'scripts/game'

function love.load()
	gameState = 'game'
	size = 3
	gridSize = 70
	tol = 1e-2 -- tolerance for angle check
	x1 = gridSize
	x2 = 0
	y1 = -0.5*gridSize
	y2 = math.floor(-math.sqrt(3/4)*gridSize)
	cx = 400
	cy = 300
	initShapes()
	love.graphics.setBackgroundColor(colors.bg)
	nodes = {}
	for x = -size,size do
		local lb,ub = yBound(x,size)
		for y = lb,ub do
			if love.math.random(2) == 1 then
				insertNode(x,y,love.math.random(3))
			end
			--nodes[#nodes+1] = {x=x,y=y,shape=3,cursor=false,lines={}}
		end
	end
	
	--[[ Testlevel
	nodes[1] = {x=0,y=0,shape=1,cursor=false,lines={}}
	nodes[2] = {x=1,y=0,shape=2,cursor=false,lines={}}
	nodes[3] = {x=1,y=1,shape=3,cursor=false,lines={}}
	nodes[4] = {x=2,y=0,shape=1,cursor=false,lines={}}--]]
	
	--[[for i = 1,5 do
		nodes[i] = {
			x = love.math.random(2*size-1)-size,
			y = love.math.random(2*size-1)-size,
			shape = love.math.random(3),
			cursor = false,
			lines = {},
		}
	end--]]
	lines = {}
	drawingLine = false
	countLines()
end


function love.update(dt)
	if gameState == 'menu' then
		menu.update(dt)
	elseif gameState == 'game' then
		game.update(dt)
	end
end

function love.draw()
	if gameState == 'menu' then
		menu.draw()
	elseif gameState == 'game' then
		game.draw()
	end
	
end


function love.keypressed( key, repeated )
	if key == 'escape' then
		love.event.quit()
	end
end

function love.mousepressed(x,y,key)
	if key == 'l' then
		if not drawingLine then
		-- not line in action
			if activeNode then
				drawingLine = true
				startNode = activeNode
			end
		else
		-- line in action
			if activeNode and activeNode ~= startNode then
				insertLine(startNode,activeNode)
				countLines()
				if activeNode.count == 1 then
					startNode = activeNode  -- continue drawing a line
				else
					drawingLine = false
					startNode = nil
				end
			end

		end
	end
	if key == 'r' then
		if drawingLine then
			drawingLine = false
			startNode = nil
		elseif activeLine then
			removeLine(activeLine)
		end
	end
end
