local MAX_STRIKES = 3
local SUCCESSFUL_ID_AMMOUNT = 5
local FAILED_ID_AMOUNT = 10

local CC = {}

function CC.register(game)
  print("Registering claim checking system")

  game.claimChecking = {}
  game.claimChecking.claimsApproved = 0
  game.claimChecking.claimsDenied = 0
  game.claimChecking.dayBalance = 0
  game.claimChecking.totalBalance = 0
  game.claimChecking.strikes = 0
  game.claimChecking.dayStarted = false
  game.claimChecking.renderCount = 0

  game:on("DAY_START", CC.startDay)
  game:on("CLAIM_APPROVED", CC.incrementClaimsApproved)
  game:on("CLAIM_DENIED", CC.incrementClaimsDenied)
  game:on("RENDER_UI", CC.renderClaimCounters)
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
  game.claimChecking.strikes = 0
  game.claimChecking.claimsApproved = 0
  game.claimChecking.claimsDenied = 0
  game.claimChecking.dayBalance = 0
end

function CC.renderClaimCounters(game, message)
  game.claimChecking.renderCount = game.claimChecking.renderCount + 1
  if game.claimChecking.dayStarted then
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", 200, 500, 60, 120)

  end
end

return CC
