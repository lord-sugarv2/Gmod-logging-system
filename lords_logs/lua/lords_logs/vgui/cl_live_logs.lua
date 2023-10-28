local PANEL = {}
function PANEL:Init()
    self:DockMargin(0, 0, 6, 0)
    self.Logs = {}
    self.margin = 6
    net.Start("LLogs:StartLiveLogs")
    net.SendToServer()

    self.Scroll = self:Add("XeninUI.ScrollPanel")
    self.Scroll:Dock(FILL)
    self.Scroll:HideScrollBar(true)
    self.bool = false

    hook.Add("LLogs:AddLiveLog", "LLogs:AddLiveLog", function(data)
        if not IsValid(self) then
            net.Start("LLogs:EndLiveLogs")
            net.SendToServer()
            return
        end

        self:AddLog(data)
    end)
end

function PANEL:FormatCol(col, al)
    return self.Opacity and ColorAlpha(col, al and al or 100) or col
end

local textCol = XeninUI.Theme.Blue
local col, col2 = XeninUI.Theme.Navbar, LLogs.OffsetColor(XeninUI.Theme.Navbar, 5)
function PANEL:AddLog(data)
    for k, v in ipairs(self.Logs) do
        v:SetPos(6, v:GetY() + v:GetTall() + 6)
    end

    local panel = self.Scroll:Add("DButton")
    panel:SetPos(6, 0)
    panel:SetSize(self:GetWide()-6, 25)
    panel:SetText("")
    panel.col = self.bool
    panel.Paint = function(s, w, h)
        local col = s.col and col2 or col
        col = s:IsHovered() and LLogs.OffsetColor(self:FormatCol(col), 5) or self:FormatCol(col)
        surface.SetDrawColor(col)
        surface.DrawRect(0, 0, w, h)

        local secondsAgo = os.difftime(os.time(), data.Timestamp)
        secondsAgo = string.NiceTime(secondsAgo).." ago"
        draw.SimpleText(secondsAgo, "LLogs:17", self.margin, h/2, s:IsHovered() and LLogs.OffsetColor(textCol, 10) or textCol, 0, 1)

        local col = s:IsHovered() and 
        LLogs.OffsetColor(LLogs.Modules[data.Module] and LLogs.Modules[data.Module].Color or color_white, 10)
        or LLogs.Modules[data.Module] and LLogs.Modules[data.Module].Color or color_white
        draw.SimpleText(data.Message, "LLogs:17", self.margin + 120, h/2, col, 0, 1)
    end
    panel.DoClick = function()
        net.Start("LLogs:RequestLog")
        net.WriteString(data.Date)
        net.WriteUInt(data.Timestamp, 32)
        net.WriteString(data.Message)
        net.SendToServer()
    end
    self.bool = not self.bool

    table.insert(self.Logs, panel)
end

function PANEL:PerformLayout(w, h)
    for k, v in ipairs(self.Logs) do
        v:SetWide(w-12)
    end
end

function PANEL:SetOpacity(bool)
    self.Opacity = bool
end

vgui.Register("LLogs:LiveLogs", PANEL, "EditablePanel")