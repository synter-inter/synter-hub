-- [[ HALLOWEEN HUB - PART 1/3 ]] --
if getgenv().HalloweenHubLoaded then return end
getgenv().HalloweenHubLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Звук
local ClickSound = Instance.new("Sound", SoundService)
ClickSound.SoundId = "rbxassetid://12221967"
ClickSound.Volume = 0.5
_G.PlayClick = function()
    local s = ClickSound:Clone(); s.Parent = SoundService; s:Play(); game:GetService("Debris"):AddItem(s, 1)
end

-- Глобальные настройки
_G.HH = _G.HH or {
    Settings = {
        SheriffESP = {Enabled = false}, MurdererESP = {Enabled = false},
        Aimbot = {Enabled = false, FOV = 120, AutoFire = false},
        SilentAim = {Enabled = false, FOV = 120},
        KnifeAimbot = {Enabled = false, FOV = 60, AutoStab = false},
        Fly = {Enabled = false, Speed = 50}, NoClip = {Enabled = false},
        AutoCollectCoins = {Enabled = false, Range = 30}, NukeAll = {Enabled = false}
    },
    Connections = {}, ESPObjects = {}, FOVCircle = nil,
    Pages = {}, TabButtons = {} -- ВАЖНО: Сохраняем сюда!
}
getgenv().OldPos = nil; getgenv().FPDH = workspace.FallenPartsDestroyHeight

-- UI
local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "HalloweenHub"; ScreenGui.ResetOnSpawn = false; ScreenGui.Parent = game:GetService("CoreGui")
local ToggleBtn = Instance.new("TextButton"); ToggleBtn.Size = UDim2.new(0, 50, 0, 50); ToggleBtn.Position = UDim2.new(0, 10, 0, 100); ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 10, 30); ToggleBtn.Text = "🎃"; ToggleBtn.TextSize = 30; ToggleBtn.BorderSizePixel = 0; ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 15); local TS = Instance.new("UIStroke", ToggleBtn); TS.Color = Color3.fromRGB(255, 100, 0); TS.Thickness = 2

local MainFrame = Instance.new("Frame"); MainFrame.Size = UDim2.new(0, 320, 0, 380); MainFrame.Position = UDim2.new(0.5, -160, 0.5, -190); MainFrame.BackgroundColor3 = Color3.fromRGB(20, 10, 30); MainFrame.BackgroundTransparency = 0.1; MainFrame.BorderSizePixel = 0; MainFrame.Active = true; MainFrame.Visible = false; MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16); local MS = Instance.new("UIStroke", MainFrame); MS.Color = Color3.fromRGB(255, 100, 0); MS.Thickness = 2

local TitleBar = Instance.new("Frame"); TitleBar.Size = UDim2.new(1, 0, 0, 35); TitleBar.BackgroundColor3 = Color3.fromRGB(30, 15, 40); TitleBar.BorderSizePixel = 0; TitleBar.Active = true; TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 16)
local Title = Instance.new("TextLabel"); Title.Size = UDim2.new(1, -40, 1, 0); Title.Position = UDim2.new(0, 10, 0, 0); Title.BackgroundTransparency = 1; Title.Text = " HALLOWEEN HUB"; Title.TextColor3 = Color3.fromRGB(255, 100, 0); Title.Font = Enum.Font.GothamBlack; Title.TextSize = 14; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.Parent = TitleBar
local CloseBtn = Instance.new("TextButton"); CloseBtn.Size = UDim2.new(0, 25, 0, 25); CloseBtn.Position = UDim2.new(1, -30, 0, 5); CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50); CloseBtn.Text = "X"; CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255); CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 12; CloseBtn.BorderSizePixel = 0; CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

local TabScroll = Instance.new("ScrollingFrame"); TabScroll.Size = UDim2.new(1, -20, 0, 30); TabScroll.Position = UDim2.new(0, 10, 0, 45); TabScroll.BackgroundTransparency = 1; TabScroll.ScrollBarThickness = 0; TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0); TabScroll.AutomaticCanvasSize = Enum.AutomaticSize.X; TabScroll.ScrollingDirection = Enum.ScrollingDirection.X; TabScroll.Parent = MainFrame
Instance.new("UIListLayout", TabScroll).FillDirection = Enum.FillDirection.Horizontal; TabScroll:FindFirstChildOfClass("UIListLayout").Padding = UDim.new(0, 5)

