-- ZENIT MM2 // v15
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

if not Drawing then
    pcall(function() StarterGui:SetCore("SendNotification", {Title="Ошибка", Text="Нет Drawing API", Duration=5}) end)
    return
end

-- CLEANUP
local OUR_GUI_NAME = "ZenitMM2_v15"
local function LooksCheatGUI(obj)
    if not obj:IsA("ScreenGui") then return false end
    if obj.Name == OUR_GUI_NAME or obj.Name == "RobloxGui" then return false end
    local known = {"zenit","mm2","aim","esp","hub","menu","cheat","script","panel","puller"}
    local low = obj.Name:lower()
    for _, k in ipairs(known) do if low:find(k) then return true end end
    return false
end
local function CleanupOldGUIs()
    local removed = 0
    local ok, core = pcall(function() return game:GetService("CoreGui") end)
    if ok and core then
        local ok2, children = pcall(function() return core:GetChildren() end)
        if ok2 and children then
            for _, obj in ipairs(children) do
                if LooksCheatGUI(obj) then pcall(function() obj:Destroy() end); removed = removed + 1 end
            end
        end
    end
    local pg = LP:FindFirstChild("PlayerGui")
    if pg then
        for _, obj in ipairs(pg:GetChildren()) do
            if LooksCheatGUI(obj) then pcall(function() obj:Destroy() end); removed = removed + 1 end
        end
    end
    pcall(function() StarterGui:SetCore("SendNotification", {Title="Cleanup", Text="Удалено: "..removed, Duration=3}) end)
end
CleanupOldGUIs()

-- КОНФИГ
local Config = {
    Aimbot=false, TargetRole="Murderer", ESP=false, ESP_Box=true, ESP_Name=true, ESP_Role=true, ESP_Dist=true,
    Chams=false, ChamsTransp=0.75, ChamsGlow=true, SilentAim=false, SilentFOV=200,
    AutoCoin=false, WallCheck=true, AutoDodge=false, AutoKill=false, AutoWin=false,
    FreezeAll=false, AutoTPRevolver=false, Noclip=false, InfiniteJump=false, Invisible=false,
    PullRole="All", BringMode=false, DodgeRadius=8, DodgeRange=25, FOV=150, Smooth=0
}
local RoleColors = {
    Murderer = Color3.fromRGB(255,50,50),
    Sheriff  = Color3.fromRGB(50,150,255),
    Innocent = Color3.fromRGB(50,255,50)
}
local GunNames = {"Gun","Revolver","Silver","Knife"}

-- BLOOM для свечения
local function EnsureBloom()
    local existing = Lighting:FindFirstChild("ZenitBloom")
    if not existing then
        local bloom = Instance.new("BloomEffect")
        bloom.Name = "ZenitBloom"
        bloom.Intensity = 0.8
        bloom.Size = 24
        bloom.Threshold = 0.9
        bloom.Parent = Lighting
    end
end
local function RemoveBloom()
    local existing = Lighting:FindFirstChild("ZenitBloom")
    if existing then existing:Destroy() end
end

-- TOUCHPAN
local ActiveScroll = nil
UserInputService.TouchPan:Connect(function(touchPositions, totalTranslation, velocity)
    if not ActiveScroll then return end
    local maxY = math.max(0, ActiveScroll.AbsoluteCanvasSize.Y - ActiveScroll.AbsoluteSize.Y)
    if maxY <= 0 then return end
    local newY = ActiveScroll.CanvasPosition.Y - totalTranslation.Y
    ActiveScroll.CanvasPosition = Vector2.new(0, math.clamp(newY, 0, maxY))
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        task.delay(0.1, function() ActiveScroll = nil end)
    end
end)

-- РОЛИ
local RoleCache = {}
local lastRoleUpdate = 0
local function hasTool(container, names)
    if not container then return false end
    for _, name in ipairs(names) do if container:FindFirstChild(name) then return true end end
    return false
