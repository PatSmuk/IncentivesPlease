local messages = require("../messages")
local DAY_END = messages.DAY_END
local START_HOUR = 9
local START_MIN = 0
local END_HOUR = 5
local END_MIN = 0

function registerClock(game)
  print("Registering clock system")
  game.clock = {}
  game.clock.currentHour = START_HOUR
  game.clock.currentMin = START_MIN
  game.clock.clockRunning = true
  
  game:on('DAY_START', resetClock)
  game:on('UPDATE', updateClock)
  game:on('RENDER_UI', renderClock)
end

function resetClock(game, message)
	game.clock.currentHour = START_HOUR
	game.clock.currentMin = START_MIN
end

function updateClock(game, message)
	if not game.clock.clockRunning then
		return
	end

	game.clock.currentMin = game.clock.currentMin + (message.dt * 3)

	if game.clock.currentMin > 60 then
		game.clock.currentHour = game.clock.currentHour + 1
		game.clock.currentMin = 0
	end

	if game.clock.currentHour > 13 then
		game.clock.currentHour = 1
	end

	if game.clock.currentHour == END_HOUR then
		game:dispatch(DAY_END())
		clockRunning = false
	end
end

function renderClock(game, message)
	love.graphics.print(string.format("%.0f", game.clock.currentHour) .. ":" .. string.format("%02.0f", game.clock.currentMin), 10, 10)
end

return registerClock
