if (bLogs.CustomConfig["DisableServerLog"] == true) then
	function ServerLog() end
end

bLogs.CreateCategory("Players",Color(0,110,255))

bLogs.DefineLogger("Weapon Pickups","Players")
bLogs.AddHook("WeaponEquip","Weapon Pickups",function(weapon)
	hook.Remove("Think","blogs_" .. weapon:EntIndex())
	hook.Add("Think","blogs_" .. weapon:EntIndex(),function()
		if (IsValid(weapon)) then
			if (IsValid(weapon:GetOwner())) then
				local n = ""
				local t = weapon:GetTable()
				if (t ~= nil) then
					if (t.PrintName ~= nil) then
						n = t.PrintName .. " (" .. weapon:GetClass() .. ")"
					elseif (t.Name) then
						n = t.Name .. " (" .. weapon:GetClass() .. ")"
					else
						n = weapon:GetClass()
					end
				else
					n = weapon:GetClass()
				end
				bLogs.Log({
					module = "Weapon Pickups",
					involved = {weapon:GetOwner():SteamID64()},
					log = bLogs.GetName(weapon:GetOwner()) .. " picked up a " .. n,
				})
				hook.Remove("Think","blogs_" .. weapon:EntIndex())
			end
		else
			hook.Remove("Think","blogs_" .. weapon:EntIndex())
		end
	end)
end)

bLogs.DefineLogger("Connections","Players")
bLogs.AddGameEvent("player_connect","Connections",function(data)
	if CLIENT then return end
	bLogs.Log({
		module = "Connections",
		involved = {util.SteamIDTo64(data.networkid)},
		log = data.name .. " (" .. data.networkid .. ") connected",
	})
end)

bLogs.AddGameEvent("player_disconnect","Connections",function(data)
	if CLIENT then return end
	bLogs.Log({
		module = "Connections",
		involved = {util.SteamIDTo64(data.networkid)}, -- ill make it support this later on
		log = data.name .. " (" .. data.networkid .. ") disconnected (" .. data.reason .. ")",
	})
end)

bLogs.AddHook("CheckPassword","Connections",function(steamid64,ip,svpassword,password,name)
	if (svpassword == "") then return end
	if (password ~= svpassword) then
		bLogs.Log({
			module = "Connections",
			involved = {steamid64},
			log = name .. " attempted to connect with the incorrect password \"" .. password .. "\"",
		})
	end
end)

bLogs.DefineLogger("Player Kills","Players")
bLogs.DefineLogger("Entity Kills","Players")
bLogs.DefineLogger("Player Damage","Players")
bLogs.DefineLogger("Entity Damage","Players")
bLogs.DefineLogger("Car Damage","Players")
bLogs.DefineLogger("Car Deaths","Players")

