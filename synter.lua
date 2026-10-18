-- ============================================================================
-- ZENIT MM2 // v14
-- TouchPan-скролл, AutoWin Innocent через кручение, честные ограничения
-- ============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

if not Drawing then
    pcall(function() StarterGui:SetCore("SendNotification", {Title = "Ошибка", Text = "Нет Drawing API", Duration = 5}) end)
    return
end

-- ============================================================================
-- CLEANUP
-- ============================================================================
local OUR_GUI_NAME = "ZenitMM2_v14"

local function LooksCheatGUI(obj)
    if not obj:IsA("ScreenGui") then return false end
    if obj.Name == OUR_GUI_NAME then return false end
    if obj.Name == "RobloxGui" then return false end
    local known = {"zenit","mm2","aim","esp","hub","menu","cheat","script","panel"}
    local low = obj.Name:lower()
    for _, k in ipairs(known) do if low:find(k) then return true end end
    local suspiciousTexts = {"aimbot","esp","chams","autocoin","wallcheck","autododge","teleport","freeze","noclip","silent","autowin","bang"}
    for _, child in ipairs(obj:GetDescendants()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then
            local t = (child.Text or ""):lower()
            for _, s in ipairs(suspiciousTexts) do if t:find(s) then return true end end
        end
    end
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
    pcall(function() StarterGui:SetCore("SendNotification", {Title = "Cleanup", Text = "Удалено: " .. removed, Duration = 3}) end)
    return removed
end

CleanupOldGUIs()

-- ============================================================================
-- КОНФИГ
-- ============================================================================
local Config = {
    Aimbot         = false,
    TargetRole     = "Murderer",
    ESP            = false,
    ESP_Box        = true,
    ESP_Name       = true,
    ESP_Role       = true,
    ESP_Dist       = true,
    Chams          = false,
    ChamsTransp    = 0.55,
    SilentAim      = false,
    SilentFOV      = 200,
    AutoCoin       = false,
    WallCheck      = true,
    AutoDodge      = false,
    AutoKill       = false,
    AutoWin        = false,
    FreezeAll      = false,
    AutoTPRevolver = false,
    Noclip         = false,
    InfiniteJump   = false,
    Invisible      = false,
    DodgeRadius    = 8,
    DodgeRange     = 25,
    FOV            = 150,
    Smooth         = 0
}

local RoleColors = {
    Murderer = Color3.fromRGB(255, 50, 50),
    Sheriff  = Color3.fromRGB(50, 150, 255),
    Innocent = Color3.fromRGB(50, 255, 50)
}

local GunNames = {"Gun", "Revolver", "Silver", "Knife"}

-- ============================================================================
-- TOUCHPAN СКРОЛЛ (правильный способ, работает на мобиле)
-- ============================================================================
local ActiveScroll = nil

local function AttachTouchPan(scrollFrame)
    scrollFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            ActiveScroll = scrollFrame
        end
    end)
end

UserInputService.TouchPan:Connect(function(touchPositions, totalTranslation, velocity)
    if not ActiveScroll then return end
    local maxY = math.max(0, ActiveScroll.AbsoluteCanvasSize.Y - ActiveScroll.AbsoluteSize.Y)
    if maxY <= 0 then return end
    local newY = ActiveScroll.CanvasPosition.Y - totalTranslation.Y
    ActiveScroll.CanvasPosition = Vector2.new(0, math.clamp(newY, 0, maxY))
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        -- сброс с задержкой чтобы не перебивать клики
        task.delay(0.1, function()
            ActiveScroll = nil
        end)
    end
end)

-- ============================================================================
-- КЭШ РОЛЕЙ + IsPlayerInGame
-- ============================================================================
local RoleCache = {}
local lastRoleUpdate = 0

local function hasTool(container, names)
    if not container then return false end
    for _, name in ipairs(names) do
        if container:FindFirstChild(name) then return true end
    end
    return false
end

local function GetRole(player)
    if not player or not player.Character then return "Innocent" end
    local attr = player:GetAttribute("Role")
    if attr and RoleColors[attr] then return attr end
    local backpack = player:FindFirstChild("Backpack")
    local char = player.Character
    if hasTool(backpack, {"Knife"}) or hasTool(char, {"Knife"}) then return "Murderer" end
    if hasTool(backpack, {"Gun", "Revolver", "Silver"}) or hasTool(char, {"Gun", "Revolver", "Silver"}) then return "Sheriff" end
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
    if p == LP then return false end
    if not p or not p.Character then return false end
    local char = p.Character
    if char.Parent ~= Workspace then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return false end
    if hum.Health <= 0 then return false end
    if hum:GetState() == Enum.HumanoidStateType.Dead then return false end
    local inRound = p:GetAttribute("InRound")
    if inRound == false then return false end
    local roleAttr = p:GetAttribute("Role")
    if roleAttr == "Lobby" or roleAttr == "Spectator" then return false end
    if p.Team then
        local tn = p.Team.Name:lower()
        if tn:find("lobby") or tn:find("spectat") then return false end
    end
    for _, name in ipairs({"Lobby", "LobbyZone", "LobbySpawn"}) do
        local lobby = Workspace:FindFirstChild(name)
        if lobby and hrp:IsDescendantOf(lobby) then return false end
    end
    return true
