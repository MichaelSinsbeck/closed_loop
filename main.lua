require 'scripts/shape'
require 'scripts/logic'
require 'scripts/utility'
colors = require 'scripts/colors'
campaign = require 'scripts/campaign'
buttonTree = require 'scripts/buttonTree'

function love.load()
	-- load game states
	states = {
		menu = require 'scripts/menu',
		game = require 'scripts/game',
		editor = require 'scripts/editor',
		levelselect = require 'scripts/levelselect',
		winscreen = require 'scripts/winscreen',
		tutorial = require 'scripts/tutorial',
	}
	campaign.loadLevels()
	lastLevel = 100
	
	--[[largeFont = love.graphics.newFont('font/CaviarDreams.ttf',50)	
	smallFont = love.graphics.newFont('font/Caviar_Dreams_Bold.ttf',20)
	tinyFont = love.graphics.newFont('font/Caviar_Dreams_Bold.ttf',14)--]]
	
	largeFont = love.graphics.newFont('font/MEgalopolisExtra.otf',50)	
	smallFont = love.graphics.newFont('font/MEgalopolisExtra.otf',20)
	tinyFont = love.graphics.newFont('font/MEgalopolisExtra.otf',16)
	
	size = 3
	gridSize = 70
	tol = 1e-2 -- tolerance for angle check
	x1 = gridSize
	x2 = 0
	y1 = -0.5*gridSize
	y2 = math.floor(-math.sqrt(3/4)*gridSize)
	cx = 400
	cy = 300
	initShapes()
	love.graphics.setBackgroundColor(colors.bg)
	nodes = {}
	--[[for x = -size,size do
		local lb,ub = yBound(x,size)
		for y = lb,ub do
			if love.math.random(2) == 1 then
				insertNode(x,y,love.math.random(3))
			end
			--nodes[#nodes+1] = {x=x,y=y,shape=3,cursor=false,lines={}}
		end
	end--]]
	
	--[[ Testlevel
	nodes[1] = {x=0,y=0,shape=1,cursor=false,lines={}}
	nodes[2] = {x=1,y=0,shape=2,cursor=false,lines={}}
	nodes[3] = {x=1,y=1,shape=3,cursor=false,lines={}}
	nodes[4] = {x=2,y=0,shape=1,cursor=false,lines={}}--]]
	
	--[[for i = 1,5 do
		nodes[i] = {
			x = love.math.random(2*size-1)-size,
			y = love.math.random(2*size-1)-size,
			shape = love.math.random(3),
			cursor = false,
			lines = {},
		}
	end--]]
	lines = {}
	drawingLine = false
	countLines()

	gotoState('menu')
end

function gotoState(newState,opts)
	gameState = newState
	if states[gameState].init then
		states[gameState].init(opts)
	end
end

function love.update(dt)
	if states[gameState].update then
		states[gameState].update(dt)
	end
end

function love.draw()
	if states[gameState].draw then
		states[gameState].draw()
	end
end

function love.keypressed( key)
	if states[gameState].keypressed then
		states[gameState].keypressed(key)
	end 
	if key == 'f1' then
		for k,v in pairs(_G) do
			print(k)
		end
	end
end

function love.mousepressed(x,y,key)
	if states[gameState].mousepressed then
		states[gameState].mousepressed(x,y,key)
	end
end

function love.mousereleased(x,y,key)
	if states[gameState].mousereleased then
		states[gameState].mousereleased(x,y,key)
	end
end
