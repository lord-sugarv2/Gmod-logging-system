bLogs.CreateCategory("DarkRP",Color(175,70,0))
bLogs.DefineLogger("Lockpicks","DarkRP",false)
bLogs.DefineLogger("Arrests","DarkRP",false)
bLogs.DefineLogger("Unarrests","DarkRP",false)
bLogs.DefineLogger("Job changes","DarkRP",false)
bLogs.DefineLogger("Name Change","DarkRP",false)
bLogs.DefineLogger("Demotes","DarkRP",false)
bLogs.DefineLogger("Doors/Vehicles","DarkRP",false)
bLogs.DefineLogger("Battering ram","DarkRP",false)
bLogs.DefineLogger("Hits","DarkRP",false)
bLogs.DefineLogger("Buys","DarkRP",false)
bLogs.DefineLogger("Wanted","DarkRP",false)
bLogs.DefineLogger("Warrants","DarkRP",false)
bLogs.DefineLogger("Pocket","DarkRP",false)
bLogs.DefineLogger("Starvation","DarkRP",false)
bLogs.DefineLogger("Weapon Checks","DarkRP",false)
bLogs.DefineLogger("Adverts","DarkRP",false)
bLogs.DefineLogger("Economy","DarkRP",false)
bLogs.DefineLogger("Laws","DarkRP",false)
bLogs.DefineLogger("Agenda","DarkRP",false)
bLogs.DefineLogger("Chat","Players")


local function chathook(ply,txt,team)
	if (!IsValid(ply)) then return end
	if (!ply:IsPlayer()) then return end
	if (txt == "") then return end
	local teams = ""
	if (team == true) then
		teams = "(TEAM) "
	end
	bLogs.Log({
		module = "Chat",
		log = bLogs.GetName(ply) .. ": " .. teams .. txt,
		involved = {ply},
	})
end