local ContentFrame = Instance.new("Frame"); ContentFrame.Size = UDim2.new(1, -20, 1, -80); ContentFrame.Position = UDim2.new(0, 10, 0, 80); ContentFrame.BackgroundTransparency = 1; ContentFrame.Parent = MainFrame

local CurrentTab = nil
local function CreateTab(name, index)
    local Btn = Instance.new("TextButton"); Btn.Size = UDim2.new(0, 75, 0, 26); Btn.BackgroundColor3 = Color3.fromRGB(35, 15, 45); Btn.Text = name; Btn.TextColor3 = Color3.fromRGB(200, 200, 200); Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 11; Btn.BorderSizePixel = 0; Btn.Parent = TabScroll
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    local Page = Instance.new("Frame"); Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = false; Page.Parent = ContentFrame
    Btn.MouseButton1Click:Connect(function()
        _G.PlayClick()
        if CurrentTab then TweenService:Create(CurrentTab, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 15, 45), TextColor3 = Color3.fromRGB(200, 200, 200)}):Play(); _G.HH.Pages[CurrentTab].Visible = false end
        CurrentTab = name; TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 100, 0), TextColor3 = Color3.fromRGB(0, 0, 0)}):Play(); _G.HH.Pages[name].Visible = true
    end)
    _G.HH.Pages[name] = Page; _G.HH.TabButtons[name] = Btn
end
CreateTab("ESP", 1); CreateTab("Combat", 2); CreateTab("Move", 3); CreateTab("Misc", 4); CreateTab("Troll", 5)
if _G.HH.TabButtons["ESP"] then CurrentTab = "ESP"; _G.HH.TabButtons["ESP"].BackgroundColor3 = Color3.fromRGB(255, 100, 0); _G.HH.TabButtons["ESP"].TextColor3 = Color3.fromRGB(0, 0, 0); _G.HH.Pages["ESP"].Visible = true end

-- Хелперы UI
_G.HH.CreateSection = function(parent, name)
    local sec = Instance.new("Frame"); sec.Size = UDim2.new(1, 0, 0, 20); sec.BackgroundTransparency = 1; sec.Parent = parent
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, 0, 1, 0); lbl.BackgroundTransparency = 1; lbl.Text = name; lbl.TextColor3 = Color3.fromRGB(255, 100, 0); lbl.TextSize = 12; lbl.Font = Enum.Font.GothamBold; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = sec
end

_G.HH.CreateToggle = function(parent, settings, name, callback)
    local frm = Instance.new("Frame"); frm.Size = UDim2.new(1, 0, 0, 30); frm.BackgroundColor3 = Color3.fromRGB(35, 15, 45); frm.BorderSizePixel = 0; frm.Parent = parent
    Instance.new("UICorner", frm).CornerRadius = UDim.new(0, 6)
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(0.6, 0, 1, 0); lbl.Position = UDim2.new(0, 8, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = name; lbl.TextColor3 = Color3.fromRGB(255, 255, 255); lbl.TextSize = 11; lbl.Font = Enum.Font.Gotham; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = frm
    local bg = Instance.new("Frame"); bg.Size = UDim2.new(0, 30, 0, 16); bg.Position = UDim2.new(1, -38, 0.5, -8); bg.BackgroundColor3 = Color3.fromRGB(50, 50, 50); bg.BorderSizePixel = 0; bg.Parent = frm
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    local dot = Instance.new("Frame"); dot.Size = UDim2.new(0, 12, 0, 12); dot.Position = UDim2.new(0, 2, 0.5, -6); dot.BackgroundColor3 = Color3.fromRGB(200, 200, 200); dot.BorderSizePixel = 0; dot.Parent = bg
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    local enabled = settings.Enabled or false
    local function update()
        if enabled then bg.BackgroundColor3 = Color3.fromRGB(255, 100, 0); TweenService:Create(dot, TweenInfo.new(0.2), {Position = UDim2.new(0, 16, 0.5, -6)}):Play()
        else bg.BackgroundColor3 = Color3.fromRGB(50, 50, 50); TweenService:Create(dot, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -6)}):Play() end
    end
    update()
    bg.MouseButton1Click:Connect(function() _G.PlayClick(); enabled = not enabled; settings.Enabled = enabled; update(); if callback then callback(enabled) end end)
