local winscreen = {}

function winscreen.draw()
	love.graphics.setColor(colors.gray)
	love.graphics.print('Winscreen',10,10)
end

function winscreen.update()
end

function winscreen.mousepressed()
end

return winscreen
