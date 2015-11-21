local campaign={levels={}}

function newLevel(name)
  local newLevel = {name = name, text = '', nodes = {}}
  table.insert(campaign.levels,newLevel)
end

function addText(text)
	local nLevels = #campaign.levels
	if nLevels > 0 then
		campaign.levels[nLevels].text = text
	else
		print('Error: Create a level first, then add text')
	end
end

function addNode(x,y,shape)
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
		checkEverything()
		gotoState('game')
	else
		print('Error: Level '.. num .. ' does not exist')
	end
end

function campaign.loadLevels()
	newLevel('Hello world')
	addText('Connect all nodes to form a closed circle')
	addNode(0,0,3)
	addNode(1,0,2)
	addNode(1,2,1)
end


return campaign
