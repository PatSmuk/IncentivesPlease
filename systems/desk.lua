local desk = {}

local createAnimator = require("../animation")
local messages = require("../messages")

local CLAIM_APPROVED  = messages.CLAIM_APPROVED
local CLAIM_DENIED    = messages.CLAIM_DENIED

local CLAIM_WIDTH   = 50
local CLAIM_HEIGHT  = 68

local BOX_INBOX = {
  x       = 6,
  y       = 540 + 228,
  width   = 90,
  height  = 120,
  glow    = love.graphics.newImage("assets/graphics/blueGlow.png")
}
local BOX_APPROVED = {
  x       = 540,
  y       = 540 + 122,
  width   = 90,
  height  = 120,
  glow    = love.graphics.newImage("assets/graphics/greenGlow.png")
}
local BOX_DENIED = {
  x       = 540,
  y       = 540 + 382,
  width   = 90,
  height  = 120,
  glow    = love.graphics.newImage("assets/graphics/redGlow.png")
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
local INVOICE_FIELDS = {"associateName", "date", "modelSerial", "quantity", "price"}
local INVOICE_FIELD_DIMENSIONS = {
  associateName = {
    x = 12,
    y = 119,
    width = 190,
    height = 37
  },
  date = {
    x = 244,
    y = 119,
    width = 190,
    height = 37
  },
  modelSerial = {
    x = 22,
    y = 225,
    width = 425,
    height = 68
  },
  quantity = {
    x = 22,
    y = 352,
    width = 425,
    height = 68
  },
  price = {
    x = 22,
    y = 480,
    width = 425,
    height = 68
  }
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
  "Raymon Brzezinski",
  "Bruce Willis",
  "Arnold Schwarzenegger",
  "Jean Claude Van Damme",
  "Sylvester Stallone",
  "Rhonda Rousey"
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
local CLAIM_REQUEST_IMAGES = {
  {
    large = love.graphics.newImage("assets/graphics/claimA.png"),
    small = love.graphics.newImage("assets/graphics/claimAsm.png")
  },
  {
    large = love.graphics.newImage("assets/graphics/claimB.png"),
    small = love.graphics.newImage("assets/graphics/claimBsm.png")
  },
  {
    large = love.graphics.newImage("assets/graphics/claimC.png"),
    small = love.graphics.newImage("assets/graphics/claimCsm.png")
  },
  {
    large = love.graphics.newImage("assets/graphics/claimD.png"),
    small = love.graphics.newImage("assets/graphics/claimDsm.png")
  },
  {
    large = love.graphics.newImage("assets/graphics/claimE.png"),
    small = love.graphics.newImage("assets/graphics/claimEsm.png")
  }
}
local INVOICE_FONT = love.graphics.newFont("assets/font/Raleway-Medium.ttf", 24)
local PICKUP_CLAIM_SOUND = love.audio.newSource("assets/sfx/pickup_claim.wav","static")

local DAYS_PER_MONTH = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}

-- How far outside the approved/denied box the claim can be before it's
--   registered as a hit
local OUT_BOX_FUDGE_FACTOR = 80

function desk.register(game)
  print("Registering table system")

  game.desk = {
    activeClaim = nil,
    currentDay = nil,
    inboxGlowAlpha = 255,
    inboxGlowAnimator = createAnimator(255, 0, 100, 20, 2, function (alpha) game.desk.inboxGlowAlpha = alpha end),
    inboxGlowGrowing = false
  }

  game:on("DAY_START", desk.startDay)
  game:on("DAY_END", desk.endDay)
  game:on("MOUSE_PRESS", desk.pickUpClaim)
  game:on("MOUSE_MOVE", desk.moveClaim)
  game:on("MOUSE_RELEASE", desk.dropClaim)
  game:on("RENDER_FG", desk.drawTable)
  game:on("UPDATE", desk.animateInboxGlow)
  game:on("UPDATE", desk.animateClaim)
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
      local claimX = BOX_INBOX.x
      if x > BOX_INBOX.x + CLAIM_WIDTH then
        claimX = x - CLAIM_WIDTH + 10
      end
      local claimY = BOX_INBOX.y
      if y > BOX_INBOX.y + CLAIM_HEIGHT then
        claimY = y - CLAIM_HEIGHT + 10
      end
      local year = math.floor(math.random() * 3) + 2013
      local month = math.ceil(math.random() * 12)
      local day = math.ceil(math.random() * DAYS_PER_MONTH[month])
      local date = string.format("%04d-%02d-%02d", year, month, day)
      local associateName = RANDOM_NAMES[math.ceil(math.random() * #RANDOM_NAMES)]
      local dealer = math.ceil(math.random() * #INVOICE_TEMPLATES)
      local modelSerial = math.ceil(math.random() * 1000000).."-"..math.ceil(math.random() * 1000000)
      local quantity = math.ceil(math.random() * 5)
      local price = math.ceil(math.random() * 100000)
      price = string.format("$%d.%02d", math.floor(price / 100), price % 100)

      local claim
      claim = {
        x = claimX,
        y = claimY,
        width = CLAIM_WIDTH,
        height = CLAIM_HEIGHT,

        dragPoint = { x = x - claimX, y = y - claimY },
        xAnimator = createAnimator(claimX, claimX, 300, 30, 0.1, function (x) claim.x = x end),
        yAnimator = createAnimator(claimY, claimY, 300, 30, 0.1, function (y) claim.y = y end),
        targetX = claimX,
        targetY = claimY,
        slideXOffset = 4,
        slideAnimator = createAnimator(4, 4, 500, 30, 0.1, function (x) claim.slideXOffset = x end),
        inSlideZone = false,

        valid = math.random() * 2 >= 1,
        request = {
          date = date,
          associateName = associateName,
          dealer = dealer,
          modelSerial = modelSerial,
          quantity = quantity,
          price = price
        },
        invoice = {
          date = date,
          associateName = associateName,
          dealer = dealer,
          modelSerial = modelSerial,
          quantity = quantity,
          price = price
        }
      }
      game.desk.activeClaim = claim

      PICKUP_CLAIM_SOUND:play()

      -- If the claim is invalid, change a field so they don't match
      if not claim.valid then
        local badField = INVOICE_FIELDS[math.ceil(math.random() * game.desk.currentDay)]
        local newValue
        local loopCount = 0
        repeat
          if badField == "date" then
            local year = math.floor(math.random() * 3) + 2013
            local month = math.ceil(math.random() * 12)
            local day = math.ceil(math.random() * DAYS_PER_MONTH[month])
            newValue = string.format("%04d-%02d-%02d", year, month, day)
          elseif badField == "associateName" then
            newValue = RANDOM_NAMES[math.ceil(math.random() * #RANDOM_NAMES)]
          elseif badField == "modelSerial" then
            newValue = math.ceil(math.random() * 1000000).."-"..math.ceil(math.random() * 1000000)
          elseif badField == "quantity" then
            newValue = math.ceil(math.random() * 5)
          elseif badField == "price" then
            local price = math.ceil(math.random() * 100000)
            newValue = string.format("$%d.%02d", math.floor(price / 100), price % 100)
          end
          claim.invoice[badField] = newValue
          loopCount = loopCount + 1
          assert(loopCount < 100, 'Infinite loop detected')
        until claim.request[badField] ~= claim.invoice[badField]
      end
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

  if desk.checkBoxCollision(claim, BOX_APPROVED, OUT_BOX_FUDGE_FACTOR) then
    game.desk.activeClaim = nil
    game:dispatch(CLAIM_APPROVED(claim))
  elseif desk.checkBoxCollision(claim, BOX_DENIED, OUT_BOX_FUDGE_FACTOR) then
    game.desk.activeClaim = nil
    game:dispatch(CLAIM_DENIED(claim))
  end
end

function desk.drawTable(game, message)
  if not game.desk.currentDay then
    return
  end

  love.graphics.push("all")
  love.graphics.setFont(INVOICE_FONT)

  local claim = game.desk.activeClaim
  if claim then
    -- Draw the glow on the approved/denied box if the claim is over it
    if desk.checkBoxCollision(claim, BOX_APPROVED, OUT_BOX_FUDGE_FACTOR) then
      love.graphics.draw(BOX_APPROVED.glow, BOX_APPROVED.x - 8, BOX_APPROVED.y - 8)
    elseif desk.checkBoxCollision(claim, BOX_DENIED, OUT_BOX_FUDGE_FACTOR) then
      love.graphics.draw(BOX_DENIED.glow, BOX_DENIED.x - 8, BOX_DENIED.y - 8)
    end

    -- Draw the small version of the claim and invoice
    love.graphics.draw(INVOICE_TEMPLATES[claim.invoice.dealer].smallImage, claim.x + claim.slideXOffset, claim.y)
    love.graphics.draw(CLAIM_REQUEST_IMAGES[game.desk.currentDay].small, claim.x, claim.y)

    local x = (claim.x - ZOOM_ZONE.x) * 2 + ZOOM_VIEW.x
    local y = (claim.y - ZOOM_ZONE.y) * 3
    love.graphics.setScissor(ZOOM_VIEW.x, ZOOM_VIEW.y, ZOOM_VIEW.width, ZOOM_VIEW.height)

    -- Draw the large invoice
    love.graphics.push()
    love.graphics.translate(x + claim.slideXOffset * 9, y)
    love.graphics.draw(INVOICE_TEMPLATES[claim.invoice.dealer].largeImage, 0, 0)
    love.graphics.setColor(40, 40, 40)
    for field, dimensions in pairs(INVOICE_FIELD_DIMENSIONS) do
      love.graphics.print(tostring(claim.invoice[field]), dimensions.x, dimensions.y)
    end
    love.graphics.setColor(255, 255, 255)
    love.graphics.pop()

    -- Draw the large claim request
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.draw(CLAIM_REQUEST_IMAGES[game.desk.currentDay].large, 0, 0)
    love.graphics.setColor(40, 40, 40)
    for i = 1, game.desk.currentDay do
      local field = INVOICE_FIELDS[i]
      local dimensions = INVOICE_FIELD_DIMENSIONS[field]
      love.graphics.print(tostring(claim.request[field]), dimensions.x, dimensions.y)
    end
    love.graphics.setColor(255, 255, 255)
    love.graphics.pop()

    love.graphics.setScissor()
  else
    -- Draw the inbox's glow when there's no claim on the desk
    love.graphics.setColor(255, 255, 255, game.desk.inboxGlowAlpha)
    love.graphics.draw(BOX_INBOX.glow, BOX_INBOX.x - 8, BOX_INBOX.y - 6)
  end

  love.graphics.pop()
end

function desk.animateInboxGlow(game, message)
  if not game.desk.currentDay then
    return
  end

  if game.desk.inboxGlowGrowing then
    if game.desk.inboxGlowAnimator(message.dt, 255) then
      game.desk.inboxGlowGrowing = false
    end
  else
    if game.desk.inboxGlowAnimator(message.dt, 0) then
      game.desk.inboxGlowGrowing = true
    end
  end
end

function desk.animateClaim(game, message)
  if not game.desk.currentDay or not game.desk.activeClaim then
    return
  end

  local claim = game.desk.activeClaim
  claim.xAnimator(message.dt, claim.targetX)
  claim.yAnimator(message.dt, claim.targetY)

  if desk.checkBoxCollision(claim, ZOOM_ZONE, 200) then
    if not claim.inSlideZone then
      claim.inSlideZone = true
      claim.slideAnimator(message.dt, CLAIM_WIDTH + 5)
    else
      claim.slideAnimator(message.dt)
    end
  else
    if claim.inSlideZone then
      claim.inSlideZone = false
      claim.slideAnimator(message.dt, 4)
    else
      claim.slideAnimator(message.dt)
    end
  end
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
