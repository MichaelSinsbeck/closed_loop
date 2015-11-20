require 'scripts/shape'
require 'scripts/logic'
require 'scripts/utility'
colors = require 'scripts/colors'

function love.load()
	size = 3
	gridSize = 70
	tol = 1e-2 -- tolerance for angle check
	x1 = gridSize
	x2 = 0
	y1 = -0.5*gridSize
	y2 = math.floor(-math.sqrt(3/4)*gridSize)
	cx = 400
	cy = 300
	radius = 3
	initShapes()
	love.graphics.setBackgroundColor(colors.bg)
	nodes = {}
	for x = -size,size do
		local lb,ub = yBound(x,size)
		for y = lb,ub do
			nodes[#nodes+1] = {x=x,y=y,shape=3,cursor=false,lines={}}
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
	-- detect closest line (only if not drawing a line
	activeLine = nil
	local mx,my = love.mouse.getPosition()
	if not drawingLine then
	local distance = 20
	
	for i,v in ipairs(lines) do
		v.cursor = false
		local sx1,sy1 = xyToScreen(v.n1.x,v.n1.y)
		local sx2,sy2 = xyToScreen(v.n2.x,v.n2.y)
		local tx,ty = v.tx,v.ty -- sx2-sx1,sy2-sy1
		local nx,ny = v.nx,v.ny -- ty, -tx
		local pos  = (mx-sx1) * tx + (my-sy1) * ty
		local orth = (mx-sx1) * nx + (my-sy1) * ny
--		print('Pos: ' .. pos .. ', orth: ' .. orth)
		if pos > 0 and pos < v.length and math.abs(orth) < distance then
			activeLine = v
			distance = math.abs(orth)
		end
	end
	end

	-- detect closest node
	activeNode = nil
	local distance = 25

	for i,v in ipairs(nodes) do
		v.cursor = false
		sx,sy = xyToScreen(v.x,v.y)
		local thisDistance = pyth(mx-sx,my-sy)
		if thisDistance < distance then
			distance = thisDistance
			activeNode = v
		end
	end
	if activeNode then
		activeNode.cursor = true
		activeLine = nil
	end
	if activeLine then
		activeLine.cursor = true
	end
end

function love.draw()
	-- draw grid
	for x = -size,size do
	local lb,ub = yBound(x,size)
		for y = lb,ub do
			local sx,sy = xyToScreen(x,y)
			love.graphics.setColor(colors.node)
			love.graphics.circle('fill',sx,sy,radius)
			love.graphics.circle('line',sx,sy,radius)
		end
	end
	-- draw line (active)	
	if drawingLine then
		love.graphics.setLineWidth(4)
		love.graphics.setColor(colors.helpline)
		mx,my = love.mouse.getPosition()
		sx,sy = xyToScreen(startNode.x,startNode.y)
		love.graphics.line(mx,my,sx,sy)
	end
	-- draw lines (set)
	for i,v in ipairs(lines) do
		if v.cursor then
			love.graphics.setColor(colors.yellow)
		elseif v.crossed then
			love.graphics.setColor(colors.red)
		else
			love.graphics.setColor(colors.black)		
		end
		love.graphics.setLineWidth(4)
		sx1,sy1 = xyToScreen(v.n1.x,v.n1.y)
		sx2,sy2 = xyToScreen(v.n2.x,v.n2.y)
		love.graphics.line(sx1,sy1,sx2,sy2)
	end
	
	-- draw nodes
	for i,v in ipairs(nodes) do
		local sx,sy = xyToScreen(v.x,v.y)
		local thisColor
		if v.cursor then
			thisColor = 'yellow'

		elseif v.count > 2 then
			thisColor = 'red'
		elseif v.ok then
			thisColor = 'green'
		else
			thisColor = 'gray'
		end
		drawShape(sx,sy,thisColor,v.shape)
	end
	if levelWon then
		love.graphics.print('Won',10,10)
	else
		love.graphics.print('Not Won',10,10)
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
