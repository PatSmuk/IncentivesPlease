local MAX_STRIKES = 3
local SUCCESSFUL_ID_AMMOUNT = 5
local FAILED_ID_AMOUNT = 10
local CC_FONT = love.graphics.newFont("assets/font/BebasNeue Bold.ttf", 28)

local APPROVED_X = 580
local APPROVED_Y = 710
local DENIED_X = 580
local DENIED_Y = 970
local SUBMITTED_X = 45
local SUBMITTED_Y = 820

local CC = {}

function CC.register(game)
  print("Registering claim checking system")

  game.claimChecking = {
    claimsApproved = 0,
    claimsDenied = 0,
    dayBalance = 0,
    totalBalance = 0,
    strikes = 0,
    currentDay = 0,
    dayStarted = false,
    dayEnded = false
  }

  game:on("DAY_START", CC.startDay)
  game:on("CLAIM_APPROVED", CC.incrementClaimsApproved)
  game:on("CLAIM_DENIED", CC.incrementClaimsDenied)
  game:on("RENDER_UI", CC.renderClaimUI)
end

function CC.updateAll(game, message)
  game.claimChecking.claimsApproved = game.claimChecking.claimsApproved + 1
  game.claimChecking.claimsDenied = game.claimChecking.claimsDenied + 1
end

function CC.incrementClaimsApproved(game, message)
  local approvedClaim = message.claim
  if approvedClaim.valid then
    print("Successfully identified a claim")
    game.claimChecking.claimsApproved = game.claimChecking.claimsApproved + 1
    game.claimChecking.dayBalance = game.claimChecking.dayBalance + SUCCESSFUL_ID_AMMOUNT
    game.claimChecking.totalBalance = game.claimChecking.totalBalance + SUCCESSFUL_ID_AMMOUNT
  else
    print("You claim identification is bad, and you should feel bad")
    game.claimChecking.dayBalance = game.claimChecking.dayBalance - FAILED_ID_AMOUNT
    game.claimChecking.totalBalance = game.claimChecking.totalBalance + FAILED_ID_AMOUNT
  end
end

function CC.incrementClaimsDenied(game, message)
  local deniedClaim = message.claim
  if not deniedClaim.valid then
    print("Successfully identified a claim")
    game.claimChecking.claimsDenied = game.claimChecking.claimsDenied + 1
    game.claimChecking.dayBalance = game.claimChecking.dayBalance + SUCCESSFUL_ID_AMMOUNT
    game.claimChecking.totalBalance = game.claimChecking.totalBalance + SUCCESSFUL_ID_AMMOUNT
  else
    print("You claim identification is bad, and you should feel bad")
    if game.claimChecking.strikes < MAX_STRIKES then
      game.claimChecking.strikes = game.claimChecking.strikes + 1
    else
      game.claimChecking.dayBalance = game.claimChecking.dayBalance + FAILED_ID_AMMOUNT
      game.claimChecking.totalBalance = game.claimChecking.totalBalance + FAILED_ID_AMMOUNT
    end
  end
end

function CC.startDay(game, message)
  print("Starting day: " .. message.day)
  game.claimChecking.dayStarted = true
  game.claimChecking.currentDay = message.day
  game.claimChecking.strikes = 0
  game.claimChecking.claimsApproved = 0
  game.claimChecking.claimsDenied = 0
  game.claimChecking.dayBalance = 0
end

function CC.renderClaimCounters(game, message)
  approvedText = game.claimChecking.claimsApproved
  deniedText = game.claimChecking.claimsDenied
  submittedText = game.claimChecking.claimsApproved + game.claimChecking.claimsDenied

  love.graphics.setColor(0, 148, 68)
  love.graphics.print(approvedText, APPROVED_X, APPROVED_Y)
  love.graphics.setColor(255, 0, 0)
  love.graphics.print(deniedText, DENIED_X, DENIED_Y)
  love.graphics.setColor(0, 0, 0)
  love.graphics.print(submittedText, SUBMITTED_X, SUBMITTED_Y)
end

function CC.renderClaimUI(game, message)
  love.graphics.push("all")
  love.graphics.setFont(CC_FONT)
  if game.claimChecking.dayStarted then
    CC.renderClaimCounters(game, message)
  end
  love.graphics.pop()
end

return CC
