LLogs.Databases = LLogs.Databases or {}
LLogs.ServerConfig = LLogs.ServerConfig or {}
function LLogs.SetServerConfig(id, name, description, value, inputType)
    LLogs.ServerConfig[id] = {name, description, value, inputType}
end

function LLogs.GetServerValue(id)
    return LLogs.ServerConfig[id][3]
end