end

_G.HH.CreateSlider = function(parent, settings, name, min, max, default, callback)
    settings.Value = default
    local frm = Instance.new("Frame"); frm.Size = UDim2.new(1, 0, 0, 45); frm.BackgroundColor3 = Color3.fromRGB(35, 15, 45); frm.BorderSizePixel = 0; frm.Parent = parent
    Instance.new("UICorner", frm).CornerRadius = UDim.new(0, 6)
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -12, 0, 16); lbl.Position = UDim2.new(0, 8, 0, 4); lbl.BackgroundTransparency = 1; lbl.Text = name .. ": " .. default; lbl.TextColor3 = Color3.fromRGB(255, 255, 255); lbl.TextSize = 10; lbl.Font = Enum.Font.Gotham; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = frm
    local sbg = Instance.new("Frame"); sbg.Size = UDim2.new(1, -16, 0, 6); sbg.Position = UDim2.new(0, 8, 0, 25); sbg.BackgroundColor3 = Color3.fromRGB(50, 50, 50); sbg.BorderSizePixel = 0; sbg.Parent = frm
    Instance.new("UICorner", sbg).CornerRadius = UDim.new(1, 0)
    local fill = Instance.new("Frame"); fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(255, 100, 0); fill.BorderSizePixel = 0; fill.Parent = sbg
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local dragging = false
    local function updateSlider(input)
        local px = input.Position.X; local sp = sbg.AbsolutePosition; local ss = sbg.AbsoluteSize
        local rx = math.clamp(px - sp.X, 0, ss.X); local pct = rx / ss.X; local val = math.floor(min + (max-min)*pct)
        settings.Value = val; fill.Size = UDim2.new(pct, 0, 1, 0); lbl.Text = name .. ": " .. val
        if callback then callback(val) end
    end
    sbg.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; updateSlider(input) end end)
    sbg.InputEnded:Connect(function() dragging = false end)
    UserInputService.TouchMoved:Connect(function(input) if dragging then updateSlider(input) end end)
end

-- Логика
local function FindSheriff()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            for _, c in pairs(plr.Character:GetChildren()) do if c:IsA("Tool") and (c.Name:lower():find("gun") or c.Name:lower():find("pistol")) then return plr end end
        end
        if plr ~= LocalPlayer and plr.Backpack then
            for _, t in pairs(plr.Backpack:GetChildren()) do if t:IsA("Tool") and (t.Name:lower():find("gun") or t.Name:lower():find("pistol")) then return plr end end
        end
    end
    return nil
end
local function FindMurderer()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            for _, c in pairs(plr.Character:GetChildren()) do if c:IsA("Tool") and (c.Name:lower():find("knife") or c.Name:lower():find("dagger")) then return plr end end
        end
        if plr ~= LocalPlayer and plr.Backpack then
            for _, t in pairs(plr.Backpack:GetChildren()) do if t:IsA("Tool") and (t.Name:lower():find("knife") or t.Name:lower():find("dagger")) then return plr end end
        end
    end
    return nil
end
local function HighlightRole(player, color)
    if player and player.Character then
        local existing = player.Character:FindFirstChild("HalloweenRoleHL")
        if existing then existing:Destroy() end
        local hl = Instance.new("Highlight"); hl.Name = "HalloweenRoleHL"; hl.FillColor = color; hl.FillTransparency = 0.3; hl.OutlineColor = Color3.fromRGB(255, 255, 255); hl.OutlineTransparency = 0; hl.Parent = player.Character
        table.insert(_G.HH.ESPObjects, hl)
    end
end
local function CreateRoleESP()
    for _, obj in pairs(_G.HH.ESPObjects) do if typeof(obj) == "Instance" and obj.Name == "HalloweenRoleHL" then pcall(function() obj:Destroy() end) end end
    if _G.HH.Settings.SheriffESP.Enabled then local s = FindSheriff(); if s then HighlightRole(s, Color3.fromRGB(0, 150, 255)) end end
    if _G.HH.Settings.MurdererESP.Enabled then local m = FindMurderer(); if m then HighlightRole(m, Color3.fromRGB(255, 50, 50)) end end
