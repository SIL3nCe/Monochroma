player = { baseLife = 3, life, damages = 1, golds = 0, foundKey} -- todo centralize datas for serializing

local cellX, cellY
local spriteId = 125

playerSpriteAlpha = 1

local damageBlink, damageCpt = 0, 0.0
local nextDamageToTake = 0
local blinkSpeedFactor = 1.4 -- 1.4 for damage, 1.1 for death

function player.initialize()
	fight.initialize()
end

function player.play(x, y)
	cellX = x
	cellY = y
	
	player.life = player.baseLife
	
	damageBlink = 0
	damageCpt = 0.0
	
	playerSpriteAlpha = 1
	
	player.foundKey = false
end

function player.stop()

end

function player.update(dt)
	-- damage/death anim
	if damageBlink > 0 then
		damageCpt = (damageCpt + dt) * blinkSpeedFactor
		playerSpriteAlpha = math.cos(damageCpt)
		
		if blinkSpeedFactor == 1.1 then -- means death
			if playerSpriteAlpha <= 0 then
				game.endFight()
				game.launchNextRoom() -- TODO leave dungeon instead
				return
			end
		end
		
		if damageCpt >= math.pi * 2 then
			damageBlink = damageBlink - 1
			damageCpt = 0
			
			if damageBlink == 0 then
				playerSpriteAlpha = 1
				player.life = player.life - nextDamageToTake
				nextDamageToTake = 0
				game.endFight()
			end
		end
	end
end

function player.draw()
	spritemanager.draw(spriteId, true, playerSpriteAlpha, dungeon.getCellCoord(cellX, cellY))
end

function player.takeDamages(damages)
	blinkSpeedFactor = player.life - damages <= 0 and 1.1 or 1.4
	nextDamageToTake = damages
	damageBlink = 3
	damageCpt = 0
end

function player.move(x, y)
		newCellX = cellX + x
		newCellY = cellY + y
		
		if (newCellX < 1 or newCellX > dungeon.maxColumnCell or newCellY < 1 or newCellY > dungeon.maxRowCell) then
			return
		end
		
		cellState = dungeon.getCellContent(newCellX, newCellY)
		--strDebug = cellX .. "," .. cellY .. " " .. newCellX.. "," .. newCellY
		
		if (cellState.loot == true) then
			cellState.loot = false
			cellState.empty = true
			cellState.cellSprite = cellState.baseCellSprite
			player.golds = player.golds + cellState.value
		elseif (cellState.key == true) then
			cellState.key = false
			cellState.empty = true
			cellState.cellSprite = cellState.baseCellSprite
			player.golds = player.golds + cellState.value
			player.foundKey = true
		end
		
		if (cellState.empty == true) then
			dungeon.onPlayerMoved(cellX, cellY, newCellX, newCellY)
			cellX = newCellX
			cellY = newCellY
			enemies.move()
		elseif(cellState.enemy == true) then
			game.launchFight(cellX, cellY, newCellX, newCellY)
		elseif (cellState.roomExit == true and player.foundKey == true) then
			game.launchNextRoom()
		end
end

return player