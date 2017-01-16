function init ()
	--initialize object and variables
	
	-- get id
	self.id = 0
	self.id = pane.containerEntityId()
	
	reinforceMaterials = {}
	baseDps = 10
	upgradeCountDown = 0
	matCheck = 5
	timeToUpdate = 1
	
	-- adding the data to the matrix, im NEO
	refinedMat = ""
	tieredMatsMatrix = {}
	tieredMatsMatrix.tier1 = {"copperbar","copperbar","copperbar","copperbar","copperbar","copperbar","ironbar","ironbar","ironbar","ironbar","tungstenbar"}
	tieredMatsMatrix.tier2 = {"copperbar","copperbar","copperbar","ironbar","ironbar","ironbar","ironbar","tungstenbar","tungstenbar","tungstenbar","titaniumbar"}
	tieredMatsMatrix.tier3 = {"copperbar","copperbar","ironbar","ironbar","tungstenbar","tungstenbar","tungstenbar","titaniumbar","titaniumbar","titaniumbar","durasteelbar"}
	tieredMatsMatrix.tier4 = {"ironbar","ironbar","tungstenbar","tungstenbar","titaniumbar","titaniumbar","titaniumbar","durasteelbar","durasteelbar","durasteelbar","refined"}
	tieredMatsMatrix.tier5 = {"tungstenbar","tungstenbar","titaniumbar","titaniumbar","durasteelbar","durasteelbar","durasteelbar","refined","refined","refined","solariumstar"}
	tieredMatsMatrix.tier6 = {"titaniumbar","titaniumbar","durasteelbar","durasteelbar","refined","refined","refined","solariumstar","solariumstar","solariumstar",{"solariumstar","goldbar"}}
	tieredMatsMatrix.tier7 = {"durasteelbar","durasteelbar","refined","refined","solariumstar","solariumstar","solariumstar",{"solariumstar","goldbar"},{"solariumstar","goldbar"},{"solariumstar","goldbar"},{"solariumstar","diamond"}}
	tieredMatsMatrix.tier8 = {"refined","refined","solariumstar","solariumstar",{"solariumstar","goldbar"},{"solariumstar","goldbar"},{"solariumstar","goldbar"},{"solariumstar","diamond"},{"solariumstar","diamond"},{"solariumstar","diamond"},{"solariumstar","refined"}}
	tieredMatsMatrix.tier9 = {"solariumstar","solariumstar",{"solariumstar","goldbar"},{"solariumstar","goldbar"},{"solariumstar","diamond"},{"solariumstar","diamond"},{"solariumstar","diamond"},{"solariumstar","refined"},{"solariumstar","refined"},{"solariumstar","refined"},{"solariumstar","refined","goldbar"}}
	tieredMatsMatrix.tier10 = {{"solariumstar","goldbar"},{"solariumstar","goldbar"},{"solariumstar","diamond"},{"solariumstar","diamond"},{"solariumstar","refined"},{"solariumstar","refined"},{"solariumstar","refined"},{"solariumstar","refined","goldbar"},{"solariumstar","refined","goldbar"},{"solariumstar","refined","goldbar"},{"solariumstar","refined","goldbar","diamond"}}
	
	luckChanceMatrix = { {5,"^#00CC00;100"},{5,"^#33CC33;90"},{5,"^#66FF33;80"},{4,"^#99FF33;70"},{4,"^#CCFF33;60"},{4,"^#FFFF00;50"},{4,"^#FFCC00;40"},{3,"^#FF9933;30"},{3,"^#FF6600;20"},{3,"^#FF0000;10"},{2,"^#FF0000;5"}}
	secureChanceMatrix = {6, 7, 8, 8, 10, 12, 15, 15, 25, 35, 50}
	
end

function update(dt)

	upgradeCountDown = upgradeCountDown + dt
	matCheck = matCheck + dt
	timeToUpdate = timeToUpdate + dt
	
	if timeToUpdate > 0.5 then
		getWeapon()
	end
	
	if matCheck < 3 then -- shortage of materials popup
		widget.setVisible ("btnUpgrade",false)
	else
		widget.setVisible("shortMatLabel",false)
	end

