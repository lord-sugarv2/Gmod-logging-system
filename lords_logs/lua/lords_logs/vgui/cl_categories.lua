local PANEL = {}
function PANEL:Init()
    self.margin = (6)
    self.Scroll = self:Add("XeninUI.ScrollPanel")
    self.Scroll:Dock(FILL)
    self.Scroll:HideScrollBar(true)

    self.Categories = {}
    self.HoverCol = LLogs.OffsetColor(XeninUI.Theme.Navbar, 20)
    self.NormalCol = LLogs.OffsetColor(XeninUI.Theme.Navbar, 10)
end

function PANEL:SetActivePanel(str)
    self:GetParent():SetupContent()

    LLogs.ClientLatency = CurTime()
    net.Start("LLogs:RequestModuleData")
    net.WriteString(str)
    net.WriteUInt(1, 32)
    net.SendToServer()
end

function PANEL:AddCategory(str)
    local category = self.Scroll:Add("XeninUI.Category")
    category:Dock(TOP)
    category:DockMargin(self.margin, self.margin, self.margin, 0)
    category:SetTall(30)
    category:SetName(str)
    category.Expand = function(s, state)
        s.Top:LerpColor("textColor", state and s:GetTopTextColorActive() or s:GetTopTextColorHover())
        s.Top:LerpColor("background", state and s:GetTopColorActive() or s:GetTopColorHover())

        local childrenNum = #s:GetChildren() - 1
        local height = state and (childrenNum*35) + ((childrenNum + 2)*self.margin) or 48
        s:SetExpanded(state)
      
        s.Top.NextHeight = state and s.Top:GetTall() or s:GetTall()
        s.Top:Lerp("NextHeight", height)
        s.invalidateLayout = true
      
        s:OnToggle(s:GetExpanded())
    end
      
      
    --category:SetContents(contents)
    self.Categories[str] = category 
end

function PANEL:AddPanel(str, col, category)
    local button = (category and self.Categories[category] or self.Scroll):Add("XeninUI.ButtonV2")
    button:SetText(str)
    button:Dock(TOP)
    button:DockMargin(self.margin, self.margin, self.margin, 0)
    button:SetSolidColor(XeninUI.Theme.Blue)
    button:SetRoundness(2)
    button:SetTall(35)
    button:SetFont("LLogs:20")
    button.DoClick = function(s)
        if type(col) == "function" then
            col()
            return
        end
        self:SetActivePanel(str)
    end
end

function PANEL:FullyLoaded()
    if not LLogs.CanAccess(LocalPlayer()) then return end

    local button = self:Add("XeninUI.ButtonV2")
    button:SetText("Admin")
    button:Dock(BOTTOM)
    button:SetTall(30)
    button:DockMargin(self.margin, self.margin, self.margin, self.margin)
    button:SetSolidColor(XeninUI.Theme.Blue)
    button:SetRoundness(2)
    button:SetFont("LLogs:20")
    button.DoClick = function(s)
        self:GetParent():SetupContent(true, "LLogs:AdminPanel")
    end
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(XeninUI.Theme.Background)
    surface.DrawRect(0, 0, w, h)
end
vgui.Register("LLogs:Categories", PANEL, "EditablePanel")