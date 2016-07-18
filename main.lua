local dispatcher = require("dispatcher")
local messages = require("messages")
local registerClaimChecking = require("systems/claimChecking")
local registerClock = require("systems/clock")
local registerScreen = require("systems/screen")
local registerTable = require("systems/table")

local MOUSE_MOVE = messages.MOUSE_MOVE
local MOUSE_PRESS = messages.MOUSE_PRESS
local MOUSE_RELEASE = messages.MOUSE_RELEASE
local RENDER_BG = messages.RENDER_BG
local RENDER_FG = messages.RENDER_FG
local RENDER_UI = messages.RENDER_UI
local UPDATE = messages.UPDATE

local game = dispatcher.createDispatcher()

function love.load()
  registerClaimChecking(game)
  registerClock(game)
  registerScreen(game)
  registerTable(game)
end

function love.mousepressed(x, y, button)
  if button ~= 1 then
    return
  end
  game:dispatch(MOUSE_PRESS(x, y))
end

function love.mousemoved(x, y, dx, dy)
  game:dispatch(MOUSE_MOVE(x, y, dx, dy))
end

function love.mousereleased(x, y, button)
  if button ~= 1 then
    return
  end
  game:dispatch(MOUSE_RELEASE(x, y))
end

function love.update(dt)
  game:dispatch(UPDATE(dt))
end

function love.draw()
  game:dispatch(RENDER_BG())
  game:dispatch(RENDER_FG())
  game:dispatch(RENDER_UI())
end