end


-- gets weapon information and shows GUI if there is a weapon
function getWeapon ()
	timeToUpdate=0
	local isWeapon = false
	if world.containerItemAt(self.id, 0) ~= nil then -- has item
		

		weapon = world.containerItemAt(self.id, 0)
		
		if root.itemConfig(weapon).config.itemTags == nil then
		
			isWeapon = false
		
		elseif root.itemConfig(weapon).config.itemTags[1] ~= "weapon" then
			
			isWeapon = false
			
		else
		
			isWeapon = true
		
		end
		
		if isWeapon then
		
			if weapon.parameters.primaryAbility == nil then
				weapon.parameters.primaryAbility = {}
			end
			
			weapon.parameters.itemName = weapon.parameters.ItemName or root.itemConfig(weapon).config.itemName
		
			weapon.parameters.primaryAbility = weapon.parameters.primaryAbility or {}
			if root.itemConfig(weapon).config.primaryAbility == nil then -- boomerangs and such dont have this
				weapon.parameters.primaryAbility.baseDps = weapon.parameters.primaryAbility.baseDps or baseDps
			else
				weapon.parameters.primaryAbility.baseDps = weapon.parameters.primaryAbility.baseDps or root.itemConfig(weapon).config.primaryAbility.baseDps or baseDps
			end
		
			weapon.parameters.level = weapon.parameters.level or root.itemConfig(weapon).config.level
			weapon.parameters.level = weapon.parameters.level or 1
			weapon.parameters.reinforceLevel = weapon.parameters.reinforceLevel or 0
					
		
			guiWeapon(true)
			figureProcessData()
		end			
	else
		guiWeapon(false)
	end
end


-- shows/hides Reinforce GUI based on parameter
function guiWeapon (on)

	widget.setVisible("lblIntro", not on)
	widget.setVisible("materialName", on)
	widget.setVisible("materialImage1", on)
	widget.setVisible("materialImage2", false)
	widget.setVisible("materialImage3", false)
	widget.setVisible("materialImage4", false)
	widget.setVisible("materialInfo", on)
	widget.setVisible("materialInfo1", on)
	widget.setVisible("materialInfo2", false)
	widget.setVisible("materialInfo3", false)
	widget.setVisible("materialInfo4", false)
	widget.setVisible("successPercentage", on)
	widget.setVisible("successLabel", on)
	widget.setVisible("btnUpgrade", on)
	widget.setVisible("upgradeLabel", on)
	
end


-- sets the Bar image and text based on bar required
function barImage(barName)
	
	refined = ""
	if root.itemConfig(weapon).config.tooltipKind == "sword" or root.itemConfig(weapon).config.category == "whip" then
		refined= "violium"
	elseif root.itemConfig(weapon).config.tooltipKind == "gun" or root.itemConfig(weapon).config.category == "chakram" or root.itemConfig(weapon).config.category == "boomerang" then
		refined = "aegisalt"
	else
		refined = "ferozium"
	end
	

	
	if type(barName) == "string" and barName ~= "refined" then
		widget.setImage("materialImage1", "/items/generic/crafting/"..barName..".png")
		widget.setVisible("materialImage1",true)
		widget.setText("materialInfo1", root.itemConfig(barName).config.shortdescription)
		widget.setVisible("materialInfo11",true)
	elseif type(barName) == "string" then
		widget.setImage("materialImage1", "/items/generic/crafting/refined"..refined..".png")
		widget.setVisible("materialImage1",true)
		widget.setText("materialInfo1", "ref. "..refined)
		widget.setVisible("materialInfo",true)
	else
	
		for i = 1, #barName do
			if barName[i] == "refined" then
				widget.setImage("materialImage"..i, "/items/generic/crafting/refined"..refined..".png")
				widget.setVisible("materialImage"..i,true)
				widget.setVisible("materialInfo"..i, true)
				widget.setText("materialInfo"..i,"ref. "..refined)
			else
				widget.setImage("materialImage"..i, "/items/generic/crafting/"..barName[i]..".png")
				widget.setVisible("materialImage"..i,true)
				widget.setText("materialInfo"..i,root.itemConfig(barName[i]).config.shortdescription)
				widget.setVisible("materialInfo"..i, true)
			end

		end
	end