end

-- ============================================================================
-- UI
-- ============================================================================
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
toggleBtn.Size = UDim2.new(0, 40, 0, 40)
toggleBtn.Position = UDim2.new(0, 8, 0, 80)
toggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
toggleBtn.Text = "Z"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18
toggleBtn.BorderSizePixel = 0
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = gui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)
local strokeBtn = Instance.new("UIStroke", toggleBtn)
strokeBtn.Color = Color3.fromRGB(255, 0, 100)
strokeBtn.Thickness = 1.5

local START_W = 300
local START_H = 460
local MIN_W = 230
local MIN_H = 200
local MAX_W = 500
local MAX_H = 800

local menu = Instance.new("Frame")
menu.Size = UDim2.new(0, START_W, 0, 0)
menu.Position = UDim2.new(0, 8, 0, 130)
menu.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
menu.BackgroundTransparency = 0.05
menu.BorderSizePixel = 0
menu.ClipsDescendants = true
menu.Active = true
menu.Parent = gui
Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 10)
local strokeMenu = Instance.new("UIStroke", menu)
strokeMenu.Color = Color3.fromRGB(255, 0, 100)
strokeMenu.Thickness = 1.5

local title = Instance.new("TextButton")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
title.BackgroundTransparency = 0.2
title.Text = "ZENIT MM2 v14"
title.TextColor3 = Color3.fromRGB(255, 0, 100)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.BorderSizePixel = 0
title.AutoButtonColor = false
title.Active = true
title.Parent = menu
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

local resizeHandle = Instance.new("TextButton")
resizeHandle.Size = UDim2.new(0, 16, 0, 16)
resizeHandle.Position = UDim2.new(1, -18, 0, 7)
resizeHandle.BackgroundColor3 = Color3.fromRGB(255, 0, 100)
resizeHandle.Text = "◢"
resizeHandle.TextColor3 = Color3.fromRGB(255, 255, 255)
resizeHandle.Font = Enum.Font.GothamBold
resizeHandle.TextSize = 12
resizeHandle.BorderSizePixel = 0
resizeHandle.AutoButtonColor = false
resizeHandle.Parent = menu
Instance.new("UICorner", resizeHandle).CornerRadius = UDim.new(0, 4)

local tabsBar = Instance.new("Frame")
tabsBar.Size = UDim2.new(1, -16, 0, 26)
tabsBar.Position = UDim2.new(0, 8, 0, 34)
tabsBar.BackgroundTransparency = 1
tabsBar.Parent = menu

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -16, 1, -66)
tabContainer.Position = UDim2.new(0, 8, 0, 64)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = menu

local function makeScrollTab(parent)
    local s = Instance.new("ScrollingFrame")
    s.Size = UDim2.new(1, 0, 1, 0)
    s.BackgroundTransparency = 1
    s.BorderSizePixel = 0
    s.ScrollBarThickness = 5
    s.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 100)
    s.CanvasSize = UDim2.new(0, 0, 0, 500)
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
local tabAuto   = makeScrollTab(tabContainer)

local allTabs = {tabAimbot, tabESP, tabColors, tabMisc, tabAuto}
for _, t in ipairs(allTabs) do t.Visible = false; AttachTouchPan(t) end
tabAimbot.Visible = true

local tabButtons = {}
local function makeTabBtn(index, total, text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1/total, -2, 1, 0)
    b.Position = UDim2.new(index/total, 2, 0, 0)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 9
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = tabsBar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    b.MouseButton1Click:Connect(callback)
    tabButtons[text] = b
    return b
end

local function ShowTab(name)
    tabAimbot.Visible = (name == "Aim")
    tabESP.Visible    = (name == "ESP")
    tabColors.Visible = (name == "Clr")
    tabMisc.Visible   = (name == "Misc")
    tabAuto.Visible   = (name == "Auto")
    for _, b in pairs(tabButtons) do b.BackgroundColor3 = Color3.fromRGB(40, 40, 50) end
    if tabButtons[name] then tabButtons[name].BackgroundColor3 = Color3.fromRGB(255, 0, 100) end
end

makeTabBtn(0, 5, "Aim",  function() ShowTab("Aim")  end)
makeTabBtn(1, 5, "ESP",  function() ShowTab("ESP")  end)
makeTabBtn(2, 5, "Clr",  function() ShowTab("Clr")  end)
makeTabBtn(3, 5, "Misc", function() ShowTab("Misc") end)
makeTabBtn(4, 5, "Auto", function() ShowTab("Auto") end)

-- ============================================================================
-- ХЕЛПЕРЫ
-- ============================================================================
local function makeToggle(parent, yPos, text, callback, defaultState)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 24)
    btn.Position = UDim2.new(0, 4, 0, yPos)
    btn.BackgroundColor3 = defaultState and Color3.fromRGB(255, 0, 100) or Color3.fromRGB(40, 40, 50)
    btn.Text = text .. ": " .. (defaultState and "ON" or "OFF")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    local state = defaultState and true or false
    if state and callback then callback(true) end
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. ": " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(255, 0, 100) or Color3.fromRGB(40, 40, 50)
        callback(state)
    end)
end