if (DarkRP) then
	local stubs = DarkRP.getHooks()

	bLogs.EnableLogger("Lockpicks")
	bLogs.EnableLogger("Arrests")
	bLogs.EnableLogger("Unarrests")
	bLogs.EnableLogger("Job changes")
	bLogs.EnableLogger("Name Change")
	bLogs.EnableLogger("Demotes")
	bLogs.EnableLogger("Doors/Vehicles")
	bLogs.EnableLogger("Battering ram")
	bLogs.EnableLogger("Hits")
	bLogs.EnableLogger("Buys")
	bLogs.EnableLogger("Wanted")
	bLogs.EnableLogger("Warrants")
	bLogs.EnableLogger("Pocket")
	bLogs.EnableLogger("Weapon Checks")
	bLogs.EnableLogger("Adverts")
	bLogs.EnableLogger("Economy")
	bLogs.EnableLogger("Laws")
	bLogs.EnableLogger("Agenda")

	if (bLogs.CustomConfig["DisableDarkRPLog"] == true) then
		DarkRP.log = function() end
	end

	bLogs.AddHook("agendaUpdated","Agenda",function(ply,t,text)
		bLogs.Log({
			module = "Agenda",
			log = bLogs.GetName(ply) .. " set the \"" .. t.Title .. "\" to \"" .. text .. "\"",
			involved = {ply},
		})
	end)

	bLogs.AddHook("addLaw","Laws",function(_,law)
		for _,v in pairs(player.GetAll()) do
			if (v:isMayor()) then
				bLogs.Log({
					module = "Laws",
					log = bLogs.GetName(v) .. " added law \"" .. law  .. "\"",
					involved = {v},
				})
				return
			end
		end
	end)
	bLogs.AddHook("removeLaw","Laws",function(_,law)
		for _,v in pairs(player.GetAll()) do
			if (v:isMayor()) then
				bLogs.Log({
					module = "Laws",
					log = bLogs.GetName(v) .. " removed law \"" .. law  .. "\"",
					involved = {v},
				})
				return
			end
		end
	end)
	bLogs.AddHook("resetLaws","Laws",function(ply)
		bLogs.Log({
			module = "Laws",
			log = bLogs.GetName(ply) .. " reset the laws",
			involved = {ply},
		})
	end)

	bLogs.AddHook("playerDroppedCheque","Economy",function(ply,recipient,amount,ent)
		ent.bLogsDropper = ply
	end)
	bLogs.AddHook("playerDroppedMoney","Economy",function(ply,amount,ent)
		ent.bLogsDropper = ply
	end)
	bLogs.AddHook("playerToreUpCheque","Economy",function(ply,recipient,amount,ent)
		bLogs.Log({
			module = "Economy",
			log = bLogs.GetName(ply) .. " tore up their " .. bLogs.FormatCurrency(ent:Getamount() or 0) .. " cheque written to " .. bLogs.GetName(ent:Getrecipient()),
			involved = {ply},
		})
	end)
	bLogs.AddHook("playerPickedUpCheque","Economy",function(ply,recipient,amount,success,ent)
		if (success) then
			if (IsValid(ent.bLogsDropper)) then
				bLogs.Log({
					module = "Economy",
					log = bLogs.GetName(ply) .. " cashed a " .. bLogs.FormatCurrency(amount) .. " cheque written by " .. bLogs.GetName(ent.bLogsDropper),
					involved = {ply},
				})
			else
				bLogs.Log({
					module = "Economy",
					log = bLogs.GetName(ply) .. " cashed a " .. bLogs.FormatCurrency(amount) .. " cheque",
					involved = {ply},
				})
			end
		end
	end)
	bLogs.AddHook("playerPickedUpMoney","Economy",function(ply,amount,ent)
		if (not IsValid(ent)) then
			bLogs.Log({
				module = "Economy",
				log = bLogs.GetName(ply) .. " picked up " .. bLogs.FormatCurrency(amount),
				involved = {ply},
			})
		else
			if (IsValid(ent.bLogsDropper)) then
				if (ent.bLogsDropper == ply) then
					bLogs.Log({
						module = "Economy",
						log = bLogs.GetName(ply) .. " picked up " .. bLogs.FormatCurrency(amount) .. " dropped by themself",
						involved = {ply},
					})
				else
					bLogs.Log({
						module = "Economy",
						log = bLogs.GetName(ply) .. " picked up " .. bLogs.FormatCurrency(amount) .. " dropped by " .. bLogs.GetName(ent.bLogsDropper),
						involved = {ply},
					})
				end
			else
				bLogs.Log({
					module = "Economy",
					log = bLogs.GetName(ply) .. " picked up " .. bLogs.FormatCurrency(amount),
					involved = {ply},
				})
			end
		end
	end)
	bLogs.AddHook("playerEnteredLottery","Economy",function(ply)
		bLogs.Log({
			module = "Economy",
			log = bLogs.GetName(ply) .. " entered the lottery",
			involved = {ply},
		})
	end)

	bLogs.AddHook("onChatCommand","Chat",function(ply,cmd,args)
		if (!IsValid(ply)) then return end
		if (!ply:IsPlayer()) then return end
		if (type(cmd) == "table") then cmd = table.concat(cmd) end
		local args_table
		if (type(args) == "table") then
			args_table = args
			args = table.concat(args," ")
		else
			args_table = string.Explode(" ",args)
		end
		if (cmd:lower() == "advert") then
			bLogs.Log({
				module = "Adverts",
				log = bLogs.GetName(ply) .. ": " .. args,
				involved = {ply},
			})
		elseif (cmd:lower() == "dropmoney" or cmd:lower() == "moneydrop" and not stubs["playerPickedUpMoney"]) then
			bLogs.Log({
				module = "Economy",
				log = bLogs.GetName(ply) .. " dropped " .. bLogs.FormatCurrency(args),
				involved = {ply},
			})
		elseif (cmd:lower() == "give") then
			local e = ply:GetEyeTrace()
			if (not e) then return end
			if (not IsValid(e.Entity)) then return end
			if (not e.Entity:IsPlayer()) then return end
			bLogs.Log({
				module = "Economy",
				log = bLogs.GetName(ply) .. " gave " .. bLogs.FormatCurrency(args_table[1]) .. " to " .. bLogs.GetName(e.Entity),
				involved = {ply,e.Entity},
			})
		elseif (cmd:lower() == "cheque" or cmd:lower() == "check") then
			local ply2 = bLogs.FindPlayer(args_table[1],true)
			if (ply2) then
				bLogs.Log({
					module = "Economy",
					log = bLogs.GetName(ply) .. " wrote a " .. bLogs.FormatCurrency(args_table[2]) .. " cheque for " .. bLogs.GetName(ply2),
					involved = {ply,ply2},
				})
			end
		end
		bLogs.Log({
			module = "Chat",
			log = bLogs.GetName(ply) .. ": /" .. cmd .. " " .. args,
			involved = {ply},
		})
		return nil
	end)
	bLogs.AddHook("PostPlayerSay","Chat",chathook)

	bLogs.AddHook("playerWeaponsChecked","Weapon Checks",function(checker,target)
		bLogs.Log({
			module = "Weapon Checks",
			log = bLogs.GetName(checker) .. " weapon checked " .. bLogs.GetName(target),
			involved = {checker,target},
		})
	end)

	bLogs.AddHook("playerWeaponsReturned","Weapon Checks",function(checker,target)
		bLogs.Log({
			module = "Weapon Checks",
			log = bLogs.GetName(checker) .. " returned the weapons of " .. bLogs.GetName(target),
			involved = {checker,target},
		})
	end)

	bLogs.AddHook("playerWeaponsConfiscated","Weapon Checks",function(checker,target)
		bLogs.Log({
			module = "Weapon Checks",
			log = bLogs.GetName(checker) .. " confiscated the weapons of " .. bLogs.GetName(target),
			involved = {checker,target},
		})
	end)

	bLogs.AddHook("playerBoughtAmmo","Buys",function(ply,entTable,ent,for_p)
		local entclass = "[UNKNOWN]"
		local entprintname
		if (IsValid(ent)) then
			entclass = ent:GetClass()
			local entTable = ent:GetTable()
			if (entTable) then
				entprintname = entTable.PrintName or entTable.name
			end
		end

		local x = entTable.PrintName or entTable.name or entprintname or entclass
		bLogs.Log({
			module = "Buys",
			log = bLogs.GetName(ply) .. " bought ammo \"" .. x .. "\" for " .. bLogs.FormatCurrency(for_p),
			involved = {ply},
		})
	end)
	bLogs.AddHook("playerBoughtCustomEntity","Buys",function(ply,entTable,ent,for_p)
		local entclass = "[UNKNOWN]"
		local entprintname
		if (IsValid(ent)) then
			entclass = ent:GetClass()
			local entTable = ent:GetTable()
			if (entTable) then
				entprintname = entTable.PrintName or entTable.name
			end
		end

		local x = entTable.PrintName or entTable.name or entprintname or entclass or "UNKNOWN"
		bLogs.Log({
			module = "Buys",
			log = bLogs.GetName(ply) .. " bought custom entity \"" .. x .. "\" for " .. bLogs.FormatCurrency(for_p),
			involved = {ply},
		})
	end)
	bLogs.AddHook("playerBoughtCustomVehicle","Buys",function(ply,entTable,ent,for_p)
		local entclass = "[UNKNOWN]"
		local entprintname
		if (IsValid(ent)) then
			entclass = ent:GetClass()
			local entTable2 = ent:GetTable()
			if (entTable2) then
				entprintname = entTable.PrintName or entTable.name
			end
		end

		local x = entTable.PrintName or entTable.name or entprintname or entclass or "UNKNOWN"
		bLogs.Log({
			module = "Buys",
			log = bLogs.GetName(ply) .. " bought custom vehicle \"" .. x .. "\" for " .. bLogs.FormatCurrency(for_p),
			involved = {ply},
		})
	end)
	bLogs.AddHook("playerBoughtFood","Buys",function(ply,entTable,ent,for_p)
		local entclass = "[UNKNOWN]"
		local entprintname
		if (IsValid(ent)) then
			entclass = ent:GetClass()
			local entTable = ent:GetTable()
			if (entTable) then
				entprintname = entTable.PrintName or entTable.name
			end
		end

		local x = entTable.PrintName or entTable.name or entprintname or entclass or "UNKNOWN"
		bLogs.Log({
			module = "Buys",
			log = bLogs.GetName(ply) .. " bought food \"" .. x .. "\" for " .. bLogs.FormatCurrency(for_p),
			involved = {ply},
		})
	end)
	bLogs.AddHook("playerBoughtPistol","Buys",function(ply,entTable,ent,for_p)
		local entclass = "[UNKNOWN]"
		local entprintname
		if (IsValid(ent)) then
			entclass = ent:GetClass()
			local entTable = ent:GetTable()
			if (entTable) then
				entprintname = entTable.PrintName or entTable.name
			end
		end

		local x = entTable.PrintName or entTable.name or entprintname or entclass or "UNKNOWN"
		bLogs.Log({
			module = "Buys",
			log = bLogs.GetName(ply) .. " bought weapon \"" .. x .. "\" for " .. bLogs.FormatCurrency(for_p),
			involved = {ply},
		})
	end)
	bLogs.AddHook("playerBoughtShipment","Buys",function(ply,entTable,ent,for_p)
		local entclass = "[UNKNOWN]"
		local entprintname
		if (IsValid(ent)) then
			entclass = ent:GetClass()
			local entTable = ent:GetTable()
			if (entTable) then
				entprintname = entTable.PrintName or entTable.name
			end
		end

		local x = entTable.PrintName or entTable.name or entprintname or entclass or "UNKNOWN"
		bLogs.Log({
			module = "Buys",
			log = bLogs.GetName(ply) .. " bought shipment \"" .. x .. "\" for " .. bLogs.FormatCurrency(for_p),
			involved = {ply},
		})
	end)
	bLogs.AddHook("playerBoughtVehicle","Buys",function(ply,ent,for_p)
		local entclass = "[UNKNOWN]"
		local entprintname
		if (IsValid(ent)) then
			entclass = ent:GetClass()
			local entTable = ent:GetTable()
			if (entTable) then
				entprintname = entTable.PrintName or entTable.name
			end
		end

		local x = entprintname or entclass or "UNKNOWN"
		bLogs.Log({
			module = "Buys",
			log = bLogs.GetName(ply) .. " bought vehicle \"" .. x .. "\" for " .. bLogs.FormatCurrency(for_p),
			involved = {ply},
		})
	end)

	bLogs.AddHook("onHitCompleted","Hits",function(hitman,target,customer)
		bLogs.Log({
			module = "Hits",
			log = bLogs.GetName(hitman) .. " accepted a hit from " .. bLogs.GetName(customer) .. " on " .. bLogs.GetName(target),
			involved = {hitman,target,customer},
		})
	end)
	bLogs.AddHook("onHitAccepted","Hits",function(hitman,target,customer)
		bLogs.Log({
			module = "Hits",
			log = bLogs.GetName(hitman) .. " completed a hit from " .. bLogs.GetName(customer) .. " on " .. bLogs.GetName(target),
			involved = {hitman,target,customer},
		})
	end)
	bLogs.AddHook("onHitFailed","Hits",function(hitman,target,reason)
		bLogs.Log({
			module = "Hits",
			log = bLogs.GetName(hitman) .. " failed a hit set on " .. bLogs.GetName(target) .. "because \"" .. reason .. "\"",
			involved = {hitman,target},
		})
	end)

	bLogs.AddHook("playerBoughtDoor","Doors/Vehicles",function(ply,door,cost)
		local nom = "door"
		if (door:IsVehicle()) then
			nom = "vehicle"
			local doorTbl = door:GetTable()
			if (doorTbl) then
				nom = doorTbl.PrintName or doorTbl.name or "vehicle"
			end
		end

		bLogs.Log({
			module = "Doors/Vehicles",
			log = bLogs.GetName(ply) .. " bought a " .. nom .. " for " .. bLogs.FormatCurrency(cost),
			involved = {ply},
		})
	end)
	bLogs.AddHook("playerKeysSold","Doors/Vehicles",function(ply,door,amount)
		local nom = "door"
		if (door:IsVehicle()) then
			nom = "vehicle"
			local doorTbl = door:GetTable()
			if (doorTbl) then
				nom = doorTbl.PrintName or doorTbl.name or "vehicle"
			end
		end

		bLogs.Log({
			module = "Doors/Vehicles",
			log = bLogs.GetName(ply) .. " sold a " .. nom .. " (with keys) and received " .. bLogs.FormatCurrency(amount),
			involved = {ply},
		})
	end)
	bLogs.AddHook("onAllowedToOwnAdded","Doors/Vehicles",function(ply,door,target)
		local nom = "door"
		if (door:IsVehicle()) then
			nom = "vehicle"
			local doorTbl = door:GetTable()
			if (doorTbl) then
				nom = doorTbl.PrintName or doorTbl.name or "vehicle"
			end
		end

		bLogs.Log({
			module = "Doors/Vehicles",
			log = bLogs.GetName(ply) .. " added " .. bLogs.GetName(target) .. " as an owner to their " .. nom .. " (with keys)",
			involved = {ply},
		})
	end)
	bLogs.AddHook("onAllowedToOwnRemoved","Doors/Vehicles",function(ply,door,target)
		local nom = "door"
		if (door:IsVehicle()) then
			nom = "vehicle"
			local doorTbl = door:GetTable()
			if (doorTbl) then
				nom = doorTbl.PrintName or doorTbl.name or "vehicle"
			end
		end

		bLogs.Log({
			module = "Doors/Vehicles",
			log = bLogs.GetName(ply) .. " removed " .. bLogs.GetName(target) .. " as an owner from their " .. nom .. " (with keys)",
			involved = {ply},
		})
	end)

	bLogs.AddHook("OnPlayerChangedTeam","Job changes",function(ply,before,after)
		before = RPExtraTeams[before] or {}
		after = RPExtraTeams[after] or {}

		bLogs.Log({
			module = "Job changes",
			log = bLogs.GetName(ply) .. " changed job from " .. (before.name or "none") or "[UNKNOWN]" .. " to " .. (after.name or "none") or "UNKNOWN",
			involved = {ply},
		})
	end)

	bLogs.AddHook("playerArrested","Arrests",function(ply,time,cop)
		local involvedtbl = {ply}
		if (IsValid(cop)) then
			table.insert(involvedtbl,cop)
		end
		bLogs.Log({
			module = "Arrests",
			log = bLogs.GetName(ply) .. " was arrested by " .. bLogs.GetName(cop) .. " for " .. time,
			involved = involvedtbl
		})
	end)
	bLogs.AddHook("playerUnArrested","Arrests",function(ply,cop)
		local involvedtbl = {ply}
		if (IsValid(cop)) then
			table.insert(involvedtbl,cop)
		end
		bLogs.Log({
			module = "Unarrests",
			log = bLogs.GetName(ply) .. " was unarrested by " .. bLogs.GetName(cop),
			involved = involvedtbl
		})
	end)

	bLogs.AddHook("onDoorRamUsed","Battering ram",function(success,cop,tr)
		if (success ~= false) then
			if (IsValid(tr.Entity)) then
				if (tr.Entity:isDoor() or tr.Entity:IsVehicle()) then
					local str = "door"
					if (tr.Entity:IsVehicle()) then
						str = "vehicle"
					end
					local owner = tr.Entity:getDoorOwner()
					if (IsValid(owner)) then
						bLogs.Log({
							module = "Battering ram",
							log = bLogs.GetName(cop) .. " battering rammed a " .. str .. " owned by " .. bLogs.GetName(owner),
							involved = {cop,owner}
						})
					else
						bLogs.Log({
							module = "Battering ram",
							log = bLogs.GetName(cop) .. " battering rammed an unowned " .. str,
							involved = {cop}
						})
					end
				else
					-- what even is this
					bLogs.Log({
						module = "Battering ram",
						log = bLogs.GetName(cop) .. " battering rammed a \"" .. tr.Entity:GetClass() .. "\"",
						involved = {cop}
					})
				end
			end
		end
	end)

	bLogs.AddHook("playerUnWanted","Wanted",function(ply,cop)
		if (IsValid(cop)) then
			bLogs.Log({
				module = "Wanted",
				log = bLogs.GetName(ply) .. " had their wanted status removed by " .. bLogs.GetName(cop),
				involved = {ply,cop},
			})
		else
			bLogs.Log({
				module = "Wanted",
				log = bLogs.GetName(ply) .. " had their wanted status removed",
				involved = {ply},
			})
		end
	end)

	bLogs.AddHook("playerWanted","Wanted",function(ply,cop,reason)
		bLogs.Log({
			module = "Wanted",
			log = bLogs.GetName(ply) .. " were given wanted status by " .. bLogs.GetName(cop) .. " for \"" .. reason .. "\"",
			involved = {ply,cop},
		})
	end)

	bLogs.AddHook("onPocketItemAdded","Pocket",function(ply,ent)
		if (!IsValid(ply)) then return end
		if (!IsValid(ent)) then return end
		if (type(ply) ~= "Player") then return end

		bLogs.Log({
			module = "Pocket",
			involved = {ply},
			log = bLogs.GetName(ply) .. " pocketed " .. bLogs.GetPrintName(ent) .. " (" .. ent:GetClass() .. ", " .. ent:GetModel() .. ")",
		})
	end)

	bLogs.AddHook("lockpickStarted","Lockpicks",function(ply,ent,tr)
		if (!IsValid(ply)) then return end
		if (!IsValid(ent)) then return end

		bLogs.Log({
			module = "Lockpicks",
			involved = {ply},
			log = bLogs.GetName(ply) .. " started lockpicking " .. ent:GetClass(),
		})
	end)

	bLogs.AddHook("onLockpickCompleted","Lockpicks",function(ply,success,ent)
		if (!IsValid(ply)) then return end
		
		if (success == false) then
			if (IsValid(ent)) then
				bLogs.Log({
					module = "Lockpicks",
					involved = {ply},
					log = bLogs.GetName(ply) .. " stopped lockpicking " .. ent:GetClass(),
				})
			else
				bLogs.Log({
					module = "Lockpicks",
					involved = {ply},
					log = bLogs.GetName(ply) .. " stopped lockpicking",
				})
			end
		else
			if (IsValid(ent)) then
				bLogs.Log({
					module = "Lockpicks",
					involved = {ply},
					log = bLogs.GetName(ply) .. " successfully lockpicked " .. ent:GetClass(),
				})
			else
				bLogs.Log({
					module = "Lockpicks",
					involved = {ply},
					log = bLogs.GetName(ply) .. " successfully lockpicked",
				})
			end
		end
	end)

	bLogs.AddHook("onPlayerChangedName","Name Change",function(ply,old,new)
		if (!IsValid(ply)) then return end
		
		bLogs.Log({
			module = "Name Change",
			involved = {ply},
			log = bLogs.GetName(ply) .. " changed their RP Name from \"" .. old .. "\" to \"" .. new .. "\"",
		})
	end)

	bLogs.AddHook("onPlayerDemoted","Demotes",function(demoter,demotee,reason)
		if (!IsValid(demotee)) then return end

		if (IsValid(demoter)) then
			if (#(reason or "") ~= 0) then
				bLogs.Log({
					module = "Demotes",
					involved = {demotee,demoter},
					log = bLogs.GetName(demotee) .. " was demoted for \"" .. reason .. "\" by " .. bLogs.GetName(demoter),
				})
			else
				bLogs.Log({
					module = "Demotes",
					involved = {demotee,demoter},
					log = bLogs.GetName(demotee) .. " was demoted by " .. bLogs.GetName(demoter),
				})
			end
		else
			if (#(reason or "") ~= 0) then
				bLogs.Log({
					module = "Demotes",
					involved = {demotee},
					log = bLogs.GetName(demotee) .. " was demoted for \"" .. reason .. "\"",
				})
			else
				bLogs.Log({
					module = "Demotes",
					involved = {demotee},
					log = bLogs.GetName(demotee) .. " was demoted.",
				})
			end
		end
	end)

	bLogs.AddHook("playerAFKDemoted","Demotes",function(ply)
		if (!IsValid(ply)) then return end
		
		bLogs.Log({
			module = "Demotes",
			involved = {ply},
			log = bLogs.GetName(ply) .. " was demoted for being AFK for too long.",
		})
	end)

	bLogs.AddHook("playerWarranted","Warrants",function(criminal,cop,reason)
		if (!IsValid(criminal)) then return end
		
		if (IsValid(cop)) then
			if (#(reason or "") ~= 0) then
				bLogs.Log({
					module = "Warrants",
					involved = {criminal,cop},
					log = bLogs.GetName(criminal) .. " received a warrant requested by " .. bLogs.GetName(cop) .. " for the reason \"" .. reason .. "\"",
				})
			else
				bLogs.Log({
					module = "Warrants",
					involved = {criminal,cop},
					log = bLogs.GetName(criminal) .. " received a warrant requested by " .. bLogs.GetName(cop) .. ".",
				})
			end
		else
			if (#(reason or "") ~= 0) then
				bLogs.Log({
					module = "Warrants",
					involved = {criminal},
					log = bLogs.GetName(criminal) .. " received a warrant for the reason \"" .. reason .. "\"",
				})
			else
				bLogs.Log({
					module = "Warrants",
					involved = {criminal},
					log = bLogs.GetName(criminal) .. " received a warrant.",
				})
			end
		end
	end)

	if (DarkRP.disabledDefaults["modules"]["hungermod"] == false) then
		bLogs.EnableLogger("Starvation")
		bLogs.AddHook("playerStarved","Starvation",function(ply)
			bLogs.Log({
				module = "Starvation",
				log = bLogs.GetName(ply) .. " died of starvation.",
				involved = {ply},
			})
		end)
	end

else

	bLogs.AddHook("PlayerSay","Chat",chathook)

end