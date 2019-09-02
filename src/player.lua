player = { life = 3, damages = 1}

local cellX, cellY
local spriteId = 125

function player.initialize()
	fight.initialize()
end

function player.play(x, y)
	cellX = x
	cellY = y
end

function player.stop()

end

function player.update(dt)

end

function player.draw()
	spritemanager.draw(spriteId, 1, dungeon.getCellCoord(cellX, cellY))
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
		if (cellState.empty == true) then
			dungeon.onPlayerMoved(cellX, cellY, newCellX, newCellY)
			cellX = newCellX
			cellY = newCellY
			--enemies.move()
		elseif(cellState.enemy == true) then
			game.launchFight(cellX, cellY, newCellX, newCellY)
		end
end

return player