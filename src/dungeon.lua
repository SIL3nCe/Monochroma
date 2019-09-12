dungeon = { maxRowCell, maxColumnCell, dungeonName, roomId }

local currentStage

local widthOffset, heightOffset
local width, height = 25, 19
local spriteSize = 32 -- 16*16 scaled by 2
local grid = {}

local roomWidth, roomHeight = 15, 13
local roomStartWidth, roomStartHeight = 5, 4

local lootSpriteId, keySpriteId = 842, 755

function dungeon.initialize()
	currentStage = 1
	local windowSize, windowHeight = love.graphics.getDimensions()
	--widthOffset = ((windowSize / 2) - ((width / 2) * spriteSize))
	--heightOffset = ((windowHeight / 2) - ((height / 2) * spriteSize))
	widthOffset = -32
	heightOffset = -32
	
	dungeon.maxRowCell = width
	dungeon.maxColumnCell = height
end

function dungeon.play()
	dungeon.dungeonName = "dungeonname"
	dungeon.roomId = 0
end

function dungeon.stop()
	for i in pairs(grid) do
		grid[i] = nil
	end
end

function dungeon.generateRoom(nEnemies)
	for i = 0, height - 1 do
		local rowTable = {}
		for j = 0, width - 1 do
			newCell = 
			{
				cellSprite = 1,
				baseCellSprite = 1,
				value = 0,
				colored = false,
				empty = true,
				block = false,
				enemy = false,
				loot = false,
				key = false,
				player = false,
				roomExit = false,
				vault = false
			}
			table.insert(rowTable, newCell)
		end
		table.insert(grid, rowTable)
	end
	
	-- Generate walls - todo pcg rooms
	for i = roomStartHeight, roomStartHeight + roomHeight do
		if (i == roomStartHeight or i == roomStartHeight + roomHeight) then
			for j = roomStartWidth, roomStartWidth + roomWidth do
				grid[i][j].empty = false
				grid[i][j].block = true
				grid[i][j].cellSprite = 102
			end
		else
			grid[i][roomStartWidth].empty = false
			grid[i][roomStartWidth].block = true
			grid[i][roomStartWidth].cellSprite = 102
			grid[i][roomStartWidth + roomWidth].empty = false
			grid[i][roomStartWidth + roomWidth].block = true
			grid[i][roomStartWidth + roomWidth].cellSprite = 102
		end
	end
	
	local emptyList = {}
	for i = roomStartHeight, roomStartHeight + roomHeight do
		for j = roomStartWidth, roomStartWidth + roomWidth do
			if (grid[i][j] ~= nil and grid[i][j].empty == true) then
				table.insert(emptyList, {x = i, y = j})
			end
		end
	end
	
	-- Player spawn
	local randId = love.math.random(1, #emptyList)
	player.play(emptyList[randId].x, emptyList[randId].y)
	grid[emptyList[randId].x][emptyList[randId].y].empty = false
	grid[emptyList[randId].x][emptyList[randId].y].player = true
	table.remove(emptyList, randId)
		
	-- Exit
	randId = love.math.random(1, #emptyList)
	grid[emptyList[randId].x][emptyList[randId].y].empty = false
	grid[emptyList[randId].x][emptyList[randId].y].roomExit = true
	grid[emptyList[randId].x][emptyList[randId].y].cellSprite = 196
	table.remove(emptyList, randId)
	
	-- Enemies spawn
	for i = 1, nEnemies do
		randId = love.math.random(1, #emptyList)
		lootVal = i == 1 and 50 or love.math.random(10, 20)
		enemies.createEnemy(emptyList[randId].x, emptyList[randId].y, lootVal, i == 1)
		
		grid[emptyList[randId].x][emptyList[randId].y].empty = false
		grid[emptyList[randId].x][emptyList[randId].y].enemy = true
		
		table.remove(emptyList, randId)
		
		if (#emptyList == 0) then
			return
		end
	end	
end

function dungeon.onPlayerMoved(oldX, oldY, newX, newY)
	grid[oldX][oldY].player = false
	grid[oldX][oldY].empty = true
	grid[oldX][oldY].colored = true
	
	grid[newX][newY].player = true
	grid[newX][newY].empty = false
	grid[newX][newY].colored = true
end

function dungeon.onEnemyMoved(oldX, oldY, newX, newY)
	grid[oldX][oldY].enemy = false
	grid[oldX][oldY].empty = true
	grid[oldX][oldY].colored = false
	
	grid[newX][newY].enemy = true
	grid[newX][newY].empty = false
	grid[newX][newY].colored = false
end

function dungeon.onEnemyDied(x, y, loot, key)
	strDebug = loot .. " " .. tostring(key)
	if (key == true) then
		grid[x][y].enemy = false
		grid[x][y].key = true
		grid[x][y].cellSprite = keySpriteId
	else
		grid[x][y].enemy = false
		grid[x][y].loot = true
		grid[x][y].cellSprite = lootSpriteId
	end
	grid[x][y].value = loot
	grid[x][y].colored = true
	
	for height = -2, 2 do
		for width = -2, 2 do
			local randId = love.math.random(0, 100)
			local chance = (height > -2 and height < 2 and width > -2 and width < 2) and 100 or 50
			if (randId <= chance) then
				grid[x + height][y + width].colored = true
			end
		end
	end
end

function dungeon.draw()
	for i = 1, height do
		for j = 1, width do
			if (grid[i][j] ~= nil) then
				spritemanager.draw(grid[i][j].cellSprite, grid[i][j].colored, 1, widthOffset + j * spriteSize, heightOffset + i * spriteSize)
				--love.graphics.print(grid[i][j].value, widthOffset + j * spriteSize, heightOffset + i * spriteSize)
				--love.graphics.print(i * width + j, widthOffset + j * spriteSize, heightOffset + i * spriteSize)
				--love.graphics.print(i .. "," .. j, widthOffset + j * spriteSize, heightOffset + i * spriteSize)
				--if (grid[i][j].empty == true)then
				--	love.graphics.print("-", widthOffset + j * spriteSize + 16, heightOffset + i * spriteSize + 16)
				--end
				--if (grid[i][j].enemy == true)then
				--	love.graphics.print("#", widthOffset + j * spriteSize + 16, heightOffset + i * spriteSize + 16)
				--end
			end
		end
	end
end

function dungeon.getCellCoord(cellX, cellY)
	if (cellX < 1 or cellX > dungeon.maxColumnCell or cellY < 1 or cellY > dungeon.maxRowCell) then
		return
	end
	
	local width = widthOffset + cellY * spriteSize
	local height = heightOffset + cellX * spriteSize
	
	--strDebug = strDebug .. "\n" .. " " .. cellX .. " " .. cellY .. " " .. width .. " " .. height
	
	return width, height
end

function dungeon.getCellContent(cellX, cellY)
	if (cellX < 1 or cellX > dungeon.maxColumnCell or cellY < 1 or cellY > dungeon.maxRowCell) then
		return nil
	end
	
	return grid[cellX][cellY]
end

return dungeon