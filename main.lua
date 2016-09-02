local createAnimator = require("animation")
local dispatcher = require("dispatcher")
local messages = require("messages")

local claimChecking = require("systems/claimChecking")
local clock = require("systems/clock")
local screen = require("systems/screen")
local desk = require("systems/desk")

local MOUSE_MOVE = messages.MOUSE_MOVE
local MOUSE_PRESS = messages.MOUSE_PRESS
local MOUSE_RELEASE = messages.MOUSE_RELEASE
local RENDER_BG = messages.RENDER_BG
local RENDER_FG = messages.RENDER_FG
local RENDER_UI = messages.RENDER_UI
local UPDATE = messages.UPDATE

local game = dispatcher.createDispatcher()

local debugActive = false
local debugAnimation = nil
local debugAlpha = 0

function love.load()
  claimChecking.register(game)
  clock.register(game)
  screen.register(game)
  desk.register(game)
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

function love.keypressed(key)

  if key == "q" or key == "escape" then
    love.event.quit(0)
  end

  if key == "d" then
    if debugActive then
      debugAnimation = createAnimator(debugAlpha, 0, 180, 20, 0.1, function (alpha) debugAlpha = alpha end)
      debugActive = false
    else
      debugAnimation = createAnimator(debugAlpha, 255, 180, 20, 0.1, function (alpha) debugAlpha = alpha end)
      debugActive = true
    end
  end
end

function love.update(dt)
  if dt > 1/10 then
    dt = 1/10
  end

  game:dispatch(UPDATE(dt))

  if debugAnimation and debugAnimation(dt) then
    debugAnimation = nil
  end
end

function love.draw()
  game:dispatch(RENDER_BG())
  game:dispatch(RENDER_FG())
  game:dispatch(RENDER_UI())

  if debugAlpha > 0 then
    love.graphics.push("all")

    love.graphics.setColor(0, 0, 0, 200 * debugAlpha/255)
    love.graphics.rectangle("fill", 0, 0, 240, 1080)
    love.graphics.rectangle("fill", 1580, 0, 340, 1080)

    love.graphics.setColor(255, 255, 255, debugAlpha)
    drawTableDebug(game, 10, 10)
    drawMessageLog(game.lastMessages, 1600, 10)

    love.graphics.pop()
  end
end

function drawTableDebug(t, x, y)
  for k, v in pairs(t) do
    if k ~= "on" and k ~= "dispatch" and k ~= "lastMessages" and k ~= "handlers" then
      if type(v) == "table" then
        love.graphics.print(k..": {", x, y)
        x = x + 20
        y = y + 14
        x, y = drawTableDebug(v, x, y)
        x = x - 20
        love.graphics.print("}", x, y)
        y = y + 14
      elseif type(v) == "string" then
        love.graphics.print(k..": \""..tostring(v).."\"", x, y)
        y = y + 14
      else
        love.graphics.print(k..": "..tostring(v), x, y)
        y = y + 14
      end
    end
  end
  return x, y
end

function drawMessageLog(log, x, y)
  for i, v in ipairs(log) do
    love.graphics.print(v, x, y)
    y = y + 14
  end
end
