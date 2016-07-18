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
  level_complete = {}
}

function endDay(game, message)
  game.screen.currentScreen = "level_complete"
end

function renderBG(game, message)
  if game.screen.currentScreen == "menu" then

  elseif game.screen.currentScreen == "game" then

  elseif game.screen.currentScreen == "level_complete" then

  end
end

function renderUI(game, message)
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

function mousePress(game, message)
  for k, button in pairs(buttons[game.screen.currentScreen]) do
    if message.x >= button.x and
       message.x <= button.x + button.width and
       message.y >= button.y and
       message.y <= button.y + button.height then
      game.screen.buttonPressed = k
    end
  end
end

function mouseRelease(game, message)
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

function registerScreen(game)
  print("Registering screen system")

  game.screen = {
    currentScreen = "menu",
    currentDay = 0,
    buttonPressed = nil
  }

  game:on('DAY_END', endDay)
  game:on('RENDER_BG', renderBG)
  game:on('RENDER_UI', renderUI)
  game:on('MOUSE_PRESS', mousePress)
  game:on('MOUSE_RELEASE', mouseRelease)
end

return registerScreen