end


-- decides what stuff it will show and display
function figureProcessData()

	getMaterialname()
	luckStuff()
	
end


-- gets required materials from the DATA - El Psy Congroo
function getMaterialname ()


	if weapon ~= nil then -- has weapon

		reinforceLevel = weapon.parameters.reinforceLevel
		
		level = weapon.parameters.level

		if(math.ceil(level)-level >= 0.5)then -- level is not an int, how weird dont you think?
			level = math.ceil(level)
		else
			level = math.floor(level)
		end
		weapon.parameters.level = level
		
		if level > 10 then
			level = 10
		end
		reinforceLevel = reinforceLevel+1
		
		sb.logInfo("weapon level: "..level)
		tprint(root.itemConfig(weapon).config,0)
		-- get material required
		if type(tieredMatsMatrix["tier" .. level][reinforceLevel]) == "string" then --only 1 material
			reinforceMaterials[1] = tieredMatsMatrix["tier" .. level][reinforceLevel]
			
		else -- 2 or more materials

			for i=1, #tieredMatsMatrix["tier"..level][reinforceLevel] do
				reinforceMaterials[i] = tieredMatsMatrix["tier"..level][reinforceLevel][i]
			end
		end
		
		-- set bar images and text
		barImage(tieredMatsMatrix["tier" .. level][reinforceLevel])
				
		widget.setText("upgradeLabel", "Current Reinforce level: +" .. reinforceLevel-1)
		
	end
end

-- sets required materials and % chance labels
function luckStuff()

	widget.setText("successPercentage", luckChanceMatrix[reinforceLevel][2] .. "%")
	widget.setText("materialInfo", "Requires x"..luckChanceMatrix[reinforceLevel][1].." of:")
	
end

-- Did you win the lottery? tuturuu
function goodjob ()

	-- init the seed for randomization
	local seed = sb.makeRandomSource():randu64()
	math.randomseed(seed)
	
	local chance = tonumber(string.sub(luckChanceMatrix[reinforceLevel][2], 10))
	
	-- randomize the randomizer
	for i=0, 10 do
		math.random()
	end


	if chance >= math.random(0,100) then
		sb.logWarn("WR - Yeahhh boy")
		return true
	end
	sb.logWarn("WR - To much Dank Souls?")
	return false
	
end


-- debug function, prints table given
function tprint (tbl, indent)
	--debbuging function
  
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      sb.logInfo(formatting)
      tprint(v, indent+1)
    elseif type(v) == 'boolean' then
      sb.logInfo(formatting .. tostring(v))      
    else
      sb.logInfo(formatting .. v)
    end
  end
end


