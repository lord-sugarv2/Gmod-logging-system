bLogs.CreateCategory("Sandbox",Color(255,0,100))

bLogs.DefineLogger("Toolgun","Sandbox",false)
bLogs.DefineLogger("Q Menu","Sandbox",false)

local GM_ = GM or GAMEMODE
if (GM_.IsSandboxDerived) then

	bLogs.EnableLogger("Toolgun")
	bLogs.EnableLogger("Q Menu")

	bLogs.AddHook("CanTool","Toolgun",function(ply,tr,tool)
		tr = tr or {}
		if (IsValid(tr.Entity)) then
			if (tr.Entity:IsWorld()) then
				bLogs.Log({
					module = "Toolgun",
					log = bLogs.GetName(ply) .. " attempted to use tool \"" .. tool .. "\" on the world",
					involved = {ply},
				})
			else
				bLogs.Log({
					module = "Toolgun",
					log = bLogs.GetName(ply) .. " attempted to use tool \"" .. tool .. "\" on entity \"" .. tr.Entity:GetClass() .. "\" (" .. tr.Entity:GetModel() .. ")",
					involved = {ply},
				})
			end
		else
			bLogs.Log({
				module = "Toolgun",
				log = bLogs.GetName(ply) .. " attempted to use tool \"" .. tool .. "\"",
				involved = {ply},
			})
		end
	end)

	bLogs.AddHook("PlayerSpawnedVehicle","Q Menu",function(ply,ent)
		local tbl = ent:GetTable()
		local name = ent:GetClass() or "[UNKNOWN]"
		if (tbl) then
			name = tbl.PrintName or tbl.name or name
		end

		bLogs.Log({
			module = "Q Menu",
			log = bLogs.GetName(ply) .. " spawned vehicle \"" .. name .. "\"",
			involved = {ply},
		})
	end)
	bLogs.AddHook("PlayerSpawnedSWEP","Q Menu",function(ply,ent)
		local tbl = ent:GetTable()
		local name = ent:GetClass() or "[UNKNOWN]"
		if (tbl) then
			name = tbl.PrintName or tbl.name or name
		end

		bLogs.Log({
			module = "Q Menu",
			log = bLogs.GetName(ply) .. " spawned SWEP \"" .. name .. "\"",
			involved = {ply},
		})
	end)
	bLogs.AddHook("PlayerSpawnedNPC","Q Menu",function(ply,ent)
		local tbl = ent:GetTable()
		local name = ent:GetClass() or "[UNKNOWN]"
		if (tbl) then
			name = tbl.PrintName or tbl.name or name
		end

		bLogs.Log({
			module = "Q Menu",
			log = bLogs.GetName(ply) .. " spawned NPC \"" .. name .. "\"",
			involved = {ply},
		})
	end)
	bLogs.AddHook("PlayerSpawnedRagdoll","Q Menu",function(ply,model)
		bLogs.Log({
			module = "Q Menu",
			log = bLogs.GetName(ply) .. " spawned ragdoll \"" .. model .. "\"",
			involved = {ply},
		})
	end)
	bLogs.AddHook("PlayerSpawnedProp","Q Menu",function(ply,model)
		bLogs.Log({
			module = "Q Menu",
			log = bLogs.GetName(ply) .. " spawned prop \"" .. model .. "\"",
			involved = {ply},
		})
	end)
	bLogs.AddHook("PlayerSpawnedEffect","Q Menu",function(ply,model)
		bLogs.Log({
			module = "Q Menu",
			log = bLogs.GetName(ply) .. " spawned effect \"" .. model .. "\"",
			involved = {ply},
		})
	end)
end