end
local function GetRole(player)
    if not player or not player.Character then return "Innocent" end
    local attr = player:GetAttribute("Role")
    if attr and RoleColors[attr] then return attr end
    local backpack = player:FindFirstChild("Backpack")
    local char = player.Character
    if hasTool(backpack, {"Knife"}) or hasTool(char, {"Knife"}) then return "Murderer" end
    if hasTool(backpack, {"Gun","Revolver","Silver"}) or hasTool(char, {"Gun","Revolver","Silver"}) then return "Sheriff" end
    return "Innocent"
end
local function UpdateRoleCache()
    local now = tick()
    if now - lastRoleUpdate < 0.5 then return end
    lastRoleUpdate = now
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then RoleCache[p] = GetRole(p) end
    end
end
local function IsPlayerInGame(p)
    if p == LP or not p or not p.Character then return false end
    local char = p.Character
    if char.Parent ~= Workspace then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return false end
    if hum.Health <= 0 or hum:GetState() == Enum.HumanoidStateType.Dead then return false end
    local inRound = p:GetAttribute("InRound")
    if inRound == false then return false end
    local roleAttr = p:GetAttribute("Role")
    if roleAttr == "Lobby" or roleAttr == "Spectator" then return false end
    if p.Team then
        local tn = p.Team.Name:lower()
        if tn:find("lobby") or tn:find("spectat") then return false end
    end
    for _, name in ipairs({"Lobby","LobbyZone","LobbySpawn"}) do
        local lobby = Workspace:FindFirstChild(name)
        if lobby and hrp:IsDescendantOf(lobby) then return false end
    end
    return true
end

-- UI
local function GetGuiParent()
    local ok, core = pcall(function() return game:GetService("CoreGui") end)
    if ok and core then return core end
    return LP:WaitForChild("PlayerGui")
end
local gui = Instance.new("ScreenGui")
gui.Name = OUR_GUI_NAME
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.Parent = GetGuiParent()

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0,40,0,40)
toggleBtn.Position = UDim2.new(0,8,0,80)
toggleBtn.BackgroundColor3 = Color3.fromRGB(25,25,30)
toggleBtn.Text = "Z"
toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18
toggleBtn.BorderSizePixel = 0
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = gui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,8)
local strokeBtn = Instance.new("UIStroke", toggleBtn)
strokeBtn.Color = Color3.fromRGB(255,0,100)
strokeBtn.Thickness = 1.5

local START_W, START_H, MIN_W, MIN_H, MAX_W, MAX_H = 320, 480, 240, 200, 520, 800
local menu = Instance.new("Frame")
menu.Size = UDim2.new(0, START_W, 0, 0)
menu.Position = UDim2.new(0,8,0,130)
menu.BackgroundColor3 = Color3.fromRGB(25,25,30)
menu.BackgroundTransparency = 0.05
menu.BorderSizePixel = 0
menu.ClipsDescendants = true
menu.Active = true
menu.Parent = gui
Instance.new("UICorner", menu).CornerRadius = UDim.new(0,10)
local strokeMenu = Instance.new("UIStroke", menu)
strokeMenu.Color = Color3.fromRGB(255,0,100)
strokeMenu.Thickness = 1.5

local title = Instance.new("TextButton")
title.Size = UDim2.new(1,0,0,30)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundColor3 = Color3.fromRGB(35,35,45)
title.BackgroundTransparency = 0.2
title.Text = "ZENIT MM2 v15"
title.TextColor3 = Color3.fromRGB(255,0,100)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.BorderSizePixel = 0
title.AutoButtonColor = false
title.Active = true
title.Parent = menu
Instance.new("UICorner", title).CornerRadius = UDim.new(0,10)

local resizeHandle = Instance.new("TextButton")
resizeHandle.Size = UDim2.new(0,16,0,16)
resizeHandle.Position = UDim2.new(1,-18,0,7)
resizeHandle.BackgroundColor3 = Color3.fromRGB(255,0,100)
resizeHandle.Text = "◢"
resizeHandle.TextColor3 = Color3.fromRGB(255,255,255)
resizeHandle.Font = Enum.Font.GothamBold
resizeHandle.TextSize = 12
resizeHandle.BorderSizePixel = 0
resizeHandle.AutoButtonColor = false
resizeHandle.Parent = menu
Instance.new("UICorner", resizeHandle).CornerRadius = UDim.new(0,4)

