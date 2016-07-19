local clock = {}

local messages = require("../messages")
local DAY_END = messages.DAY_END
local START_HOUR = 9
local START_MIN = 0
local END_HOUR = 10
local END_MIN = 59
local CLOCK_SPEED = 15

local font = love.graphics.newFont("assets/font/DS-DIGI.ttf", 60)
local amFont = love.graphics.newFont("assets/font/DS-DIGI.ttf", 17)
local calFont = love.graphics.newFont("assets/font/BebasNeue Bold.ttf", 40)

function clock.register(game)
  print("Registering clock system")
  game.clock = {}
  game.clock.currentHour = START_HOUR
  game.clock.currentMin = START_MIN
  game.clock.clockRunning = false
  game.clock.dayStarted = false
  game.clock.amOrPm = 'AM';
  game.clock.addSpace = true;

  game:on("DAY_START", clock.startDay)
  game:on('DAY_START', clock.resetClock)
  game:on('UPDATE', clock.updateClock)
  game:on('RENDER_UI', clock.renderClock)
  game:on('RENDER_UI', clock.renderCalender)
  game:on('DAY_END', clock.endDay)
end

function clock.resetClock(game, message)
	game.clock.currentHour = START_HOUR
	game.clock.currentMin = START_MIN
	game.clock.amOrPm = 'AM'
	game.clock.addSpace = true
end

function clock.updateClock(game, message)
	if not game.clock.clockRunning then
		return
	end

	game.clock.currentMin = game.clock.currentMin + (message.dt * CLOCK_SPEED)

	if game.clock.currentMin >= END_MIN then
		game.clock.currentHour = game.clock.currentHour + 1
		game.clock.currentMin = 0
	end

	if game.clock.currentHour >= 12 then
		game.clock.amOrPm = 'PM'
	end

	if game.clock.currentHour > 12 then
		game.clock.currentHour = 1
		game.clock.addSpace = true
	end

	if game.clock.currentHour > 9 and game.clock.currentHour <= 12 then
		game.clock.addSpace = false
	end 

	if game.clock.addSpace and game.clock.currentHour == 1 then
		game.clock.xpos = 405
	elseif game.clock.addSpace then 
		game.clock.xpos = 392
	elseif game.clock.currentHour == 11 then 
		game.clock.xpos = 390
	else
		game.clock.xpos = 385
	end

	if game.clock.currentHour == END_HOUR then
		game:dispatch(DAY_END(game.clock.day))
		game.clock.clockRunning = false
		return
	end
end

function clock.renderClock(game, message)
	if game.clock.dayStarted then
		love.graphics.push("all")
		love.graphics.setColor(255,0,0,255)



  	-- 	if game.clock.currentHour == END_HOUR - 1 and math.floor(game.clock.currentMin) % 2 == 1 then
			-- game.clock.isClockDark = true
			-- love.graphics.setColor(26,26,26,255)
	  -- 	else 
	  -- 		game.clock.isClockDark = false
	  -- 		love.graphics.setColor(255,0,0,255)
	  -- 	end


  		love.graphics.setFont(font)
		love.graphics.print(string.format("%.0f", game.clock.currentHour) .. ":" .. string.format("%02.0f", game.clock.currentMin), game.clock.xpos, 110)

		love.graphics.setFont(amFont)
		love.graphics.print(game.clock.amOrPm, 490, 103)
		love.graphics.pop()
	end
end

function clock.renderCalender(game, message)
	if game.clock.dayStarted then
		xpos = 538
		ypos = 150
		love.graphics.setFont(calFont)
		love.graphics.push("all")
		love.graphics.setColor(0,0,0,255)
		if game.clock.day == 1 then
			calDay = "Mon"
		elseif game.clock.day == 2 then
			calDay = "Tues"
		elseif game.clock.day == 3 then
			calDay = "Wed"
		elseif game.clock.day == 4 then
			calDay = "Thur"
		else
			calDay = "Fri"
		end
		love.graphics.printf(calDay, xpos, ypos, 70, "center")
		love.graphics.pop()
	end
end

function clock.startDay(game, message)
	game.clock.dayStarted = true
	game.clock.clockRunning = true
	game.clock.day = message.day
end

function clock.endDay(game, message)
	game.clock.dayStarted = false
end

return clock