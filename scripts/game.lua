local game = {}
local nextButton
local backButton
local winTimer
local fadeTime = 0.3
local yTitle
local yText
local yCongrats
local previousNode
local lineTimer = 0
local lineTime = 0.2

local function admissibleAngle(x1,y1,x2,y2)
	local dx,dy = x2-x1,y2-y1
	local thisAngle = math.atan2(dy,dx)
	local divisor = math.pi/6
	local roundedAngle = math.floor((thisAngle/divisor)+0.5)*divisor
	return math.abs(thisAngle-roundedAngle) < tol
end

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
	previousNode = activeNode
	activeNode = nil
	local distance = 25

	for i,v in ipairs(nodes) do
		v.cursor = false
		local sx,sy = xyToScreen(v.x,v.y)
		local thisDistance = pyth(mx-sx,my-sy)
		if thisDistance < distance then
			if drawingLine then
				local rx,ry = xyToScreen(startNode.x,startNode.y)
				if admissibleAngle(sx,sy,rx,ry) then
					distance = thisDistance
					activeNode = v
				end
			else
				distance = thisDistance
				activeNode = v
			end
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
	-- potential connections
	if activeNode then
		local sx1,sy1 = xyToScreen(activeNode.x,activeNode.y)
		for i,n in ipairs(activeNode.neighbors) do
			local sx2,sy2 = xyToScreen(n.x,n.y)
			local factor = tween(lineTimer/lineTime)
			sx2 = sx1 + (sx2-sx1) * factor
			sy2 = sy1 + (sy2-sy1) * factor
			love.graphics.setLineWidth(2)
			love.graphics.setColor(colors.node)			
			love.graphics.line(sx1,sy1,sx2,sy2)
		end
	elseif startNode then
		local sx1,sy1 = xyToScreen(startNode.x,startNode.y)
		for i,n in ipairs(startNode.neighbors) do
			local sx2,sy2 = xyToScreen(n.x,n.y)
			local factor = tween(lineTimer/lineTime)
			sx2 = sx1 + (sx2-sx1) * factor
			sy2 = sy1 + (sy2-sy1) * factor			
			love.graphics.setLineWidth(2)
			love.graphics.setColor(colors.node)			
			love.graphics.line(sx1,sy1,sx2,sy2)
		end
	end
	-- draw line (active)	
	if drawingLine then
		love.graphics.setLineWidth(4)
		love.graphics.setColor(colors.helpline)
		local mx,my = love.mouse.getPosition()
		local sx,sy = xyToScreen(startNode.x,startNode.y)
		love.graphics.line(sx,sy,mx,my)
		--[[ Force the angle (unintuitive)
		local angle = math.atan2(my-sy,mx-sx)
		local divisor = math.pi/6
		local newAngle = math.floor((angle/divisor)+0.5)*divisor
		local distance = pyth(mx-sx,my-sy)
		local lx = sx + math.cos(newAngle) * distance * math.cos(angle-newAngle)
		local ly = sy + math.sin(newAngle) * distance * math.cos(angle-newAngle)
		love.graphics.line(sx,sy,lx,ly)--]]
	end
	-- draw lines (set)
	for i,v in ipairs(lines) do
		if v.cursor then
			love.graphics.setColor(colors.yellow)
		elseif v.okCrossed then
			love.graphics.setColor(colors.black)
		else
			love.graphics.setColor(colors.red)		
		end
		love.graphics.setLineWidth(4)
		sx1,sy1 = xyToScreen(v.n1.x,v.n1.y)
		sx2,sy2 = xyToScreen(v.n2.x,v.n2.y)
		love.graphics.line(sx1,sy1,sx2,sy2)
	end
	
	-- draw potential connections
	if love.keyboard.isDown('tab') then
		love.graphics.setLineWidth(2)
		love.graphics.setColor(colors.node)
		for i,n1 in ipairs(nodes) do
			local sx1,sy1 =xyToScreen(n1.x,n1.y)
			for j,n2 in ipairs(n1.neighbors) do
				if n2.idx < n1.idx then
					local sx2,sy2 =xyToScreen(n2.x,n2.y)
					love.graphics.line(sx1,sy1,sx2,sy2)
				end
			end			
		end
	end
end

