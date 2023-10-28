bLogs.CreateCategory("Extras",Color(0,100,0))
bLogs.CreateCategory("Admin Mods",Color(255,0,0))

bLogs.DefineLogger("Maestro","Admin Mods",false)
bLogs.DefineLogger("LAC","Extras",false)
bLogs.DefineLogger("ULX","Admin Mods",false)
bLogs.DefineLogger("ServerGuard","Admin Mods",false)
bLogs.DefineLogger("ServerGuard (Silent)","Admin Mods",false)
bLogs.DefineLogger("FAdmin","Admin Mods",false)
bLogs.DefineLogger("AWarn","Extras",false)
bLogs.DefineLogger("Hitman Module","Extras",false)
bLogs.DefineLogger("HHH","Extras",false)
bLogs.DefineLogger("Cuffs","Extras",false)
bLogs.DefineLogger("NLR Zones","Extras",false)
bLogs.DefineLogger("WCK","Extras",false)

if (wck) then
	bLogs.EnableLogger("WCK")

	bLogs.AddHook("WCKVideoQueued","WCK",function(queuetable)
		bLogs.Log({
			module = "WCK",
			log = bLogs.GetName(queuetable.player) .. " requested video \"" .. queuetable.video_title .. "\" (" .. queuetable.video_url .. ") at cinema \"" .. queuetable.cinema .. "\"",
			involved = {queuetable.ply}
		})
	end)
end
if (maestro) then
	bLogs.EnableLogger("Maestro")

	bLogs.AddHook("maestro_command","Maestro",function(ply,cmd,args)
		bLogs.Log({
			module = "Maestro",
			log = bLogs.GetName(ply) .. " ran Maestro command \"" .. cmd .. "\" with arguments \"" .. table.concat(args,", ") .. "\"",
			involved = {ply}
		})
	end)
end
if (ulx and ULib) then
	bLogs.EnableLogger("ULX")

	local blacklist = {
		["ulx noclip"] = "",
	}

	bLogs.AddHook(ULib.HOOK_COMMAND_CALLED,"ULX",function(ply,cmd,args)
		if (blacklist[cmd] == "*") then return end
		if (blacklist[cmd] == table.concat(args or {}," ")) then return end
		bLogs.Log({
			module = "ULX",
			log = bLogs.GetName(ply) .. " ran ULX command \"" .. string.gsub(cmd .. " " .. table.concat(args," ")," $","") .. "\"",
			involved = {ply}
		})
	end)
end
if (serverguard) then
	bLogs.EnableLogger("ServerGuard")
	bLogs.EnableLogger("ServerGuard (Silent)")

	bLogs.AddHook(serverguard.RanCommand or "serverguard.RanCommand","ServerGuard",function(ply,cmdtable,silent,args)
		if (silent == true) then
			bLogs.Log({
				module = "ServerGuard (Silent)",
				log = bLogs.GetName(ply) .. " ran silent ServerGuard command \"" .. string.gsub(cmdtable.command .. " " .. table.concat(args," ")," $","") .. "\"",
				involved = {ply},
			})
		else
			bLogs.Log({
				module = "ServerGuard (Silent)",
				log = bLogs.GetName(ply) .. " ran ServerGuard command \"" .. string.gsub(cmdtable.command .. " " .. table.concat(args," ")," $","") .. "\"",
				involved = {ply},
			})
		end
	end)
end
if (FAdmin) then if (FAdmin.Messages) then
	bLogs.EnableLogger("FAdmin")

	--[[

		So, I had a look at the hook for FAdmin command uses.
		It would return values such as the arguments, player who called it, etc.
		However: I discovered that many of the commands literally just return arguments like "1.00", "5.00" etc.
		So, to fix this, I decided to override the current ConsoleNotify thing (what you see in your console), find SteamIDs and add to the involved list.
		owch that was hacky!!!

	--]]

	local original = FAdmin.Messages.ConsoleNotify
	function FAdmin.Messages.ConsoleNotify(ply,message)
		local involved_ = {}
		local message_ = message

		for v,_ in string.gmatch(message,"STEAM_%d:%d:%d+") do
			table.insert(involved_,util.SteamIDTo64(v))
			string.gsub(message_,v,bLogs.GetName(v))
		end

		bLogs.Log({
			module = "FAdmin",
			log = message_,
			involved = involved_,
		})

		return original(ply,message)
	end
end end

if (AWarn) then
	bLogs.EnableLogger("AWarn")

	bLogs.AddHook("AWarnPlayerWarned","AWarn",function(ply,admin,reason)
		bLogs.Log({
			module = "AWarn",
			log = bLogs.GetName(ply) .. " was warned by " .. bLogs.GetName(admin) .. " with reason \"" .. reason or "(none)" .. "\"",
			involved = {ply,admin}
		})
	end)

	bLogs.AddHook("AWarnPlayerIDWarned","AWarn",function(steamid,admin,reason)
		local ply = bLogs.GetName(steamid)

		if (ply ~= nil and ply ~= "UNKNOWN") then
			bLogs.Log({
				module = "AWarn",
				log = ply .. " was warned by " .. bLogs.GetName(admin) .. " with reason \"" .. reason or "(none)" .. "\"",
				involved = {steamid,admin}
			})
		else
			bLogs.Log({
				module = "AWarn",
				log = steamid .. " (unknown player) was warned by " .. bLogs.GetName(admin) .. " with reason \"" .. reason or "(none)" .. "\"",
				involved = {steamid,admin}
			})
		end
	end)

	bLogs.AddHook("AWarnLimitKick","AWarn",function(ply)
		bLogs.Log({
			module = "AWarn",
			log = bLogs.GetName(ply) .. " was kicked for having too many active warnings.",
			involved = {ply}
		})
	end)

	bLogs.AddHook("AWarnLimitBan","AWarn",function(ply)
		bLogs.Log({
			module = "AWarn",
			log = bLogs.GetName(ply) .. " was banned for having too many active warnings.",
			involved = {ply}
		})
	end)