local function makeButton(parent, yPos, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 24)
    btn.Position = UDim2.new(0, 4, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    btn.MouseButton1Click:Connect(callback)
end

local function makeSlider(parent, yLabel, yBar, labelText, min, max, default, callback)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -8, 0, 14)
    lbl.Position = UDim2.new(0, 4, 0, yLabel)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText .. ": " .. default
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -8, 0, 8)
    bar.Position = UDim2.new(0, 4, 0, yBar)
    bar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    bar.BorderSizePixel = 0
    bar.Parent = parent
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)

    local fill = Instance.new("Frame")
    local relDef = (default - min) / (max - min)
    fill.Size = UDim2.new(relDef, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 0, 100)
    fill.BorderSizePixel = 0
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

    local dragging = false
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relX = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local val = math.floor(relX * (max - min) + min)
            fill.Size = UDim2.new(relX, 0, 1, 0)
            lbl.Text = labelText .. ": " .. val
            callback(val)
        end
    end)
end

-- ============================================================================
-- ВКЛАДКА AIM
-- ============================================================================
local function makeRoleBtn(parent, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 24)
    btn.Position = UDim2.new(0, 4, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.Text = "Target: " .. Config.TargetRole
    btn.TextColor3 = RoleColors[Config.TargetRole]
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    local order = {"Murderer", "Sheriff", "Innocent"}
    local idx = 1
    btn.MouseButton1Click:Connect(function()
        idx = (idx % #order) + 1
        Config.TargetRole = order[idx]
        btn.Text = "Target: " .. Config.TargetRole
        btn.TextColor3 = RoleColors[Config.TargetRole]
    end)
end

makeToggle(tabAimbot, 4,   "Aimbot",    function(v) Config.Aimbot = v end)
makeToggle(tabAimbot, 32,  "WallCheck", function(v) Config.WallCheck = v end, true)
makeRoleBtn(tabAimbot, 60)
makeSlider(tabAimbot, 92, 108, "FOV",    50, 500, 150, function(v) Config.FOV = v end)
makeSlider(tabAimbot, 124, 140, "Smooth",  0, 100,   0, function(v) Config.Smooth = v end)
makeToggle(tabAimbot, 164, "AutoDodge",   function(v) Config.AutoDodge = v end)
makeSlider(tabAimbot, 196, 212, "DodgeRadius", 1, 30, 8,  function(v) Config.DodgeRadius = v end)
makeSlider(tabAimbot, 228, 244, "DodgeRange",  5, 60, 25, function(v) Config.DodgeRange = v end)
makeToggle(tabAimbot, 264, "SilentAim",   function(v) Config.SilentAim = v end)
makeSlider(tabAimbot, 296, 312, "SilentFOV", 50, 500, 200, function(v) Config.SilentFOV = v end)
tabAimbot.CanvasSize = UDim2.new(0, 0, 0, 340)

-- ============================================================================
-- ВКЛАДКА ESP
-- ============================================================================
makeToggle(tabESP, 4,   "ESP",          function(v) Config.ESP = v end)
makeToggle(tabESP, 32,  "Chams",        function(v) Config.Chams = v end)
makeToggle(tabESP, 60,  "ESP Box",      function(v) Config.ESP_Box = v end, true)
makeToggle(tabESP, 88,  "ESP Name",     function(v) Config.ESP_Name = v end, true)
makeToggle(tabESP, 116, "ESP Role",     function(v) Config.ESP_Role = v end, true)
makeToggle(tabESP, 144, "ESP Distance", function(v) Config.ESP_Dist = v end, true)
makeSlider(tabESP, 176, 192, "ChamsTransp", 0, 100, 55, function(v) Config.ChamsTransp = v / 100 end)
tabESP.CanvasSize = UDim2.new(0, 0, 0, 220)

-- ============================================================================
-- ВКЛАДКА ЦВЕТА
-- ============================================================================
local presetColors = {
    Color3.fromRGB(255, 50, 50), Color3.fromRGB(50, 150, 255), Color3.fromRGB(50, 255, 50),
    Color3.fromRGB(255, 200, 50), Color3.fromRGB(200, 50, 255), Color3.fromRGB(50, 255, 255),
    Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0),
}

local function makeColorRow(parent, yPos, roleName)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 70, 0, 22)
    label.Position = UDim2.new(0, 4, 0, yPos)
    label.BackgroundTransparency = 1
    label.Text = roleName .. ":"
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent

    local current = Instance.new("Frame")
    current.Size = UDim2.new(0, 22, 0, 22)
    current.Position = UDim2.new(0, 76, 0, yPos)
    current.BackgroundColor3 = RoleColors[roleName]
    current.BorderSizePixel = 0
    current.Parent = parent
    Instance.new("UICorner", current).CornerRadius = UDim.new(0, 4)

    local palette = Instance.new("Frame")
    palette.Size = UDim2.new(0, 22, 0, 0)
    palette.Position = UDim2.new(0, 76, 0, yPos + 24)
    palette.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    palette.BorderSizePixel = 0
    palette.ClipsDescendants = true
    palette.ZIndex = 5
    palette.Parent = parent
    Instance.new("UICorner", palette).CornerRadius = UDim.new(0, 4)

    for i, col in ipairs(presetColors) do
        local sw = Instance.new("TextButton")
        sw.Size = UDim2.new(0, 18, 0, 18)
        sw.Position = UDim2.new(0, 2, 0, (i - 1) * 20 + 2)
        sw.BackgroundColor3 = col
        sw.Text = ""
        sw.BorderSizePixel = 0
        sw.AutoButtonColor = false
        sw.ZIndex = 6
        sw.Parent = palette
        Instance.new("UICorner", sw).CornerRadius = UDim.new(0, 3)
        sw.MouseButton1Click:Connect(function()
            RoleColors[roleName] = col
            current.BackgroundColor3 = col
            palette.Size = UDim2.new(0, 22, 0, 0)
        end)
    end

    current.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if palette.Size.Y.Offset > 0 then
                palette.Size = UDim2.new(0, 22, 0, 0)
            else
                palette.Size = UDim2.new(0, 22, 0, #presetColors * 20 + 4)
            end
        end
    end)
