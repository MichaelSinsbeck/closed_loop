local function randomPermutation(n)
	local perm = {}
	for i=1,n do
		perm[i] = i
	end
	for i=1,n-1 do
		j=love.math.random(i,n)
		perm[i],perm[j] = perm[j],perm[i]
	end
	return perm
end

function newOrder(nColor,nShape,nFill,nLevels,name,isFullRandom)
	if isFullRandom then
		return newOrderRandom(nColor,nShape,nFill,nLevels,name)	
	else
		return newOrderStratified(nColor,nShape,nFill,nLevels,name)
	end
end

function newOrderStratified(nColor,nShape,nFill,nLevels,name)
	local nStages = nColor*nShape*nFill
	if nLevels > nStages then
		nLevels = nStages
	end
	stageRegister = {}
	stages = {}
	stages.name = name
	-- randomly select some shapes, colors, fillstyles
	colorPerm = randomPermutation(#color)
	shapePerm = randomPermutation(#outline)
	fillPerm = randomPermutation(2)
	-- generate combinations and cross table
	crossTable = {}
	for i=0,nStages-1 do
		local N = i
		local thisFill= N%nFill
		N = (N-thisFill)/nFill
		local thisShape = N%nShape
		N = (N-thisShape)/nShape
		local thisColor = N%nColor
		thisFill = thisFill + 1
		thisShape = thisShape + 1
		thisColor = thisColor + 1
		local newStage = {shape = shapePerm[thisShape], color=colorPerm[thisColor],fill=fillPerm[thisFill]}
		table.insert(stageRegister,newStage)
		table.insert(crossTable, 0)
	end
	
	for i=1,nLevels do
		local minCross = math.huge
		-- find minimum of crosstable
		for k,v in ipairs(crossTable) do
			minCross = math.min(v,minCross)
		end
			
		-- put minimal elements into one table
		local idxTable = {}
		for k,v in ipairs(crossTable) do
			if v == minCross then				
				table.insert(idxTable,k)
			end
		end

		-- pull random one	
		local idx = love.math.random(#idxTable)
		local newShape = stageRegister[idxTable[idx]]
		table.insert(stages,newShape)

		-- update cross table
		for k,v in ipairs(stageRegister) do
			if v.shape == newShape.shape then
				crossTable[k] = crossTable[k] + 1
			end
			if v.color == newShape.color then
				crossTable[k] = crossTable[k] + 1
			end
			if v.fill == newShape.fill then
				crossTable[k] = crossTable[k] + 1
			end
			if v == newShape then
				crossTable[k] = crossTable[k] + 100
			end			
		end
	end
	-- assign directions
	assignDirections(stages)
	
	return stages
end

function newOrderRandom(nColor,nShape,nFill,nLevels,name)
	local nStages = nColor*nShape*nFill
	if nLevels > nStages then
		nLevels = nStages
	end
	local stages = {}
	stages.name = name
	-- randomly select some shapes, colors, fillstyles
	colorPerm = randomPermutation(#color)
	shapePerm = randomPermutation(#outline)
	--fillPerm = randomPermutation(2)
	-- generate all combinations in order
	for i=0,nStages-1 do
		local N = i
		local thisFill= N%nFill
		N = (N-thisFill)/nFill
		local thisShape = N%nShape
		N = (N-thisShape)/nShape
		local thisColor = N%nColor
		thisFill = thisFill + 1
		thisShape = thisShape + 1
		thisColor = thisColor + 1
		newStage = {shape = shapePerm[thisShape], color=colorPerm[thisColor],fill=thisFill}
		table.insert(stages,newStage)
	end
	-- shuffle
	for i=1,nStages-1 do
		j = love.math.random(i,nStages)
		stages[i],stages[j] =	stages[j],stages[i]
	end

	for i=nLevels+1,nStages do
		stages[i] = nil
	end
	
	-- assign directions
	assignDirections(stages)

	return stages
end

function assignDirections(stageList)
	local nLevels = #stageList
	local first = love.math.random(2)
	stageList[1].direction = first
	count={0,0}
	count[first] = 1
	for i=2,nLevels do
		local thisDirection
		if count[2] >= nLevels/2 or count[2] > count[1]+1 or count[1] == 0 then
			thisDirection = 1
		elseif count[1] >= nLevels/2 or count[1] > count[2]+1 or count[2] == 0 then
			thisDirection = 2
		else
			if love.math.random() < 0.5 then
				thisDirection = 2
			else
				thisDirection = 1
			end
		end
		count[thisDirection] = count[thisDirection] + 1 
		stageList[i].direction = thisDirection
	end
	return stageList
end

function generateLevel(stages,level,nShapes)
	local newLevel = {}
	for i=1,nShapes do
		table.insert(newLevel,stages[love.math.random(level)])
	end
	return newLevel
end

function initShapes()
	color = {
		{170,0,0},
		{33,68,120},
		{0,128,0},
		{255,204,0},
		{255,102,0},
		{0,212,170},
		{233,221,175},
		{136,0,170},
	}
	outline = {}
	-- rectangle
	outline[1] = {-.8,-.8,-.8,.8,.8,.8,.8,-.8}
	-- triangle
	outline[2] = {0,-.8,-0.8,0.8,0.8,0.8}
	-- star
	outline[3] = {}
	for i=0,4 do
		local factor = 0.9
		local ratio = 0.49
		outline[3][4*i+1] = math.sin(i*math.pi*2/5) * factor
		outline[3][4*i+2] = -math.cos(i*math.pi*2/5) * factor
		outline[3][4*i+3] = ratio*math.sin((i+0.5)*math.pi*2/5) * factor
		outline[3][4*i+4] = ratio*-math.cos((i+0.5)*math.pi*2/5)		 * factor
	end
	-- circle
	outline[4] = {}
	local nSeg = 40
	local factor = 0.9
	for i=0,nSeg-1 do
		outline[4][2*i+1] = math.sin(i*math.pi*2/nSeg) * factor
		outline[4][2*i+2] = -math.cos(i*math.pi*2/nSeg) * factor
	end
	-- diamond
	outline[5] = {0.9,0,0,0.9,-0.9,0,0,-0.9}
	-- cross
	outline[6] = {0.9,0.6,0.6,0.9,0,0.3
							,-0.6,0.9,-0.9,0.6,-0.3,0
							,-0.9,-0.6,-0.6,-0.9,0,-0.3
							,0.6,-0.9,0.9,-0.6,0.3,0}
	-- heart
	outline[7] = {}
	local curve = love.math.newBezierCurve(
		0,0.9,0.4,0.5,1.08,-0.07,0.85,-0.65)
	for k,v in ipairs(curve:render()) do
		if k>2 then
			table.insert(outline[7],v)
		end
	end
	curve = love.math.newBezierCurve(
		0.85,-0.65,0.62,-1,0.13,-.8,0.,-0.6)
	for k,v in ipairs(curve:render()) do
		if k>2 then
			table.insert(outline[7],v)
		end
	end
	curve = love.math.newBezierCurve(
		0,-0.6,-.13,-0.8,-0.62,-1,-0.85,-0.65)
	for k,v in ipairs(curve:render()) do
		if k>2 then
			table.insert(outline[7],v)
		end
	end	
	curve = love.math.newBezierCurve(
	-0.85,-0.65,-1.08,-0.07,-0.4,0.5,-0,0.9)
	for k,v in ipairs(curve:render()) do
		if k>2 then
			table.insert(outline[7],v)
		end
	end		
	
	-- half-moon
	outline[8] = {}
	local nSeg = 20
	local r = 0.9
	for i=1,2*nSeg do
		local angle = i/nSeg*4*math.pi/3/2 + math.pi/6
		table.insert(outline[8],r*math.cos(angle))
		table.insert(outline[8],r*math.sin(angle))
	end
	local cx = r*math.cos(-math.pi/6)
	local cy = r*math.sin(-math.pi/6)
	for i=1,nSeg do
		local angle = i*2*math.pi/3/nSeg + math.pi*5/6
		table.insert(outline[8],cx + r*math.cos(angle))
		table.insert(outline[8],cy -r*math.sin(angle))
	end
	
	insides = {}
	for i=1,#outline do
		if love.math.isConvex(outline[i]) then
		insides[i] = {outline[i]}
		else
		insides[i] = love.math.triangulate(outline[i])
		end
	end
end

function drawShape(x,y,colorIdx,shapeIdx,fillIdx,scale,fade)
	local thisScale = scale or 1
	thisScale = thisScale * 50
	local lineWidth = 5
	local fade = fade or 1
	local r = color[colorIdx][1]*fade + (1-fade) * 25
	local g = color[colorIdx][2]*fade + (1-fade) * 25
	local b = color[colorIdx][3]*fade + (1-fade) * 35

	love.graphics.push()
	love.graphics.translate(x,y)
	love.graphics.scale(thisScale,thisScale)	
	love.graphics.setColor(r,g,b,alpha)
	love.graphics.setLineWidth(0.2)
	
	for k,v in ipairs(insides[shapeIdx]) do
		if fillIdx == 1 then
			love.graphics.polygon('fill',v)
		end
	end
	love.graphics.polygon('line',outline[shapeIdx])
	love.graphics.pop()
end
