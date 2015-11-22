local menu = {}
local buttons = {}
local activeButton
local downButton

function menu.init()
	local emptyfunc = function()	end
	buttonTree.clear()
	local w = 200
	local x = cx - 0.5*w
	local h = 30

	buttonTree.addButton(x,200,w,h,'Start Game',function() gotoState('levelselect') end)
	buttonTree.addButton(x,240,w,h,'Editor',function() gotoState('editor') end)
	buttonTree.addButton(x,280,w,h,'Toggle Fullscreen',emptyfunc)
	buttonTree.addButton(x,320,w,h,'Sound is on',emptyfunc)
	buttonTree.addButton(x,360,w,h,'Quit',function() love.event.quit() end)
end

function menu.update(dt)
	buttonTree.update(dt)
end

function menu.draw()
	buttonTree.draw()
end

function menu.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	end
end

function menu.mousepressed(x,y,key)
	buttonTree.mousepressed(x,y,key)
end

function menu.mousereleased(x,y,key)
	buttonTree.mousereleased(x,y,key)
end

return menu
