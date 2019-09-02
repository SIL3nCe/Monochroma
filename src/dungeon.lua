dungeon = { maxRowCell, maxColumnCell }

local currentStage

local widthOffset, heightOffset
local width, height = 25, 19
local spriteSize = 33 -- 16*16 scaled by 2
local grid = {}

local roomWidth, roomHeight = 14, 13
local roomStartWidth, roomStartHeight = 5, 3

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

function dungeon.stop()
	grid = nil
end

function dungeon.generateRoom(nEnemies)
	for i = 0, height - 1 do
		local rowTable = {}
		for j = 0, width - 1 do
			newCell = 
			{
				cellSprite = 1,
				empty = true,
				block = false,
				enemy = false,
				player = false,
				stair = false,
				vault = false
			}
			table.insert(rowTable, newCell)
		end
		table.insert(grid, rowTable)
	end
	
	local emptyList = {}
	for i = roomStartHeight, roomHeight do
		for j = roomStartWidth, roomWidth do
			if (grid[i][j] ~= nil) then
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
		
	
	-- Enemies spawn
	for i = 1, nEnemies do
		randId = love.math.random(1, #emptyList)
		enemies.createEnemy(emptyList[randId].x, emptyList[randId].y)
		
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
	
	grid[newX][newY].player = true
	grid[newX][newY].empty = false
end

function dungeon.onEnemyMoved(oldX, oldY, newX, newY)
	grid[oldX][oldY].enemy = false
	grid[oldX][oldY].empty = true
	
	if (newX ~= -1 and newY ~= -1) then
		grid[newX][newY].enemy = true
		grid[newX][newY].empty = false
	end
end

function dungeon.draw()
	for i = 1, height do
		for j = 1, width do
			if (grid[i][j] ~= nil) then
				spritemanager.draw(grid[i][j].cellSprite, 1, widthOffset + j * spriteSize, heightOffset + i * spriteSize)
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