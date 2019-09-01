fight = {}

local nCards = 13 -- per colors
local cardBack = 512
local cards = {} -- Base card game to use
local tempCards = {} -- Current card game used
local playerCards = {}
local enemyCards = {}

local enemyId

function fight.initialize()
	startLoc = 531
	local cardValue
	for i = 1, nCards do
		table.insert(cards, { id = i, hidden = false, value = (i < 10) and i or 10, spriteId = startLoc + i })
		table.insert(cards, { id = i, hidden = false, value = (i < 10) and i or 10, spriteId = startLoc + i + 32 })
		table.insert(cards, { id = i, hidden = false, value = (i < 10) and i or 10, spriteId = startLoc + i + 64 })
		table.insert(cards, { id = i, hidden = false, value = (i < 10) and i or 10, spriteId = startLoc + i + 96 })
	end
end

function fight.stop()
	for i in pairs(tempCards) do
		tempCards[i] = nil
	end

	for i in pairs(playerCards) do
		playerCards[i] = nil
	end
	
	for i in pairs(enemyCards) do
		enemyCards[i] = nil
	end
end

local function drawCard()
	rand = love.math.random(1, #tempCards)
	card = copieTable(tempCards[rand])
	table.remove(tempCards, rand)
	
	return card
end

function fight.play(cellX, cellY, enemyX, enemyY)
	enemyId = enemies.getEnemyIdFromCoord(enemyX, enemyY)
	for i,card in ipairs(cards) do
		table.insert(tempCards, copieTable(card))
	end
	
	playerCards.score = 0
	for i = 1, 2 do
		card = drawCard()
		table.insert(playerCards, card)
		playerCards.score = playerCards.score + card.value
	end
	
	for i = 1, 2 do
		table.insert(enemyCards, drawCard())
	end
	enemyCards.score = enemyCards[1].value
	enemyCards[2].hidden = true
	
	if (cellX < enemyX or cellY < enemyY) then -- come from the top or left
		playerCards.startX = cellX
		playerCards.startY = cellY - 1
		playerCards.direction = -1
		
		enemyCards.startX = enemyX
		enemyCards.startY = enemyY + 1
		enemyCards.direction = 1
	else -- from bottom or right
		playerCards.startX = cellX
		playerCards.startY = cellY + 1
		playerCards.direction = 1
		
		enemyCards.startX = enemyX
		enemyCards.startY = enemyY - 1
		enemyCards.direction = -1
	end
end

function fight.draw()
	--for i,card in ipairs(tempCards) do
	--	if (card.hidden == true) then
	--		spriteManager.draw(cardBack, 50 + (i - (math.floor(i / 13) * 13)) * 32, 50 + 32 * (math.floor(i / 13)))
	--	else
	--		spriteManager.draw(card.spriteId, 50 + (i - (math.floor(i / 13) * 13)) * 32, 50 + 32 * (math.floor(i / 13)))
	--	end
	--end
	--for i,card in ipairs(cards) do
	--	love.graphics.print(card.value, 50 + (i - (math.floor(i / 13) * 13)) * 32, 250 + 32 * (math.floor(i / 13)))
	--end
	
	playerY = playerCards.startY
	for i,card in ipairs(playerCards) do
		spriteManager.draw(card.spriteId, dungeon.getCellCoord(playerCards.startX, playerY))
		playerY = playerY + playerCards.direction
	end
	if (#playerCards ~= 0) then
		love.graphics.print(playerCards.score, dungeon.getCellCoord(playerCards.startX, playerY))
	end
	
	enemyY = enemyCards.startY
	for i,card in ipairs(enemyCards) do
		if (card.hidden == true) then
			spriteManager.draw(cardBack, dungeon.getCellCoord(enemyCards.startX, enemyY))
		else
			spriteManager.draw(card.spriteId, dungeon.getCellCoord(enemyCards.startX, enemyY))
		end
		enemyY = enemyY + enemyCards.direction
	end
	if (#enemyCards ~= 0) then
		love.graphics.print(enemyCards.score, dungeon.getCellCoord(enemyCards.startX, enemyY))
	end
end

function fight.keypressed(key)
	if key == "space" then -- draw
		rand = love.math.random(1,  #tempCards)
		table.insert(playerCards, tempCards[rand])
		playerCards.score = playerCards.score + tempCards[rand].value
		table.remove(tempCards, rand)	

		if (playerCards.score > 21) then 
			player.takeDamages(enemies.getEnemyDamages(enemyId))
			game.endFight()
		end

	elseif key == "rshift" then -- stop
		if (playerCards.score < enemyCards.score) then
			player.takeDamages(enemies.getEnemyDamages(enemyId))
		elseif (playerCards.score > enemyCards.score) then
			enemyCards.score = enemyCards.score + enemyCards[2].value
			enemyCards[2].hidden = false

			if (playerCards.score < enemyCards.score) then
				player.takeDamages(enemies.getEnemyDamages(enemyId))
			elseif (playerCards.score > enemyCards.score) then
				while(enemyCards.score < 22 or enemyCards.score < playerCards.score) do
					card = drawCard()
					table.insert(enemyCards, card)
					enemyCards.score = enemyCards.score + card.value
				end
				
				if (enemyCards.score > 21 or enemyCards.score < playerCards.score) then
					enemies.takeDamages(enemyId, player.damages)
				elseif (enemyCards.score > playerCards.score) then
					player.takeDamages(enemies.getEnemyDamages(enemyId))
				end
			end
		end
		
		game.endFight()
	end
end

return fight