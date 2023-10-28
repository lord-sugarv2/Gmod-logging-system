local PANEL = {}
function PANEL:Init()
    self.margin = (6)
    self.Categories = self:Add("LLogs:Categories")
    self.Categories:Dock(LEFT)
    self.Categories:SetWide((180))
    self.Categories:AddPanel("All", Color(255, 100, 100))
    self.Categories:AddPanel("Live Logs", function()
        LLogs:LiveLogs()
    end)

    local tbl = {}
    for k, v in pairs(LLogs.Modules) do
        tbl[v.Category] = tbl[v.Category] or {}
        table.Add(tbl[v.Category], {{v.Name, v.Color, v.Category}})
    end

    for k, v in pairs(tbl) do
        self.Categories:AddCategory(k)
        for k, v in ipairs(v) do
            self.Categories:AddPanel(v[1], v[2], v[3])
        end
    end
    self.Categories:FullyLoaded()

    self:SetupContent()
    self.Categories:SetActivePanel("All")
end

function PANEL:SetupContent(hideControls, panel)
    self.LogPanel = self:Add("LLogs:Content")
    self.LogPanel:Dock(FILL)
    self.LogPanel:DockMargin(self.margin, 0, 0, 0)
    self.LogPanel:HideControls(hideControls)
    self.LogPanel.Paint = function(s, w, h)
        surface.SetDrawColor(XeninUI.Theme.Background)
        surface.DrawRect(0, 0, w, h)
    end

    if not panel then return end
    local panel = self.LogPanel:Add(panel)
    panel:Dock(FILL)
end
vgui.Register("LLogs:Main", PANEL, "EditablePanel")