local PANEL = {}
function PANEL:Init()
    self.margin = (6)
    self.Scroll = self:Add("XeninUI.ScrollPanel")
    self.Scroll:Dock(FILL)

    self.ContentBox = self:Add("LLogs:PageControls")
    self.ContentBox:Dock(BOTTOM)
    self.ContentBox:DockMargin(0, self.margin, self.margin, self.margin)
    self.ContentBox:SetTall((40))

    hook.Add("LLogs:ReceivedModuleData", "LLogs:UpdateContent", function(moduleName, data)
        if not IsValid(self) then return end
        if self.HideControls then return end
        self.Data = data
        self.ContentBox.Data = data
        self:PopulateData(data)
    end)
end

function PANEL:HideControls(bool)
    self.HideControls = bool
    if not bool then return end
    self.ContentBox:Remove()
end

local textCol = XeninUI.Theme.Blue
function PANEL:PopulateData(data)
    self.Scroll:Clear()
    local bool, col, col2 = false, XeninUI.Theme.Navbar, LLogs.OffsetColor(XeninUI.Theme.Navbar, 5)
    for k, v in ipairs(data.Results) do
        local panel = self.Scroll:Add("DButton")
        panel:Dock(TOP)
        panel:DockMargin(0, self.margin, self.margin, 0)
        panel:SetTall((25))
        panel:SetText("")
        panel.col = bool
        panel.Paint = function(s, w, h)
            local showDates = not LLogs.showText
            local col = s.col and col2 or col
            col = s:IsHovered() and LLogs.OffsetColor(col, 5) or col
            surface.SetDrawColor(col)
            surface.DrawRect(0, 0, w, h)

            local showSeconds = LLogs.showSeconds
            if showSeconds then
                local secondsAgo = os.difftime(os.time(), v.Timestamp)
                secondsAgo = string.NiceTime(secondsAgo).." ago"
                draw.SimpleText(showDates and (v.Date .." - "..secondsAgo) or secondsAgo, "LLogs:17", self.margin, h/2, s:IsHovered() and LLogs.OffsetColor(textCol, 10) or textCol, 0, 1)
                draw.SimpleText(v.Message, "LLogs:17", showDates and (self.margin + 210) or self.margin + 120, h/2, s:IsHovered() and LLogs.OffsetColor(LLogs.Modules[v.Module] and LLogs.Modules[v.Module].Color or color_white, 10) or LLogs.Modules[v.Module] and LLogs.Modules[v.Module].Color or color_white, 0, 1)
            else
                draw.SimpleText(showDates and (v.Date .." - "..os.date("%I:%M:%S", v.Timestamp)) or os.date("%I:%M:%S", v.Timestamp), "LLogs:17", self.margin, h/2, s:IsHovered() and LLogs.OffsetColor(textCol, 10) or textCol, 0, 1)
                draw.SimpleText(v.Message, "LLogs:17", showDates and (self.margin + 170) or self.margin + 80, h/2, s:IsHovered() and LLogs.OffsetColor(LLogs.Modules[v.Module] and LLogs.Modules[v.Module].Color or color_white, 10) or LLogs.Modules[v.Module] and LLogs.Modules[v.Module].Color or color_white, 0, 1)    
            end
        end
        panel.DoClick = function()
            net.Start("LLogs:RequestLog")
            net.WriteString(v.Date)
            net.WriteUInt(v.Timestamp, 32)
            net.WriteString(v.Message)
            net.SendToServer()
        end
        bool = not bool
    
        --local time = os.date("%H:%M:%S", v.Timestamp)
        --self.ListView:AddLine(v.Date, time, v.Message)
    end
    self.Scroll:Rebuild()
end
vgui.Register("LLogs:Content", PANEL, "EditablePanel")