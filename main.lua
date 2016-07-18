local dispatcher = require("dispatcher")
local messages = require("messages")
local registerClaimChecking = require("systems/claimChecking")
local registerClock = require("systems/clock")
local registerScreen = require("systems/screen")
local registerTable = require("systems/table")

local RENDER_BG = messages.RENDER_BG
local RENDER_FG = messages.RENDER_FG
local RENDER_UI = messages.RENDER_UI
local UPDATE = messages.UPDATE

local game = dispatcher.createDispatcher()

function love.load()
  registerClaimChecking()
  registerClock()
  registerScreen()
  registerTable()
end

function love.update(dt)
  game:dispatch(UPDATE(dt))
end

function love.draw()
  game:dispatch(RENDER_BG())
  game:dispatch(RENDER_FG())
  game:dispatch(RENDER_UI())
end