end

local colorLbl = Instance.new("TextLabel")
colorLbl.Size = UDim2.new(1, -8, 0, 20)
colorLbl.Position = UDim2.new(0, 4, 0, 0)
colorLbl.BackgroundTransparency = 1
colorLbl.Text = "Цвета ролей (тап на квадрат)"
colorLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
colorLbl.Font = Enum.Font.GothamBold
colorLbl.TextSize = 10
colorLbl.TextXAlignment = Enum.TextXAlignment.Left
colorLbl.Parent = tabColors

makeColorRow(tabColors, 26, "Murderer")
makeColorRow(tabColors, 56, "Sheriff")
makeColorRow(tabColors, 86, "Innocent")
tabColors.CanvasSize = UDim2.new(0, 0, 0, 140)

-- ============================================================================
-- ВКЛАДКА MISC
-- ============================================================================
makeToggle(tabMisc, 4,   "AutoCoin",       function(v) Config.AutoCoin = v end)
makeToggle(tabMisc, 32,  "FreezeAll",      function(v) Config.FreezeAll = v; if ApplyFreezeAll then ApplyFreezeAll(v) end end)
makeToggle(tabMisc, 60,  "AutoTP Revolver",function(v) Config.AutoTPRevolver = v end)
makeToggle(tabMisc, 88,  "Noclip",         function(v) Config.Noclip = v; SetNoclip(v) end)
makeToggle(tabMisc, 116, "InfiniteJump",   function(v) Config.InfiniteJump = v end)
makeToggle(tabMisc, 144, "Invisible",      function(v) Config.Invisible = v; SetInvisible(v) end)
makeButton(tabMisc, 176, "TP to Gun",      function() if TeleportToGun then TeleportToGun() end end)
makeButton(tabMisc, 204, "TP to Coin",     function() if TeleportToCoin then TeleportToCoin() end end)
makeButton(tabMisc, 232, "TP to Revolver", function() if TeleportToRevolver then TeleportToRevolver() end end)
makeButton(tabMisc, 260, "Bang (TP + cam)",function() BangToNearest() end)
makeButton(tabMisc, 288, "Cleanup GUIs",   function() CleanupOldGUIs() end)
tabMisc.CanvasSize = UDim2.new(0, 0, 0, 320)

-- ============================================================================
-- ВКЛАДКА AUTO
-- ============================================================================
makeToggle(tabAuto, 4,   "AutoKill (ближний)", function(v) Config.AutoKill = v end)
makeToggle(tabAuto, 32,  "AutoWin (всех)",     function(v) Config.AutoWin = v end)
tabAuto.CanvasSize = UDim2.new(0, 0, 0, 64)

-- ============================================================================
-- DRAG / RESIZE / Z
-- ============================================================================
local menuDragging = false
local menuDragStart, menuStartPos

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        menuDragging = true; menuDragStart = input.Position; menuStartPos = menu.Position
    end
end)

local resizing = false
local resizeStart, resizeStartSize
resizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        resizing = true; resizeStart = input.Position; resizeStartSize = menu.AbsoluteSize
    end
end)

local btnDragging = false
local btnWasDragged = false
local btnDragStart, btnStartPos
toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        btnDragging = true; btnWasDragged = false
        btnDragStart = input.Position; btnStartPos = toggleBtn.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local delta
        if menuDragging and menuDragStart and menuStartPos then
            delta = input.Position - menuDragStart
            menu.Position = UDim2.new(menuStartPos.X.Scale, menuStartPos.X.Offset + delta.X, menuStartPos.Y.Scale, menuStartPos.Y.Offset + delta.Y)
        end
        if resizing and resizeStart then
            delta = input.Position - resizeStart
            local newW = math.clamp(resizeStartSize.X + delta.X, MIN_W, MAX_W)
            local newH = math.clamp(resizeStartSize.Y + delta.Y, MIN_H, MAX_H)
            menu.Size = UDim2.new(0, newW, 0, newH)
        end
        if btnDragging and btnDragStart and btnStartPos then
            delta = input.Position - btnDragStart
            if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then btnWasDragged = true end
            toggleBtn.Position = UDim2.new(btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X, btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if btnDragging and not btnWasDragged then
            local open = menu.Size.Y.Offset > 0
            TweenService:Create(menu, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = open and UDim2.new(0, START_W, 0, 0) or UDim2.new(0, START_W, 0, START_H)
            }):Play()
        end
        menuDragging = false; menuDragStart = nil; menuStartPos = nil
        resizing = false; resizeStart = nil
        btnDragging = false; btnDragStart = nil; btnStartPos = nil
    end
