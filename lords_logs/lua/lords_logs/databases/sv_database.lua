function LLogs.GetDatabase()
    return LLogs.Databases[LLogs.GetServerValue("Database")]
end

function LLogs.CreateDatabase(callback)
    callback = callback or function() end
    LLogs.GetDatabase().InitializeDatabase(function()
        callback()
    end)
end
LLogs.CreateDatabase()

util.AddNetworkString("LLog:AddLiveLog")
LLogs.LiveLogsUsers = LLogs.LiveLogsUsers or {}
function LLogs.DatabaseLog(ModuleName, date, timestamp, message, ExtraInfo, callback)
    callback = callback or function() end
    LLogs.GetDatabase().Log(ModuleName, date, timestamp, message, ExtraInfo, function()
        for ply, bool in pairs(LLogs.LiveLogsUsers) do
            if not IsValid(ply) or not bool then continue end
            if not LLogs.CanAccess(ply) then LLogs:EndLiveLogs(ply) continue end
            net.Start("LLog:AddLiveLog")
            net.WriteString(date)
            net.WriteString(message)
            net.WriteUInt(timestamp, 32)
            net.WriteString(ModuleName)
            net.Send(ply)
        end

        callback()
    end)
end

function LLogs.ResetDatabase(callback)
    callback = callback or function() end
    LLogs.GetDatabase().ResetDatabase(function()
        callback()
    end)
end

function LLogs.SearchDatabase(moduleName, callback)
    LLogs.GetDatabase().SearchModules(moduleName, function(results)
        callback(results, moduleName)
    end)
end

function LLogs.GetLogInfo(date, timestamp, message, callback)
    LLogs.GetDatabase().RequestLog(date, timestamp, message, function(data)
        callback(data)
    end)
end

function LLogs.WipeLogs(callback)
    callback = callback or function() end
    LLogs.GetDatabase().WipeLogs(function()
        callback()
    end)
end