end

-- Вкладка ESP
_G.HH.CreateSection(_G.HH.Pages["ESP"], "Role ESP")
_G.HH.CreateToggle(_G.HH.Pages["ESP"], _G.HH.Settings.SheriffESP, "Sheriff ESP (Blue)", CreateRoleESP)
_G.HH.CreateToggle(_G.HH.Pages["ESP"], _G.HH.Settings.MurdererESP, "Murderer ESP (Red)", CreateRoleESP)

-- Вкладка Move
_G.HH.CreateSection(_G.HH.Pages["Move"], "Movement")
_G.HH.CreateToggle(_G.HH.Pages["Move"], _G.HH.Settings.Fly, "Fly", function(on)
    if on then
        if _G.HH.Connections.Fly then _G.HH.Connections.Fly:Disconnect() end
        local char = LocalPlayer.Character; if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart"); local hum = char:FindFirstChild("Humanoid")
        if root and hum then
            local bg = Instance.new("BodyGyro"); bg.P = 9e4; bg.maxTorque = Vector3.new(9e9, 9e9, 9e9); bg.CFrame = root.CFrame; bg.Parent = root
            local bv = Instance.new("BodyVelocity"); bv.maxForce = Vector3.new(9e9, 9e9, 9e9); bv.Parent = root
            _G.HH.Connections.Fly = RunService.RenderStepped:Connect(function()
                if not _G.HH.Settings.Fly.Enabled then bg:Destroy(); bv:Destroy(); _G.HH.Connections.Fly:Disconnect(); hum.PlatformStand = false; return end
                hum.PlatformStand = true; bv.Velocity = Camera.CFrame.LookVector * _G.HH.Settings.Fly.Speed; bg.CFrame = Camera.CFrame
            end)
        end
    else
        if _G.HH.Connections.Fly then _G.HH.Connections.Fly:Disconnect() end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.PlatformStand = false end
    end
end)
_G.HH.CreateSlider(_G.HH.Pages["Move"], _G.HH.Settings.Fly, "Fly Speed", 10, 200, 50, function(v) _G.HH.Settings.Fly.Speed = v end)
_G.HH.CreateToggle(_G.HH.Pages["Move"], _G.HH.Settings.NoClip, "NoClip", function(on)
    if on then
        if _G.HH.Connections.NC then _G.HH.Connections.NC:Disconnect() end
        _G.HH.Connections.NC = RunService.Stepped:Connect(function()
            if not _G.HH.Settings.NoClip.Enabled then return end
            if LocalPlayer.Character then for _, p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
        end)
    else if _G.HH.Connections.NC then _G.HH.Connections.NC:Disconnect() end end
end)

-- Вкладка Troll (Fling)
local FlingBtn = Instance.new("TextButton"); FlingBtn.Size = UDim2.new(1, 0, 0, 40); FlingBtn.BackgroundColor3 = Color3.fromRGB(35, 15, 45); FlingBtn.Text = "Enable Fling Menu"; FlingBtn.TextColor3 = Color3.fromRGB(255,255,255); FlingBtn.Font = Enum.Font.GothamBold; FlingBtn.TextSize = 13; FlingBtn.BorderSizePixel = 0; FlingBtn.Parent = _G.HH.Pages["Troll"]
Instance.new("UICorner", FlingBtn).CornerRadius = UDim.new(0, 8)
FlingBtn.MouseButton1Click:Connect(function() _G.PlayClick(); print("Fling Menu Activated") end)

ToggleBtn.MouseButton1Click:Connect(function() _G.PlayClick(); MainFrame.Visible = not MainFrame.Visible; if MainFrame.Visible then MainFrame.Size = UDim2.new(0,0,0,0); TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0,320,0,380)}):Play() end end)
CloseBtn.MouseButton1Click:Connect(function() _G.PlayClick(); TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)}):Play(); task.wait(0.3); MainFrame.Visible = false end)

local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = MainFrame.Position; input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end) end end)
TitleBar.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - dragStart; MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)

