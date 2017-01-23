function init()

end

function mergeAugments()
	local aug1 = world.containerItemAt(pane.containerEntityId(), 0);
	local aug2 = world.containerItemAt(pane.containerEntityId(), 1);
	
	if (not aug1 ) or (not aug2) then
		return; -- not enough items so exit
	else
		
		aug1 = root.itemConfig(aug1);
		aug2 = root.itemConfig(aug2);
		if aug1.config.category == "eppAugment" and aug2.config.category == "eppAugment" then
			--delete items
			world.containerConsumeAt(pane.containerEntityId(), 0, 1);
			world.containerConsumeAt(pane.containerEntityId(), 1, 1);
			if aug1.parameters ~= {} and aug1.parameters ~= nil then
				applyParameters(aug1);
			end
			if aug2.parameters ~= {} and aug2.parameters ~= nil then
				applyParameters(aug2);
			end
			--effect things
			local effectList  = {};
			local uniqueTester  = {};
			local uniqueModifierTester  = {};
			-- add part 1
			for _,eff in pairs(aug1.config.augment.effects) do
				if type(eff) == "string" then
					if tonumber(string.sub(eff, -3, -1)) ~= nil then
						-- set Level if effect has level
						
						local lvl = tonumber(string.sub(eff, -3, -1));--effect level
						local effName = string.sub(eff, 1, -4); -- effect name
						
						uniqueTester[effName] = lvl;
					
					elseif tonumber(string.sub(eff, -2, -1)) ~= nil then
						-- set Level if effect has level
						
						local lvl = tonumber(string.sub(eff, -2, -1));--effect level
						local effName = string.sub(eff, 1, -3); -- effect name
						
						uniqueTester[effName] = lvl;
					
					elseif tonumber(string.sub(eff, -1, -1)) ~= nil then
						-- set Level if effect has level
						
						local lvl = tonumber(string.sub(eff, -1, -1));--effect level
						local effName = string.sub(eff, 1, -2); -- effect name
						
						uniqueTester[effName] = lvl;
					
					else
						--no effect level needed
						uniqueTester[eff] = 0;
					end
				elseif type(eff) == "table" then
					uniqueModifierTester[eff["stat"]] = eff["amount"];
				end
			end
			
			-- add part 2
			for _,eff in pairs(aug2.config.augment.effects) do
				if type(eff) == "string" then
					if not (uniqueTester[eff]) then
						local lvl = 0;
						local effName = ""
						if tonumber(string.sub(eff, -3, -1)) ~= nil then
							
							lvl = tonumber(string.sub(eff, -3, -1));--effect level
							effName = string.sub(eff, 1, -4); -- effect name
							
							if not uniqueTester[effName] then
								-- set level if effect not added
								uniqueTester[effName] = tonumber(lvl);
							elseif lvl > uniqueTester[effName] then
								-- set level if lvl is higher than the current lvl
								uniqueTester[effName] = tonumber(lvl);
							end
							
						elseif tonumber(string.sub(eff, -2, -1)) ~= nil then
							
							lvl = tonumber(string.sub(eff, -2, -1));--effect level
							effName = string.sub(eff, 1, -3); -- effect name
							
							if not uniqueTester[effName] then
								-- set level if effect not added
								uniqueTester[effName] = tonumber(lvl);
							elseif lvl > uniqueTester[effName] then
								-- set level if lvl is higher than the current lvl
								uniqueTester[effName] = tonumber(lvl);
							end
							
						elseif tonumber(string.sub(eff, -1, -1)) ~= nil then
							
							lvl = tonumber(string.sub(eff, -1, -1));--effect level
							effName = string.sub(eff, 1, -2); -- effect name
							
							if not uniqueTester[effName] then
								-- set level if effect not added
								uniqueTester[effName] = tonumber(lvl);
							elseif lvl > uniqueTester[effName] then
								-- set level if lvl is higher than the current lvl
								uniqueTester[effName] = tonumber(lvl);
							end
							
						else
							uniqueTester[eff] = 0;
						end
					end
				elseif type(eff) == "table" then
					if not uniqueModifierTester[eff["stat"]] then
						uniqueModifierTester[eff["stat"]] = eff["amount"];
					elseif uniqueModifierTester[eff["stat"]] < eff["amount"] then
						uniqueModifierTester[eff["stat"]] = eff["amount"];
					end
				end
			end
			
			
			-- merge effect list
			for effName, lvl in pairs(uniqueTester) do
				if lvl == 0 then
					--if no level
					table.insert(effectList, effName);
				else
					--if has level
					table.insert(effectList, effName..tostring(lvl));
				end
			end
			
			for effName, lvl in pairs(uniqueModifierTester) do
				table.insert(effectList, {stat = effName, amount = lvl});
			end
			
			local dispName, tooltipSize = getMaximumLevels(aug1.config.augment.displayName..", "..aug2.config.augment.displayName)
			tooltipSize = (tooltipSize - 1) // 4;

			if tooltipSize < 0 then
				tooltipSize = 0;
			elseif tooltipSize > 6 then
				tooltipSize = 6;
			end
			local rarityLevel = "Common";
			if tooltipSize >= 3 then
				rarityLevel = "Legendary";
			elseif tooltipSize == 2 then
				rarityLevel = "Rare";
			elseif tooltipSize == 1 then
				rarityLevel = "Uncommon";
			end
			
			
			
			-- give merged tech to player
			player.giveItem({name = "combinedaugment", count = 1, parameters = { augment = { effects = effectList, displayName = dispName, name = dispName}, description = "Contains:\n"..dispName, price = (aug1.config.price or 0) + (aug2.config.price or 0), tooltipKind = "eppcombinedaugment"..tostring(tooltipSize), rarity = rarityLevel } } );
		elseif aug1.config.category == "enviroProtectionPack" and aug2.config.category == "enviroProtectionPack" then
			if (not aug1.parameters or aug1.parameters == {}) and (not aug2.parameters or aug2.parameters == {}) then
				return;-- no process needed
			end
			if not aug1.parameters.currentAugment and not aug2.parameters.currentAugment then
				return;-- no process needed
			end
			--delete items;
			world.containerConsumeAt(pane.containerEntityId(), 0, 1);
			world.containerConsumeAt(pane.containerEntityId(), 1, 1);
			
			--get augment to keep
			local epp2Spawn = "";
			if #aug1.config.statusEffects >= #aug2.config.statusEffects then
				epp2Spawn = aug1.config.itemName;
			else
				epp2Spawn = aug2.config.itemName;
			end
			
			--augment creation item list
			local effectList  = {};
			local uniqueTester  = {};
			local uniqueModifierTester  = {};
			
			-- add part 1
			if aug1.parameters and aug1.parameters ~= {} then -- has to process check
				if aug1.parameters.currentAugment then
					for _,eff in pairs(aug1.parameters.currentAugment.effects) do
						if type(eff) == "string" then
							if tonumber(string.sub(eff, -3, -1)) ~= nil then
								-- set Level if effect has level
								
								local lvl = tonumber(string.sub(eff, -3, -1));--effect level
								local effName = string.sub(eff, 1, -4); -- effect name
								
								uniqueTester[effName] = lvl;
							
							elseif tonumber(string.sub(eff, -2, -1)) ~= nil then
								-- set Level if effect has level
								
								local lvl = tonumber(string.sub(eff, -2, -1));--effect level
								local effName = string.sub(eff, 1, -3); -- effect name
								
								uniqueTester[effName] = lvl;
							
							elseif tonumber(string.sub(eff, -1, -1)) ~= nil then
								-- set Level if effect has level
								
								local lvl = tonumber(string.sub(eff, -1, -1));--effect level
								local effName = string.sub(eff, 1, -2); -- effect name
								
								uniqueTester[effName] = lvl;
							
							else
								--no effect level needed
								uniqueTester[eff] = 0;
							end
						elseif type(eff) == "table" then
							uniqueModifierTester[eff["stat"]] = eff["amount"];
						end
					end
				end
			end
			
			-- add part 2
			if aug2.parameters and aug2.parameters ~= {} then -- has to process check
				if aug2.parameters.currentAugment then
					for _,eff in pairs(aug2.parameters.currentAugment.effects) do
						if type(eff) == "string" then
							if not (uniqueTester[eff]) then
								local lvl = 0;
								local effName = ""
								if tonumber(string.sub(eff, -3, -1)) ~= nil then
									
									lvl = tonumber(string.sub(eff, -3, -1));--effect level
									effName = string.sub(eff, 1, -4); -- effect name
									
									if not uniqueTester[effName] then
										-- set level if effect not added
										uniqueTester[effName] = tonumber(lvl);
									elseif lvl > uniqueTester[effName] then
										-- set level if lvl is higher than the current lvl
										uniqueTester[effName] = tonumber(lvl);
									end
									
								elseif tonumber(string.sub(eff, -2, -1)) ~= nil then
									
									lvl = tonumber(string.sub(eff, -2, -1));--effect level
									effName = string.sub(eff, 1, -3); -- effect name
									
									if not uniqueTester[effName] then
										-- set level if effect not added
										uniqueTester[effName] = tonumber(lvl);
									elseif lvl > uniqueTester[effName] then
										-- set level if lvl is higher than the current lvl
										uniqueTester[effName] = tonumber(lvl);
									end
									
								elseif tonumber(string.sub(eff, -1, -1)) ~= nil then
									
									lvl = tonumber(string.sub(eff, -1, -1));--effect level
									effName = string.sub(eff, 1, -2); -- effect name
									
									if not uniqueTester[effName] then
										-- set level if effect not added
										uniqueTester[effName] = tonumber(lvl);
									elseif lvl > uniqueTester[effName] then
										-- set level if lvl is higher than the current lvl
										uniqueTester[effName] = tonumber(lvl);
									end
									
								else
									uniqueTester[eff] = 0;
								end
							end
						elseif type(eff) == "table" then
							if not uniqueModifierTester[eff["stat"]] then
								uniqueModifierTester[eff["stat"]] = eff["amount"];
							elseif uniqueModifierTester[eff["stat"]] < eff["amount"] then
								uniqueModifierTester[eff["stat"]] = eff["amount"];
							end
						end
					end
				end
			end
			
			
			-- merge effect list
			for effName, lvl in pairs(uniqueTester) do
				if lvl == 0 then
					--if no level
					table.insert(effectList, effName);
				else
					--if has level
					table.insert(effectList, effName..tostring(lvl));
				end
			end
			
			for effName, lvl in pairs(uniqueModifierTester) do
				table.insert(effectList, {stat = effName, amount = lvl});
			end
			
			
			local dispName = "";
			local tooltipSize = 0;
			if aug1.parameters.currentAugment and aug2.parameters.currentAugment then
				dispName, tooltipSize = getMaximumLevels(aug1.parameters.currentAugment.displayName..", "..aug2.parameters.currentAugment.displayName)
			elseif aug1.parameters.currentAugment and not aug2.parameters.currentAugment then
				dispName, tooltipSize = getMaximumLevels(aug1.parameters.currentAugment.displayName)
			else
				dispName, tooltipSize = getMaximumLevels(aug2.parameters.currentAugment.displayName)
			end
			tooltipSize = (tooltipSize - 1) // 4;

			if tooltipSize < 0 then
				tooltipSize = 0;
			elseif tooltipSize > 6 then
				tooltipSize = 6;
			end
			
			-- give merged tech to player
			player.giveItem({name = epp2Spawn, count = 1, parameters = { tooltipKind = "combinedepp"..tostring(tooltipSize) ,currentAugment = { displayIcon = "/items/augments/back/combinedaugment.png", name = "combinedaugment", type = "back", effects = effectList, displayName = dispName, name = dispName} } } );
		elseif (aug1.config.category == "eppAugment" and aug2.config.category == "enviroProtectionPack") or (aug2.config.category == "eppAugment" and aug1.config.category == "enviroProtectionPack") then
			
			--delete items;
			world.containerConsumeAt(pane.containerEntityId(), 0, 1);
			world.containerConsumeAt(pane.containerEntityId(), 1, 1);
			local temp = {};
			--reorder
			if aug1.config.category == "eppAugment" then
				temp = copy(aug1);
				aug1 = copy(aug2);
				aug2 = copy(temp);
				temp = nil;
			end
			
			
			if aug2.parameters ~= {} and aug2.parameters ~= nil then
				applyParameters(aug2);
			end
			
			--get augment to keep
			local epp2Spawn = "";
			epp2Spawn = aug1.config.itemName;
			
			--augment creation item list
			local effectList  = {};
			local uniqueTester  = {};
			local uniqueModifierTester  = {};
			
			-- add part 1
			if aug1.parameters and aug1.parameters ~= {} then -- has to process check
				if aug1.parameters.currentAugment then
					for _,eff in pairs(aug1.parameters.currentAugment.effects) do
						if type(eff) == "string" then
							if tonumber(string.sub(eff, -3, -1)) ~= nil then
								-- set Level if effect has level
								
								local lvl = tonumber(string.sub(eff, -3, -1));--effect level
								local effName = string.sub(eff, 1, -4); -- effect name
								
								uniqueTester[effName] = lvl;
							
							elseif tonumber(string.sub(eff, -2, -1)) ~= nil then
								-- set Level if effect has level
								
								local lvl = tonumber(string.sub(eff, -2, -1));--effect level
								local effName = string.sub(eff, 1, -3); -- effect name
								
								uniqueTester[effName] = lvl;
							
							elseif tonumber(string.sub(eff, -1, -1)) ~= nil then
								-- set Level if effect has level
								
								local lvl = tonumber(string.sub(eff, -1, -1));--effect level
								local effName = string.sub(eff, 1, -2); -- effect name
								
								uniqueTester[effName] = lvl;
							
							else
								--no effect level needed
								uniqueTester[eff] = 0;
							end
						elseif type(eff) == "table" then
							uniqueModifierTester[eff["stat"]] = eff["amount"];
						end
					end
				end
			end
			
			-- add part 2
			for _,eff in pairs(aug2.config.augment.effects) do
				if type(eff) == "string" then
					if not (uniqueTester[eff]) then
						local lvl = 0;
						local effName = ""
						if tonumber(string.sub(eff, -3, -1)) ~= nil then
							
							lvl = tonumber(string.sub(eff, -3, -1));--effect level
							effName = string.sub(eff, 1, -4); -- effect name
							
							if not uniqueTester[effName] then
								-- set level if effect not added
								uniqueTester[effName] = tonumber(lvl);
							elseif lvl > uniqueTester[effName] then
								-- set level if lvl is higher than the current lvl
								uniqueTester[effName] = tonumber(lvl);
							end
							
						elseif tonumber(string.sub(eff, -2, -1)) ~= nil then
							
							lvl = tonumber(string.sub(eff, -2, -1));--effect level
							effName = string.sub(eff, 1, -3); -- effect name
							
							if not uniqueTester[effName] then
								-- set level if effect not added
								uniqueTester[effName] = tonumber(lvl);
							elseif lvl > uniqueTester[effName] then
								-- set level if lvl is higher than the current lvl
								uniqueTester[effName] = tonumber(lvl);
							end
							
						elseif tonumber(string.sub(eff, -1, -1)) ~= nil then
							
							lvl = tonumber(string.sub(eff, -1, -1));--effect level
							effName = string.sub(eff, 1, -2); -- effect name
							
							if not uniqueTester[effName] then
								-- set level if effect not added
								uniqueTester[effName] = tonumber(lvl);
							elseif lvl > uniqueTester[effName] then
								-- set level if lvl is higher than the current lvl
								uniqueTester[effName] = tonumber(lvl);
							end
							
						else
							uniqueTester[eff] = 0;
						end
					end
				elseif type(eff) == "table" then
					if not uniqueModifierTester[eff["stat"]] then
						uniqueModifierTester[eff["stat"]] = eff["amount"];
					elseif uniqueModifierTester[eff["stat"]] < eff["amount"] then
						uniqueModifierTester[eff["stat"]] = eff["amount"];
					end
				end
			end
			
			
			-- merge effect list
			for effName, lvl in pairs(uniqueTester) do
				if lvl == 0 then
					--if no level
					table.insert(effectList, effName);
				else
					--if has level
					table.insert(effectList, effName..tostring(lvl));
				end
			end
			
			for effName, lvl in pairs(uniqueModifierTester) do
				table.insert(effectList, {stat = effName, amount = lvl});
			end
			
			
			local dispName = "";
			local tooltipSize = 0;
			if aug1.parameters.currentAugment then
				dispName, tooltipSize = getMaximumLevels(aug1.parameters.currentAugment.displayName..", "..aug2.config.augment.displayName)
			else
				dispName, tooltipSize = getMaximumLevels(aug2.config.augment.displayName)
			end
			tooltipSize = (tooltipSize - 1) // 4;

			if tooltipSize < 0 then
				tooltipSize = 0;
			elseif tooltipSize > 6 then
				tooltipSize = 6;
			end
			
			
			-- give merged tech to player
			player.giveItem({name = epp2Spawn, count = 1, parameters = { tooltipKind = "combinedepp"..tostring(tooltipSize) ,currentAugment = { displayIcon = "/items/augments/back/combinedaugment.png", name = "combinedaugment", type = "back", effects = effectList, displayName = dispName, name = dispName} } } );
		else
			return; -- can't merge non epp augment things
		end
	end
