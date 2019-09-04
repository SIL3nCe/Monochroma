hud = {}

local heartFull = 731
local heartEmpty = 729
local heartX, heartY = 2, 1

local goldSprite = 810
local goldX, goldY = heartX + 2, heartY + 1

local keySprite = 755
local keyX, keyY = goldX + 2, goldY


function hud.initialize()

end

function hud.play()
end

function hud.stop()
end

function hud.draw()	
	for i = 1, player.baseLife do
		local sprite = player.life >= i and heartFull or heartEmpty
		spriteManager.draw(sprite, 1, dungeon.getCellCoord(heartX, heartY + i))
	end
	
	spriteManager.draw(goldSprite, 1, dungeon.getCellCoord(goldX, goldY))
    love.graphics.print(player.golds, dungeon.getCellCoord(goldX, goldY + 1))
	
	if (player.foundKey == true) then
		spriteManager.draw(keySprite, 1, dungeon.getCellCoord(keyX, keyY))
	end
end

return hud