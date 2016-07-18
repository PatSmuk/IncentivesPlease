local messages = require("../messages")

local buttons = {
  menu = {
    start = {
      imgPath = "assets/graphics/startButton.png",
      img = nil,
      x = 536,
      y = 400,
      widthScale = 0.1,
      heightScale = 0.1,
      onClick = function (game)
        game.screen.currentScreen = "game"
        game.screen.currentDay = 1
        game:dispatch(messages.DAY_START(game.screen.currentDay))
      end
    },
    quit = {
      imgPath = "assets/graphics/exitButton.png",
      img = nil,
      x = 536,
      y = 460,
      widthScale = 0.1,
      heightScale = 0.1,
      onClick = function (game)
        love.window.close()
      end
    }
  },
  game = {},
  levelComplete = {
    nextLevel = {
      imgPath = "assets/graphics/startButton.png",
      img = nil,
      x = 580,
      y = 560,
      widthScale = 0.1,
      heightScale = 0.1,
      onClick = function (game)
        game.screen.currentScreen "game"
        game.screen.currentDay = game.screen.currentDay + 1
        game:dispatch(messages.DAY_START(game.screen.currentDay))
      end
    }
  }
}

local backgrounds = {
  menu = {},
  game = {},
  levelComplete = {}
}

function endDay(game, message)
  game.screen.currentScreen = "levelComplete"
end

function renderBG(game, message)
  for k, background in pairs(backgrounds[game.screen.currentScreen]) do
    love.graphics.draw(background.img, background.x, background.y)
  end
end

function renderUI(game, message)
  for k, button in pairs(buttons[game.screen.currentScreen]) do
    love.graphics.draw(
      button.img,
      button.x,
      button.y,
      0,
      button.widthScale,
      button.heightScale
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

  for k, buttonGroup in pairs(buttons) do
    for i, button in pairs(buttonGroup) do
      button.img = love.graphics.newImage(button.imgPath)
      button.width = button.img:getWidth() * button.widthScale
      button.height = button.img:getHeight() * button.heightScale
    end
  end

  game:on('DAY_END', endDay)
  game:on('RENDER_BG', renderBG)
  game:on('RENDER_UI', renderUI)
  game:on('MOUSE_PRESS', mousePress)
  game:on('MOUSE_RELEASE', mouseRelease)
end

return registerScreen
