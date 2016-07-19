local desk = {}

local createAnimator = require("../animation")
local messages = require("../messages")

local CLAIM_APPROVED  = messages.CLAIM_APPROVED
local CLAIM_DENIED    = messages.CLAIM_DENIED

local CLAIM_WIDTH   = 50
local CLAIM_HEIGHT  = 68

local BOX_INBOX = {
  x       = 6 + 20,
  y       = 540 + 32 + 228,
  width   = CLAIM_WIDTH,
  height  = CLAIM_HEIGHT
}
local BOX_APPROVED = {
  x       = 540 + 20,
  y       = 540 + 32 + 122,
  width   = CLAIM_WIDTH,
  height  = CLAIM_HEIGHT
}
local BOX_DENIED = {
  x       = 540 + 20,
  y       = 540 + 32 + 382,
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
  height  = 216,
  image   = love.graphics.newImage("assets/graphics/matSm.png")
}
local ZOOM_VIEW = {
  x       = 640,
  y       = 0,
  width   = 1280,
  height  = 1080,
  image   = love.graphics.newImage("assets/graphics/matLg.png")
}

local RANDOM_NAMES = {
  "Keli Clermont",
  "Colin Merlo",
  "Chantal Rousey",
  "Briana Comacho",
  "Pricilla Mares",
  "Clement Chabolla",
  "Franklyn Linton",
  "Tammara Delia",
  "Era Recore",
  "Georgette Saraiva",
  "Mark Fry",
  "Meghan Dubois",
  "Eustolia Turner",
  "Wilma Trosper",
  "Holly Leonetti",
  "Noelle Korte",
  "Kimberli Breuer",
  "Tamie Langenfeld",
  "Shira Lawless",
  "Ghislaine Yard",
  "Dorothea Cobbley",
  "Katy Ahumada",
  "Hollie Woodrow",
  "Claud Zambrana",
  "Tyron Goodenough",
  "Freda Bradberry",
  "Mikaela Dickens",
  "Bok Amen",
  "Janelle Edlin",
  "Raymon Brzezinski"
}
local INVOICE_TEMPLATES = {
  {
    largeImage = love.graphics.newImage("assets/graphics/invoiceA.png"),
    smallImage = love.graphics.newImage("assets/graphics/invoiceAsm.png"),
    dealerName = "Thumbs-Up Appliances"
  },
  {
    largeImage = love.graphics.newImage("assets/graphics/invoiceB.png"),
    smallImage = love.graphics.newImage("assets/graphics/invoiceBsm.png"),
    dealerName = "Loch Ness Inc."
  },
  {
    largeImage = love.graphics.newImage("assets/graphics/invoiceC.png"),
    smallImage = love.graphics.newImage("assets/graphics/invoiceCsm.png"),
    dealerName = "Zombies & Co."
  },
  {
    largeImage = love.graphics.newImage("assets/graphics/invoiceD.png"),
    smallImage = love.graphics.newImage("assets/graphics/invoiceDsm.png"),
    dealerName = "Al Paca's Tire Hut"
  },
  {
    largeImage = love.graphics.newImage("assets/graphics/invoiceE.png"),
    smallImage = love.graphics.newImage("assets/graphics/invoiceEsm.png"),
    dealerName = "Munster & Sons"
  }
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
  game:on("UPDATE", desk.updateAnimations)
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
      local date = math.floor(math.random() * 3) + 2013
      local associateName = RANDOM_NAMES[math.ceil(math.random() * #RANDOM_NAMES)]
      local dealer = math.ceil(math.random() * #INVOICE_TEMPLATES)
      local claim
      claim = {
        x = BOX_INBOX.x,
        y = BOX_INBOX.y,
        width = CLAIM_WIDTH,
        height = CLAIM_HEIGHT,
        dragPoint = { x = x - BOX_INBOX.x, y = y - BOX_INBOX.y },
        xAnimator = createAnimator(BOX_INBOX.x, BOX_INBOX.x, 300, 30, function (x) claim.x = x end),
        yAnimator = createAnimator(BOX_INBOX.y, BOX_INBOX.y, 300, 30, function (y) claim.y = y end),
        targetX = BOX_INBOX.x,
        targetY = BOX_INBOX.y,
        valid = math.random() * 2 < 1,
        request = {
          date = date,
          associateName = associateName,
          dealer = dealer
        },
        invoice = {
          date = date,
          associateName = associateName,
          dealer = dealer
        }
      }
      game.desk.activeClaim = claim
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
  claim.targetX = x - claim.dragPoint.x
  claim.targetY = y - claim.dragPoint.y

  -- Constrain the claim's X coordinate
  if claim.targetX < DESKTOP_VIEW.x then
    claim.targetX = DESKTOP_VIEW.x
  elseif claim.targetX + CLAIM_WIDTH > DESKTOP_VIEW.x + DESKTOP_VIEW.width then
    claim.targetX = DESKTOP_VIEW.x + DESKTOP_VIEW.width - CLAIM_WIDTH
  end

  -- Constrain the claim's Y coordinate
  if claim.targetY < DESKTOP_VIEW.y then
    claim.targetY = DESKTOP_VIEW.y
  elseif claim.targetY + CLAIM_HEIGHT > DESKTOP_VIEW.y + DESKTOP_VIEW.height then
    claim.targetY = DESKTOP_VIEW.y + DESKTOP_VIEW.height - CLAIM_HEIGHT
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

  local claim = game.desk.activeClaim
  if claim then
    love.graphics.draw(INVOICE_TEMPLATES[claim.invoice.dealer].smallImage, claim.x, claim.y)

    local x = (claim.x - ZOOM_ZONE.x) * 5 + ZOOM_VIEW.x
    local y = (claim.y - ZOOM_ZONE.y) * 5
    love.graphics.setScissor(ZOOM_VIEW.x, ZOOM_VIEW.y, ZOOM_VIEW.width, ZOOM_VIEW.height)
    love.graphics.draw(INVOICE_TEMPLATES[claim.invoice.dealer].largeImage, x, y)
    love.graphics.setScissor()
  end

  love.graphics.pop()
end

function desk.updateAnimations(game, message)
  if not game.desk.currentDay or not game.desk.activeClaim then
    return
  end

  local claim = game.desk.activeClaim
  claim.xAnimator(message.dt, claim.targetX)
  claim.yAnimator(message.dt, claim.targetY)
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
