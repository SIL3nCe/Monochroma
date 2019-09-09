enemies = {}

local enemyList = {}

function enemies.stop()
	for i=1, #enemyList do
		enemyList[i] = nil
	end
end

function enemies.createEnemy(x, y, loot, key)
	enemy = 
	{
		cellX = x,
		cellY = y,
		spriteId = 32,
		
		damages = 1,
		life = 1,
		
		lootValue = loot,
		hasKey = key
	}
	
	table.insert(enemyList, enemy)
end

function enemies.takeDamages(enemyId, damages)
	if (enemyList[enemyId] == nil) then
		return
	end
	
	stdDebug = "enemy take damage " .. damages

	enemyList[enemyId].life = enemyList[enemyId].life - damages
	
	if (enemyList[enemyId].life <= 0) then
		dungeon.onEnemyDied(enemyList[enemyId].cellX, enemyList[enemyId].cellY, enemyList[enemyId].lootValue, enemyList[enemyId].hasKey)
		table.remove(enemyList, enemyId)
	end
end

function enemies.move()
	for i, enemy in ipairs(enemyList) do
		local direction = {}
		table.insert(direction, { x = 0, y = 0 })
		
		local cellState = dungeon.getCellContent(enemy.cellX + 1, enemy.cellY)
		if (cellState ~= nil and cellState.empty == true) then
			table.insert(direction, { x = 1, y = 0 })
		end
		
		cellState = dungeon.getCellContent(enemy.cellX - 1, enemy.cellY)
		if (cellState ~= nil and cellState.empty == true) then
			table.insert(direction, { x = -1, y = 0 })
		end
		
		cellState = dungeon.getCellContent(enemy.cellX , enemy.cellY + 1)
		if (cellState ~= nil and cellState.empty == true) then
			table.insert(direction, { x = 0, y = 1 })
		end
		
		cellState = dungeon.getCellContent(enemy.cellX, enemy.cellY - 1)
		if (cellState ~= nil and cellState.empty == true) then
			table.insert(direction, { x = 0, y = -1 })
		end
		
		rand = love.math.random(1, #direction)
		
		newCellX = enemy.cellX + direction[rand].x
		newCellY = enemy.cellY + direction[rand].y
		
		--todo rand move nothing,l,r,u,d
		
		if (newCellX >= 1 and newCellX <= dungeon.maxRowCell and newCellY >= 1 and newCellY <= dungeon.maxColumnCell) then
			cellState = dungeon.getCellContent(newCellX, newCellY)

			if (cellState.empty == true) then
				dungeon.onEnemyMoved(enemy.cellX, enemy.cellY, newCellX, newCellY)
				enemy.cellX = newCellX
				enemy.cellY = newCellY
			end
		end
	end
end

function enemies.update(dt)

end

function enemies.draw()
	for i, enemy in ipairs(enemyList) do
		spritemanager.draw(enemy.spriteId, false, 1, dungeon.getCellCoord(enemy.cellX, enemy.cellY))
	end
end

function enemies.getEnemyIdFromCoord(cellX, cellY)
	for i, enemy in ipairs(enemyList) do
		if (enemy.cellX == cellX) then
			if (enemy.cellY == cellY) then
				return i
			end
		end
	end
	
	return nil
end

function enemies.getEnemyDamages(enemyId)
	return enemyList[enemyId].damages
end

return enemies