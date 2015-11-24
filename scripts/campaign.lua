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

local function addTutorial(number)
	local nLevels = #campaign.levels
	campaign.levels[nLevels].tutorial = number
end

local function addNode(x,y,shape,connections)
	local nLevels = #campaign.levels
	if nLevels > 0 then
		local newNode = {
			x = x,
			y = y,
			shape = shape,
			connections = connections,
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
			insertNode(thisNode.x,thisNode.y,thisNode.shape,thisNode.connections)
		end
		levelName = level.name
		levelText = level.text
		levelNumber = num
		if level.tutorial then
			gotoState('tutorial',level.tutorial)
		else
			gotoState('game')
		end
	else
		print('Error: Level '.. num .. ' does not exist')
	end
end

function campaign.loadLevels()
	newChapter('Introduction')
	
	newLevel('Level 1.1')
	--addText('Click the nodes to form a closed circuit')
	addTutorial(1)
	addNode(-2,-1,1,1)
	addNode(0,0,1,3)
	addNode(1,-1,1,1)
	addNode(1,2,1,1)


	newLevel('Level 1.2')
	--addText('Line segments may not cross')
	addTutorial(2)
	addNode(-2,-1,1,1)
	addNode(-1,1,1,2)
	addNode(1,-1,1,1)
	addNode(1,2,1,2)
	addNode(2,1,1,2)


	
	newLevel('On the Grid')
	--addText('')
	addTutorial(3)
	addNode(-3,-2,1,2)
	addNode(-3,-1,1,2)
	addNode(0,0,1,2)
	addNode(0,2,1,2)
	addNode(1,-2,1,2)
	addNode(2,2,1,2)
	addNode(3,2,1,2)
	
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
