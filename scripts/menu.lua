local menu = {}
local buttons = {}
local activeButton

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
		if b.highlight then
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
		print('hallo')
	end
	addbutton('Start Game',function() gotoState('game') end)
	addbutton('Editor',emptyfunc)
	addbutton('Toggle Fullscreen',emptyfunc)
	addbutton('Sound is on',emptyfunc)
	addbutton('Quit',emptyfunc)
end

function menu.update(dt)
	-- check whether a button is touched
	local mx,my = love.mouse.getPosition()
	activeButton = nil
	for i,b in ipairs(buttons) do
		b.highlight = false
		if mx >= b.x and my > b.y and mx <= b.x+b.w and  my <= b.y+b.h then
		  activeButton = b
		end
	end
	if activeButton then
		activeButton.highlight = true
	end
end

function menu.draw()
	drawButtons()
end

function menu.mousepressed()
	if activeButton then
		activeButton.func()
	end
end

function menu.keypressed(key)
	if key == 'return' then
		campaign.startLevel(1)
	end
end

return menu
