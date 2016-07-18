local screen = {}

local messages = require("../messages")

local buttons = {
  menu = {
    start = {
      x = 500,
      y = 320,
      width = 120,
      height = 40,
      onClick = function (game)
        game.screen.currentScreen = "game"
        game.screen.currentDay = 1
        game:dispatch(messages.DAY_START(game.screen.currentDay))
      end
    },
    quit = {
      x = 660,
      y = 320,
      width = 120,
      height = 40,
      onClick = function (game)
        love.window.close()
      end
    }
  },
  game = {},
  levelComplete = {
    nextLevel = {
      x = 580,
      y = 560,
      width = 120,
      height = 40,
      onClick = function (game)
        game.screen.currentScreen "game"
        game.screen.currentDay = game.screen.currentDay + 1
        game:dispatch(messages.DAY_START(game.screen.currentDay))
      end
    }
  }
}

function screen.endDay(game, message)
  game.screen.currentScreen = "levelComplete"
end

function screen.renderBG(game, message)
  if game.screen.currentScreen == "menu" then

  elseif game.screen.currentScreen == "game" then

  elseif game.screen.currentScreen == "levelComplete" then

  end
end

function screen.renderUI(game, message)
  for k, button in pairs(buttons[game.screen.currentScreen]) do
    love.graphics.rectangle(
      "fill",
      button.x,
      button.y,
      button.width,
      button.height
    )
  end
end

function screen.mousePress(game, message)
  for k, button in pairs(buttons[game.screen.currentScreen]) do
    if message.x >= button.x and
       message.x <= button.x + button.width and
       message.y >= button.y and
       message.y <= button.y + button.height then
      game.screen.buttonPressed = k
    end
  end
end

function screen.mouseRelease(game, message)
  for k, button in pairs(buttons[game.screen.currentScreen]) do
    if message.x >= button.x and
       message.x <= button.x + button.width and
       message.y >= button.y and
       message.y <= button.y + button.height and
       game.screen.buttonPressed == k then
      button.onClick(game)
    end
  end

  game.screen.buttonPressed = nil
end

function screen.register(game)
  print("Registering screen system")

  game.screen = {
    currentScreen = "menu",
    currentDay = 0,
    buttonPressed = nil
  }

  game:on('DAY_END', screen.endDay)
  game:on('RENDER_BG', screen.renderBG)
  game:on('RENDER_UI', screen.renderUI)
  game:on('MOUSE_PRESS', screen.mousePress)
  game:on('MOUSE_RELEASE', screen.mouseRelease)
end

return screen
