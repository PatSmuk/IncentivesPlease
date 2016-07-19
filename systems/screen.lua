local screen = {}

local messages = require("../messages")
local createAnimator = require("animation")

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
      imgPath = "assets/graphics/nextLevelButton.png",
      x = 810,
      y = 750,
      widthScale = 1,
      heightScale = 1,
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
      imgPath = "assets/graphics/playAgainButton.png",
      x = 810,
      y = 750,
      widthScale = 1,
      heightScale = 1,
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
      y = 850,
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
      orientation = 0
    },
    logo = {
      imgPath = "assets/graphics/logo.png",
      x = 758,
      y = 200,
      orientation = 0
    }
  },
  game = {
    desk = {
      imgPath = "assets/graphics/desk-view.png",
      x = 0,
      y = 0,
      orientation = 0
    },
    invoice = {
      imgPath = "assets/graphics/InvoiceView.png",
      x = 0,
      y = 541,
      orientation = 0
    },
    deskMat = {
      imgPath = "assets/graphics/matSm.png",
      x = 192,
      y = 702,
      orientation = 0
    },
    zoomed = {
      imgPath = "assets/graphics/matLg.png",
      x = 641,
      y = 0,
      orientation = 0
    }
  },
  levelComplete = {},
  gameComplete = {}
}

local backgroundsOrder = {
  menu = {"bg", "logo"},
  game = {"desk", "invoice", "zoomed", "deskMat"},
  levelComplete = {},
  gameComplete = {}
}

function screen.update(game, message)
  if backgrounds.menu.logo.orientation <= -0.1 then
    game.screen.logo.animation = createAnimator(
      backgrounds.menu.logo.orientation, 0.1, 0.05, 0.01, 0.0000001,
      function (orientation)
        backgrounds.menu.logo.orientation = orientation
      end
    )
  elseif backgrounds.menu.logo.orientation >= 0.1 then
    game.screen.logo.animation = createAnimator(
      backgrounds.menu.logo.orientation, -0.1, 0.05, 0.01, 0.0000001,
      function (orientation)
        backgrounds.menu.logo.orientation = orientation
      end
    )
  end

  if game.screen.logo.animation and game.screen.logo.animation(message.dt) then
    game.screen.logo.animation = nil
  end
end

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
  for i, backgroundKey in ipairs(backgroundsOrder[game.screen.currentScreen]) do
    local background = backgrounds[game.screen.currentScreen][backgroundKey]
    love.graphics.push()
    love.graphics.translate(background.x + background.width/2, background.y + background.height/2)
    love.graphics.rotate(background.orientation)
    love.graphics.draw(
      background.img, -background.width/2, -background.height/2
    )
    love.graphics.pop()
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
    logo = {
      direction = "right"
    }
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

  sfxGameStart = love.audio.newSource("assets/sfx/game_start.wav","static")
  sfxGameStart:play()

  game.screen.logo.animation = createAnimator(
    backgrounds.menu.logo.orientation, 0.1, 0.05, 0.01, 0.0000001,
    function (orientation)
      backgrounds.menu.logo.orientation = orientation
    end
  )

  game:on('UPDATE', screen.update)
  game:on('DAY_END', screen.endDay)
  game:on('RENDER_BG', screen.renderBG)
  game:on('RENDER_UI', screen.renderUI)
  game:on('MOUSE_PRESS', screen.mousePress)
  game:on('MOUSE_RELEASE', screen.mouseRelease)
end

return screen