local tabsBar = Instance.new("Frame")
tabsBar.Size = UDim2.new(1,-16,0,26)
tabsBar.Position = UDim2.new(0,8,0,34)
tabsBar.BackgroundTransparency = 1
tabsBar.Parent = menu

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1,-30,1,-66)
tabContainer.Position = UDim2.new(0,8,0,64)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = menu

-- СКРОЛЛ-ПОЛОСА СПРАВА
local scrollBarBg = Instance.new("Frame")
scrollBarBg.Size = UDim2.new(0,6,1,-66)
scrollBarBg.Position = UDim2.new(1,-14,0,64)
scrollBarBg.BackgroundColor3 = Color3.fromRGB(40,40,50)
scrollBarBg.BorderSizePixel = 0
scrollBarBg.Parent = menu
Instance.new("UICorner", scrollBarBg).CornerRadius = UDim.new(0,3)

local scrollThumb = Instance.new("Frame")
scrollThumb.Size = UDim2.new(1,0,0.3,0)
scrollThumb.Position = UDim2.new(0,0,0,0)
scrollThumb.BackgroundColor3 = Color3.fromRGB(255,0,100)
scrollThumb.BorderSizePixel = 0
scrollThumb.Parent = scrollBarBg
Instance.new("UICorner", scrollThumb).CornerRadius = UDim.new(0,3)

local draggingThumb = false
scrollThumb.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingThumb = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingThumb = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingThumb and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local rel = math.clamp((input.Position.Y - scrollBarBg.AbsolutePosition.Y)/scrollBarBg.AbsoluteSize.Y,0,1)
        local tab = GetActiveTab()
        if tab then
            local maxY = math.max(0, tab.AbsoluteCanvasSize.Y - tab.AbsoluteSize.Y)
            tab.CanvasPosition = Vector2.new(0, rel * maxY)
        end
    end
end)

local function makeScrollTab(parent)
    local s = Instance.new("ScrollingFrame")
    s.Size = UDim2.new(1,0,1,0)
    s.BackgroundTransparency = 1
    s.BorderSizePixel = 0
    s.ScrollBarThickness = 0
    s.CanvasSize = UDim2.new(0,0,0,500)
    s.Active = true
    s.ElasticBehavior = Enum.ElasticBehavior.Never
    s.ScrollingDirection = Enum.ScrollingDirection.Y
    s.Parent = parent
    return s
end
local tabAimbot = makeScrollTab(tabContainer)
local tabESP    = makeScrollTab(tabContainer)
local tabColors = makeScrollTab(tabContainer)
local tabMisc   = makeScrollTab(tabContainer)
local tabPull   = makeScrollTab(tabContainer)
local tabAuto   = makeScrollTab(tabContainer)
local allTabs = {tabAimbot, tabESP, tabColors, tabMisc, tabPull, tabAuto}
for _, t in ipairs(allTabs) do t.Visible = false end
tabAimbot.Visible = true

local tabButtons = {}
local function makeTabBtn(index, total, text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1/total,-2,1,0)
    b.Position = UDim2.new(index/total,2,0,0)
    b.BackgroundColor3 = Color3.fromRGB(40,40,50)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 9
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = tabsBar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,5)
    b.MouseButton1Click:Connect(callback)
    tabButtons[text] = b
    return b
end
local function ShowTab(name)
    tabAimbot.Visible = (name=="Aim")
    tabESP.Visible    = (name=="ESP")
    tabColors.Visible = (name=="Clr")
    tabMisc.Visible   = (name=="Misc")
    tabPull.Visible   = (name=="Pull")
    tabAuto.Visible   = (name=="Auto")
    for _, b in pairs(tabButtons) do b.BackgroundColor3 = Color3.fromRGB(40,40,50) end
    if tabButtons[name] then tabButtons[name].BackgroundColor3 = Color3.fromRGB(255,0,100) end
