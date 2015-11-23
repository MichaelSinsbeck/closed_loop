local tutorial = {}
local timer = 0
local number -- which page should be shown?
local skipButton
local phase

--[[
These are the tutorials:
1) Rule 1: Numbers indicate connections
2) Rule 2: Don't make separate groups
   Rule 3: Lines may not cross
3) Rule 3: Directions

--]]

function tutorial.draw()
	love.graphics.setLineWidth(4)
	love.graphics.setColor(colors.tutorialbg)
	love.graphics.rectangle('fill',30,30,740,540)
	buttonTree.draw()
	
	if number == 1 then
	local textWidth = 250
	love.graphics.printf('Rule 1: Each node must be connected to as many other nodes as indicated by the numbers',0,40,2*cx,'center')
	
	-- draw 2 grid
		local radius = 3
		for x = -2,2 do
		local lb,ub = yBound(x,2)
			for y = lb,ub do
				local sx,sy = xyToScreen(x,y)
				love.graphics.setColor(colors.node)
				love.graphics.circle('fill',sx,sy,radius)
				love.graphics.circle('line',sx,sy,radius)
			end
		end		
		local sx,sy
		love.graphics.setColor(colors.black)
		love.graphics.setLineWidth(4)
		local tx,ty
		sx,sy = xyToScreen(0,1)
		
		tx,ty = xyToScreen(-2,-1)
		love.graphics.line(sx,sy,tx,ty)
		tx,ty = xyToScreen(0,-1)
		love.graphics.line(sx,sy,tx,ty)
		tx,ty = xyToScreen(2,1)
		love.graphics.line(sx,sy,tx,ty)
		sx,sy = xyToScreen(0,-1)
		love.graphics.line(sx,sy,tx,ty)
		
		
		sx,sy = xyToScreen(-2,-1)
		drawShape(sx,sy,'gray',1)
		drawCenteredText('1',sx,sy)
		sx,sy = xyToScreen(0,1)
		drawShape(sx,sy,'gray',1)
		drawCenteredText('3',sx,sy)
		sx,sy = xyToScreen(0,-1)
		drawShape(sx,sy,'gray',1)
		drawCenteredText('2',sx,sy)
		sx,sy = xyToScreen(2,1)
		drawShape(sx,sy,'gray',1)
		drawCenteredText('2',sx,sy)

	end -- end number == 1
	
	if number == 2 then
	local textWidth = 250
	love.graphics.printf("Rule 2: Don't form separate groups",60,40,cx-90,'center')
	love.graphics.printf('Rule 3: Lines may not cross',cx+30,40,cx-90,'center')
	
	-- draw 2 grid
		local offset = 2.5*gridSize
		local radius = 3
		for x = -2,2 do
		local lb,ub = yBound(x,2)
			for y = lb,ub do
				local sx,sy = xyToScreen(x,y)
				love.graphics.push()
					love.graphics.translate(-offset,0)
					love.graphics.circle('fill',sx,sy,radius)
					love.graphics.circle('line',sx,sy,radius)
				love.graphics.pop()
				love.graphics.push()
					love.graphics.translate(offset,0)
					love.graphics.circle('fill',sx,sy,radius)
					love.graphics.circle('line',sx,sy,radius)
				love.graphics.pop()
			end
		end
		
		-- diagram left
		love.graphics.push()
		love.graphics.translate(-offset,0)
		local sx,sy
		love.graphics.setColor(colors.black)
		love.graphics.setLineWidth(4)
		local tx,ty
		sx,sy = xyToScreen(2,0)
		tx,ty = xyToScreen(2,2)
		love.graphics.line(sx,sy,tx,ty)
		sx,sy = xyToScreen(0,2)
		love.graphics.line(sx,sy,tx,ty)
		tx,ty = xyToScreen(2,0)
		love.graphics.line(sx,sy,tx,ty)
		sx,sy = xyToScreen(-2,0)
		tx,ty = xyToScreen(-2,-2)
		love.graphics.line(sx,sy,tx,ty)
		sx,sy = xyToScreen(0,-2)
		love.graphics.line(sx,sy,tx,ty)
		tx,ty = xyToScreen(-2,0)
		love.graphics.line(sx,sy,tx,ty)
		
		sx,sy = xyToScreen(2,0)
		drawShape(sx,sy,'gray',1)
		drawCenteredText('2',sx,sy)
		sx,sy = xyToScreen(2,2)
		drawShape(sx,sy,'gray',1)
		drawCenteredText('2',sx,sy)
		sx,sy = xyToScreen(0,2)
		drawShape(sx,sy,'gray',1)
		drawCenteredText('2',sx,sy)
		sx,sy = xyToScreen(-2,0)
		drawShape(sx,sy,'gray',1)
		drawCenteredText('2',sx,sy)
		sx,sy = xyToScreen(-2,-2)
		drawShape(sx,sy,'gray',1)
		drawCenteredText('2',sx,sy)
		sx,sy = xyToScreen(0,-2)
		drawShape(sx,sy,'gray',1)
		drawCenteredText('2',sx,sy)
		love.graphics.pop()
		
		-- diagram right
		love.graphics.push()
		love.graphics.translate(offset,0)
		local sx,sy
		
		love.graphics.setLineWidth(4)
		local tx,ty
		sx,sy = xyToScreen(-2,0)
		tx,ty = xyToScreen(2,0)
		love.graphics.setColor(colors.red)
		love.graphics.line(sx,sy,tx,ty)
		sx,sy = xyToScreen(2,2)
		love.graphics.setColor(colors.black)
		love.graphics.line(sx,sy,tx,ty)
		tx,ty = xyToScreen(-2,-2)
		love.graphics.setColor(colors.red)
		love.graphics.line(sx,sy,tx,ty)
		
		sx,sy = xyToScreen(-2,0)
		drawShape(sx,sy,'gray',1)
		drawCenteredText('1',sx,sy)
		sx,sy = xyToScreen(2,0)
		drawShape(sx,sy,'gray',1)
		drawCenteredText('2',sx,sy)
		sx,sy = xyToScreen(2,2)
		drawShape(sx,sy,'gray',1)
		drawCenteredText('2',sx,sy)
		sx,sy = xyToScreen(-2,-2)
		drawShape(sx,sy,'gray',1)
		drawCenteredText('1',sx,sy)
		
		love.graphics.pop()

	end -- end number == 2
	
	if number == 3 then
	local offsetFull = 2.5*gridSize
	local offset = (1-tween(2*(timer-3))) * offsetFull
	-- draw 2 grid
		local radius = 3
		for x = -2,2 do
		local lb,ub = yBound(x,2)
			for y = lb,ub do
				local sx,sy = xyToScreen(x,y)
				love.graphics.setColor(colors.node)
				
				love.graphics.push()
					love.graphics.translate(-offset,-50)
					love.graphics.circle('fill',sx,sy,radius)
					love.graphics.circle('line',sx,sy,radius)
				love.graphics.pop()
				
				love.graphics.push()
					love.graphics.translate(offset,-50)
					love.graphics.circle('fill',sx,sy,radius)
					love.graphics.circle('line',sx,sy,radius)				
				love.graphics.pop()
			end
		end

		local sx,sy,tx,ty
		sx,sy = xyToScreen(0,0)		
		
		love.graphics.push()
			love.graphics.translate(-offset,-50)
			love.graphics.setColor(colors.helpline)
			love.graphics.setLineWidth(2)
			tx,ty = xyToScreen(2,0)
			love.graphics.line(sx,sy,tx,ty)
			tx,ty = xyToScreen(0,2)
			love.graphics.line(sx,sy,tx,ty)
			tx,ty = xyToScreen(2,2)
			love.graphics.line(sx,sy,tx,ty)
			tx,ty = xyToScreen(-2,0)
			love.graphics.line(sx,sy,tx,ty)
			tx,ty = xyToScreen(0,-2)
			love.graphics.line(sx,sy,tx,ty)
			tx,ty = xyToScreen(-2,-2)
			love.graphics.line(sx,sy,tx,ty)
			drawShape(sx,sy,'gray',1)
		love.graphics.pop()
		
		love.graphics.push()
			love.graphics.translate(offset,-50)
			love.graphics.setColor(colors.helpline)
			love.graphics.setLineWidth(2)
			tx,ty = xyToScreen(2,1)
			love.graphics.line(sx,sy,tx,ty)
			tx,ty = xyToScreen(1,2)
			love.graphics.line(sx,sy,tx,ty)
			tx,ty = xyToScreen(1,-1)
			love.graphics.line(sx,sy,tx,ty)
			tx,ty = xyToScreen(-2,-1)
			love.graphics.line(sx,sy,tx,ty)
			tx,ty = xyToScreen(-1,-2)
			love.graphics.line(sx,sy,tx,ty)
			tx,ty = xyToScreen(-1,1)
			love.graphics.line(sx,sy,tx,ty)
			drawShape(sx,sy,'gray',1)
		love.graphics.pop()
		
		love.graphics.setFont(smallFont)
		love.graphics.setColor(colors.blue)
		
		local textWidth = 250
		love.graphics.printf('Rule 3: Connections can only go in certain directions',0,40,2*cx,'center')
		
		local alpha = (1-tween((timer-3)*4))*255
		love.graphics.setColor(colors.blue[1],colors.blue[2],colors.blue[3],alpha)
		love.graphics.printf('The six main directions',cx-offsetFull-0.5*textWidth,410,textWidth,'center')
		love.graphics.printf('And the diagonales in between',cx+offsetFull-0.5*textWidth,410,textWidth,'center')
		local alpha = (tween((timer-3)*4))*255
		love.graphics.setColor(colors.blue[1],colors.blue[2],colors.blue[3],alpha)
		love.graphics.printf('In the game, press [tab] to view all possible connections',cx-200,410,400,'center')
		
		-- rectangles to reveal parts individually
		local alpha = (1-tween((timer-1)*2))*255
		love.graphics.setColor(colors.tutorialbg[1],colors.tutorialbg[2],colors.tutorialbg[3],alpha)
		love.graphics.rectangle('fill',60,100,340,380)
		
		alpha = (1-tween((timer-2)*3))*255
		love.graphics.setColor(colors.tutorialbg[1],colors.tutorialbg[2],colors.tutorialbg[3],alpha)
		love.graphics.rectangle('fill',400,100,340,380)
	end
	
end

function tutorial.update(dt)
	timer = timer + dt
	timer = math.min(timer,phase)
	if number == 1 or number == 2 then
		skipButton.x = 550
		nextButton.y = 850
	elseif number == 3 then
		local weight = tween((timer-3)*3)
		skipButton.x = 550 * weight + 900 * (1-weight)
		nextButton.y = 620 * weight + 500 * (1-weight)
	end
	
	buttonTree.update(dt)
end

function tutorial.init(n)
	--love.graphics.setBackgroundColor(colors.tutorialbg)
	timer = 0
	number = n or 1
	phase = 1
	buttonTree.clear()
	nextButton = buttonTree.addButton(300,500,200,30,'Next',function() timer = phase phase = phase + 1 end)
	skipButton = buttonTree.addButton(900,500,200,30,'Ok, got it!',function() gotoState('game') end)
end

function tutorial.mousepressed(x,y,key)
	buttonTree.mousepressed(x,y,key)
end

function tutorial.mousereleased(x,y,key)
	buttonTree.mousereleased(x,y,key)
end

return tutorial