end


function applyParameters(item)
	for k,v in pairs(item.parameters) do
		if type(v) == "table" then
			if table.isArray2(v) then
				item.config[k] = v;
			else
				item.config[k] = applyTable(item.config[k], item.parameters[k]);
			end
		else
			item.config[k] = v;
		end
	end
	return item;
end

function applyTable(conf, param)
	for k,v in pairs(param) do
		if type(v) == "table" then
			if table.isArray2(v) then
				conf[k] = v;
			else
				conf[k] = applyTable(conf[k], param[k]);
			end
		else
			conf[k] = v
		end
	end
	return conf;
end

function table.isArray2(tbl)
	for k,v in pairs(tbl) do
		if type(k) ~= "number"  then
			return false;
		end
	end
	return true;
end

function table.isArray1(tbl)
	local hasTable = false;
	for k,v in pairs(tbl) do
		if type(v) == "table" then
			hasTable = true;
			local tblKeyCount = 0;
			for _,_ in pairs(v) do
				tblKeyCount = tblKeyCount + 1;
			end
			if tblKeyCount >= 3 then
				return false;	
			end
		end
		if type(k) ~= "number"  then
			return false;
		end
	end
	if hasTable and #tbl >= 3 then
		return false;
	else
		return true;
	end
end

--debug print
function printtable(tbl)
	sb.logInfo("printing table start");
	for k,v in pairs(tbl) do
		if type(v) == "table" then
			if table.isArray1(v) then
				local arrstr = "[ ";
				for _,data in pairs(v) do
					arrstr = arrstr..printValue(data)..", ";
				end
				arrstr = string.sub(arrstr, 1,-3);
				arrstr = arrstr.." ]";
				sb.logInfo(printKey(k).." : "..arrstr);
			else
				sb.logInfo(printKey(k).." : {");
				printtable2(1,"	",v);
				sb.logInfo("}");
			end
		else
			sb.logInfo(printKey(k).." : "..printValue(v));
		end
	end	sb.logInfo("printing table end");

