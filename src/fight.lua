fight = {}

local nCards = 13 -- per colors
local cardBack = 512
local cards = {} -- Base card game to use
local tempCards = {} -- Current card game used
local playerCards = {}
local enemyCards = {}

local enemyId

local cardAnimation = false
local playerDraw, enemyDraw = false, false

function fight.initialize()
	startLoc = 531
	local cardValue
	for i = 1, nCards do
		table.insert(cards, { id = i, hidden = false, alpha = 0, value = (i < 10) and i or 10, spriteId = startLoc + i })
		table.insert(cards, { id = i, hidden = false, alpha = 0, value = (i < 10) and i or 10, spriteId = startLoc + i + 32 })
		table.insert(cards, { id = i, hidden = false, alpha = 0, value = (i < 10) and i or 10, spriteId = startLoc + i + 64 })
		table.insert(cards, { id = i, hidden = false, alpha = 0, value = (i < 10) and i or 10, spriteId = startLoc + i + 96 })
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
	
	enemyId = nil
	cardAnimation = false
	playerDraw, enemyDraw = false, false
end

local function drawCard()
	rand = love.math.random(1, #tempCards)
	card = copieTable(tempCards[rand])
	table.remove(tempCards, rand)
	
	return card
end

local function computeScore(cardList)
	local asCard =  false
	cardList.score = 0
	for i,card in ipairs(cardList) do
		if (card.hidden == false) then
			cardList.score = cardList.score + card.value
			if (card.value == 1) then
				asCard = true
			end
		end
	end
	
	if (asCard == true and cardList.score + 10 <= 21) then
		cardList.score = cardList.score + 10
	end
end

function fight.play(cellX, cellY, enemyX, enemyY)
	enemyId = enemies.getEnemyIdFromCoord(enemyX, enemyY)
	for i,card in ipairs(cards) do
		table.insert(tempCards, copieTable(card))
	end
	
	playerCards.score = 0
	for i = 1, 2 do
		table.insert(playerCards, drawCard())
	end
	
	enemyCards.score = 0
	for i = 1, 2 do
		table.insert(enemyCards, drawCard())
	end
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

function fight.update(dt)
	cardAnimation = false
	for i,card in ipairs(playerCards) do
		if (card.alpha < 1) then
			card.alpha = card.alpha + (0.1 * dt * 60)
			cardAnimation = true
		end
	end
	
	if (cardAnimation == false) then
		computeScore(playerCards)
		if (playerDraw == true) then
			if (playerCards.score > 21) then 
				player.takeDamages(enemies.getEnemyDamages(enemyId))
				game.endFight()
			end
			playerDraw = false
		end
	end
	
	for i,card in ipairs(enemyCards) do
		if (card.alpha < 1) then
			card.alpha = card.alpha + (0.1 * dt * 60)
			cardAnimation = true
		end
	end
	
	if (cardAnimation == false) then
		computeScore(enemyCards)
		if (enemyDraw == true) then
			if (enemyCards.score > 21) then
				enemies.takeDamages(enemyId, player.damages)
				game.endFight()
			elseif (playerCards.score < enemyCards.score) then
				player.takeDamages(enemies.getEnemyDamages(enemyId))
				game.endFight()
			elseif (playerCards.score > enemyCards.score) then
				table.insert(enemyCards, drawCard())
			else -- it's a draw
				game.endFight()
			end
		end
	end
end

function fight.draw()
	--for i,card in ipairs(tempCards) do
	--	if (card.hidden == true) then
	--		spriteManager.draw(cardBack, 1, 50 + (i - (math.floor(i / 13) * 13)) * 32, 50 + 32 * (math.floor(i / 13)))
	--	else
	--		spriteManager.draw(card.spriteId, 1, 50 + (i - (math.floor(i / 13) * 13)) * 32, 50 + 32 * (math.floor(i / 13)))
	--	end
	--end
	--for i,card in ipairs(cards) do
	--	love.graphics.print(card.value, 1, 50 + (i - (math.floor(i / 13) * 13)) * 32, 250 + 32 * (math.floor(i / 13)))
	--end
	
	playerY = playerCards.startY
	for i,card in ipairs(playerCards) do
		spriteManager.draw(card.spriteId, card.alpha, dungeon.getCellCoord(playerCards.startX, playerY))
		playerY = playerY + playerCards.direction
	end
	if (#playerCards ~= 0) then
		love.graphics.print(playerCards.score, dungeon.getCellCoord(playerCards.startX, playerY))
	end
	
	enemyY = enemyCards.startY
	for i,card in ipairs(enemyCards) do
		if (card.hidden == true) then
			spriteManager.draw(cardBack, card.alpha, dungeon.getCellCoord(enemyCards.startX, enemyY))
		else
			spriteManager.draw(card.spriteId, card.alpha, dungeon.getCellCoord(enemyCards.startX, enemyY))
		end
		enemyY = enemyY + enemyCards.direction
	end
	if (#enemyCards ~= 0) then
		love.graphics.print(enemyCards.score, dungeon.getCellCoord(enemyCards.startX, enemyY))
	end
end

function fight.keypressed(key)
	if cardAnimation then 
		return 
	end
	
	if key == "space" then -- draw
		table.insert(playerCards, drawCard())
		playerDraw = true
	elseif key == "rshift" then -- stop
		enemyCards[2].hidden = false
		enemyDraw = true
	end
end

return fight