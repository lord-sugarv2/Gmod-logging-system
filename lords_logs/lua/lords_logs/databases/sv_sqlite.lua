LLogs.Databases["sqlite"] = LLogs.Databases["sqlite"] or {}
LLogs.Databases["sqlite"].InitializeDatabase = function(callback)
    sql.Query("CREATE TABLE IF NOT EXISTS LLogs (ModuleName, Date TEXT, Timestamp INTEGER, Message TEXT, ExtraInfo TEXT, Size INTEGER)")
    callback = callback or function() end
    callback()
end

LLogs.Databases["sqlite"].ResetDatabase = function(callback)
    sql.Query("DROP TABLE LLogs")
    callback = callback or function() end
    callback()
end

LLogs.Databases["sqlite"].Log = function(ModuleName, date, timestamp, message, ExtraInfo, callback)
    local date, message, ExtraInfo, ModuleName = sql.SQLStr(date), sql.SQLStr(message), util.TableToJSON(ExtraInfo), sql.SQLStr(ModuleName)
    local size = string.len(date) + string.len(tostring(timestamp)) + string.len(message) + string.len(ExtraInfo) + string.len(ModuleName)
    sql.Query("INSERT INTO LLogs (ModuleName, Date, Timestamp, Message, ExtraInfo, Size) VALUES("..ModuleName..", "..date..", "..timestamp..", "..message..", "..sql.SQLStr(ExtraInfo)..", "..size..")")
    callback = callback or function() end
    callback()
end

LLogs.Databases["sqlite"].SearchModules = function(ModuleName, callback)
    local data = {}
    if ModuleName == "All" then
        data = sql.Query("SELECT * FROM LLogs;")
    else
        data = sql.Query("SELECT * FROM LLogs WHERE ModuleName = "..sql.SQLStr(ModuleName)..";")
    end

    data = data and data or {}
    data = table.Reverse(data) -- flip the table so the recent values are at top

    callback = callback or function(data) end
    callback(data, ModuleName)
end

LLogs.Databases["sqlite"].RequestLog = function(date, timestamp, message, callback)
    local data = sql.Query("SELECT * FROM LLogs WHERE Date = "..sql.SQLStr(date).." AND Timestamp = "..sql.SQLStr(timestamp).." AND Message = "..sql.SQLStr(message)..";")
    data = data and data[1] or {}
    callback = callback or function(data) end
    callback(data)
end

LLogs.Databases["sqlite"].WipeLogs = function(callback)
    sql.Query("DROP TABLE LLogs")
    LLogs.CreateDatabase()
    callback()
end