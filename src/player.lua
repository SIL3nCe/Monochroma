player = { baseLife = 3, life, damages = 1, golds = 0, foundKey} -- todo centralize datas for serializing

local cellX, cellY
local spriteId = 125

function player.initialize()
	fight.initialize()
end

function player.play(x, y)
	cellX = x
	cellY = y
	
	player.life = player.baseLife
	
	player.foundKey = false
end

function player.stop()

end

function player.update(dt)

end

function player.draw()
	spritemanager.draw(spriteId, true, 1, dungeon.getCellCoord(cellX, cellY))
end

function player.takeDamages(damages)
	stdDebug = "player take damage " .. damages
	player.life = player.life - damages
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