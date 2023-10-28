--[[
    To add a module just copy this file and paste it in the same area
    Then copy and paste this for each logging type

    local MODULE = {}
    MODULE.Category = "DarkRP" -- Name of the category we want to add it to
    MODULE.Name = "Adverts" -- Name of the module (this does not have to be unique)
    MODULE.Color = Color(255, 100, 100) -- Color of module text in the "all" view
    
    -- Now create your hook
    hook.Add("playerAdverted", "LLogs:"..MODULE.Name, function(ply, text, ent)
        if not IsValid(ply) then return end
        local str = "%s (%s) adverted: %s" -- all the %s will be formatted from the line below
        str = string.format(str, ply:Nick(), ply:SteamID(), text) -- replace the %s with the info
        LLogs.Log(MODULE.Name, str, LLogs.FormatPlayer(ply)) -- (modulename, log line, EXTRA INFO)
    end)
    LLogs.AddModule(MODULE) -- create the module

    -- More use of the log line can be seen below
    local str = "%s (%s) + %s (%s) stole %s" -- all the %s will be formatted from the line below
    str = string.format(str, playerOne:Nick(), playerOne:SteamID(), playerTwo:Nick(), playerTwo:SteamID(), printer:GetClass()) -- replace the %s with the info
    LLogs.Log(MODULE.Name, "These players stole the entity!", LLogs.FormatPlayer(playerOne), LLogs.FormatPlayer(playerTwo), LLogs.FormatEnt(printer))
]]--