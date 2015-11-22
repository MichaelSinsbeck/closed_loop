local menu = {}
local buttons = {}
local activeButton
local downButton

local function addbutton(name,func)
	local w = 200
	local nButtons = #buttons
	local newButton = {
		name = name, 
		func = func,
		x = cx-0.5*w,
		w = w,
		y = 200+nButtons*40,
		h = 30,
		highlight = false,
	}
	table.insert(buttons,newButton)
end

function drawButtons()
	for i,b in ipairs(buttons) do
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
		love.graphics.printf(b.name, b.x, b.y+3, b.w, 'center' )
	end
end

function menu.init()
	local emptyfunc = function()
		--print('hallo')
	end
	addbutton('Start Game',function() gotoState('game') end)
	addbutton('Editor',emptyfunc)
	addbutton('Toggle Fullscreen',emptyfunc)
	addbutton('Sound is on',emptyfunc)
	addbutton('Quit',function() love.event.quit() end)
end

function menu.update(dt)
	-- check whether a button is touched
	local mx,my = love.mouse.getPosition()
	activeButton = nil
	for i,b in ipairs(buttons) do
		b.highlight = false
		b.down = false
		if mx >= b.x and my > b.y and mx <= b.x+b.w and  my <= b.y+b.h then
		  activeButton = b
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

function menu.draw()
	drawButtons()
end

function menu.mousepressed()
	if activeButton then
		downButton = activeButton
		--activeButton.func()
	else
		downButton = nil
	end
end

function menu.keypressed(key)
	if key == 'return' then
		campaign.startLevel(1)
	end
end

function menu.mousereleased(x,y,key)
	if activeButton and activeButton == downButton then
		activeButton.func()
	end
	downButton = nil
end

return menu
