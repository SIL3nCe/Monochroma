spriteManager = {}

local spriteSheet
local quadList = {}

function spriteManager.initialize()
	spriteSheet = love.graphics.newImage("resources/colored.png")
	nSprite = 32 -- 32 * 32 sprites
	spriteSize = 16
	
	for i = 0, nSprite - 1 do
		for j = 0, nSprite - 1 do
			table.insert(quadList, love.graphics.newQuad(spriteSize * j, spriteSize * i, spriteSize, spriteSize, spriteSheet:getDimensions()))
		end
	end
end

function spriteManager.draw(spriteId, alpha, x, y)
	assert(spriteId ~= nil, "spriteManager.draw : invalid spriteId")
	assert(spriteId > 0 and spriteId < 1025, "spriteManager.draw : " .. spriteId .. " is not a valid sprite id")
	
	love.graphics.setColor( 255, 255, 255, alpha)
	love.graphics.draw(spriteSheet, quadList[spriteId], x, y, 0 , 2, 2)
	love.graphics.setColor( 255, 255, 255, 1 )
end

return spriteManager