local buttonTree = {}

local buttons = {}
local activeButton
local downButton

function buttonTree.addButton(x,y,w,h,name,func,locked)
	local newButton = {
		name = name, 
		func = func,
		x = x,
		y = y,
		w = w,
		h = h,
		highlight = false,
		down = false,
		locked = locked
	}
	table.insert(buttons,newButton)
	return newButton
end

function buttonTree.clear()
	buttons = {}
	activeButton = nil
	downButton = nil
end

function buttonTree.draw()
	for i,b in ipairs(buttons) do
		if b.locked then
			love.graphics.setColor(colors.node)
			--love.graphics.rectangle('fill',b.x,b.y,b.w,b.h)
			love.graphics.rectangle('line',b.x,b.y,b.w,b.h)
			love.graphics.setColor(colors.helpline)
			love.graphics.setFont(smallFont)
			love.graphics.printf(b.name, b.x, b.y+0.5*b.h-12, b.w, 'center' )			
		else
			if b.down then
				love.graphics.setColor(colors.orange)
			elseif b.highlight and not downButton then
				love.graphics.setColor(colors.yellow)
			else
				love.graphics.setColor(colors.node)
			end
			love.graphics.rectangle('fill',b.x,b.y,b.w,b.h)
			love.graphics.rectangle('line',b.x,b.y,b.w,b.h)
			love.graphics.setColor(colors.gray)
			love.graphics.setFont(smallFont)
			love.graphics.printf(b.name, b.x, b.y+0.5*b.h-12, b.w, 'center' )
		end
	end
end

function buttonTree.update(dt)
	-- check whether a button is touched
	local mx,my = love.mouse.getPosition()
	activeButton = nil
	for i,b in ipairs(buttons) do
		if not b.locked then
			b.highlight = false
			b.down = false
			if mx >= b.x and my > b.y and mx <= b.x+b.w and  my <= b.y+b.h then
				activeButton = b
			end
		end
	end
	if activeButton then
		if activeButton == downButton then
			activeButton.down = true
		else
			activeButton.highlight = true
		end
	end
end

function buttonTree.mousepressed(x,y,key)
	if key == 'l' then
		if activeButton then
			downButton = activeButton
			--activeButton.func()
		else
			downButton = nil
		end
	end
end

function buttonTree.mousereleased(x,y,key)
	if key == 'l' then
		if activeButton and activeButton == downButton then
			activeButton.func()
		end
		downButton = nil
	end
end

return buttonTree
