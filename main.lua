require 'scripts/shape'
colors = require 'scripts/colors'

function love.load()
	size = 3
	gridSize = 70
	x1 = gridSize
	x2 = 0
	y1 = -0.5*gridSize
	y2 = math.floor(-math.sqrt(3/4)*gridSize)
	cx = 400
	cy = 300
	radius = 3
	initShapes()
	love.graphics.setBackgroundColor(colors.bg)
	level = {}
	for i = 1,5 do
		level[i] = {
			x = love.math.random(2*size-1)-size,
			y = love.math.random(2*size-1)-size,
			shape = love.math.random(3),
			cursor = false,
		}
	end
	lines = {}
	drawingLine = false
	countLines()
end

function yBound(x,size)
	local lb = -size
	local ub = size
	if lb < x-size then lb = x-size end
	if ub > x+size then ub = x+size end
	return lb,ub
end

function pyth(dx,dy)
	return math.sqrt(dx^2+dy^2)
end

function love.update(dt)
	-- detect closest line
	activeLine = nil
	local distance = 20
	local mx,my = love.mouse.getPosition()
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

	-- detect closest node
	activeNode = nil
	local distance = 25

	for i,v in ipairs(level) do
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
	

	for i,v in ipairs(level) do
		local sx,sy = xyToScreen(v.x,v.y)
		local thisColor
		if v.cursor then
			thisColor = 'yellow'

		elseif v.count > 2 then
			thisColor = 'red'
		else
			thisColor = 'gray'
		end
		drawShape(sx,sy,thisColor,v.shape)
	end
end

function xyToScreen(x,y)
	return x*x1+y*y1+cx, x*x2+y*y2+cy
end

function love.keypressed( key, repeated )
	if key == 'escape' then
		love.event.quit()
	end
end

function insertLine(node1,node2)
	local sx1,sy1 = xyToScreen(node1.x,node1.y)
	local sx2,sy2 = xyToScreen(node2.x,node2.y)
	local tx,ty = sx2-sx1,sy2-sy1
	local length = pyth(tx,ty)
	tx,ty = tx/length,ty/length
	local nx,ny = ty,-tx
	local newLine = {
		n1 = node1,
		n2 = node2,
		cursor = false,
		tx = tx, ty = ty,
		nx = nx, ny = ny,
		length = length,
		x1 = sx1, y1 = sy1, x2 = sx2, y2 = sy2,
  }	
	table.insert(lines,newLine)
	detectCrossings()	
end

function countLines()
	for i,v in ipairs(level) do
		v.count = 0
	end
	for i,v in ipairs(lines) do
		v.n1.count = v.n1.count+1
		v.n2.count = v.n2.count+1
	end
end

function detectCrossings()
	for i=1,#lines do
		lines[i].crossed = false
	end
	for i = 1,#lines do
		for j = i+1,#lines do
			local l1 = lines[i]
			local l2 = lines[j]
			-- check if endpoints of line 2 are on different sides of line 1
			local dx1,dy1 = l2.x1 - l1.x1, l2.y1 - l1.y1
			local dx2,dy2 = l2.x2 - l1.x1, l2.y2 - l1.y1
			local orth1 = dx1 * l1.nx + dy1 * l1.ny
			local orth2 = dx2 * l1.nx + dy2 * l1.ny
			local prod1 = orth1*orth2
			-- this is unoptimized
			dx1,dy1 = l1.x1 - l2.x1, l1.y1 - l2.y1
			dx2,dy2 = l1.x2 - l2.x1, l1.y2 - l2.y1
			orth1 = dx1 * l2.nx + dy1 * l2.ny
			orth2 = dx2 * l2.nx + dy2 * l2.ny
			local prod2 = orth1*orth2

			if prod1 <= 0 and prod2 <= 0 then
				if not (prod1 == 0 and prod2 == 0) then
					l1.crossed = true
					l2.crossed = true				
				end
			end
		end
	end
end

function removeLine(line)
	for i,v in ipairs(lines) do
		if v == line then
			table.remove(lines,i)
			countLines()
			detectCrossings()
			break
		end
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