end)

-- ============================================================================
-- NOCLIP / INVISIBLE / INFJUMP
-- ============================================================================
local noclipConn = nil
function SetNoclip(state)
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    if not state then
        local char = LP.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then pcall(function() part.CanCollide = true end) end
            end
        end
        return
    end
    noclipConn = RunService.Stepped:Connect(function()
        local char = LP.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then pcall(function() part.CanCollide = false end) end
            end
        end
    end)
end

local invisConn = nil
local invisOriginalTransp = {}
local invisOriginalName = nil
local invisOriginalHealth = nil

function SetInvisible(state)
    if invisConn then invisConn:Disconnect(); invisConn = nil end
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not state then
        for part, orig in pairs(invisOriginalTransp) do
            if part and part.Parent then pcall(function() part.Transparency = orig end) end
        end
        invisOriginalTransp = {}
        if hum and invisOriginalName then pcall(function() hum.DisplayDistanceType = invisOriginalName end) end
        if hum and invisOriginalHealth then pcall(function() hum.HealthDisplayType = invisOriginalHealth end) end
        invisOriginalName = nil; invisOriginalHealth = nil
        return
    end
    if hum then
        invisOriginalName = hum.DisplayDistanceType
        invisOriginalHealth = hum.HealthDisplayType
        pcall(function()
            hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
        end)
    end
    invisConn = RunService.Stepped:Connect(function()
        local c = LP.Character
        if not c then return end
        for _, part in ipairs(c:GetDescendants()) do
            if part:IsA("BasePart") then
                if invisOriginalTransp[part] == nil then invisOriginalTransp[part] = part.Transparency end
                pcall(function() part.Transparency = 1; part.LocalTransparencyModifier = 1 end)
            elseif part:IsA("Decal") or part:IsA("Texture") then
                if invisOriginalTransp[part] == nil then invisOriginalTransp[part] = part.Transparency end
                pcall(function() part.Transparency = 1 end)
            end
        end
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then
            pcall(function()
                h.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                h.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
            end)
        end
    end)
end

UserInputService.JumpRequest:Connect(function()
    if not Config.InfiniteJump then return end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
end)

-- ============================================================================
-- SILENT AIM
-- ============================================================================
local function GetSilentTarget()
    local center = Camera.ViewportSize / 2
    local closest, dist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if IsPlayerInGame(p) then
            local role = RoleCache[p] or GetRole(p)
            if role == Config.TargetRole then
                local head = p.Character:FindFirstChild("Head")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if head and hum and hum.Health > 0 then
                    local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if mag <= Config.SilentFOV and mag < dist then dist = mag; closest = head end
                    end
                end
            end
        end
    end
    return closest
end

pcall(function()
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        if not Config.SilentAim then return oldIndex(self, key) end
        if self == game:GetService("Mouse") then
            if key == "Hit" then
                local target = GetSilentTarget()
                if target then return CFrame.new(target.Position) end
            elseif key == "UnitRay" then
                local target = GetSilentTarget()
                if target then return Ray.new(Camera.CFrame.Position, (target.Position - Camera.CFrame.Position).Unit * 1000) end
            end
        end
        return oldIndex(self, key)
    end)
end)

-- ============================================================================
-- FOV + ESP + CHAMS
-- ============================================================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1; FOVCircle.NumSides = 40; FOVCircle.Filled = false
FOVCircle.Radius = Config.FOV; FOVCircle.Color = RoleColors.Murderer; FOVCircle.Visible = false

local SilentFOVCircle = Drawing.new("Circle")
SilentFOVCircle.Thickness = 1; SilentFOVCircle.NumSides = 40; SilentFOVCircle.Filled = false
SilentFOVCircle.Radius = Config.SilentFOV; SilentFOVCircle.Color = Color3.fromRGB(255, 200, 50); SilentFOVCircle.Visible = false

local ESP = {}
local Chams = {}

local function CreateESP(plr)
    if plr == LP then return end
    local d = { Box = Drawing.new("Square"), Text = Drawing.new("Text") }
    d.Box.Visible = false; d.Box.Thickness = 1; d.Box.Filled = false
    d.Text.Visible = false; d.Text.Center = true; d.Text.Outline = true; d.Text.Size = 12
    d.Text.Color = Color3.fromRGB(255, 255, 255)
    ESP[plr] = d
end

for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(function(p) CreateESP(p) end)
Players.PlayerRemoving:Connect(function(p)
    if ESP[p] then
        pcall(function() ESP[p].Box:Remove() end)
        pcall(function() ESP[p].Text:Remove() end)
        ESP[p] = nil
    end
    RoleCache[p] = nil
    if Chams[p] then pcall(function() Chams[p]:Destroy() end); Chams[p] = nil end
end)

local function ApplyChams(plr, role)
    if plr == LP or not plr.Character then return end
    local hl = Chams[plr]
    if not hl or hl.Parent ~= plr.Character then
        if hl then pcall(function() hl:Destroy() end) end
        hl = Instance.new("Highlight")
        hl.Name = "ZenitChams"
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = plr.Character
        Chams[plr] = hl
    end
    local color = RoleColors[role] or RoleColors.Innocent
    hl.FillTransparency = Config.ChamsTransp
    hl.FillColor = color; hl.OutlineColor = color
