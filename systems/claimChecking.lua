local MAX_STRIKES = 3
local SUCCESSFUL_ID_AMOUNT = 5
local FAILED_ID_AMOUNT = 10
local CC_FONT = love.graphics.newFont("assets/font/BebasNeue Bold.ttf", 28)
local END_SCREEN_FONT = love.graphics.newFont("assets/font/BebasNeue Bold.ttf", 126)
local DAY_END_BG_PATH = "assets/graphics/backgroundDayEnd.png"
local DAY_END_BG = love.graphics.newImage(DAY_END_BG_PATH)

local APPROVED_X = 580
local APPROVED_Y = 710
local DENIED_X = 580
local DENIED_Y = 970

local CC = {}

function CC.register(game)
  print("Registering claim checking system")

  game.claimChecking = {
    claimsApproved = 0,
    claimsDenied = 0,
    correctId = 0,
    wrongId = 0,
    dayBalance = 0,
    totalBalance = 0,
    strikes = 0,
    currentDay = 0,
    dayStarted = false,
    dayEnded = false
  }

  game:on("DAY_START", CC.startDay)
  game:on("DAY_END", CC.endDay)
  game:on("CLAIM_APPROVED", CC.incrementClaimsApproved)
  game:on("CLAIM_DENIED", CC.incrementClaimsDenied)
  game:on("RENDER_UI", CC.renderClaimUI)
end

---------------
-- DAY LOGIC --
---------------

function CC.startDay(game, message)
  print("Starting day: " .. message.day)
  game.claimChecking.dayEnded = false
  game.claimChecking.dayStarted = true
  game.claimChecking.currentDay = message.day
  game.claimChecking.strikes = 0
  game.claimChecking.claimsApproved = 0
  game.claimChecking.claimsDenied = 0
  game.claimChecking.wrongId = 0
  game.claimChecking.correctId = 0
  game.claimChecking.dayBalance = 0
  if message.day == 1 then
    game.claimChecking.totalBalance = 0
  end
end

function CC.endDay(game, message)
  game.claimChecking.dayStarted = false
  game.claimChecking.dayEnded = true
end

-----------------
-- CLAIM LOGIC --
-----------------

function CC.incrementClaimsApproved(game, message)
  local approvedClaim = message.claim
  game.claimChecking.claimsApproved = game.claimChecking.claimsApproved + 1
  if approvedClaim.valid then
    print("Successfully identified a claim")
    sfxGameStart = love.audio.newSource("assets/sfx/claim_correct.wav","static")
    sfxGameStart:play()
    game.claimChecking.correctId = game.claimChecking.correctId + 1
    game.claimChecking.dayBalance = game.claimChecking.dayBalance + SUCCESSFUL_ID_AMOUNT
    game.claimChecking.totalBalance = game.claimChecking.totalBalance + SUCCESSFUL_ID_AMOUNT
  else
    print("You claim identification is bad, and you should feel bad")
    game.claimChecking.wrongId = game.claimChecking.wrongId + 1
    sfxGameStart = love.audio.newSource("assets/sfx/claim_incorrect.wav","static")
    sfxGameStart:play()
    if game.claimChecking.strikes < MAX_STRIKES then
      game.claimChecking.strikes = game.claimChecking.strikes + 1
    else
      game.claimChecking.dayBalance = game.claimChecking.dayBalance - FAILED_ID_AMOUNT
      game.claimChecking.totalBalance = game.claimChecking.totalBalance - FAILED_ID_AMOUNT
    end
  end
end

function CC.incrementClaimsDenied(game, message)
  local deniedClaim = message.claim
  game.claimChecking.claimsDenied = game.claimChecking.claimsDenied + 1
  if not deniedClaim.valid then
    print("Successfully identified a claim")
    sfxGameStart = love.audio.newSource("assets/sfx/claim_correct.wav","static")
    sfxGameStart:play()
    game.claimChecking.correctId = game.claimChecking.correctId + 1
    game.claimChecking.dayBalance = game.claimChecking.dayBalance + SUCCESSFUL_ID_AMOUNT
    game.claimChecking.totalBalance = game.claimChecking.totalBalance + SUCCESSFUL_ID_AMOUNT
  else
    print("You claim identification is bad, and you should feel bad")
    game.claimChecking.wrongId = game.claimChecking.wrongId + 1
    sfxGameStart = love.audio.newSource("assets/sfx/claim_incorrect.wav","static")
    sfxGameStart:play()
    if game.claimChecking.strikes < MAX_STRIKES then
      game.claimChecking.strikes = game.claimChecking.strikes + 1
    else
      game.claimChecking.dayBalance = game.claimChecking.dayBalance - FAILED_ID_AMOUNT
      game.claimChecking.totalBalance = game.claimChecking.totalBalance - FAILED_ID_AMOUNT
    end
  end
