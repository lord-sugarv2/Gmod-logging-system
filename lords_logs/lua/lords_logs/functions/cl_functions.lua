XeninUI:CreateFont("LLogs:20:Bold", 20)
XeninUI:CreateFont("LLogs:20", 20)
XeninUI:CreateFont("LLogs:17", 17)
XeninUI:CreateFont("LLogs:15", 15)

function LLogs:Open()
    if LLogs.Menu then LLogs.Menu:Remove() end
    LLogs.Menu = vgui.Create("XeninUI.Frame")
    LLogs.Menu:SetSize(ScrW() * .6, ScrH() * .7)
    LLogs.Menu:MakePopup()
    LLogs.Menu:Center()
    LLogs.Menu:SetTitle(string.format(LLogs.GetServerValue("MenuTitle"), LLogs.GetServerValue("ServerName")))

    local panel = LLogs.Menu:Add("LLogs:Main")
    panel:Dock(FILL)
end

net.Receive("LLogs:Open", function()
    LLogs:Open()
end)

net.Receive("LLogs:SendsLogs", function()
    local int = net.ReadInt(32)
    local data = {
        moduleName = net.ReadString(),
        pagesAmount = net.ReadUInt(32),
        currentPage = net.ReadUInt(32),
        resultsOnPage = net.ReadUInt(6),
        Results = {},
    }

    for i = 1, data.resultsOnPage do
        local tbl = {
            Date = net.ReadString(),
            Message = net.ReadString(),
            Timestamp = net.ReadUInt(32),
            Module = net.ReadString(),
        }
        table.Add(data.Results, {tbl})
    end
    hook.Run("LLogs:ReceivedModuleData", data.moduleName, data)
    LLogs.ServerLatency = int
    LLogs.ClientLatencyFinal = LLogs.ClientLatency - CurTime()
end)

net.Receive("LLogs:Notify", function()
    local int, seconds, message = net.ReadUInt(3), net.ReadUInt(8), net.ReadString()
    notification.AddLegacy(message, int, seconds)
end)

net.Receive("LLogs:NetworkConfig", function()
    local data = net.ReadTable()
    for k, v in pairs(data) do
        LLogs.ServerConfig[k][3] = v
    end
end)

net.Receive("LLogs:LogInfo", function()
    local data = net.ReadTable()
    data = util.JSONToTable(data.ExtraInfo)
    local frame = vgui.Create("XeninUI.Frame")
    frame:SetSize((400), (250))
    frame:MakePopup()
    frame:Center()
    frame:SetTitle("Log Viewer")

    local panel = frame:Add("LLogs:LogViewer")
    panel:Dock(FILL)
    panel:SetData(data)
end)

hook.Add("InitPostEntity", "LLogs:CanReceive", function()
    net.Start("LLogs:RequestConfig")
    net.SendToServer()
end)

function LLogs.OffsetColor(col, offset)
    return Color(col.r + offset, col.g + offset, col.b + offset)
end

function LLogs:LiveLogs()
    if IsValid(self.LiveLogsMenu) then
        self.LiveLogsMenu:Remove()
        return
    end

    self.LiveLogsMenu = vgui.Create("DFrame")
    self.LiveLogsMenu:SetSize(350, 250)
    self.LiveLogsMenu:DockPadding(0, 24, 0, 0)
    self.LiveLogsMenu:SetSizable(true)
    self.LiveLogsMenu:SetTitle("")
    self.LiveLogsMenu.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, s.Opacity and ColorAlpha(XeninUI.Theme.Background, 100) or XeninUI.Theme.Background)
        draw.RoundedBoxEx(6, 0, 0, w, 24, s.Opacity and ColorAlpha(XeninUI.Theme.Navbar, 100) or XeninUI.Theme.Navbar, true, true)
    end

    local Check = self.LiveLogsMenu:Add("DCheckBoxLabel")
    Check:SetSize(20, 20)
    Check:SetPos(2, 2)
    Check:SetText("Opacity")

    local liveLogs = self.LiveLogsMenu:Add("LLogs:LiveLogs")
    liveLogs:Dock(FILL)

    Check.OnChange = function(s, bool)
        self.LiveLogsMenu.Opacity = bool
        liveLogs:SetOpacity(bool)
    end
end

net.Receive("LLog:AddLiveLog", function()
    local Date = net.ReadString()
    local Message = net.ReadString()
    local Timestamp = net.ReadUInt(32)
    local Module = net.ReadString()

    hook.Run("LLogs:AddLiveLog", {Date = Date, Message = Message, Timestamp = Timestamp, Module = Module})
end)