end
-- debug printery
function printtable2(iter,tab,tbl)
	--anti fuckery
	if iter >= 10 then
		return;
	end
	
	for k,v in pairs(tbl) do
		if type(v) == "table" then
			if table.isArray1(v) then
				local arrstr = "[ ";
				for _,data in pairs(v) do
					arrstr = arrstr..printValue(data)..", ";
				end
				arrstr = string.sub(arrstr, 1,-3);
				arrstr = arrstr.." ]";
				sb.logInfo(tab..printKey(k).." : "..arrstr);
			else
				sb.logInfo(tab..printKey(k).." : {");
				printtable2(iter+1,tab.."	",v);
				sb.logInfo(tab.."}");
			end
		else
			sb.logInfo(tab..printKey(k).." : "..printValue(v):gsub("%%","°/o'"));
		end
	end
end

function printKey(key)
	if tonumber(key) ~= nil then
		return key;
	else
		return "\""..tostring(key).."\"";
	end
end

function printValue(value)
	if not value then
		return "null";
	elseif type(value) == "table" then
		local rt = "{ ";
		for k,v in pairs(value) do
			rt = rt..printKey(k).. " : " ..printValue(v)..", ";
		end
		rt = string.sub(rt, 1,-3).."}";
		return rt;
	elseif type(value) == "function" then
		return "lua function";
	elseif type(value) == "string" then
		return "\""..value.."\"";
	elseif type(value) == "char" then
		return "'"..value.."'";
	else
		return tostring(value);
	end