end

local function RemoveChams(plr)
    local hl = Chams[plr]
    if hl then pcall(function() hl:Destroy() end); Chams[plr] = nil end
end

-- ============================================================================
-- МОНЕТЫ
-- ============================================================================
local CoinCache = {}
local lastCoinCache = 0
local function RefreshCoinCache()
    CoinCache = {}
    local seen = {}
    local function add(obj)
        if obj and not seen[obj] and (obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("Tool")) then
            seen[obj] = true; table.insert(CoinCache, obj)
        end
    end
    local folder = Workspace:FindFirstChild("Coins")
    if folder then for _, c in ipairs(folder:GetChildren()) do add(c) end end
    for _, c in ipairs(Workspace:GetChildren()) do
        local n = c.Name:lower()
        if n == "coin" or n:find("coin") then add(c) end
    end
    lastCoinCache = tick()
end

local function CollectCoinFast()
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum or myHum.Health <= 0 then return end
    if #CoinCache == 0 or (tick() - lastCoinCache) > 1 then RefreshCoinCache() end
    local nearest, nearDist = nil, math.huge
    for _, c in ipairs(CoinCache) do
        if c and c.Parent then
            local d = (c.Position - myHRP.Position).Magnitude
            if d < nearDist then nearDist = d; nearest = c end
        end
    end
    if not nearest then return end
    pcall(function() myHRP.CFrame = CFrame.new(nearest.Position + Vector3.new(0, 3, 0)) end)
end

-- ============================================================================
-- TP / BANG
-- ============================================================================
function TeleportToCoin()
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    RefreshCoinCache()
    local nearest, nearDist = nil, math.huge
    for _, c in ipairs(CoinCache) do
        if c and c.Parent then
            local d = (c.Position - myHRP.Position).Magnitude
            if d < nearDist then nearDist = d; nearest = c end
        end
    end
    if nearest then pcall(function() myHRP.CFrame = CFrame.new(nearest.Position + Vector3.new(0, 3, 0)) end) end
end

local function FindWeaponPos(names, fromPos)
    local candidates = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Tool") then
            for _, name in ipairs(names) do if obj.Name == name then table.insert(candidates, obj); break end end
        end
    end
    local nearest, nearDist = nil, math.huge
    for _, obj in ipairs(candidates) do
        local pos
        if obj:IsA("Tool") and obj:FindFirstChild("Handle") then pos = obj.Handle.Position end
        if pos then
            local d = (pos - fromPos).Magnitude
            if d < nearDist then nearDist = d; nearest = pos end
        end
    end
    return nearest
end

function TeleportToGun()
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    local pos = FindWeaponPos(GunNames, myHRP.Position)
    if pos then pcall(function() myHRP.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)) end) end
end

function TeleportToRevolver()
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    local pos = FindWeaponPos({"Revolver", "Gun", "Silver"}, myHRP.Position)
    if pos then pcall(function() myHRP.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)) end) end
end

function BangToNearest()
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    local nearest, nearDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if IsPlayerInGame(p) then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local d = (hrp.Position - myHRP.Position).Magnitude
                if d < nearDist then nearDist = d; nearest = hrp end
            end
        end
    end
    if nearest then
        pcall(function()
            myHRP.CFrame = nearest.CFrame * CFrame.new(0, 0, -1.5)
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, nearest.Position)
        end)
    end
end

-- ============================================================================
-- FREEZE
-- ============================================================================
local frozenPlayers = {}
function ApplyFreezeAll(state)
    if not state then
        for p, data in pairs(frozenPlayers) do
            if p.Character then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hum then pcall(function() hum.WalkSpeed = data.walk; hum.JumpPower = data.jump end) end
                if hrp then pcall(function() hrp.Anchored = false end) end
            end
        end
        frozenPlayers = {}
        return
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and IsPlayerInGame(p) then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp then
                frozenPlayers[p] = {walk = hum.WalkSpeed, jump = hum.JumpPower}
                pcall(function() hum.WalkSpeed = 0; hum.JumpPower = 0; hrp.Anchored = true end)
            end
        end
    end
end

-- ============================================================================
-- AUTOKILL
-- ============================================================================
local lastKill = 0
local function TryAutoKill()
    local now = tick()
    if now - lastKill < 0.8 then return end
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum or myHum.Health <= 0 then return end
    local knife = myChar:FindFirstChild("Knife")
    if not knife then
        local bp = LP:FindFirstChild("Backpack")
        if bp then knife = bp:FindFirstChild("Knife") end
    end
    if not knife then return end
    local target, targetDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if IsPlayerInGame(p) then
            local role = RoleCache[p] or GetRole(p)
            if role ~= "Murderer" then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local d = (hrp.Position - myHRP.Position).Magnitude
                    if d < targetDist then targetDist = d; target = hrp end
                end
            end
        end
    end
    if not target then return end
    pcall(function()
        myHRP.CFrame = target.CFrame * CFrame.new(0, 0, 2.5)
        if knife.Parent ~= myChar then knife.Parent = myChar end
        task.wait(0.08)
        if knife.Activate then knife:Activate() end
        if knife:FindFirstChild("Activated") then knife:Activated() end
    end)
    lastKill = now
