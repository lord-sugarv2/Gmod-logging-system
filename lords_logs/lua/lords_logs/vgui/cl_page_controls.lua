local PANEL = {}
function PANEL:Init()
    self.margin, self.Col = (6), XeninUI.Theme.Background 

    self.CurrentPage = self:Add("DPanel")
    self.CurrentPage.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, self.Col)
        draw.SimpleText(self.Data and self.Data.currentPage or 0, "LLogs:20", w/2, h/2, color_white, 1, 1)
    end

    self.FilterBox = self:Add("DPanel")
    self.FilterBox:Dock(LEFT)
    self.FilterBox:DockMargin(self.margin, self.margin, 0, self.margin)
    self.FilterBox.Paint = nil

    self.FilterText = self.FilterBox:Add("XeninUI.TextEntry")
    self.FilterText:Dock(FILL)
    self.FilterText:DockMargin(0, 0, self.margin, 0)
    self.FilterText:SetPlaceholder("Context Filter")
    self.FilterText:SetBackgroundColor(self.Col)
    self.FilterText.OnValueChange = function() end

    self.FilterButton = self.FilterBox:Add("XeninUI.ButtonV2")
    self.FilterButton:Dock(RIGHT)
    self.FilterButton:SetWide((75))
    self.FilterButton:SetText("Filter")
    self.FilterButton:SetSolidColor(XeninUI.Theme.Blue)
    self.FilterButton:SetRoundness(2)
    self.FilterButton.DoClick = function()
        LLogs.ClientLatency = CurTime()
        net.Start("LLogs:RequestWithFilter")
        net.WriteString(self.Data.moduleName)
        net.WriteString(self.FilterText:GetText())
        net.SendToServer()
    end

    self.Forward = self:Add("DButton")
    self.Forward:SetText("")
    self.Forward.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, self.Col)
        draw.SimpleText(">", "LLogs:20", w/2, h/2, color_white, 1, 1)
    end
    self.Forward.DoClick = function()
        LLogs.ClientLatency = CurTime()
        net.Start("LLogs:ChangePage")
        net.WriteUInt(self.Data and self.Data.currentPage + 1 or 1, 32)
        net.SendToServer()
    end

    self.ForwardSkip = self:Add("DButton")
    self.ForwardSkip:SetText("")
    self.ForwardSkip.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, self.Col)
        draw.SimpleText(">>", "LLogs:20", w/2, h/2, color_white, 1, 1)
    end
    self.ForwardSkip.DoClick = function()
        LLogs.ClientLatency = CurTime()
        net.Start("LLogs:ChangePage")
        net.WriteUInt(self.Data.pagesAmount, 32)
        net.SendToServer()
    end

    self.Backwards = self:Add("DButton")
    self.Backwards:SetText("")
    self.Backwards.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, self.Col)
        draw.SimpleText("<", "LLogs:20", w/2, h/2, color_white, 1, 1)
    end
    self.Backwards.DoClick = function()
        LLogs.ClientLatency = CurTime()
        net.Start("LLogs:ChangePage")
        net.WriteUInt(self.Data and self.Data.currentPage - 1 or 1, 32)
        net.SendToServer()
    end

    self.BackwardsSkip = self:Add("DButton")
    self.BackwardsSkip:SetText("")
    self.BackwardsSkip.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, self.Col)
        draw.SimpleText("<<", "LLogs:20", w/2, h/2, color_white, 1, 1)
    end
    self.BackwardsSkip.DoClick = function()
        LLogs.ClientLatency = CurTime()
        net.Start("LLogs:ChangePage")
        net.WriteUInt(1, 32)
        net.SendToServer()
    end

    self.removeText = self:Add("XeninUI.CheckboxV2")
    self.removeText:Dock(RIGHT)
    self.removeText:DockMargin(0, self.margin, self.margin, self.margin)
    self.removeText:SetState(LLogs.showText)
    self.removeText.PerformLayout = function(s, w, h)
        s:SetWide(s:GetTall())
    end
    self.removeText.OnStateChanged = function(s)
        LLogs.showText = self.removeText.State
    end

    self.secondsInstead = self:Add("XeninUI.CheckboxV2")
    self.secondsInstead:Dock(RIGHT)
    self.secondsInstead:DockMargin(0, self.margin, self.margin, self.margin)
    self.secondsInstead.PerformLayout = function(s, w, h)
        s:SetWide(s:GetTall())
    end
    self.secondsInstead.OnStateChanged = function(s)
        LLogs.showSeconds = self.secondsInstead.State
    end
end

function PANEL:PerformLayout(w, h)
    local w2, h2 = (40), (30) - self.margin
    local size = w2 + (w2/1.5) + (w2) + (w2/1.5) + (self.margin*4)
    self.CurrentPage:SetSize(w2, h2)
    self.CurrentPage:SetPos((w/2) - (w2/2), (h/2) - (h2/2))

    self.Forward:SetSize(w2/1.5, h2)
    self.Forward:SetPos((w/2) + (w2/2) + self.margin, (h/2) - (h2/2))

    self.ForwardSkip:SetSize(w2, h2)
    self.ForwardSkip:SetPos((w/2) + (w2/2) + self.margin + (w2/1.5) + self.margin, (h/2) - (h2/2))

    self.Backwards:SetSize(w2/1.5, h2)
    self.Backwards:SetPos((w/2) - (w2/2) - (w2/1.5) - self.margin, (h/2) - (h2/2))

    local x = (w/2) - (w2/2) - (w2/1.5) - self.margin - w2 - self.margin
    self.BackwardsSkip:SetSize(w2, h2)
    self.BackwardsSkip:SetPos(x, (h/2) - (h2/2))

    self.FilterBox:SetWide((w/2) - (size/2) - (self.margin*6))
end

function PANEL:Paint(w, h)
    draw.RoundedBox(6, 0, 0, w, h, XeninUI.Theme.Primary)

    local startX = (w/2) + (40/2) + self.margin + (40/1.5) + self.margin + 40
    draw.SimpleText(math.Round(LLogs.ClientLatencyFinal or 0).."ms cl / "..math.Round(LLogs.ServerLatency or 0).."ms sv", "LLogs:17", startX + (((w - self.margin - h - self.margin - h) - startX) / 2), h/2, color_white, 1, 1)
end
vgui.Register("LLogs:PageControls", PANEL, "EditablePanel")