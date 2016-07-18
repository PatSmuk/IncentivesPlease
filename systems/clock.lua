local messages = require("../messages")
local DAY_END = messages.DAY_END
local START_HOUR = 9
local START_MIN = 0
local END_HOUR = 5
local END_MIN = 0

local clockRunning, currentHour, currentMin

function registerClock(game)
  print("Registering clock system")
  currentHour = START_HOUR
  currentMin = START_MIN
  clockRunning = true
  
  game:on('DAY_START', resetClock)
  game:on('UPDATE', updateClock)
  game:on('RENDER_UI', renderClock)
end

function resetClock(game, message)
	currentHour = START_HOUR
	currentMin = START_MIN
end

function updateClock(game, message)
	if not clockRunning then
		return
	end

	currentMin = currentMin + (message.dt * 3)

	if currentMin > 60 then
		currentHour = currentHour + 1
		currentMin = 0
	end

	if currentHour > 13 then
		currentHour = 1
	end

	if currentHour == END_HOUR then
		game:dispatch(DAY_END())
		clockRunning = false
	end
end

function renderClock(game, message)
	love.graphics.print(string.format("%.0f", currentHour) .. ":" .. string.format("%02.0f", currentMin), 10, 10)
end

return registerClock