end

if (HitModule) then
	bLogs.EnableLogger("Hitman Module")

	bLogs.AddHook("HMHitmanKilled","Hitman Module",function(victim,target,reward)
		bLogs.Log({
			module = "Hitman Module",
			log = bLogs.GetName(target) .. " was killed while trying to complete a hit on " .. bLogs.GetName(victim) .. " for " .. bLogs.FormatCurrency(reward),
			involved = {victim,target},
		})
	end)

	bLogs.AddHook("HMHitComplete","Hitman Module",function(victim,target,reward)
		bLogs.Log({
			module = "Hitman Module",
			log = bLogs.GetName(victim) .. " successfully completed a hit on " .. bLogs.GetName(target) .. " for $" .. bLogs.FormatCurrency(reward),
			involved = {victim,target},
		})
	end)

	bLogs.AddHook("HMHitAccepted","Hitman Module",function(hitman,target,reward)
		bLogs.Log({
			module = "Hitman Module",
			log = bLogs.GetName(hitman) .. " accepted a hit on " .. bLogs.GetName(target) .. " for a reward of " .. bLogs.FormatCurrency(reward),
			involved = {hitman,target},
		})
	end)
end

if (hhh) then
	
	bLogs.EnableLogger("HHH")

	bLogs.AddHook("hhh_hitRequested","HHH",function(hitinfo)
		if (hitinfo == nil) then return end
		bLogs.Log({
			module = "HHH",
			log = bLogs.GetName(hitinfo.requester) .. " requested a hit on " .. bLogs.GetName(hitinfo.target) .. " for a reward of " .. bLogs.FormatCurrency(hitinfo.reward),
			involved = {hitinfo.requester,hitinfo.target},
		})
	end)

	bLogs.AddHook("hhh_hitAborted","HHH",function(hitinfo)
		if (hitinfo == nil) then return end
		bLogs.Log({
			module = "HHH",
			log = bLogs.GetName(hitinfo.requester) .. "'s hit on " .. bLogs.GetName(hitinfo.target) .. " for a reward of " .. bLogs.FormatCurrency(hitinfo.reward) .. " was aborted",
			involved = {hitinfo.requester,hitinfo.target},
		})
	end)

	bLogs.AddHook("hhh_hitFinished","HHH",function(hitman,target)
		if (hitman == target) then return end
		bLogs.Log({
			module = "HHH",
			log = bLogs.GetName(hitman) .. " successfully completed a hit on " .. bLogs.GetName(target),
			involved = {hitman,target},
		})
	end)

end

if (nlr) then
	
	bLogs.EnableLogger("NLR Zones")

	bLogs.AddHook("PlayerEnteredNlrZone","NLR Zones",function(ply)
		bLogs.Log({
			module = "NLR Zones",
			log = bLogs.GetName(ply) .. " entered an NLR zone.",
			involved = {ply},
		})
	end)

	bLogs.AddHook("PlayerExitedNlrZone","NLR Zones",function(ply)
		bLogs.Log({
			module = "NLR Zones",
			log = bLogs.GetName(ply) .. " exited an NLR zone.",
			involved = {ply},
		})
	end)

	bLogs.AddHook("PlayerBreakNLR","NLR Zones",function(ply)
		bLogs.Log({
			module = "NLR Zones",
			log = bLogs.GetName(ply) .. " broke NLR!",
			involved = {ply},
		})
	end)
end

if (ConVarExists("cuffs_allowbreakout")) then

	bLogs.EnableLogger("Cuffs")	

	bLogs.AddHook("OnHandcuffed","Cuffs",function(cuffer,cuffed)
		bLogs.Log({
			module = "Cuffs",
			log = bLogs.GetName(cuffer) .. " cuffed " .. bLogs.GetName(cuffed),
			involved = {cuffer,cuffed},
		})
	end)

	bLogs.AddHook("OnHandcuffBreak","Cuffs",function(CuffedPlayer,_,mate)
		if (IsValid(mate)) then
			bLogs.Log({
				module = "Cuffs",
				log = bLogs.GetName(mate) .. " broke " .. bLogs.GetName(CuffedPlayer) .. " out of handcuffs",
				involved = {CuffedPlayer,mate},
			})
		else
			bLogs.Log({
				module = "Cuffs",
				log = bLogs.GetName(CuffedPlayer) .. " broke free from their handcuffs",
				involved = {CuffedPlayer},
			})
		end
	end)
end

if (LAC) then
	bLogs.EnableLogger("LAC")

	bLogs.AddHook(LAC.OnDetect or "LAC.OnDetect","LAC",function(ply,_,detection)
		bLogs.Log({
			module = "LAC",
			log = bLogs.GetName(ply) .. " was detected for \"" .. detection .. "\"!",
			involved = {ply},
		})
	end)
end