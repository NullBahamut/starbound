require "/stats/effects/fu_armoreffects/setbonuses_common.lua"

function init()
    if (world.type() == "sulphuricdark") or (world.type() == "sulphuric") or (world.type() == "sulphuricocean")  then
	    setBonusInit("fu_boneset2", {
	      {stat = "maxHealth", baseMultiplier = 1.10},
	      {stat = "powerMultiplier", baseMultiplier = 1.10},
	      {stat = "physicalResistance", baseMultiplier = 1.10},
              {stat = "sulphuricImmunity", amount = 1}
	    }) 
       else
	    setBonusInit("fu_boneset2", {
	      {stat = "maxHealth", baseMultiplier = 1.0},
	      {stat = "powerMultiplier", baseMultiplier = 1.0},
	      {stat = "physicalResistance", baseMultiplier = 1.0},
              {stat = "sulphuricImmunity", amount = 1}
	    })        
    end  	
end