end
makeTabBtn(0,6,"Aim",  function() ShowTab("Aim")  end)
makeTabBtn(1,6,"ESP",  function() ShowTab("ESP")  end)
makeTabBtn(2,6,"Clr",  function() ShowTab("Clr")  end)
makeTabBtn(3,6,"Misc", function() ShowTab("Misc") end)
makeTabBtn(4,6,"Pull", function() ShowTab("Pull") end)
makeTabBtn(5,6,"Auto", function() ShowTab("Auto") end)-- ХЕЛПЕРЫ
local function makeToggle(parent, yPos, text, callback, defaultState)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-8,0,24)
    btn.Position = UDim2.new(0,4,0,yPos)
    btn.BackgroundColor3 = defaultState and Color3.fromRGB(255,0,100) or Color3.fromRGB(40,40,50)
    btn.Text = text..": "..(defaultState and "ON" or "OFF")
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,5)
    local state = defaultState and true or false
    if state and callback then callback(true) end
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text..": "..(state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(255,0,100) or Color3.fromRGB(40,40,50)
        callback(state)
    end)
end
local function makeButton(parent, yPos, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-8,0,24)
    btn.Position = UDim2.new(0,4,0,yPos)
    btn.BackgroundColor3 = Color3.fromRGB(60,60,80)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,5)
    btn.MouseButton1Click:Connect(callback)
