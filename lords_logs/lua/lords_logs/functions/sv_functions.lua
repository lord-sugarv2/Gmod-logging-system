function LLogs.Log(ModuleName, str, ...)
    local Timestamp = os.time()
    local Date = LLogs.FormatTime("%d/%m/%Y", Timestamp)
    LLogs.DatabaseLog(ModuleName, Date, Timestamp, str, {...}, function() end)

    if LLogs.GetServerValue("ConsolePrint") then
        local TimeString = LLogs.FormatTime("%d/%m/%Y - %H:%M:%S", Timestamp)
        print(TimeString..":", str)
    end
end

function LLogs.NetworkLogs(ply, moduleName, results, pageIndex, callback)
    local resultsPerPage = LLogs.GetServerValue("ResultsPerPage")
    local pagesAmount = math.ceil(#results / LLogs.GetServerValue("ResultsPerPage"))
    local currentIndex = math.min(pageIndex, pagesAmount)

    local resultsOnPage = {}
    for i = ((currentIndex-1)*resultsPerPage), ((currentIndex)*resultsPerPage)-1 do
        i = i + 1
        if results[i] then
            table.Add(resultsOnPage, {results[i]})
        end
    end

    ply.LLogsData = {moduleName = moduleName, page = currentIndex}
    net.Start("LLogs:SendsLogs")
    net.WriteInt(CurTime() - LLogs.ServerLatency[ply], 32)
    net.WriteString(moduleName)
    net.WriteUInt(pagesAmount, 32)
    net.WriteUInt(currentIndex, 32)
    net.WriteUInt(#resultsOnPage, 6)
    for k, v in ipairs(resultsOnPage) do
        net.WriteString(v.Date)
        net.WriteString(v.Message)
        net.WriteUInt(v.Timestamp, 32)
        net.WriteString(v.ModuleName)
    end
    net.Send(ply)

    callback = callback or function() end
    callback(ply)
end

util.AddNetworkString("LLogs:Notify")
function LLogs:Notify(ply, intType, seconds, message)
    net.Start("LLogs:Notify")
    net.WriteUInt(intType, 3)
    net.WriteUInt(seconds, 8)
    net.WriteString(message)
    net.Send(ply)
end

LLogs.ServerLatency = LLogs.ServerLatency or {}

util.AddNetworkString("LLogs:SendsLogs")
util.AddNetworkString("LLogs:RequestModuleData")
net.Receive("LLogs:RequestModuleData", function(len, ply)
    if not LLogs.CanAccess(ply) then LLogs:Notify(ply, 1, 3, "You do not have access to this.") return end
    if ply.LLogsPreventUse then LLogs:Notify(ply, 1, 3, "Wait: Still proccessing your other action.") return end
    ply.LLogsPreventUse = true
    LLogs.ServerLatency[ply] = CurTime()

    local moduleName, index = net.ReadString(), net.ReadUInt(32)
    LLogs.SearchDatabase(moduleName, function(results, moduleName)
        LLogs.NetworkLogs(ply, moduleName, results, index, function(ply)
            ply.LLogsPreventUse = false
        end)
    end)
end)

util.AddNetworkString("LLogs:RequestWithFilter")
net.Receive("LLogs:RequestWithFilter", function(len, ply)
    if not LLogs.CanAccess(ply) then LLogs:Notify(ply, 1, 3, "You do not have access to this.") return end
    if ply.LLogsPreventUse then LLogs:Notify(ply, 1, 3, "Wait: Still proccessing your other action.") return end
    ply.LLogsPreventUse = true

    LLogs.ServerLatency[ply] = CurTime()

    local moduleName, filter = net.ReadString(), net.ReadString()
    filter = string.lower(filter)
    LLogs.SearchDatabase(moduleName, function(results, moduleName)
        local data = {}
        for k, v in ipairs(results) do
            if not string.find(string.lower(v.Message), filter) then continue end
            table.Add(data, {v})
        end

        LLogs.NetworkLogs(ply, moduleName, data, 1, function(ply)
            ply.LLogsPreventUse = false
        end)
    end)
end)

util.AddNetworkString("LLogs:Open")
hook.Add("PlayerSay", "LLogs:ChatCommand", function(ply, text)
    if string.lower(text) ~= LLogs.GetServerValue("ChatCommand") and string.lower(text) ~= "/logs" then return end
    if not LLogs.CanAccess(ply) then LLogs:Notify(ply, 1, 3, "You do not have access to this.") return end
    net.Start("LLogs:Open")
    net.Send(ply)
end)

util.AddNetworkString("LLogs:ChangePage")
net.Receive("LLogs:ChangePage", function(len, ply)
    if not LLogs.CanAccess(ply) then LLogs:Notify(ply, 1, 3, "You do not have access to this.") return end
    if ply.LLogsPreventUse then LLogs:Notify(ply, 1, 3, "Wait: Still proccessing your other action.") return end
    ply.LLogsPreventUse = true

    LLogs.ServerLatency[ply] = CurTime()

    local index = net.ReadUInt(32)
    local moduleName = ply.LLogsData and ply.LLogsData.moduleName or ""
    LLogs.SearchDatabase(moduleName, function(results, moduleName)
        LLogs.NetworkLogs(ply, moduleName, results, index, function(ply)
            ply.LLogsPreventUse = false
        end)
    end)
end)

util.AddNetworkString("LLogs:NetworkConfig")
function LLogs:NetworkConfig(ply)
    net.Start("LLogs:NetworkConfig")
    net.WriteTable(util.JSONToTable(file.Read("llogs_config.json", "DATA")))
    net.Send(ply)
end

util.AddNetworkString("LLogs:RequestConfig")
net.Receive("LLogs:RequestConfig", function(len, ply)
    if ply.LLogsReceived then return end
    ply.LLogsReceived = true
    LLogs:NetworkConfig(ply)
end)

local STRING_VALUE = 1
local BOOL_VALUE = 2
local NUMBER_VALUE = 3

util.AddNetworkString("LLogs:SubmitSetting")
net.Receive("LLogs:SubmitSetting", function(len, ply)
    if not table.HasValue(LLogs.Manager, ply:GetUserGroup()) then LLogs:Notify(ply, 1, 3, "You do not have access to this.") return end

    local id, intType = net.ReadString(), net.ReadUInt(3)
    if intType == STRING_VALUE then
        local text = net.ReadString()
        local fileData = util.JSONToTable(file.Read("llogs_config.json", "DATA"))
        fileData[id] = text
        file.Write("llogs_config.json", util.TableToJSON(fileData))
        LLogs.ServerConfig[id][3] = text
    elseif intType == BOOL_VALUE then
        local bool = net.ReadBool()
        local fileData = util.JSONToTable(file.Read("llogs_config.json", "DATA"))
        fileData[id] = bool
        file.Write("llogs_config.json", util.TableToJSON(fileData))
        LLogs.ServerConfig[id][3] = bool
    elseif intType == NUMBER_VALUE then
        local int = net.ReadUInt(32)
        local fileData = util.JSONToTable(file.Read("llogs_config.json", "DATA"))
        fileData[id] = int
        file.Write("llogs_config.json", util.TableToJSON(fileData))
        LLogs.ServerConfig[id][3] = int
    end
    LLogs:NetworkConfig(ply)
end)

util.AddNetworkString("LLogs:LogInfo")
util.AddNetworkString("LLogs:RequestLog")
net.Receive("LLogs:RequestLog", function(len, ply)
    if not LLogs.CanAccess(ply) then LLogs:Notify(ply, 1, 3, "You do not have access to this.") return end
    if ply.LLogsPreventUse then LLogs:Notify(ply, 1, 3, "Wait: Still proccessing your other action.") return end
    ply.LLogsPreventUse = true

    local date, timestamp, message = net.ReadString(), net.ReadUInt(32), net.ReadString()
    LLogs.GetLogInfo(date, timestamp, message, function(data)
        net.Start("LLogs:LogInfo")
        net.WriteTable(data)
        net.Send(ply)
        ply.LLogsPreventUse = false
    end)
end)

local function load()
    if not file.Exists("llogs_config.json", "DATA") then
        file.Write("llogs_config.json", util.TableToJSON({}))
    end

    local data = util.JSONToTable(file.Read("llogs_config.json", "DATA"))
    for k, v in pairs(data) do
        LLogs.ServerConfig[k][3] = v
    end
end
load()

function LLogs:EndLiveLogs(ply)
    LLogs.LiveLogsUsers[ply] = false
end

function LLogs:StartLiveLogs(ply)
    LLogs.LiveLogsUsers[ply] = true
end

util.AddNetworkString("LLogs:EndLiveLogs")
net.Receive("LLogs:EndLiveLogs", function(len, ply)
    LLogs:EndLiveLogs(ply)
end)

util.AddNetworkString("LLogs:StartLiveLogs")
net.Receive("LLogs:StartLiveLogs", function(len, ply)
    LLogs:StartLiveLogs(ply)
end)

util.AddNetworkString("LLogs:GotoPos")
net.Receive("LLogs:GotoPos", function(len, ply)
    if not LLogs.CanAccess(ply) then LLogs:Notify(ply, 1, 3, "You do not have access to this.") return end
    local vec = net.ReadVector()
    ply:SetPos(vec)
end)

util.AddNetworkString("LLogs:WipeLogs")
net.Receive("LLogs:WipeLogs", function(len, ply)
    if not table.HasValue(LLogs.Manager, ply:GetUserGroup()) then LLogs:Notify(ply, 1, 3, "You do not have access to this.") return end

    LLogs.WipeLogs(function()
        print("WIPED ALL LOGS")
    end)
end)