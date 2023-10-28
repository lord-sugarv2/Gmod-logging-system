function LLogs.FormatTime(str, timestamp)
    return LLogs.GetServerValue("UTCTime") and os.date("!"..str, timestamp) or os.date(str, timestamp)
end

LLogs.Modules = LLogs.Modules or {}
function LLogs.AddModule(MODULE)
    LLogs.Modules[MODULE.Name] = MODULE
end

function LLogs.CanAccess(ply)
    return table.HasValue(LLogs.Access, ply:GetUserGroup())
end

function LLogs.GetName(ply)
    if not IsValid(ply) then return "N/A" end

    return ply:Nick() .. " ("..ply:SteamID()..")"
end

function LLogs.FormatPlayer(ply, title)
    title = title or ""
    if not ply or not IsValid(ply) then
        return {
            Title = title,
            Name = "N/A",
            SteamID = "N/A",
            SteamID64 = "N/A",
            EventPos = "N/A",
            Ent = ply,
            Type = "Player",
        }
    end

    local data = {
        Title = title,
        Name = ply:Nick(),
        SteamID = ply:SteamID(),
        SteamID64 = ply:SteamID64(),
        EventPos = ply:GetPos(),
        Ent = ply,
        Type = "Player",
    }
    return data
end

function LLogs.FormatEnt(ent, title)
    title = title or ""
    if not ent or not IsValid(ent) then 
        return {
            Title = title,
            Name = "N/A",
            Class = "N/A",
            EventPos = "N/A",
            Ent = nil,
            Type = "Entity",
            Model = "ERROR",
        }
    end

    local data = {
        Title = title,
        Name = ent.PrintName,
        Class = ent:GetClass(),
        EventPos = ent:GetPos(),
        Ent = ent,
        Type = "Entity",
        Model = ent:GetModel()
    }
    return data
end