--round function from util.round
function roundNumber(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end


--updates tooltips for weapons that dont update them automatically
function updateUniquesTooltip()
	
	if string.sub(root.itemConfig(weapon).config.itemName,-8) == "magnorbs" or root.itemConfig(weapon).config.itemName == "remotegrenadelauncher" or root.itemConfig(weapon).config.category== "boomerang" or root.itemConfig(weapon).config.category== "chakram" or root.itemConfig(weapon).config.itemName== "magnorbs" then
	--leave please
	else

	
	-- populate tooltip fields

	weapon.parameters.tooltipFields = weapon.parameters.tooltipFields or {}
	weapon.parameters.primaryAbility = weapon.parameters.primaryAbility or {}
	if root.itemConfig(weapon).config.category == "bow" then
		local bestDrawTime = (root.itemConfig(weapon).config.primaryAbility.powerProjectileTime[1] + root.itemConfig(weapon).config.primaryAbility.powerProjectileTime[2]) / 2
		local bestDrawMultiplier = root.evalFunction(root.itemConfig(weapon).config.primaryAbility.drawPowerMultiplier, bestDrawTime)
		weapon.parameters.tooltipFields.maxDamageLabel = roundNumber(weapon.parameters.primaryAbility.projectileParameters.power * root.itemConfig(weapon).config.damageLevelMultiplier * bestDrawMultiplier, 1)
	
	elseif root.itemConfig(weapon).config.category == "whip" then
	
		-- calculate damage level multiplier
		level = weapon.parameters.level or root.itemConfig(weapon).config.level
		weapon.parameters.damageLevelMultiplier = root.evalFunction("weaponDamageLevelMultiplier", level )
		local crackDps = weapon.parameters.primaryAbility.crackDps or root.itemConfig(weapon).config.primaryAbility.crackDps
	
		weapon.parameters.tooltipFields.damagePerShotLabel = roundNumber(
       ( crackDps + root.itemConfig(weapon).config.primaryAbility.chainDps) * root.itemConfig(weapon).config.primaryAbility.fireTime * weapon.parameters.damageLevelMultiplier, 1)

	else
	
		local fireTime = weapon.parameters.primaryAbility.fireTime or root.itemConfig(weapon).config.primaryAbility.fireTime or 1.0
		local baseDpsU = weapon.parameters.primaryAbility.baseDps or root.itemConfig(weapon).config.primaryAbility.baseDps or 0
		local energyUsage = weapon.parameters.primaryAbility.energyUsage or root.itemConfig(weapon).config.primaryAbility.energyUsage or 0
	
		weapon.parameters.tooltipFields.dpsLabel = roundNumber(baseDpsU * root.itemConfig(weapon).config.damageLevelMultiplier, 1)
		weapon.parameters.tooltipFields.speedLabel = roundNumber(1 / fireTime, 1)
		weapon.parameters.tooltipFields.damagePerShotLabel = roundNumber(baseDpsU * fireTime * root.itemConfig(weapon).config.damageLevelMultiplier, 1)
		weapon.parameters.tooltipFields.energyPerShotLabel = roundNumber(energyUsage * fireTime, 1)
	end
	end
end


function addReinforceToWeapon(weaponType, increaseNumber)
	weapon.parameters.projectileParameters = weapon.parameters.projectileParameters or {}
	weapon.parameters.primaryAbility = weapon.parameters.primaryAbility or {}
	weapon.parameters.primaryAbility.projectileParameters = weapon.parameters.primaryAbility.projectileParameters or {}
	local damage = 0
	--sb.logInfo("final test: weapon is a " .. weaponType)
	
	if weaponType == "dragonhead" then
		
		weapon.parameters.primaryAbility.chargeLevels = weapon.parameters.primaryAbility.chargeLevels or root.itemConfig(weapon).config.primaryAbility.chargeLevels

		weapon.parameters.primaryAbility.chargeLevels[1].baseDamage = weapon.parameters.primaryAbility.chargeLevels[1].baseDamage + increaseNumber
		weapon.parameters.primaryAbility.chargeLevels[2].baseDamage = weapon.parameters.primaryAbility.chargeLevels[2].baseDamage + increaseNumber * 8
	
		damage = weapon.parameters.primaryAbility.chargeLevels[1].baseDamage
	
	elseif weaponType == "remotegrenadelauncher" or weaponType == "boomerang" or weaponType == "chakram" or weaponType == "magnorbs" then
		if weapon.parameters.projectileParameters.power == nil then
			weapon.parameters.projectileParameters.power = root.itemConfig(weapon).config.projectileParameters.power + increaseNumber
		else
			weapon.parameters.projectileParameters.power = weapon.parameters.projectileParameters.power + increaseNumber
		end
		
		damage = weapon.parameters.projectileParameters.power
		
	elseif weaponType == "staff" or weaponType == "wand" then
		if root.itemConfig(weapon).config.itemName ~= "teslastaff" then
			if weapon.parameters.primaryAbility.projectileParameters.baseDamage == nil then
				weapon.parameters.primaryAbility.projectileParameters.baseDamage = root.itemConfig(weapon).config.primaryAbility.projectileParameters.baseDamage + increaseNumber
			else
				weapon.parameters.primaryAbility.projectileParameters.baseDamage = weapon.parameters.primaryAbility.projectileParameters.baseDamage +increaseNumber
			end
		
		damage = weapon.parameters.primaryAbility.projectileParameters.baseDamage
		
		else
			weapon.parameters.primaryAbility = weapon.parameters.primaryAbility or root.itemConfig(weapon).config.primaryAbility
			weapon.parameters.primaryAbility.damageConfig = weapon.parameters.primaryAbility.damageConfig or root.itemConfig(weapon).config.primaryAbility.damageConfig
			weapon.parameters.primaryAbility.damageConfig.baseDamage = weapon.parameters.primaryAbility.damageConfig.baseDamage +increaseNumber*1.75
		
			damage = weapon.parameters.primaryAbility.damageConfig.baseDamage
		end	
	

	elseif weaponType == "bow" or weaponType =="pollenpump" then
			if weapon.parameters.primaryAbility.projectileParameters.power == nil then
				weapon.parameters.primaryAbility.projectileParameters.power = root.itemConfig(weapon).config.primaryAbility.projectileParameters.power +1
			else
				weapon.parameters.primaryAbility.projectileParameters.power = weapon.parameters.primaryAbility.projectileParameters.power +1
			end
			
			damage = weapon.parameters.primaryAbility.projectileParameters.power
	
	elseif weaponType == "miniknoglauncher" then
		weapon.parameters.primaryAbility.baseDamage = weapon.parameters.primaryAbility.baseDamage or root.itemConfig(weapon).config.primaryAbility.baseDamage
		weapon.parameters.primaryAbility.baseDamage = weapon.parameters.primaryAbility.baseDamage + increaseNumber
		
		damage = weapon.parameters.primaryAbility.baseDamage
		
	elseif weaponType == "whip" then
	
		weapon.parameters.primaryAbility.crackDps = weapon.parameters.primaryAbility.crackDps or root.itemConfig(weapon).config.primaryAbility.crackDps
		weapon.parameters.primaryAbility.crackDps = weapon.parameters.primaryAbility.crackDps + increaseNumber
		
		damage = weapon.parameters.primaryAbility.crackDps
		
	else
		weapon.parameters.primaryAbility.baseDps = weapon.parameters.primaryAbility.baseDps + increaseNumber
	
		damage = weapon.parameters.primaryAbility.baseDps
		
	end

	--sb.logInfo("damage is " ..damage)
	
end


-- time to d-d-d-d-d-d-d-duel!!!!, i mean upgrade the weapon
function btnUpgrade ()
		
	if upgradeCountDown > 0.5 then -- this isnt a clicker, dont spam that button!!
		upgradeCountDown = 0
	
		-- Material requirements validation
		local hasAllmats = {0,0}
		
		for i=1, #reinforceMaterials do -- gets number of required items that the player has in the inventory ready to spend
			
			if reinforceMaterials[i] == "refined" then
				if player.hasItem("refined"..refined) then
					hasAllmats[1] = hasAllmats[1]+ 1
				end
			elseif player.hasItem(reinforceMaterials[i]) then
				hasAllmats[1] = hasAllmats[1] +1
			end
		end
		
		if hasAllmats[1] == #reinforceMaterials then -- has all materials
			
			for j=1, #reinforceMaterials do
				
				if reinforceMaterials[j] == "refined" then
					if (player.hasCountOfItem("refined"..refined) >= luckChanceMatrix[reinforceLevel][1]) then
						hasAllmats[2] = hasAllmats[2] +1
					end
				elseif (player.hasCountOfItem( reinforceMaterials[j] ) >= luckChanceMatrix[reinforceLevel][1]) then
					hasAllmats[2] = hasAllmats[2] + 1
				end
			end
			
			if hasAllmats[2] == #reinforceMaterials then -- player has everything to reinforce
				
				for l=1, luckChanceMatrix[reinforceLevel][1] do -- remove materials from player one by one until it reaches the required count
					for k=1, #reinforceMaterials do
						if reinforceMaterials[k] == "refined" then
							player.consumeItem("refined"..refined,false)
						else
							player.consumeItem( reinforceMaterials[k] , false )
						end
					end
				end

				if goodjob() then -- NOT bad luck brian!
			
			
					-- Reinforce
					weapon.parameters.tooltipFields = {}

					
				-- get the specific variable of the damage based on weapon type 
				
					local weaponsNamesToSpecify = {{"remotegrenadelauncher",1},{"fireworkgun",0.3},{"magnorbs",0.25},{"dragonhead",0.2},{"pollenpump",1},{"miniknoglauncher",0.5}}
					local weaponCategoriesToSpecify = {{"boomerang",0.5},{"bow",1},{"whip",0.75}, {"chakram",0.5},{"fistWeapon",1}}
					local typeSize = 0
					local weaponTypeSentToReinforce = false
					local reinforceMultiplier = 0.80
				
					for i = 1, #weaponsNamesToSpecify do
						typeSize = string.len(weaponsNamesToSpecify[i][1])
						if weaponsNamesToSpecify[i][1] == string.sub(root.itemConfig(weapon).config.itemName,-typeSize) then
							addReinforceToWeapon(weaponsNamesToSpecify[i][1],weaponsNamesToSpecify[i][2] * reinforceMultiplier)
							weaponTypeSentToReinforce = true
							break
						end
					end
					
					if weaponTypeSentToReinforce == false then
						for j=1, #weaponCategoriesToSpecify do
							if root.itemConfig(weapon).config.category == weaponCategoriesToSpecify[j][1] then
								addReinforceToWeapon(weaponCategoriesToSpecify[j][1],weaponCategoriesToSpecify[j][2] * reinforceMultiplier)
								weaponTypeSentToReinforce = true
								break
							end
						end
					end
					
					
					if weaponTypeSentToReinforce == false then
						if root.itemConfig(weapon).config.category == "staff" or root.itemConfig(weapon).config.category == "wand" then
							addReinforceToWeapon(root.itemConfig(weapon).config.category,1 * reinforceMultiplier)
						elseif root.itemConfig(weapon).config.tooltipKind == "gun" or root.itemConfig(weapon).config.tooltipKind == "sword" or root.itemConfig(weapon).config.itemTags[2] == "melee" then
							if root.itemConfig(weapon).config.tooltipKind == "gun" then
								addReinforceToWeapon(root.itemConfig(weapon).config.tooltipKind,1 * reinforceMultiplier)
							else
								addReinforceToWeapon("sword",reinforceMultiplier * 1)
							end
						end
					end

					if weapon.parameters.reinforceLevel <10 then
						weapon.parameters.tooltipFields.reinforceLabel = "+" .. weapon.parameters.reinforceLevel+1
						weapon.parameters.reinforceLevel = weapon.parameters.reinforceLevel +1
					end
					
					--update labels
					updateUniquesTooltip()
									
					world.containerTakeAt(self.id, 0)
					world.sendEntityMessage(self.id, "reinforce", weapon)
					weapon= nil
					widget.playSound("/sfx/interface/ship_confirm1.ogg")
					timeToUpdate = 0
				else
					widget.playSound("/sfx/interface/nav_insufficient_fuel.ogg")
				end
			end
		else
		
			widget.setVisible("btnUpgrade",false)
			widget.setVisible("shortMatLabel",true)
			matCheck = 0
		
		end
	end
end