bLogs.AddHook("PlayerDeath","Player Kills",function(ply,This_Is_Stupidly_Random,ply2)
	if (type(ply) ~= "Player") then return end
	if (not IsValid(ply2) and not ply2:IsWorld()) then return end
	if (ply2:IsWorld()) then
		bLogs.Log({
			module = "Player Kills",
			log = bLogs.GetName(ply) .. " was killed by falldamage or crushing",
			involved = {ply},
		})
		return
	end
	if (type(ply2) == "Player") then
		if (ply:HasGodMode()) then return end
		local wep = ply2:GetActiveWeapon()

		if (ply == ply2) then
			bLogs.Log({
				module = "Player Kills",
				log = bLogs.GetName(ply) .. " killed themself",
				involved = {ply},
			})

			return nil
		end

		local wepStr
		if (IsValid(wep)) then
			wepStr = bLogs.GetPrintName(wep)
		end

		if (wepStr ~= nil) then
			bLogs.Log({
				module = "Player Kills",
				log = bLogs.GetName(ply) .. " was killed by " .. bLogs.GetName(ply2) .. " with a " .. wepStr,
				involved = {ply,ply2},
			})
		else
			bLogs.Log({
				module = "Player Kills",
				log = bLogs.GetName(ply) .. " was killed by " .. bLogs.GetName(ply2),
				involved = {ply,ply2},
			})
		end
	elseif (type(ply2) == "Vehicle") then
		local found = false
		for _,v in pairs(player.GetAll()) do
			local veh = v:GetVehicle()
			if (veh ~= nil) then
				if (veh == ply2) then
					found = v
				end
			end
		end
		if (found ~= false) then
			bLogs.Log({
				module = "Car Deathmatch",
				log = bLogs.GetName(ply) .. " was killed by " .. bLogs.GetName(found) .. " with a " .. ply2:GetClass(),
				involved = {ply,found[1]},
			})
		else
			bLogs.Log({
				module = "Car Deathmatch",
				log = bLogs.GetName(ply) .. " was killed by a vehicle with nobody driving it (" .. ply2:GetClass() .. ")",
				involved = {ply},
			})
		end
	elseif (table.HasValue({"Entity","Weapon","NPC","NextBot"},type(ply2)) and IsValid(ply2)) then
		local owner = bLogs.GetOwner(ply2)
		if (ply2:GetClass() == "prop_physics") then
			if (IsValid(owner)) then
				bLogs.Log({
					module = "Entity Kills",
					log = bLogs.GetName(ply) .. " was killed by a prop (" .. ply2:GetModel() .. ") owned by " .. bLogs.GetName(owner),
					involved = {ply,owner},
				})
			else
				bLogs.Log({
					module = "Entity Kills",
					log = bLogs.GetName(ply) .. " was killed by a world prop (unowned) (" .. ply2:GetModel() .. ")",
					involved = {ply},
				})
			end
		elseif (IsValid(owner)) then
			bLogs.Log({
				module = "Entity Kills",
				log = bLogs.GetName(ply) .. " was killed by an entity (" .. (ply2:GetModel() or "no model") .. ", " .. (ply2:GetClass() or "unknown class") .. ") owned by " .. bLogs.GetName(owner),
				involved = {ply,owner},
			})
		else
			bLogs.Log({
				module = "Entity Kills",
				log = bLogs.GetName(ply) .. " was killed by an entity (" .. (ply2:GetModel() or "no model") .. ", " .. (ply2:GetClass() or "unknown class") .. ") with an unknown owner (possibly a world/blocked entity)",
				involved = {ply},
			})
		end
	elseif (not IsValid(ply2)) then
		bLogs.Log({
			module = "Entity Kills",
			log = bLogs.GetName(ply) .. " was killed by an unknown entity (maybe a map entity?)",
			involved = {ply},
		})
	else
		-- im not sure how this is possible lol
		bLogs.Log({
			module = "Entity Kills",
			log = bLogs.GetName(ply) .. " was killed by \"" .. tostring(ply2) .. "\" with a \"" .. tostring(This_Is_Stupidly_Random) .. "\"??",
			involved = {ply},
		})
	end
end)

