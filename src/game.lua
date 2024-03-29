dungeon = require 'src/dungeon'
player = require 'src/player'
enemies = require 'src/enemies'
fight = require 'src/fight'
hud = require 'src/affichagetetehaute'

game = {}

local isInFight = false

function game.initialize()
	dungeon.initialize()
	player.initialize()
end

function game.play()
	dungeon.play()
	dungeon.generateRoom(3)
end

function game.stop()
	dungeon.stop()
	player.stop()
	enemies.stop()
end

function game.update(dt)
	player.update(dt)
	enemies.update(dt)
	if (isInFight == true) then	
		fight.update(dt)
	end
end

function game.launchFight(playerX, playerY, enemyX, enemyY)
	isInFight = true
	fight.play(playerX, playerY, enemyX, enemyY)
end

function game.endFight()
	fight.stop()
	isInFight = false
end

function game.draw()
	dungeon.draw()
	player.draw()
	enemies.draw() -- after player to draw life on top of player
	hud.draw()
	
	if (isInFight == true) then	
		fight.draw()
	end
end

function game.launchNextRoom()
	game.stop()
	dungeon.roomId = dungeon.roomId + 1
	-- if 1 merchant/storekeeper/shopkeeper ?
	-- if 10, last level (boss?)
	-- if 11, leave dungeon
	dungeon.generateRoom(3)
end

function game.keypressed(key)
	if (key == "f1") then -- restart
		game.launchNextRoom()
	end
	
	if (isInFight == true) then
		fight.keypressed(key)
	else
		if (key == "up") then
			player.move(-1, 0)
		elseif (key == "down") then
			player.move(1, 0)
		elseif (key == "left") then
			player.move(0, -1)
		elseif (key == "right") then
			player.move(0, 1)
		end
	end
end

function game.mousepressed(x, y, button, istouch, presses)
end

function game.mousemoved(x, y, dx, dy, istouch)
end

return game