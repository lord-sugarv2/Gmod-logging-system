bLogs.CreateCategory("TTT",Color(255,0,0))

bLogs.DefineLogger("Karma Kicks","TTT",false)
bLogs.DefineLogger("Equipment","TTT",false)
bLogs.DefineLogger("Body Found","TTT",false)
bLogs.DefineLogger("DNA Found","TTT",false)

if (ROLE_TRAITOR ~= nil) then

	bLogs.EnableLogger("Karma Kicks")
	bLogs.EnableLogger("Equipment")
	bLogs.EnableLogger("Body Found")
	bLogs.EnableLogger("DNA Found")

	bLogs.AddHook("TTTKarmaLow","Karma Kicks",function(ply)
		bLogs.Log({
			module = "Karma Kicks",
			log = bLogs.GetName(ply) .. " was kicked for having low karma.",
			involved = {ply},
		})
	end)

	bLogs.AddHook("TTTOrderedEquipment","Equipment",function(ply,equipment)
		if (tonumber(equipment)) then
			for _,class in pairs(EquipmentItems) do
				for _,v in pairs(class) do
					if (v.id == equipment) then
						equipment = v.name
						break
					end
				end
			end
		end

		bLogs.Log({
			module = "Equipment",
			log = bLogs.GetName(ply) .. " ordered equipment \"" .. equipment .. "\"",
			involved = {ply},
		})
	end)

	bLogs.AddHook("TTTFoundDNA","DNA Found",function(ply,dna_owner)
		bLogs.Log({
			module = "DNA Found",
			log = bLogs.GetName(dna_owner) .. "'s DNA was found by " .. bLogs.GetName(ply),
			involved = {ply,dna_owner},
		})
	end)

	bLogs.AddHook("TTTBodyFound","Body Found",function(ply,deadply)
		bLogs.Log({
			module = "Body Found",
			log = bLogs.GetName(deadply) .. "'s body was found by " .. bLogs.GetName(ply),
			involved = {ply,deadply},
		})
	end)

end