end

-- ============================================================================
-- AUTOWIN
-- Sheriff: silent aim + Activate
-- Murderer: TP + knife
-- Innocent: КРУЧЕНИЕ вокруг убийцы (реальный выкид невозможен из клиента)
-- ============================================================================
local lastWinTick = 0
local WIN_COOLDOWN = 0.3
local spinAngle = 0

local function GetMyRole()
    local myChar = LP.Character
    if not myChar then return "Innocent" end
    local bp = LP:FindFirstChild("Backpack")
    if hasTool(myChar, {"Knife"}) or hasTool(bp, {"Knife"}) then return "Murderer" end
    if hasTool(myChar, {"Gun", "Revolver", "Silver"}) or hasTool(bp, {"Gun", "Revolver", "Silver"}) then return "Sheriff" end
    local attr = LP:GetAttribute("Role")
    if attr then return attr end
    return "Innocent"
end

local function TryAutoWin()
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum or myHum.Health <= 0 then return end

    local myRole = GetMyRole()

    if myRole == "Sheriff" then
        for _, p in ipairs(Players:GetPlayers()) do
            if IsPlayerInGame(p) then
                local role = RoleCache[p] or GetRole(p)
                if role == "Murderer" then
                    local head = p.Character:FindFirstChild("Head")
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if head and hum and hum.Health > 0 then
                        pcall(function()
                            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, head.Position)
                            local gun = myChar:FindFirstChild("Gun") or myChar:FindFirstChild("Revolver") or myChar:FindFirstChild("Silver")
                            if not gun then
                                local bp = LP:FindFirstChild("Backpack")
                                if bp then
                                    gun = bp:FindFirstChild("Gun") or bp:FindFirstChild("Revolver") or bp:FindFirstChild("Silver")
                                    if gun then gun.Parent = myChar end
                                end
                            end
                            if gun then
                                if gun.Activate then gun:Activate() end
                                if gun:FindFirstChild("Activated") then gun:Activated() end
                            end
                        end)
                        return
                    end
                end
            end
        end

    elseif myRole == "Murderer" then
        local target, targetDist = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if IsPlayerInGame(p) then
                local role = RoleCache[p] or GetRole(p)
                if role ~= "Murderer" then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        local d = (hrp.Position - myHRP.Position).Magnitude
                        if d < targetDist then targetDist = d; target = hrp end
                    end
                end
            end
        end
        if not target then return end
        local knife = myChar:FindFirstChild("Knife")
        if not knife then
            local bp = LP:FindFirstChild("Backpack")
            if bp then knife = bp:FindFirstChild("Knife") end
        end
        pcall(function()
            myHRP.CFrame = target.CFrame * CFrame.new(0, 0, 2.5)
            if knife then
                if knife.Parent ~= myChar then knife.Parent = myChar end
                task.wait(0.08)
                if knife.Activate then knife:Activate() end
                if knife:FindFirstChild("Activated") then knife:Activated() end
            end
        end)

    else
        -- INNOCENT: крутимся вокруг убийцы, спамим любой Tool + Velocity вниз
        local murderer, murdererDist = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if IsPlayerInGame(p) then
                local role = RoleCache[p] or GetRole(p)
                if role == "Murderer" then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        local d = (hrp.Position - myHRP.Position).Magnitude
                        if d < murdererDist then murdererDist = d; murderer = hrp end
                    end
                end
            end
        end
        if murderer then
            spinAngle = spinAngle + 0.6
            local offset = CFrame.Angles(0, spinAngle, 0) * CFrame.new(0, 0, -2)
            pcall(function()
                myHRP.CFrame = murderer.CFrame * offset
            end)
            -- пробуем выкинуть через Velocity (сработает если сервер отдал ownership)
            pcall(function()
                local mhrp = murderer
                mhrp.Velocity = Vector3.new(0, -5000, 0)
                mhrp.AssemblyLinearVelocity = Vector3.new(0, -5000, 0)
            end)
            -- активируем любой Tool
            pcall(function()
                for _, t in ipairs(myChar:GetChildren()) do
                    if t:IsA("Tool") then
                        if t.Activate then t:Activate() end
                    end
                end
            end)
        end
    end
end

-- ============================================================================
-- AUTODODGE
-- ============================================================================
local lastDodge = 0
local function FindSafeSpot(fromPos, murdererPos, range)
    local myChar = LP.Character
    local best, bestDist = nil, -1
    for i = 1, 24 do
        local angle = math.random() * math.pi * 2
        local dist = range * (0.6 + math.random() * 0.4)
        local offset = Vector3.new(math.cos(angle) * dist, 0, math.sin(angle) * dist)
        local probe = fromPos + offset
        if (probe - murdererPos).Magnitude < 6 then continue end
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {myChar}
        params.IgnoreWater = true
        local downResult = Workspace:Raycast(probe + Vector3.new(0, 2, 0), Vector3.new(0, -10, 0), params)
        local upResult = Workspace:Raycast(probe + Vector3.new(0, 1, 0), Vector3.new(0, 6, 0), params)
        if downResult and not upResult then
            if math.abs(downResult.Position.Y - fromPos.Y) <= 6 then
                local nd = (probe - murdererPos).Magnitude
                if nd > bestDist then bestDist = nd; best = downResult.Position + Vector3.new(0, 3, 0) end
            end
        end
    end
    return best
