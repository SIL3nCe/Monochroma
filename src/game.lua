dungeon = require 'src/dungeon'
player = require 'src/player'
enemies = require 'src/enemies'
fight = require 'src/fight'

game = {}

local isInFight = false

function game.initialize()
	dungeon.initialize()
	player.initialize()
end

function game.play()
	dungeon.generateRoom(3)
end

function game.stop()
	dungeon.stop()
	player.stop()
	enemies.stop()
end

function game.update(dt)

end

function game.launchFight(playerX, playerY, enemyX, enemyY)
	isInFight = true
	fight.play(playerX, playerY, enemyX, enemyY)
end

function game.endFight()
	if (player.life <= 0) then
		-- gameover
	end
	
	fight.stop()
	isInFight = false
end

function game.draw()
	dungeon.draw()
	enemies.draw()
	player.draw()
	
	if (isInFight == true) then	
		fight.draw()
	end
end

function game.keypressed(key)
	if (isInFight == true) then
		fight.keypressed(key)
	else
		if key == "up" then
			player.move(-1, 0)
		elseif key == "down" then
			player.move(1, 0)
		elseif key == "left" then
			player.move(0, -1)
		elseif key == "right" then
			player.move(0, 1)
		end
	end
end

function game.mousepressed(x, y, button, istouch, presses)
end

function game.mousemoved(x, y, dx, dy, istouch)
end

return game