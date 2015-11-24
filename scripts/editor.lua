local editor = {}
local gridPoints = {}

local function outputLevel()
	print('')
	print("newLevel('')")
	print("addText('')")
	for i,p in ipairs(gridPoints) do
		if p.node then
			print('addNode(' .. p.x .. ',' .. p.y .. ',' .. p.node .. ','.. p.connections.. ')')
		end
	end
end

function editor.draw()
	love.graphics.setColor(colors.gray)
	love.graphics.print('Editor',10,10)
	
	-- draw grid and nodes
	local radius = 3

	for i,p in ipairs(gridPoints) do
		if p.node then
			-- draw node
			drawShape(p.sx,p.sy,'gray',p.node)
			drawCenteredText(p.connections,p.sx,p.sy)
			--love.graphics.setFont(tinyFont)
			--love.graphics.setColor(colors.gray)
			--love.graphics.printf(p.connections,p.sx-20,p.sy-8,40,'center')			 
		else
			-- draw grid point otherwise
			love.graphics.setColor(colors.node)
			radius = 3

			love.graphics.circle('fill',p.sx,p.sy,radius)
			love.graphics.circle('line',p.sx,p.sy,radius,20)
		end
	end
	if activePoint then
		love.graphics.setColor(colors.red)
		love.graphics.circle('line',activePoint.sx, activePoint.sy, 20,40)
	end
end

function editor.init()

	editorActive = true
	
	-- create grid if it is empty
	if #gridPoints == 0 then
		for x = -size,size do
		local lb,ub = yBound(x,size)
			for y = lb,ub do
				local sx,sy = xyToScreen(x,y)
				local newPoint = {
					x = x, y = y,
					sx = sx, sy = sy,
				}
				table.insert(gridPoints,newPoint)
			end
		end
	end
end

function editor.update()
	-- detect closest node
	activePoint = nil
	mx,my = love.mouse.getPosition()
	local distance = 100

	for i,v in ipairs(gridPoints) do
		v.cursor = false
		sx,sy = v.sx,v.sy
		local thisDistance = pyth(mx-sx,my-sy)
		if thisDistance < distance then
			distance = thisDistance
			activePoint = v
		end
	end
end

function editor.keypressed(key)
	if activePoint then
		if key == '1' then
			activePoint.node = 1
			activePoint.connections = 2
		elseif key == '2' then
			activePoint.node = 2
			activePoint.connections = 2
		elseif key == '3' then
			activePoint.node = 3
			activePoint.connections = 2
		elseif key == ' ' then
			activePoint.node = nil
			activePoint.connections = nil
		end
	end
	if key == 'o' then
		outputLevel()
	end
	
	if key == 'return' then -- test level
		clearLevel()
		for i,p in ipairs(gridPoints) do
			if p.node then
				insertNode(p.x,p.y,p.node,p.connections)
			end
		end
		gotoState('game')
	end	
	
	if key == 'escape' then
		gotoState('menu')
		editorActive = false
	end
end

function editor.mousepressed(x,y,key)
	if key == 'wu' and activePoint.connections then
		activePoint.connections = math.min(activePoint.connections + 1,12)
	end
	if key == 'wd' and activePoint.connections then
		activePoint.connections = math.max(activePoint.connections - 1,1)
	end
end

return editor