end

local function TryDodge()
    local now = tick()
    if now - lastDodge < 1.5 then return end
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum or myHum.Health <= 0 then return end
    local nearest, nearestDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if IsPlayerInGame(p) then
            local role = RoleCache[p] or GetRole(p)
            if role == "Murderer" then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local d = (hrp.Position - myHRP.Position).Magnitude
                    if d < nearestDist then nearestDist = d; nearest = hrp end
                end
            end
        end
    end
    if not nearest or nearestDist > Config.DodgeRadius then return end
    local safe = FindSafeSpot(myHRP.Position, nearest.Position, Config.DodgeRange)
    if safe then pcall(function() myHRP.CFrame = CFrame.new(safe) end); lastDodge = now end
end

-- ============================================================================
-- АИМБОТ
-- ============================================================================
local function IsVisible(head)
    if not Config.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local filter = {LP.Character}
    if head and head.Parent then table.insert(filter, head.Parent) end
    params.FilterDescendantsInstances = filter
    params.IgnoreWater = true
    return Workspace:Raycast(origin, head.Position - origin, params) == nil
end

local function GetTarget()
    local closest, dist = nil, math.huge
    local center = Camera.ViewportSize / 2
    for _, p in ipairs(Players:GetPlayers()) do
        if IsPlayerInGame(p) then
            local role = RoleCache[p] or GetRole(p)
            if role == Config.TargetRole then
                local head = p.Character:FindFirstChild("Head")
                local hum  = p.Character:FindFirstChildOfClass("Humanoid")
                if head and hum and hum.Health > 0 then
                    local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if mag <= Config.FOV and mag < dist and IsVisible(head) then dist = mag; closest = head end
                    end
                end
            end
        end
    end
    return closest
end

-- ============================================================================
-- ГЛАВНЫЙ ЦИКЛ
-- ============================================================================
local coinTimer, dodgeTimer, revolverTimer = 0, 0, 0

RunService.RenderStepped:Connect(function(dt)
    pcall(function()
        UpdateRoleCache()

        FOVCircle.Position = Camera.ViewportSize / 2
        FOVCircle.Radius = Config.FOV
        FOVCircle.Visible = Config.Aimbot
        FOVCircle.Color = RoleColors[Config.TargetRole]

        SilentFOVCircle.Position = Camera.ViewportSize / 2
        SilentFOVCircle.Radius = Config.SilentFOV
        SilentFOVCircle.Visible = Config.SilentAim

        if Config.Aimbot then
            local myHum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if myHum and myHum.Health > 0 then
                local target = GetTarget()
                if target then
                    local lookAt = CFrame.lookAt(Camera.CFrame.Position, target.Position)
                    if Config.Smooth <= 0 then
                        Camera.CFrame = lookAt
                    else
                        local alpha = math.clamp(1 - (Config.Smooth / 100), 0.01, 1) * math.clamp(dt * 60, 0.1, 2)
                        Camera.CFrame = Camera.CFrame:Lerp(lookAt, alpha)
                    end
                end
            end
        end

        for p, d in pairs(ESP) do
            local char = p.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if Config.ESP and IsPlayerInGame(p) and hrp and hum and hum.Health > 0 then
                local role = RoleCache[p] or "Innocent"
                local top = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.5, 0))
                local bot = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                if top.Z > 0 and bot.Z > 0 then
                    local h = math.abs(bot.Y - top.Y)
                    local w = h * 0.6
                    local x = (top.X + bot.X) / 2 - w / 2
                    local y = top.Y
                    if Config.ESP_Box then
                        d.Box.Size = Vector2.new(w, h); d.Box.Position = Vector2.new(x, y)
                        d.Box.Color = RoleColors[role]; d.Box.Visible = true
                    else d.Box.Visible = false end
                    local lines = {}
                    if Config.ESP_Name then table.insert(lines, p.Name) end
                    if Config.ESP_Role then table.insert(lines, role) end
                    if Config.ESP_Dist then
                        table.insert(lines, math.floor((Camera.CFrame.Position - hrp.Position).Magnitude) .. "m")
                    end
                    if #lines > 0 then
                        d.Text.Text = table.concat(lines, " | ")
                        d.Text.Position = Vector2.new(x + w/2, y - 26)
                        d.Text.Color = RoleColors[role]; d.Text.Visible = true
                    else d.Text.Visible = false end
                else d.Box.Visible = false; d.Text.Visible = false end
            else d.Box.Visible = false; d.Text.Visible = false end
            if Config.Chams and IsPlayerInGame(p) then
                ApplyChams(p, RoleCache[p] or "Innocent")
            else RemoveChams(p) end
        end

        if Config.AutoCoin then
            coinTimer = coinTimer + dt
            if coinTimer >= 0.05 then coinTimer = 0; CollectCoinFast() end
        end
        if Config.AutoDodge then
            dodgeTimer = dodgeTimer + dt
            if dodgeTimer >= 0.1 then d
