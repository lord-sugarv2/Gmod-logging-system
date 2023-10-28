local PANEL = {}
function PANEL:Init()
    self.margin = (6)

    self.Scroll = self:Add("XeninUI.ScrollPanel")
    self.Scroll:Dock(FILL)

    local title = self.Scroll:Add("DLabel")
    title:Dock(TOP)
    title:SetWide((150))
    title:SetText("USE %s TO REFERENCE SERVER NAME")
    title:SetFont("LLogs:20")
    title:SetContentAlignment(5)

    local m2 = (self.margin/2)
    local col = XeninUI.Theme.Primary
    for k, v in pairs(LLogs.ServerConfig) do
        local panel = self.Scroll:Add("DPanel")
        panel:Dock(TOP)
        panel:DockMargin(self.margin, self.margin, self.margin, 0)
        panel:SetTall((40))
        panel.Paint = function(s, w, h)
            draw.RoundedBox(6, 0, 0, w, h, col)
        end

        local title = panel:Add("DLabel")
        title:Dock(LEFT)
        title:DockMargin(self.margin, 0, 0, 0)
        title:SetWide((150))
        title:SetText(v[1])
        title:SetFont("LLogs:20")
        title:SetContentAlignment(0)
        title:SizeToContents()

        surface.SetFont("LLogs:20")
        local tw, th = surface.GetTextSize(v[1])
        local infobutton = panel:Add("XeninUI.Button")
        infobutton:SetPos(self.margin + tw + m2, (5))
        infobutton:SetSize((12), (12))
        infobutton.Paint = function(s, w, h)
            draw.RoundedBox(self.margin, 0, 0, w, h, Color(0, 110, 255))
        end
        infobutton.DoClick = function()
            chat.AddText(color_white, v[2])
        end
    
        local submit = panel:Add("XeninUI.ButtonV2")
        submit:Dock(RIGHT)
        submit:DockMargin(0, m2, m2, m2)
        submit:SetWide((100))
        submit:SetText("Submit")
        submit:SetSolidColor(XeninUI.Theme.Blue)
        submit:SetRoundness(2)
        submit.DoClick = function(s)
            panel.SubmitValue()
        end

        if v[4] == "STRING" then
            local textbox = panel:Add("XeninUI.TextEntry")
            textbox:Dock(FILL)
            textbox:DockMargin(self.margin*4, m2, self.margin, m2)
            textbox:SetText(v[3])
            textbox.OnValueChange = function() end
            panel.SubmitValue = function()
                net.Start("LLogs:SubmitSetting")
                net.WriteString(k)
                net.WriteUInt(1, 3)
                net.WriteString(textbox:GetText())
                net.SendToServer()
            end
        elseif v[4] == "BOOL" then
            local box = panel:Add("XeninUI.CheckboxV2")
            box:Dock(RIGHT)
            box:DockMargin(self.margin*4, m2, self.margin, m2)
            box:SetState(v[3])
            box:SetWide(panel:GetTall()-self.margin)
            panel.SubmitValue = function()
                net.Start("LLogs:SubmitSetting")
                net.WriteString(k)
                net.WriteUInt(2, 3)
                net.WriteBool(box.State)
                net.SendToServer()
            end
        elseif v[4] == "NUMBER" then
            local textbox = panel:Add("XeninUI.TextEntry")
            textbox:Dock(FILL)
            textbox:DockMargin(self.margin*4, m2, self.margin, m2)
            textbox:SetText(v[3])
            textbox:SetNumeric(true)
            textbox.OnValueChange = function() end
            panel.SubmitValue = function()
                net.Start("LLogs:SubmitSetting")
                net.WriteString(k)
                net.WriteUInt(3, 3)
                net.WriteUInt(textbox:GetText(), 32)
                net.SendToServer()
            end
        end
    end

    local panel = self.Scroll:Add("DPanel")
    panel:Dock(TOP)
    panel:DockMargin(self.margin, self.margin, self.margin, 0)
    panel:SetTall((40))
    panel.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, col)
    end

    local title = panel:Add("DLabel")
    title:Dock(LEFT)
    title:DockMargin(self.margin, 0, 0, 0)
    title:SetWide((150))
    title:SetText("WIPE ALL LOGS")
    title:SetFont("LLogs:20")
    title:SetContentAlignment(0)
    title:SizeToContents()

    surface.SetFont("LLogs:20")
    local tw, th = surface.GetTextSize("WIPE ALL LOGS")
    local infobutton = panel:Add("XeninUI.Button")
    infobutton:SetPos(self.margin + tw + m2, (5))
    infobutton:SetSize((12), (12))
    infobutton.Paint = function(s, w, h)
        draw.RoundedBox(self.margin, 0, 0, w, h, Color(0, 110, 255))
    end
    infobutton.DoClick = function()
        chat.AddText(color_white, "Wipe all the logs database (undoable)")
    end

    local submit = panel:Add("XeninUI.ButtonV2")
    submit:Dock(RIGHT)
    submit:DockMargin(0, m2, m2, m2)
    submit:SetWide((100))
    submit:SetText("Wipe")
    submit:SetSolidColor(XeninUI.Theme.Blue)
    submit:SetRoundness(2)
    submit.DoClick = function(s)
        XeninUI:SimpleQuerySingle("Confirmation", "I ACKNOWLEDGE THIS ACTION IS IRREVERSIBLE AND WILL WIPE ALL LOGS", "WIPE", function()
            net.Start("LLogs:WipeLogs")
            net.SendToServer()
        end)
    end
end

function PANEL:PerformLayout(w, h)

end

function PANEL:Paint(w, h)

end
vgui.Register("LLogs:AdminPanel", PANEL, "EditablePanel")