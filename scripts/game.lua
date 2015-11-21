local game = {}

local function nearestLine(mx,my)
-- detect closest line (only if not drawing a line
	activeLine = nil
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
end

local function nearestNode(mx,my)
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
end

local function drawGrid()
-- draw grid
	local radius = 3
	for x = -size,size do
	local lb,ub = yBound(x,size)
		for y = lb,ub do
			local sx,sy = xyToScreen(x,y)
			love.graphics.setColor(colors.node)
			love.graphics.circle('fill',sx,sy,radius)
			love.graphics.circle('line',sx,sy,radius)
		end
	end
end

local function drawLines()
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
end

local function drawNodes()
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
		drawShape(sx,sy,thisColor,v.shape,v.angle)
	end
end

function drawText()
	love.graphics.setColor(colors.gray)
	if levelName then
		love.graphics.setFont(largeFont)
		love.graphics.printf(levelName,0,30,2*cx,'center')
	end
	
	love.graphics.setColor(colors.blue)
	if levelText then
		love.graphics.setFont(smallFont)
		love.graphics.printf(levelText,0,2*cy - 60,2*cx, 'center')
	end

end

function game.draw()

	drawGrid()
	drawLines()
	drawNodes()
	drawText()
	if levelWon then
		--love.graphics.print('Won',10,10)
	else
		--love.graphics.print('Not Won',10,10)
	end
end

function game.update(dt)
	for i,v in ipairs(nodes) do
		v.angle = 0.5*(v.angle + v.targetAngle)
	end

	local mx,my = love.mouse.getPosition()
	nearestLine(mx,my)
	nearestNode(mx,my)
	
	if activeNode then
		activeNode.cursor = true
		activeLine = nil
	end
	if activeLine then
		activeLine.cursor = true
	end
end

function game.mousepressed(x,y,key)
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

function game.keypressed(key)
end
return game
