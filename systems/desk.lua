local desk = {}

local messages = require("../messages")

local CLAIM_APPROVED  = messages.CLAIM_APPROVED
local CLAIM_DENIED    = messages.CLAIM_DENIED

local BOX_IN_TOP    = 10
local BOX_IN_BOTTOM = 20
local BOX_IN_LEFT   = 10
local BOX_IN_RIGHT  = 20

local BOX_APPROVED_TOP    = 10
local BOX_APPROVED_BOTTOM = 20
local BOX_APPROVED_LEFT   = 60
local BOX_APPROVED_RIGHT  = 70

local BOX_DENIED_TOP    = 50
local BOX_DENIED_BOTTOM = 60
local BOX_DENIED_LEFT   = 60
local BOX_DENIED_RIGHT  = 70

local CLAIM_WIDTH   = 30
local CLAIM_HEIGHT  = 60

local DESKTOP_TOP     = 590
local DESKTOP_BOTTOM  = 1080
local DESKTOP_LEFT    = 0
local DESKTOP_RIGHT   = 640

local ZOOM_TOP    = 0
local ZOOM_BOTTOM = 1080
local ZOOM_LEFT   = 640
local ZOOM_RIGHT  = 1920

function desk.register(game)
  print("Registering table system")

  game.desk = {
    activeClaim = nil,
    dayStarted = false
  }

  game:on("DAY_START", desk.startDay)
  game:on("DAY_END", desk.endDay)
  game:on("MOUSE_PRESS", desk.pickUpClaim)
  game:on("MOUSE_MOVE", desk.moveClaim)
  game:on("MOUSE_RELEASE", desk.dropClaim)
  game:on("RENDER_FG", desk.drawTable)
end

function desk.startDay(game, message)
  game.desk.dayStarted = true
  game.desk.activeClaim = nil
end

function desk.endDay(game, message)
  game.desk.dayStarted = false
end

function desk.pickUpClaim(game, message)
  if not game.desk.dayStarted then
    return
  end
end

function desk.moveClaim(game, message)
  if not game.desk.dayStarted or not game.desk.activeClaim then
    return
  end
end

function desk.dropClaim(game, message)
  if not game.desk.dayStarted or not game.desk.activeClaim or not game.desk.activeClaim.moving then
    return
  end
end

function desk.drawTable(game, message)
  if not game.desk.dayStarted then
    return
  end
end

return desk
