spritemanager = require 'src/spritemanager'

mainmenu = require 'src/mainmenu'
game = require 'src/game'

gameState = 
{
	mainmenu = false,
	game = true,
	pause = false
}

local currentState = game
local pausedAudioSources = nil

function switchState(newState)
	gameState[currentState.state] = false
	currentState.stop()
	currentState = newState
	currentState.play()
	gameState[currentState.state] = true
end

function love.load()
	love.window.setTitle("Monochroma")
	
	love.graphics.setDefaultFilter("nearest", "nearest") 

	strDebug = "..."

	spritemanager.initialize()
	
	mainmenu.initialize()
	game.initialize()
	
	currentState.play()
 end

function love.update(dt)
    if gameIsPaused then 
        return 
    end

	currentState.update(dt)
 end

function love.draw()
	currentState.draw()

	-- debug
    love.graphics.print(strDebug, 15, 15)
end

function love.focus(f) 
    gameIsPaused = not f
end

function love.quit()

end

function love.keypressed(key)
	currentState.keypressed(key)
end

function love.mousepressed(x, y, button, istouch, presses)
	currentState.mousepressed(x, y, button, istouch, presses)
end

function love.mousemoved(x, y, dx, dy, istouch)
	currentState.mousemoved(x, y, dx, dy, istouch)
end

-- UTILITIES
function copieTable(src) -- not recursive
	assert(src ~= nil)
	
	dst = { }
	for k, v in pairs(src) do
		dst[k] = v
	end
	
	return dst
end
