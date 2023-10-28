bLogs = bLogs or {}
bLogs.CustomConfig = bLogs.CustomConfig or {}
bLogs.CategoryCache = bLogs.CategoryCache or {}
bLogs.ModuleCache = bLogs.ModuleCache or {}
bLogs.EnabledCache = bLogs.EnabledCache or {}

function bLogs.EnableLogger(moduleName)
    bLogs.EnabledCache[moduleName] = true

    if bLogs.ModuleCache[moduleName] then
        LLogs.AddModule(bLogs.ModuleCache[moduleName])
    end 
end

function bLogs.GetName(ply)
    return LLogs.GetName(ply)
end

function bLogs.CreateCategory(name, color)
    bLogs.CategoryCache[name] = color
end

function bLogs.DefineLogger(moduleName, categoryName, bool)
    local MODULE = {}
    MODULE.Category = categoryName
    MODULE.Name = moduleName
    MODULE.Color = bLogs.CategoryCache[categoryName] or Color(255, 100, 100)
    bLogs.ModuleCache[moduleName] = MODULE

    if type(bool) == "nil" or bLogs.EnabledCache[moduleName] then
        LLogs.AddModule(bLogs.ModuleCache[moduleName])
    end
end

function bLogs.AddHook(hookName, hookStr, func)
    hook.Add(hookName, hookName..hookStr, func)
end

function bLogs.AddGameEvent(hookName, hookStr, func)
    if CLIENT then return end
    gameevent.Listen(hookName)
    hook.Add(hookName, hookName..hookStr, func)
end

function bLogs.FormatCurrency(amt)
    amt = tonumber(amt)
    return DarkRP and DarkRP.formatMoney(amt) or string.Comma(amt)
end

function bLogs.Log(DATA)
    if CLIENT then return end
    local str = DATA.log
    local tbl = {}
    for k, v in ipairs(DATA.involved) do
        table.insert(tbl, LLogs.FormatPlayer(v))
    end
    LLogs.Log(DATA.module, str, unpack(tbl))
end

-- no idea what this actually does so :shrug:
function bLogs.NoBipolarNetworkIDs(s)
    return s 
end

function bLogs.GetPrintName(ent)
    return ent:GetPrintName()
end

function bLogs.GetOwner(ent)
    return ent:GetOwner()
end