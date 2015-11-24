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

function checkEverything()
	countLines()
	checkAngles()
	detectCrossings()
	assignAngles()
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
	end
end

function checkAngles()
	for i,v in ipairs(nodes) do
		v.ok = false
		if v.count == v.connections then
			if v.shape == 1 then
				v.ok = true
			elseif v.shape == 2 then
				local dotProduct = math.abs(v.lines[1].nx * v.lines[2].nx + v.lines[1].ny * v.lines[2].ny)
				--print(dotProduct)
				if math.abs(dotProduct-0.5) < tol or
				   math.abs(dotProduct-1) < tol then
				  v.ok = true
				end
			elseif v.shape == 3 then
				local dotProduct = math.abs(v.lines[1].nx * v.lines[2].nx + v.lines[1].ny * v.lines[2].ny)

				if math.abs(dotProduct) < tol or
				   math.abs(dotProduct-1) < tol then
				  v.ok=true
				end
			end
		end
	end
	levelWon = true
	for i,v in ipairs(nodes) do
		levelWon = levelWon and v.ok
	end
	for i,v in ipairs(lines) do
		levelWon = levelWon and (not v.crossed)
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


