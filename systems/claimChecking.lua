local MAX_STRIKES = 3
local SUCCESSFUL_ID_AMMOUNT = 5
local FAILED_ID_AMOUNT = 10

function registerClaimChecking(game)
  print("Registering claim checking system")

  game.claimChecking = {}
  game.claimChecking.claimsApproved = 0
  game.claimChecking.claimsDenied = 0
  game.claimChecking.dayBalance = 0
  game.claimChecking.totalBalance = 0
  game.claimChecking.strings = 0
end

function incrementClaimsApproved(approvedClaim)
  if approvedClaim.valid then
    game.claimChecking.claimsApproved = game.claimChecking.claimsApproved + 1
    game.claimChecking.dayBalance = game.claimChecking.dayBalance + SUCCESSFUL_ID_AMMOUNT
    game.claimChecking.totalBalance = game.claimChecking.totalBalance + SUCCESSFUL_ID_AMMOUNT
  else
    game.claimChecking.dayBalance = game.claimChecking.dayBalance - FAILED_ID_AMOUNT
    game.claimChecking.totalBalance = game.claimChecking.totalBalance + FAILED_ID_AMOUNT
  end
end

function incrementClaimsDenied(deniedClaim)
  if not deniedClaim.valid then
    game.claimChecking.claimsDenied = game.claimChecking.claimsDenied + 1
    game.claimChecking.dayBalance = game.claimChecking.dayBalance + SUCCESSFUL_ID_AMMOUNT
    game.claimChecking.totalBalance = game.claimChecking.totalBalance + SUCCESSFUL_ID_AMMOUNT
  else
    game.claimChecking.dayBalance = game.claimChecking.dayBalance + FAILED_ID_AMMOUNT
    game.claimChecking.totalBalance = game.claimChecking.totalBalance + FAILED_ID_AMMOUNT
  end
end

function

return registerClaimChecking