print("[HALLOWEEN HUB] Part 1 Loaded (UI + ESP + Move)")-- [[ HALLOWEEN HUB - PART 2/3 : COMBAT ]] --
if not _G.HH then return end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local CombatTab = _G.HH.Pages["Combat"]
if not CombatTab then return end

_G.HH.CreateSection(CombatTab, "Aimbot")
_G.HH.CreateToggle(CombatTab, _G.HH.Settings.Aimbot, "Enable Aimbot", function(on)
    if on then
        if not _G.HH.FOVCircle then local c = Drawing.new("Circle"); c.Radius = _G.HH.Settings.Aimbot.FOV; c.Color = Color3.fromRGB(255, 100, 0); c.Thickness = 1.5; c.Transparency = 0.7; c.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2); _G.HH.FOVCircle = c end
        if _G.HH.Connections.Aim then _G.HH.Connections.Aim:Disconnect() end
        _G.HH.Connections.Aim = RunService.RenderStepped:Connect(function()
            if not _G.HH.Settings.Aimbot.Enabled then if _G.HH.FOVCircle then _G.HH.FOVCircle:Remove(); _G.HH.FOVCircle = nil end return end
            local target = nil; local bestDist = _G.HH.Settings.Aimbot.FOV
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local head = player.Character:FindFirstChild("Head")
                    local hum = player.Character:FindFirstChild("Humanoid")
                    if head and hum and hum.Health > 0 then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                            if dist < bestDist then bestDist = dist; target = player end
                        end
                    end
                end
            end
            if target and target.Character then
                local aimPart = target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
                if aimPart then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimPart.Position)
                    if _G.HH.Settings.Aimbot.AutoFire then pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton1(Vector2.new()) end) end
                end
            end
        end)
    else if _G.HH.Connections.Aim then _G.HH.Connections.Aim:Disconnect() end end
end)
_G.HH.CreateSlider(CombatTab, _G.HH.Settings.Aimbot, "Aimbot FOV", 40, 400, 120, function(v) _G.HH.Settings.Aimbot.FOV = v end)
_G.HH.CreateToggle(CombatTab, _G.HH.Settings.Aimbot, "AutoFire", function(on) _G.HH.Settings.Aimbot.AutoFire = on end)

_G.HH.CreateSection(CombatTab, "Silent Aim")
_G.HH.CreateToggle(CombatTab, _G.HH.Settings.SilentAim, "Silent Aim", function(on) _G.HH.Settings.SilentAim.Enabled = on end)
_G.HH.CreateSlider(CombatTab, _G.HH.Settings.SilentAim, "Silent FOV", 40, 400, 120, function(v) _G.HH.Settings.SilentAim.FOV = v end)

print("[HALLOWEEN HUB] Part 2 Loaded (Combat)")-- [[ HALLOWEEN HUB - PART 3/3 : MISC ]] --
if not _G.HH then return end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local MiscTab = _G.HH.Pages["Misc"]
if not MiscTab then return end

_G.HH.CreateSection(MiscTab, "Auto Collect")
_G.HH.CreateToggle(MiscTab, _G.HH.Settings.AutoCollectCoins, "Auto Collect Coins", function(on)
    if on then
        if _G.HH.Connections.ACC then _G.HH.Connections.ACC:Disconnect() end
        _G.HH.Connections.ACC = RunService.RenderStepped:Connect(function()
            if not _G.HH.Settings.AutoCollectCoins.Enabled then return end
            local myChar = LocalPlayer.Character; if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("gem") or obj.Name:lower():find("crystal")) then
                    if (myChar.HumanoidRootPart.Position - obj.Position).Magnitude < _G.HH.Settings.AutoCollectCoins.Range then myChar.HumanoidRootPart.CFrame = CFrame.new(obj.Position + Vector3.new(0,3,0)) end
                end
            end
        end)
    else if _G.HH.Connections.ACC then _G.HH.Connections.ACC:Disconnect() end end
end)
_G.HH.CreateSlider(MiscTab, _G.HH.Settings.AutoCollectCoins, "Range", 10, 100, 30, function(v) _G.HH.Settings.AutoCollectCoins.Range = v end)

print("[HALLOWEEN HUB] Part 3 Loaded (Misc)")