bLogs.AddHook("EntityTakeDamage","Player Damage",function(ply,dmginfo)
	if (type(ply) ~= "Player") then return end
	if (dmginfo:GetDamage() == 0) then return end
	if (ply:HasGodMode()) then return end
	local This_Is_Stupidly_Random = dmginfo:GetInflictor()
	local ply2 = dmginfo:GetAttacker()
	if (not IsValid(ply2) and not ply2:IsWorld()) then return end

	if ((ply:Health() - dmginfo:GetDamage()) < 1) then return end

	if (ply2:IsWorld()) then
		bLogs.Log({
			module = "Player Damage",
			log = bLogs.GetName(ply) .. " was damaged by falldamage or crushing for " .. math.Round(dmginfo:GetDamage()) .. " damage",
			involved = {ply},
		})
		return
	end

	if (type(ply2) == "Player") then
		local wep = ply2:GetActiveWeapon()

		if (ply == ply2) then
			bLogs.Log({
				module = "Player Damage",
				log = bLogs.GetName(ply) .. " damaged themself for " .. math.Round(dmginfo:GetDamage()) .. " damage",
				involved = {ply},
			})

			return nil
		end

		local wepStr
		if (IsValid(wep)) then
			wepStr = bLogs.GetPrintName(wep)
		end

		if (wepStr ~= nil) then
			bLogs.Log({
				module = "Player Damage",
				log = bLogs.GetName(ply) .. " was damaged for " .. math.Round(dmginfo:GetDamage()) .. " damage by " .. bLogs.GetName(ply2) .. " with a " .. wepStr,
				involved = {ply,ply2},
			})
		else
			bLogs.Log({
				module = "Player Damage",
				log = bLogs.GetName(ply) .. " was damaged for " .. math.Round(dmginfo:GetDamage()) .. " damage by " .. bLogs.GetName(ply2),
				involved = {ply,ply2},
			})
		end
	elseif (not IsValid(ply2)) then
		bLogs.Log({
			module = "Entity Kills",
			log = bLogs.GetName(ply) .. " was killed by an unknown entity (maybe a map entity?)",
			involved = {ply},
		})
	elseif (type(ply2) == "Vehicle") then
		local found = false
		for _,v in pairs(player.GetAll()) do
			local veh = v:GetVehicle()
			if (veh ~= nil) then
				if (veh == ply2) then
					found = v
				end
			end
		end
		if (found ~= false) then
			bLogs.Log({
				module = "Car Damage",
				log = bLogs.GetName(ply) .. " was damaged for " .. math.Round(dmginfo:GetDamage()) .. " damage by " .. bLogs.GetName(found) .. " with a " .. ply2:GetClass(),
				involved = {ply,found[1]},
			})
		else
			bLogs.Log({
				module = "Car Damage",
				log = bLogs.GetName(ply) .. " was damaged for " .. math.Round(dmginfo:GetDamage()) .. " damage by a vehicle with nobody driving it (" .. ply2:GetClass() .. ")",
				involved = {ply},
			})
		end
	elseif (table.HasValue({"Entity","Weapon","NPC","NextBot"},type(ply2)) and IsValid(ply2)) then
		local owner = bLogs.GetOwner(ply2)
		if (ply2:GetClass() == "prop_physics") then
			if (IsValid(owner)) then
				bLogs.Log({
					module = "Entity Damage",
					log = bLogs.GetName(ply) .. " was damaged by a prop (" .. ply2:GetModel() .. ") for " .. math.Round(dmginfo:GetDamage()) .. " damage owned by " .. bLogs.GetName(owner),
					involved = {ply,owner},
				})
			else
				bLogs.Log({
					module = "Entity Damage",
					log = bLogs.GetName(ply) .. " was damaged by a prop (" .. ply2:GetModel() .. ") for " .. math.Round(dmginfo:GetDamage()) .. " damage by a world prop",
					involved = {ply},
				})
			end
		else
			if (IsValid(owner)) then
				bLogs.Log({
					module = "Entity Damage",
					log = bLogs.GetName(ply) .. " was damaged by an entity (" .. ply2:GetModel() .. ", " .. ply2:GetClass() .. ") for " .. math.Round(dmginfo:GetDamage()) .. " damage owned by " .. bLogs.GetName(owner),
					involved = {ply,owner},
				})
			else
				bLogs.Log({
					module = "Entity Damage",
					log = (bLogs.GetName(ply) or "UNKNOWN") .. " was damaged by an entity (" .. (ply2:GetModel() or "UNKNOWN") .. ", " .. (ply2:GetClass() or "UNKNOWN") .. ") for " .. math.Round(dmginfo:GetDamage()) .. " damage with an unknown owner (possibly a world/blocked entity)",
					involved = {ply},
				})
			end
		end
	end
end)