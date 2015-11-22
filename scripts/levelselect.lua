local levelselect = {}

function levelselect.draw()
	for i,c in ipairs(campaign.chapters) do
		local y = i*100+60
		love.graphics.setColor(colors.gray)
		love.graphics.setFont(smallFont)
		love.graphics.printf(c, 90, y, 400, 'left' )
	end
	buttonTree.draw()
	--love.graphics.setColor(colors.gray)
	--love.graphics.print('Levelselect',10,10)
end

function levelselect.init()
	buttonTree.clear()
	for i,l in ipairs(campaign.levels) do
		local locked = false
		if i > lastLevel then locked = true end
		local thisName = '' .. l.number
		local x = l.number * 50 + 50
		local y = l.chapter * 100 + 100
		buttonTree.addButton(x,y,40,40,thisName,function() campaign.startLevel(i) end,locked)
	end
end

function levelselect.update(dt)
	buttonTree.update(dt)
end

function levelselect.keypressed(key)
	if key == 'escape' then
		gotoState('menu')
	end
end

function levelselect.mousepressed(x,y,key)
	buttonTree.mousepressed(x,y,key)
end

function levelselect.mousereleased(x,y,key)
	buttonTree.mousereleased(x,y,key)
end

return levelselect
