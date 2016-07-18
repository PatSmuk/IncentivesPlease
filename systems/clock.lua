local clock = {}

local messages = require("../messages")
local DAY_END = messages.DAY_END
local START_HOUR = 9
local START_MIN = 0
local END_HOUR = 5
local END_MIN = 59

function clock.register(game)
  print("Registering clock system")
  game.clock = {}
  game.clock.currentHour = START_HOUR
  game.clock.currentMin = START_MIN
  game.clock.clockRunning = true
  game.clock.amOrPm = 'AM';

  game:on('DAY_START', clock.resetClock)
  game:on('UPDATE', clock.updateClock)
  game:on('RENDER_UI', clock.renderClock)
end

function clock.resetClock(game, message)
	game.clock.currentHour = START_HOUR
	game.clock.currentMin = START_MIN
	game.clock.amOrPm = 'AM';
end

function clock.updateClock(game, message)
	if not game.clock.clockRunning then
		return
	end

	game.clock.currentMin = game.clock.currentMin + (message.dt * 3)

	if game.clock.currentMin >= END_MIN then
		game.clock.currentHour = game.clock.currentHour + 1
		game.clock.currentMin = 0
	end

	if game.clock.currentHour >= 12 then
		game.clock.amOrPm = 'PM'
	end

	if game.clock.currentHour > 12 then
		game.clock.currentHour = 1
	end

	if game.clock.currentHour == END_HOUR then
		game:dispatch(DAY_END())
		game.clock.clockRunning = false
		return
	end
end

function clock.renderClock(game, message)
	love.graphics.print(string.format("%.0f", game.clock.currentHour) .. ":" .. string.format("%02.0f", game.clock.currentMin) .. " " .. game.clock.amOrPm, 10, 10)
end

return clock