local function drawNodes()
	-- draw nodes
	for i,v in ipairs(nodes) do
		local sx,sy = xyToScreen(v.x,v.y)
		local thisColor
		if v.cursor then
			thisColor = 'yellow'

		elseif v.okCount and v.okAngle then
			thisColor = 'green'
		else
			thisColor = 'gray'
		end
		drawShape(sx,sy,thisColor,v.shape,v.angle)
		-- draw number of connections on top
		drawCenteredText(v.connections,sx,sy)
		--love.graphics.setFont(tinyFont)
		--love.graphics.setColor(colors.gray)
		--love.graphics.printf(v.connections,sx-20,sy-8,40,'center')
	end
end

function drawText()
	love.graphics.setColor(colors.gray)
	if levelName then
		love.graphics.setFont(largeFont)
		love.graphics.printf(levelName,0,yTitle,2*cx,'center')
	end
	
	love.graphics.setColor(colors.gray)
	if levelName then
		love.graphics.setFont(largeFont)
		love.graphics.printf('Puzzle solved!',0,yCongrats,2*cx,'center')
	end
	
	love.graphics.setColor(colors.blue)
	if levelText then
		love.graphics.setFont(smallFont)
		love.graphics.printf(levelText,0,yText,2*cx, 'center')
	end
end

function game.init()
	love.graphics.setBackgroundColor(colors.bg)
	levelWon = false
	winTimer = 0
	lineTimer = 0
	-- check all angles and stuff and create buttons
	checkEverything()
	local nextfunc = function()
		if editorActive then
			gotoState('editor')
		else
			campaign.startLevel(levelNumber + 1)
		end
	end
	
	
	local nextText = 'Next Level'
	if editorActive then nextText = 'Back to Editor' end
	
	yTitle = 30
	yText = 2*cy - 60
	yCongrats = 2*cy + 50
	buttonTree.clear()
	nextButton = buttonTree.addButton(900,500,200,30,nextText,nextfunc)
	backButton = buttonTree.addButton(-300,500,200,30,'Back to Menu',function() gotoState('levelselect') end)
end

function game.draw()

	drawGrid()
	drawLines()
	drawNodes()
	drawText()
	buttonTree.draw()
	
	if levelWon then
		--love.graphics.print('Won',10,10)
	else
		--love.graphics.print('Not Won',10,10)
	end
end

function game.update(dt)
	lineTimer = lineTimer + dt
	
	-- rotate all the nodes
	for i,v in ipairs(nodes) do
		v.angle = 0.5*(v.angle + v.targetAngle)
	end

	-- find nearest line or node
	local mx,my = love.mouse.getPosition()
	nearestLine(mx,my)
	nearestNode(mx,my)
	if activeNode and activeNode ~= previousNode then
		lineTimer = 0
	end
	if activeNode then
		activeNode.cursor = true
		activeLine = nil
	end
	if activeLine then
		activeLine.cursor = true
	end
	
	-- fade in buttons smoothly
	if levelWon then
		-- winTimer
		winTimer = winTimer + dt
		
		weight = tween(winTimer/fadeTime)
		
		nextButton.x = 550 * weight + 900 * (1-weight)
		backButton.x = 50 * weight - 300 * (1-weight)
		yTitle = -100 * weight + 30 * (1-weight)
		yText = (2*cy + 50) * weight +  (2*cy - 60) * (1-weight)
		yCongrats = (2*cy - 60) * weight + (2*cy + 50) * (1-weight)
	end
	
	-- process buttons
	buttonTree.update(dt)
	
	
end

function game.mousepressed(x,y,key)
	buttonTree.mousepressed(x,y,key)
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
				local sx1,sy1 = xyToScreen(activeNode.x,activeNode.y)
				local sx2,sy2 = xyToScreen(startNode.x,startNode.y)
				if admissibleAngle(sx1,sy1,sx2,sy2) then
					insertLine(startNode,activeNode)
					
					--countLines()
					--v.okCount
					--if love.keyboard.isDown('rctrl','lctrl') then
					if activeNode.count < activeNode.connections then
						startNode = activeNode  -- continue drawing a line
					else
						drawingLine = false
						startNode = nil
					end
					if levelWon then
						drawingLine = false
						startNode = nil
					end
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

function game.mousereleased(x,y,key)
	buttonTree.mousereleased(x,y,key)
end

function game.keypressed(key)
	if key == 'escape' then
		if editorActive then
			gotoState('editor')
		else
			gotoState('levelselect')
		end
	end
end
return game
