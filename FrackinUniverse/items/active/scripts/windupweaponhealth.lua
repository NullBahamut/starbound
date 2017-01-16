require "/scripts/util.lua"

local oldInit = init
local oldUpdate = update
local oldUnInit = uninit
local baseFireTime
local baseInaccuracy

function init()
  oldInit()
  baseFireTime = self.primaryAbility.fireTime
  baseInaccuracy = self.primaryAbility.inaccuracy
end

function update(dt, fireMode, shiftHeld)

  local scaleFactor = status.resource("health") / status.resourceMax("health") + 0.01
  local scaleFactor2 = status.resource("health") / status.resourceMax("health") + 1
  self.primaryAbility.fireTime = baseFireTime * scaleFactor
  self.primaryAbility.inaccuracy = baseInaccuracy * scaleFactor
  oldUpdate(dt, fireMode, shiftHeld)

end

function uninit()
  self.primaryAbility.fireTime = baseFireTime
  self.primaryAbility.fireTime = baseInaccuracy
  oldUnInit()
end