end

------------------------------
-- SHOW STUFF ON THE SCREEN --
------------------------------

function drawSuccessfulId()
  successPath = "assets/graphics/correctIcon.png"
  moneyPath = "assets/graphics/moneyIcon.png"

end

function drawFailedId()
  failedPath = "assets/graphics/wrongIcon.png"
end

function CC.renderClaimCounters(game, message)
  approvedText = game.claimChecking.claimsApproved
  deniedText = game.claimChecking.claimsDenied
  moneyMadeText = game.claimChecking.totalBalance .. " JBucks"
  strikeCounter = ""

  if game.claimChecking.strikes == 1 then
    strikeCounter = "X"
  elseif game.claimChecking.strikes == 2 then
    strikeCounter = "X  X"
  elseif game.claimChecking.strikes >= 3 then
    strikeCounter = "X  X  X"
  end

  love.graphics.setColor(0, 148, 68)
  love.graphics.print(approvedText, APPROVED_X, APPROVED_Y)
  love.graphics.setColor(255, 0, 0)
  love.graphics.print(deniedText, DENIED_X, DENIED_Y)
  love.graphics.setColor(0, 0, 0)
  love.graphics.print(moneyMadeText, 40, 20)
  drawStrikeBoxes()
end

function drawStrikeBoxes ()
  love.graphics.setColor(255, 255, 255)
  love.graphics.rectangle("fill", 40, 50, 15, 30)
  love.graphics.rectangle("fill", 60, 50, 15, 30)
  love.graphics.rectangle("fill", 80, 50, 15, 30)
  love.graphics.setColor(255, 0, 0)
  love.graphics.print(strikeCounter, 41, 53)
end

function CC.renderDayEnd(game, message)
  love.graphics.draw(DAY_END_BG, 0, 0)
  love.graphics.setColor(0, 0, 0)
  if game.claimChecking.currentDay == 5 then
    CC.renderGameEnd(game, message)
  else
    if game.claimChecking.dayBalance > 0 then
      moneyMade = "You made " .. game.claimChecking.dayBalance .. " JBucks today!"
    elseif game.claimChecking.dayBalance == 0 then
      moneyMade = "You made no money today.  Some days getting out of bed just isn't worth it"
    else
      moneyMade = "You lost " .. math.abs(game.claimChecking.dayBalance) .. " JBucks today.  Your family is proud?"
    end

    if game.claimChecking.wrongId == 1 then
      strikesText = "You made 1 mistake"
    else
      strikesText = "You made " .. game.claimChecking.wrongId .. " mistakes"
    end

    love.graphics.printf(moneyMade, 0, 100, 1920, "center")
    love.graphics.printf(strikesText, 0, 400, 1920, "center")
  end
end

function CC.renderGameEnd(game, message)
  endText = "Your week and Incentives Please is done, you can choose to work harder or give up."
  finalMoneyText = ""
  if game.claimChecking.totalBalance == 0 then
    finalMoneyText = "You didn't manage to make any money.  It is suggested you work harder."
  elseif game.claimChecking.totalBalance < 0 then
    finalMoneyText = "You cost the company " .. math.abs(game.claimChecking.totalBalance) .. ".  Just sayin'..."
  elseif game.claimChecking.totalBalance > 0 then
    finalMoneyText = "Great success!  You have made " .. game.claimChecking.totalBalance .. " JBucks.  Buy yourself something nice."
  end

  love.graphics.printf(finalMoneyText, 0, 200, 1920, "center")
end

function CC.renderClaimUI(game, message)
  love.graphics.push("all")

  if game.claimChecking.dayStarted then
    love.graphics.setFont(CC_FONT)
    CC.renderClaimCounters(game, message)
  elseif game.claimChecking.dayEnded then

    love.graphics.setFont(END_SCREEN_FONT)
    CC.renderDayEnd(game, message)
  end
  love.graphics.pop()
end

return CC
