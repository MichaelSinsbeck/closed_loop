--[[

Functions:

insertNode
insertLine
removeLine
checkEverything
countLines
checkAngles
detectCrossings

--]]

local angleConstraints = {12,6,4} -- circle, hexagon, square

function clearLevel()
	nodes = {}
	lines = {}
end

function insertNode(x,y,shape,connections)
	connections = connections or 2
	local idx = #nodes + 1
	local newNode = {x=x,y=y,shape=shape,connections = connections,cursor=false,lines={},angle=0, targetAngle=0,neighbors={},idx=idx}
	table.insert(nodes,newNode)
	
	local sx1,sy1 = xyToScreen(x,y)
	-- create list of neighbors for new node
	for i = 1,#nodes-1 do
		local n = nodes[i]
		local sx2,sy2 = xyToScreen(n.x,n.y)
		local dx,dy = sx2-sx1,sy2-sy1
		local thisAngle = math.atan2(dy,dx)
		local divisor = math.pi/6
		local roundedAngle = math.floor((thisAngle/divisor)+0.5)*divisor
		if math.abs(thisAngle-roundedAngle) < tol then
			table.insert(n.neighbors,newNode)
			table.insert(newNode.neighbors,n)
		end
	end
end

function insertLine(node1,node2)
	-- check, if this line does already exist
	for i,l in ipairs(lines) do
		if (l.n1 == node1 and l.n2 == node2) or
		   (l.n1 == node2 and l.n2 == node1) then
		  return
		end
	end
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
	checkEverything()
end

function removeLine(line)
	for i,v in ipairs(lines) do
		if v == line then
			table.remove(lines,i)
			checkEverything()
			break
		end
	end
end

function checkWin()
	print('\nChecking win condition\n')
	levelWon = true
	-- check Angle conditions
	for i,v in ipairs(nodes) do
		levelWon = levelWon and v.okAngle
	end
	-- check crossings
	for i,v in ipairs(lines) do
		levelWon = levelWon and v.okCrossed
	end
	-- check connectivity
	
	-- check numbers
	for i,v in ipairs(nodes) do
		levelWon = levelWon and v.okCount
	end
	
end

function checkEverything()
	countLines()
	checkAngles()
	detectCrossings()
	assignAngles()
	checkWin()
end

function countLines()
	-- assign lines to nodes
	for i,v in ipairs(nodes) do -- empty line table
		v.lines = {}
	end
	for i,v in ipairs(lines) do -- fill line table
		table.insert(v.n1.lines,v)
		table.insert(v.n2.lines,v)
	end
	for i,v in ipairs(nodes) do -- count
		v.count = #v.lines
		v.okCount = (v.count == v.connections)
	end
end

function checkAngles()
	for i,n in ipairs(nodes) do
		n.okAngle = true
		local nLines = #n.lines
		if nLines == 0 then break end
	
		local divisor = math.pi*2 / angleConstraints[n.shape]
		local l1 = n.lines[1]
		local angle1 = math.atan2(l1.ny,l1.nx)
		for j = 2,nLines do
			local l2 = n.lines[j]
			local angle2 = math.atan2(l2.ny,l2.nx)
			local diffAngle = angle2-angle1
			local roundedAngle = math.floor(diffAngle/divisor+0.5)*divisor
			if math.abs(roundedAngle-diffAngle) > tol then
				n.okAngle = false
				return
			end
		end		
	end
end

function detectCrossings()
	for i,l in ipairs(lines) do
		l.okCrossed = true
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
					l1.okCrossed = false
					l2.okCrossed = false
				end
			end
		end
	end
end

function assignAngles()
	for i,v in ipairs(nodes) do
		if #v.lines > 0 then
			local tx,ty = v.lines[1].nx, v.lines[1].ny
			v.targetAngle = math.atan2(ty,tx)
			
		else
			v.targetAngle = 0
		end
	end
end


