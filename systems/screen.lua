local screen = {}

local messages = require("../messages")

local buttons = {
  menu = {
    start = {
      imgPath = "assets/graphics/startButton.png",
      x = 854,
      y = 750,
      widthScale = 0.1,
      heightScale = 0.1,
      onClick = function (game)
        game.screen.bgmusic:setLooping(true)
        game.screen.bgmusic:play()
        game.screen.currentScreen = "game"
        game.screen.currentDay = 1
        game:dispatch(messages.DAY_START(game.screen.currentDay))
      end
    },
    quit = {
      imgPath = "assets/graphics/exitButton.png",
      x = 854,
      y = 825,
      widthScale = 0.1,
      heightScale = 0.1,
      onClick = function (game)
        love.event.quit()
      end
    }
  },
  game = {},
  levelComplete = {
    nextLevel = {
      imgPath = "assets/graphics/startButton.png",
      x = 854,
      y = 750,
      widthScale = 0.1,
      heightScale = 0.1,
      onClick = function (game)
        game.screen.bgmusic:setPitch(game.screen.bgmusic:getPitch()+0.1)

        game.screen.currentScreen = "game"
        game.screen.currentDay = game.screen.currentDay + 1
        game:dispatch(messages.DAY_START(game.screen.currentDay))
      end
    }
  },
  gameComplete = {
    
    startAgain = {
      imgPath = "assets/graphics/startButton.png",
      x = 854,
      y = 750,
      widthScale = 0.1,
      heightScale = 0.1,
      onClick = function (game)
        game.screen.bgmusic:setPitch(1.0)
        game.screen.bgmusic:play()
        game.screen.currentScreen = "game"
        game.screen.currentDay = 1
        game:dispatch(messages.DAY_START(game.screen.currentDay))
      end
    },
    quit = {
      imgPath = "assets/graphics/exitButton.png",
      x = 854,
      y = 825,
      widthScale = 0.1,
      heightScale = 0.1,
      onClick = function (game)
        love.event.quit()
      end
    }
  }
}

local backgrounds = {
  menu = {
    bg = {
      imgPath = "assets/graphics/background.png",
      x = 0,
      y = 0,
      widthScale = 1,
      heightScale = 1
    },
    logo = {
      imgPath = "assets/graphics/logo.png",
      x = 758,
      y = 200,
      widthScale = 0.2,
      heightScale = 0.2
    }
  },
  game = {
    desk = {
      imgPath = "assets/graphics/desk-view.png",
      x = 0,
      y = 0,
      widthScale = 1,
      heightScale = 1
    },
    invoice = {
      imgPath = "assets/graphics/InvoiceView.png",
      x = 0,
      y = 541,
      widthScale = 1,
      heightScale = 1
    },
    zoomed = {
      imgPath = "assets/graphics/zoomedBackground.png",
      x = 641,
      y = 0,
      widthScale = 5.25,
      heightScale = 5.25
    }
  },
  levelComplete = {},
  gameComplete = {}
}

function screen.endDay(game, message)
  if (message.day == 5) then
    game.screen.currentScreen = "gameComplete"
    game.screen.bgmusic:stop()
    sfxGameEnd = love.audio.newSource("assets/sfx/game_end.wav","static")
    sfxGameEnd:play()
  else
    game.screen.currentScreen = "levelComplete"
    sfxNextLevel = love.audio.newSource("assets/sfx/next_level.wav","static")
    sfxNextLevel:play()
  end
end

function screen.renderBG(game, message)
  for k, background in pairs(backgrounds[game.screen.currentScreen]) do
    love.graphics.draw(
      background.img,
      background.x,
      background.y,
      0,
      background.widthScale,
      background.heightScale
    )
  end
end

function screen.renderUI(game, message)
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
  }

  for k, buttonGroup in pairs(buttons) do
    for i, button in pairs(buttonGroup) do
      button.img = love.graphics.newImage(button.imgPath)
      button.width = button.img:getWidth() * button.widthScale
      button.height = button.img:getHeight() * button.heightScale
    end
  end

  for k, backgroundGroup in pairs(backgrounds) do
    for i, background in pairs(backgroundGroup) do
      background.img = love.graphics.newImage(background.imgPath)
      background.width = background.img:getWidth() * background.widthScale
      background.height = background.img:getHeight() * background.heightScale
    end
  end

  game.screen.bgmusic = love.audio.newSource("assets/sfx/music_1.wav")
  

  game:on('DAY_END', screen.endDay)
  game:on('RENDER_BG', screen.renderBG)
  game:on('RENDER_UI', screen.renderUI)
  game:on('MOUSE_PRESS', screen.mousePress)
  game:on('MOUSE_RELEASE', screen.mouseRelease)
end

return screen
