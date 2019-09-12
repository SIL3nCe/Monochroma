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
		spriteAlpha = 1,
		
		damages = 1,
		life = 1,
		
		lootValue = loot,
		hasKey = key,
		
		damageBlink = 0,
		damageCpt =	0.0,
		nextDamageToTake = 0,
		blinkSpeedFactor = 1.4 -- 1.4 for damage, 1.05 for death
	}
	
	table.insert(enemyList, enemy)
end

function enemies.takeDamages(enemyId, damages)
	if (enemyList[enemyId] == nil) then
		return
	end
	
	enemyList[enemyId].blinkSpeedFactor = enemyList[enemyId].life - damages <= 0 and 1.05 or 1.4
	
	if enemyList[enemyId].blinkSpeedFactor ~= 1.4 then -- spawn loot before fading
		dungeon.onEnemyDied(enemyList[enemyId].cellX, enemyList[enemyId].cellY, enemyList[enemyId].lootValue, enemyList[enemyId].hasKey)
	end
	
	enemyList[enemyId].nextDamageToTake = damages
	enemyList[enemyId].damageBlink = 2
	enemyList[enemyId].damageCpt = 0
	
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
	for i, enemy in ipairs(enemyList) do
		-- damage/death anim
		if enemy.damageBlink > 0 then
			enemy.damageCpt = (enemy.damageCpt + dt) * enemy.blinkSpeedFactor
			enemy.spriteAlpha = math.cos(enemy.damageCpt)
			
			if enemy.blinkSpeedFactor ~= 1.4 then -- means death
				if enemy.spriteAlpha <= 0 then
					game.endFight()
					table.remove(enemyList, i)
					return
				end
			end
			
			if enemy.damageCpt >= math.pi * 2 then
				enemy.damageBlink = enemy.damageBlink - 1
				enemy.damageCpt = 0
				
				if enemy.damageBlink == 0 then
					enemy.spriteAlpha = 1
					enemy.life = enemy.life - enemy.nextDamageToTake
					enemy.nextDamageToTake = 0
					game.endFight()
				end
			end
		end
	end
end

function enemies.draw()
	for i, enemy in ipairs(enemyList) do
		spritemanager.draw(enemy.spriteId, false, enemy.spriteAlpha, dungeon.getCellCoord(enemy.cellX, enemy.cellY))
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