end

function getMaximumLevels(str)
	--split string at ", \n*", from lua-users.org with some modification
	local t = {};
	local last = 1;
	local s, e, cap = string.find(str,"(.-), [\n]*", 1);
	while s do
		if s ~= 1 or cap ~= "" then
			table.insert(t,cap);
		end
		last = e+1;
		s, e, cap = string.find(str,"(.-), [\n]*", last);
	end
	if last <= #str then
		cap = string.sub(str,last);
		table.insert(t, cap);
	end
	--end of split
	
	--keep unique and better
	local tbl = {};
	for _,v in pairs(t) do
		if string.match(v," VI$") then
			tbl[string.sub(v, 1, -4)] = 6;
		elseif string.match(v," V$") then
			if not tbl[string.sub(v, 1, -3)] then
				tbl[string.sub(v, 1, -3)] = 5;
			elseif tbl[string.sub(v, 1, -3)] < 5 then
				tbl[string.sub(v, 1, -3)] = 5;
			end
		elseif string.match(v," IV$") then
			if not tbl[string.sub(v, 1, -4)] then
				tbl[string.sub(v, 1, -4)] = 4;
			elseif tbl[string.sub(v, 1, -4)] < 4 then
				tbl[string.sub(v, 1, -4)] = 4;
			end
		elseif string.match(v," III$") then
				if not tbl[string.sub(v, 1, -5)] then
				tbl[string.sub(v, 1, -5)] = 3;
			elseif tbl[string.sub(v, 1, -5)] < 3 then
				tbl[string.sub(v, 1, -5)] = 3;
			end
		elseif string.match(v," II$") then
			if not tbl[string.sub(v, 1, -4)] then
				tbl[string.sub(v, 1, -4)] = 2;
			elseif tbl[string.sub(v, 1, -4)] < 2 then
				tbl[string.sub(v, 1, -4)] = 2;
			end
		elseif string.match(v," I$") then
			if not tbl[string.sub(v, 1, -3)] then
				tbl[string.sub(v, 1, -3)] = 1;
			end
		else
			tbl[v.." 1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"] = 0;
		end
	end
	
	-- create output name
	local disp = "";
	local count = 0;
	
	for k,v in spairs(tbl) do 
		if disp ~= "" then
			disp = disp..", ";
			if count ~= 0 and (count % 2) == 0 then
				disp = disp.."\n";
			end
		end
		if v == 0 then
			disp = disp..k;
		else
			disp = disp..k.." "..numberToRoman(v);
		end
		
		count = count + 1;
	end
	disp = disp:gsub(" 1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", "");
	
	return disp, count;
end

function numberToRoman(num)
	if num == 0 then
		return "";
	elseif num == 1 then
		return "I";
	elseif num == 2 then
		return "II";
	elseif num == 3 then
		return "III";
	elseif num == 4 then
		return "IV";
	elseif num == 5 then
		return "V";
	elseif num == 6 then
		return "VI";
	end
end

function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function copy(obj)
  if type(obj) ~= 'table' then return obj end
  local res = {}
  for k, v in pairs(obj) do res[copy(k)] = copy(v) end
  return res
end