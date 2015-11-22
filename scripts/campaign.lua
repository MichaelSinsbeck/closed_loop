local campaign={levels={},chapters = {}}
local chapter = 0
local number = 1

local function newLevel(name)
  local newLevel = {name = name, text = '', nodes = {}, chapter = chapter, number = number}
  table.insert(campaign.levels,newLevel)
  number = number + 1
end

local function addText(text)
	local nLevels = #campaign.levels
	if nLevels > 0 then
		campaign.levels[nLevels].text = text
	else
		print('Error: Create a level first, then add text')
	end
end

local function newChapter(name)
	number = 1
	chapter = chapter + 1
	table.insert(campaign.chapters,name)
end

local function addNode(x,y,shape)
	local nLevels = #campaign.levels
	if nLevels > 0 then
		local newNode = {
			x = x,
			y = y,
			shape = shape,
		}
		table.insert(campaign.levels[nLevels].nodes,newNode)
	else
		print('Error: Create a level first, then add nodes')
	end
end

function campaign.startLevel(num)
	local level = campaign.levels[num]
	if level then
		-- add all the nodes
		clearLevel()
		for i,thisNode in ipairs(level.nodes) do
			--print('adding node: x = ' .. thisNode.x .. ', y = ' .. thisNode.y .. ', shape = ' .. thisNode.shape)
			insertNode(thisNode.x,thisNode.y,thisNode.shape)
		end
		levelName = level.name
		levelText = level.text
		levelNumber = num
		gotoState('game')
	else
		print('Error: Level '.. num .. ' does not exist')
	end
end

function campaign.loadLevels()
	newChapter('Introduction')
	
	newLevel('Hello')
	addText('Click the nodes to form a closed circuit')
	addNode(-2,-1,1)
	addNode(1,-1,1)
	addNode(1,2,1)

	newLevel('Intersection')
	addText('Line segments may not cross')
	addNode(-3,-2,1)
	addNode(-3,-1,1)
	addNode(-2,-3,1)
	addNode(-2,1,1)
	addNode(-1,-3,1)
	addNode(-1,2,1)
	addNode(1,-2,1)
	addNode(1,3,1)
	addNode(2,-1,1)
	addNode(2,3,1)
	addNode(3,1,1)
	addNode(3,2,1)
	
	newLevel('Around the clock')
	addText('Lines can only go in certain directions')
	addNode(-3,-2,1)
	addNode(-3,-1,1)
	addNode(0,0,1)
	addNode(0,2,1)
	addNode(1,-2,1)
	addNode(2,2,1)
	addNode(3,2,1)
	
	-- Be careful not to form two separate circuits
	-- By the way, each puzzle has only one unique solution.

	
	newLevel('Hello world')
	addText('Connect all nodes to form a closed circle')
	addNode(0,0,3)
	addNode(1,0,2)
	addNode(1,2,1)
	newLevel('2')
	addText('Information text is displayed at the bottom')
	addNode(0,0,3)
	addNode(1,0,2)
	addNode(1,2,1)
	newLevel('3')
	newChapter('Angles')
	newLevel('3')
	newChapter('Inside and outside')
	newLevel('Vier')
end


return campaign