end
local function makeSlider(parent, yLabel, yBar, labelText, min, max, default, callback)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-8,0,14)
    lbl.Position = UDim2.new(0,4,0,yLabel)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText..": "..default
    lbl.TextColor3 = Color3.fromRGB(200,200,200)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1,-8,0,8)
    bar.Position = UDim2.new(0,4,0,yBar)
    bar.BackgroundColor3 = Color3.fromRGB(40,40,50)
    bar.BorderSizePixel = 0
    bar.Parent = parent
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0,4)
    local fill = Instance.new("Frame")
    local relDef = (default-min)/(max-min)
    fill.Size = UDim2.new(relDef,0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(255,0,100)
    fill.BorderSizePixel = 0
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0,4)
    local dragging = false
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relX = math.clamp((input.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
            local val = math.floor(relX*(max-min)+min)
            fill.Size = UDim2.new(relX,0,1,0)
            lbl.Text = labelText..": "..val
            callback(val)
        end
    end)
end

-- AIM
makeToggle(tabAimbot,4,"Aimbot",function(v) Config.Aimbot=v end)
makeToggle(tabAimbot,32,"WallCheck",function(v) Config.WallCheck=v end,true)
local roleBtn = Instance.new("TextButton")
roleBtn.Size = UDim2.new(1,-8,0,24)
roleBtn.Position = UDim2.new(0,4,0,60)
roleBtn.BackgroundColor3 = Color3.fromRGB(40,40,50)
roleBtn.Text = "Target: "..Config.TargetRole
roleBtn.TextColor3 = RoleColors[Config.TargetRole]
roleBtn.Font = Enum.Font.GothamBold
roleBtn.TextSize = 10
roleBtn.BorderSizePixel = 0
roleBtn.AutoButtonColor = false
roleBtn.Parent = tabAimbot
Instance.new("UICorner", roleBtn).CornerRadius = UDim.new(0,5)
local roleOrder = {"Murderer","Sheriff","Innocent"}
local roleIdx = 1
roleBtn.MouseButton1Click:Connect(function()
    roleIdx = (roleIdx % #roleOrder) + 1
    Config.TargetRole = roleOrder[roleIdx]
    roleBtn.Text = "Target: "..Config.TargetRole
    roleBtn.TextColor3 = RoleColors[Config.TargetRole]
end)
makeSlider(tabAimbot,92,108,"FOV",50,500,150,function(v) Config.FOV=v end)
makeSlider(tabAimbot,124,140,"Smooth",0,100,0,function(v) Config.Smooth=v end)
makeToggle(tabAimbot,164,"AutoDodge",function(v) Config.AutoDodge=v end)
makeSlider(tabAimbot,196,212,"DodgeRadius",1,30,8,function(v) Config.DodgeRadius=v end)
makeSlider(tabAimbot,228,244,"DodgeRange",5,60,25,function(v) Config.DodgeRange=v end)
makeToggle(tabAimbot,264,"SilentAim",function(v) Config.SilentAim=v end)
makeSlider(tabAimbot,296,312,"SilentFOV",50,500,200,function(v) Config.SilentFOV=v end)
tabAimbot.CanvasSize = UDim2.new(0,0,0,340)

-- ESP (с Bloom)
makeToggle(tabESP,4,"ESP",function(v) Config.ESP=v end)
makeToggle(tabESP,32,"Chams (Blur)",function(v)
    Config.Chams=v
    if v and Config.ChamsGlow then EnsureBloom() else RemoveBloom() end
end)
makeToggle(tabESP,60,"Chams Glow",function(v)
    Config.ChamsGlow=v
    if Config.Chams and v then EnsureBloom() else RemoveBloom() end
end)
makeToggle(tabESP,88,"ESP Box",function(v) Config.ESP_Box=v end,true)
makeToggle(tabESP,116,"ESP Name",function(v) Config.ESP_Name=v end,true)
makeToggle(tabESP,144,"ESP Role",function(v) Config.ESP_Role=v end,true)
makeToggle(tabESP,172,"ESP Distance",function(v) Config.ESP_Dist=v end,true)
makeSlider(tabESP,204,220,"ChamsTransp",0,100,75,function(v) Config.ChamsTransp=v/100 end)
tabESP.CanvasSize = UDim2.new(0,0,0,250)

-- ЦВЕТА
local presetColors = {
    Color3.fromRGB(255,50,50), Color3.fromRGB(50,150,255), Color3.fromRGB(50,255,50),
    Color3.fromRGB(255,200,50), Color3.fromRGB(200,50,255), Color3.fromRGB(50,255,255),
    Color3.fromRGB(255,255,255), Color3.fromRGB(0,0,0),
}
local function makeColorRow(parent, yPos, roleName)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0,70,0,22)
    label.Position = UDim2.new(0,4,0,yPos)
    label.BackgroundTransparency = 1
    label.Text = roleName..":"
    label.TextColor3 = Color3.fromRGB(200,200,200)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    local current = Instance.new("Frame")
    current.Size = UDim2.new(0,22,0,22)
    current.Position = UDim2.new(0,76,0,yPos)
    current.BackgroundColor3 = RoleColors[roleName]
    current.BorderSizePixel = 0
    current.Parent = parent
    Instance.new("UICorner", current).CornerRadius = UDim.new(0,4)
    local palette = Instance.new("Frame")
    palette.Size = UDim2.new(0,22,0,0)
    palette.Position = UDim2.new(0,76,0,yPos+24)
    palette.BackgroundColor3 = Color3.fromRGB(35,35,45)
    palette.BorderSizePixel = 0
    palette.ClipsDescendants = true
    palette.ZIndex = 5
    palette.Parent = parent
    Instance.new("UICorner", palette).CornerRadius = UDim.new(0,4)
    for i, col in ipairs(presetColors) do
        local sw = Instance.new("TextButton")
        sw.Size = UDim2.new(0,18,0,18)
        sw.Position = UDim2.new(0,2,0,(i-1)*20+2)
        sw.BackgroundColor3 = col
        sw.Text = ""
        sw.BorderSizePixel = 0
        sw.AutoButtonColor = false
        sw.ZIndex = 6
        sw.Parent = palette
        Instance.new("UICorner", sw).CornerRadius = UDim.new(0,3)
        sw.MouseButton1Click:Connect(function()
            RoleColors[roleName] = col
            current.BackgroundColor3 = col
            palette.Size = UDim2.new(0,22,0,0)
        end)
    end
    current.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if palette.Size.Y.Offset > 0 then
                palette.Size = UDim2.new(0,22,0,0)
            else
                palette.Size = UDim2.new(0,22,0,#presetColors*20+4)
            end
        end
    end)
end
makeColorRow(tabColors,26,"Murderer")
makeColorRow(tabColors,56,"Sheriff")
makeColorRow(tabColors,86,"Innocent")
tabColors.CanvasSize = UDim2.new(0,0,0,140)

-- MISC
makeToggle(tabMisc,4,"AutoCoin",function(v) Config.AutoCoin=v end)
makeToggle(tabMisc,32,"FreezeAll",function(v) Config.FreezeAll=v; if ApplyFreezeAll then ApplyFreezeAll(v) end end)
makeToggle(tabMisc,60,"AutoTP Revolver",function(v) Config.AutoTPRevolver=v end)
makeToggle(tabMisc,88,"Noclip",function(v) Config.Noclip=v; SetNoclip(v) end)
makeToggle(tabMisc,116,"InfiniteJump",function(v) Config.InfiniteJump=v end)
makeToggle(tabMisc,144,"Invisible",function(v) Config.Invisible=v; SetInvisible(v) end)
makeButton(tabMisc,176,"TP to Gun",function() if TeleportToGun then TeleportToGun() end end)
makeButton(tabMisc,204,"TP to Coin",function() if TeleportToCoin then TeleportToCoin() end end)
makeButton(tabMisc,232,"TP to Revolver",function() if TeleportToRevolver then TeleportToRevolver() end end)
makeButton(tabMisc,260,"Cleanup GUIs",function() CleanupOldGUIs() end)
tabMisc.CanvasSize = UDim2.new(0,0,0,295)

-- PULL (по ролям)
local pullRoleBtn = Instance.new("TextButton")
pullRoleBtn.Size = UDim2.new(1,-8,0,24)
pullRoleBtn.Position = UDim2.new(0,4,0,4)
pullRoleBtn.BackgroundColor3 = Color3.fromRGB(40,40,50)
pullRoleBtn.Text = "Pull Role: All"
pullRoleBtn.TextColor3 = Color3.fromRGB(200,200,200)
pullRoleBtn.Font = Enum.Font.GothamBold
pullRoleBtn.TextSize = 10
pullRoleBtn.BorderSizePixel = 0
pullRoleBtn.AutoButtonColor = false
pullRoleBtn.Parent = tabPull
Instance.new("UICorner", pullRoleBtn).CornerRadius = UDim.new(0,5)
local pullRoleOrder = {"All","Murderer","Sheriff","Innocent"}
local pullRoleIdx = 1
pullRoleBtn.MouseButton1Click:Connect(function()
    pullRoleIdx = (pullRoleIdx % #pullRoleOrder) + 1
    Config.PullRole = pullRoleOrder[pullRoleIdx]
    pullRoleBtn.Text = "Pull Role: "..Config.PullRole
    pullRoleBtn.TextColor3 = Config.PullRole == "All" and Color3.fromRGB(200,200,200) or RoleColors[Config.PullRole]
end)
local isBringing = false
local bringConn = nil
local function StopBring()
    isBringing = false
    if bringConn then bringConn:Disconnect(); bringConn = nil end
end
local function StartBring()
    if isBringing then return end
    isBringing = true
    bringConn = RunService.Heartbeat:Connect(function()
        if not isBringing then return end
        local myChar = LP.Character
        if not myChar then return end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        local myCF = myRoot.CFrame
        local front = (myCF * CFrame.new(0,0,-3)).Position
        local targetCF = CFrame.new(front.X, myCF.Position.Y, front.Z)
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and IsPlayerInGame(p) then
                local role = RoleCache[p] or GetRole(p)
                if Config.PullRole == "All" or role == Config.PullRole then
                    local otherRoot = p.Character:FindFirstChild("HumanoidRootPart")
                    if otherRoot then
                        pcall(function() otherRoot.CFrame = targetCF end)
                    end
                end
            end
        end
        pcall(function() myRoot.CFrame = myCF end)
    end)
end
makeButton(tabPull,36,"Bring Players (по роли)",function() StartBring() end)
makeButton(tabPull,64,"Unbring / Stop",function() StopBring() end)
makeButton(tabPull,92,"Pull All в лобби? (осторожно)",function()
    Config.PullRole = "All"
    StartBring()
end)
tabPull.CanvasSize = UDim2.new(0,0,0,130)

-- AUTO
makeToggle(tabAuto,4,"AutoKill (ближний)",function(v) Config.AutoKill=v end)
makeToggle(tabAuto,32,"AutoWin (всех)",function(v) Config.AutoWin=v end)
tabAuto.CanvasSize = UDim2.new(0,0,0,64)
