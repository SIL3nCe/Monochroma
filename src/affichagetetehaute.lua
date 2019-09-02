hud = {}

local heartFull = 731
local heartEmpty = 729

local heartX, heartY = 2, 1

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
end

return hud