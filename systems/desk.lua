local desk = {}

local messages = require("../messages")

local CLAIM_APPROVED  = messages.CLAIM_APPROVED
local CLAIM_DENIED    = messages.CLAIM_DENIED

local CLAIM_WIDTH   = 90
local CLAIM_HEIGHT  = 122

local BOX_INBOX = {
  x       = 6,
  y       = 540 + 228,
  width   = CLAIM_WIDTH,
  height  = CLAIM_HEIGHT
}
local BOX_APPROVED = {
  x       = 540,
  y       = 540 + 122,
  width   = CLAIM_WIDTH,
  height  = CLAIM_HEIGHT
}
local BOX_DENIED = {
  x       = 540,
  y       = 540 + 382,
  width   = CLAIM_WIDTH,
  height  = CLAIM_HEIGHT
}

local DESKTOP_VIEW = {
  x       = 0,
  y       = 540,
  width   = 640,
  height  = 540
}
local ZOOM_ZONE = {
  x       = 192,
  y       = 702,
  width   = 256,
  height  = 216
}
local ZOOM_VIEW = {
  x       = 640,
  y       = 0,
  width   = 1280,
  height  = 1080
}

function desk.register(game)
  print("Registering table system")

  game.desk = {
    activeClaim = nil,
    currentDay = nil
  }

  game:on("DAY_START", desk.startDay)
  game:on("DAY_END", desk.endDay)
  game:on("MOUSE_PRESS", desk.pickUpClaim)
  game:on("MOUSE_MOVE", desk.moveClaim)
  game:on("MOUSE_RELEASE", desk.dropClaim)
  game:on("RENDER_FG", desk.drawTable)
end

function desk.startDay(game, message)
  game.desk.currentDay = message.day
  game.desk.activeClaim = nil
end

function desk.endDay(game, message)
  game.desk.currentDay = nil
end

function desk.pickUpClaim(game, message)
  local x, y = message.x, message.y

  if not game.desk.currentDay then
    return
  end

  -- If there's an active, check if the player is clicking on it
  if game.desk.activeClaim then
    if desk.checkPointCollision(x, y, game.desk.activeClaim) then
      game.desk.activeClaim.dragPoint = {
        x = x - game.desk.activeClaim.x,
        y = y - game.desk.activeClaim.y
      }
    end
  else
    -- Otherwise check if the player is clicking on the inbox
    if desk.checkPointCollision(x, y, BOX_INBOX) then
      game.desk.activeClaim = {
        x = BOX_INBOX.x,
        y = BOX_INBOX.y,
        width = CLAIM_WIDTH,
        height = CLAIM_HEIGHT,
        dragPoint = { x = x - BOX_INBOX.x, y = y - BOX_INBOX.y },
        valid = math.random() * 2 < 1
      }
    end
  end
end

function desk.moveClaim(game, message)
  local x, y = message.x, message.y
  local claim = game.desk.activeClaim

  if not game.desk.currentDay or not game.desk.activeClaim or not game.desk.activeClaim.dragPoint then
    return
  end

  -- Update the claim's position
  local dx = x - claim.x - claim.dragPoint.x
  local dy = y - claim.y - claim.dragPoint.y
  claim.x = claim.x + dx
  claim.y = claim.y + dy

  -- Constrain the claim's X coordinate
  if claim.x < DESKTOP_VIEW.x then
    claim.x = DESKTOP_VIEW.x
  elseif claim.x + CLAIM_WIDTH > DESKTOP_VIEW.x + DESKTOP_VIEW.width then
    claim.x = DESKTOP_VIEW.x + DESKTOP_VIEW.width - CLAIM_WIDTH
  end

  -- Constrain the claim's Y coordinate
  if claim.y < DESKTOP_VIEW.y then
    claim.y = DESKTOP_VIEW.y
  elseif claim.y + CLAIM_HEIGHT > DESKTOP_VIEW.y + DESKTOP_VIEW.height then
    claim.y = DESKTOP_VIEW.y + DESKTOP_VIEW.height - CLAIM_HEIGHT
  end
end

function desk.dropClaim(game, message)
  local x, y = message.x, message.y
  local claim = game.desk.activeClaim

  if not game.desk.currentDay or not claim or not claim.dragPoint then
    return
  end

  claim.dragPoint = nil

  if desk.checkBoxCollision(claim, BOX_APPROVED, 30) then
    game.desk.activeClaim = nil
    game:dispatch(CLAIM_APPROVED(claim))
  elseif desk.checkBoxCollision(claim, BOX_DENIED, 30) then
    game.desk.activeClaim = nil
    game:dispatch(CLAIM_DENIED(claim))
  end
end

function desk.drawTable(game, message)
  love.graphics.push("all")

  if not game.desk.currentDay then
    love.graphics.pop()
    return
  end

  love.graphics.setColor(102, 51, 0)
  love.graphics.rectangle("fill", ZOOM_ZONE.x, ZOOM_ZONE.y, ZOOM_ZONE.width, ZOOM_ZONE.height)

  local claim = game.desk.activeClaim
  if claim then
    if claim.valid then
      love.graphics.setColor(20, 255, 40)
    else
      love.graphics.setColor(255, 40, 20)
    end

    love.graphics.rectangle("fill", claim.x, claim.y, CLAIM_WIDTH, CLAIM_HEIGHT)

    local x = (claim.x - ZOOM_ZONE.x) * 5 + ZOOM_VIEW.x
    local y = (claim.y - ZOOM_ZONE.y) * 5
    local width = CLAIM_WIDTH * 5
    local height = CLAIM_HEIGHT * 5
    if x < ZOOM_VIEW.x then
      width = width - (ZOOM_VIEW.x - x)
      x = ZOOM_VIEW.x
    end
    if width > 0 then
      love.graphics.rectangle("fill", math.max(x, ZOOM_VIEW.x), y, width, height)
    end
  end

  love.graphics.pop()
end

function desk.checkBoxCollision(box1, box2, error)
  -- Check if box 1 fully contains box 2 (within error)
  if (box1.y - error) <= box2.y and (box1.x - error) <= box2.x and
      (box1.y + box1.height + error) >= (box2.y + box2.height) and
      (box1.x + box1.width + error) >= (box2.x + box2.width) then
    return true
  end
  -- Check if box 2 fully contains box 1 (within error)
  if (box1.y - error) >= box2.y and (box1.x - error) >= box2.x and
      (box1.y + box1.height + error) <= (box2.y + box2.height) and
      (box1.x + box1.width + error) <= (box2.x + box2.width) then
    return true
  end
  return false
end

function desk.checkPointCollision(x, y, box)
  if box.y <= y and box.x <= x and
      (box.y + box.height) >= y and
      (box.x + box.width) >= x then
    return true
  end
  return false
end

return desk
