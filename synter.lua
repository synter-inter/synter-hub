-- [[ ETHEREAL HUB - MONOLITH MOBILE EDITION ]] --
-- Всё в одном месте. Без ключей, без вотермарок. Чистый функционал.

if getgenv().EtherealMonolithLoaded then return end
getgenv().EtherealMonolithLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")

-- Очистка старых версий
if game:GetService("CoreGui"):FindFirstChild("EtherealMonolith") then
    game:GetService("CoreGui"):FindFirstChild("EtherealMonolith"):Destroy()
end

-- ========== ЗВУК ==========
local ClickSound = Instance.new("Sound", SoundService)
ClickSound.SoundId = "rbxassetid://12221967"
ClickSound.Volume = 0.5
local function PlayClick()
    local s = ClickSound:Clone()
    s.Parent = SoundService
    s:Play()
    game:GetService("Debris"):AddItem(s, 1)
end

-- ========== НАСТРОЙКИ ==========
local Settings = {
    SheriffESP = false, MurdererESP = false,
    GunESP = false, CoinESP = false,
    Aimbot = false, AimbotFOV = 120, AimbotSmoothness = 1, AutoFire = false,
    SilentAim = false, SilentAimFOV = 120,
    KnifeAimbot = false, KnifeAimbotFOV = 60, KnifeAutoStab = false,
    Fly = false, FlySpeed = 50,
    NoClip = false, SpeedHack = false, SpeedValue = 50,
    InfiniteJump = false,
    AutoCollect = false, AutoCollectRange = 30,
    GodMode = false
}
local Connections = {}
local ESPObjects = {}
local FOVCircle = nil
local KnifeFOVCircle = nil
getgenv().OldPos = nil
getgenv().FPDH = workspace.FallenPartsDestroyHeight

-- ========== UI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EtherealMonolith"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 1000
ScreenGui.Parent = game:GetService("CoreGui")

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 10, 0, 100)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ToggleBtn.Text = "E"
ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 200)
ToggleBtn.TextSize = 24
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 12)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 400)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Active = true
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = " ETHEREAL HUB"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local TabScroll = Instance.new("ScrollingFrame")
TabScroll.Size = UDim2.new(1, -20, 0, 30)
TabScroll.Position = UDim2.new(0, 10, 0, 45)
TabScroll.BackgroundTransparency = 1
TabScroll.ScrollBarThickness = 0
TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
TabScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
TabScroll.ScrollingDirection = Enum.ScrollingDirection.X
TabScroll.Parent = MainFrame

local TabLayout = Instance.new("UIListLayout")
TabLayout.Parent = TabScroll
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 5)

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -80)
ContentFrame.Position = UDim2.new(0, 10, 0, 80)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local Pages = {}
local TabButtons = {}
local CurrentTab = nil

local function CreateTab(name, index)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 80, 0, 26)
    Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 11
    Btn.BorderSizePixel = 0
    Btn.Parent = TabScroll
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 200)
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.Parent = ContentFrame
    local PL = Instance.new("UIListLayout")
    PL.Parent = Page
    PL.SortOrder = Enum.SortOrder.LayoutOrder
    PL.Padding = UDim.new(0, 6)

    Btn.MouseButton1Click:Connect(function()
        PlayClick()
        if CurrentTab then
            TweenService:Create(CurrentTab, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 35), TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
            Pages[CurrentTab].Visible = false
        end
        CurrentTab = name
        TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 255, 200), TextColor3 = Color3.fromRGB(0, 0, 0)}):Play()
        Pages[name].Visible = true
    end)

    Pages[name] = Page
    TabButtons[name] = Btn
end

CreateTab("ESP", 1); CreateTab("Combat", 2); CreateTab("Move", 3); CreateTab("Misc", 4); CreateTab("Troll", 5)

if TabButtons["ESP"] then
    CurrentTab = "ESP"
    TabButtons["ESP"].BackgroundColor3 = Color3.fromRGB(0, 255, 200)
    TabButtons["ESP"].TextColor3 = Color3.fromRGB(0, 0, 0)
    Pages["ESP"].Visible = true
end

-- ========== ХЕЛПЕРЫ ==========
local function CreateSection(parent, name)
    local sec = Instance.new("Frame"); sec.Size = UDim2.new(1, 0, 0, 20); sec.BackgroundTransparency = 1; sec.Parent = parent
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, 0, 1, 0); lbl.BackgroundTransparency = 1; lbl.Text = name; lbl.TextColor3 = Color3.fromRGB(0, 255, 200); lbl.TextSize = 12; lbl.Font = Enum.Font.GothamBold; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = sec
end

local function CreateToggle(parent, name, default, callback)
    local frm = Instance.new("Frame"); frm.Size = UDim2.new(1, 0, 0, 30); frm.BackgroundColor3 = Color3.fromRGB(30, 30, 35); frm.BorderSizePixel = 0; frm.Parent = parent
    Instance.new("UICorner", frm).CornerRadius = UDim.new(0, 6)
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(0.6, 0, 1, 0); lbl.Position = UDim2.new(0, 8, 0, 0); lbl.BackgroundTransparency = 1; lbl.Text = name; lbl.TextColor3 = Color3.fromRGB(255, 255, 255); lbl.TextSize = 11; lbl.Font = Enum.Font.Gotham; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = frm
    local bg = Instance.new("Frame"); bg.Size = UDim2.new(0, 30, 0, 16); bg.Position = UDim2.new(1, -38, 0.5, -8); bg.BackgroundColor3 = Color3.fromRGB(60, 60, 65); bg.BorderSizePixel = 0; bg.Parent = frm
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
    local dot = Instance.new("Frame"); dot.Size = UDim2.new(0, 12, 0, 12); dot.Position = UDim2.new(0, 2, 0.5, -6); dot.BackgroundColor3 = Color3.fromRGB(200, 200, 200); dot.BorderSizePixel = 0; dot.Parent = bg
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    local enabled = default or false
    local function update()
        if enabled then bg.BackgroundColor3 = Color3.fromRGB(0, 255, 200); TweenService:Create(dot, TweenInfo.new(0.2), {Position = UDim2.new(0, 16, 0.5, -6)}):Play()
        else bg.BackgroundColor3 = Color3.fromRGB(60, 60, 65); TweenService:Create(dot, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -6)}):Play() end
    end
    update()
    bg.MouseButton1Click:Connect(function() PlayClick(); enabled = not enabled; update(); if callback then callback(enabled) end end)
end

local function CreateSlider(parent, name, min, max, default, callback)
    local frm = Instance.new("Frame"); frm.Size = UDim2.new(1, 0, 0, 45); frm.BackgroundColor3 = Color3.fromRGB(30, 30, 35); frm.BorderSizePixel = 0; frm.Parent = parent
    Instance.new("UICorner", frm).CornerRadius = UDim.new(0, 6)
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, -12, 0, 16); lbl.Position = UDim2.new(0, 8, 0, 4); lbl.BackgroundTransparency = 1; lbl.Text = name .. ": " .. default; lbl.TextColor3 = Color3.fromRGB(255, 255, 255); lbl.TextSize = 10; lbl.Font = Enum.Font.Gotham; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = frm
    local sbg = Instance.new("Frame"); sbg.Size = UDim2.new(1, -16, 0, 6); sbg.Position = UDim2.new(0, 8, 0, 25); sbg.BackgroundColor3 = Color3.fromRGB(60, 60, 65); sbg.BorderSizePixel = 0; sbg.Parent = frm
    Instance.new("UICorner", sbg).CornerRadius = UDim.new(1, 0)
    local fill = Instance.new("Frame"); fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(0, 255, 200); fill.BorderSizePixel = 0; fill.Parent = sbg
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local dragging = false
    local function updateSlider(input)
        local px = input.Position.X; local sp = sbg.AbsolutePosition; local ss = sbg.AbsoluteSize
        local rx = math.clamp(px - sp.X, 0, ss.X); local pct = rx / ss.X; local val = math.floor(min + (max-min)*pct)
        fill.Size = UDim2.new(pct, 0, 1, 0); lbl.Text = name .. ": " .. val
        if callback then callback(val) end
    end
    sbg.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; updateSlider(input) end end)
    sbg.InputEnded:Connect(function() dragging = false end)
    UserInputService.TouchMoved:Connect(function(input) if dragging then updateSlider(input) end end)
end

-- ========== ЛОГИКА ==========
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
        local existing = player.Character:FindFirstChild("EtherealRoleHL")
        if existing then existing:Destroy() end
        local hl = Instance.new("Highlight"); hl.Name = "EtherealRoleHL"; hl.FillColor = color; hl.FillTransparency = 0.3; hl.OutlineColor = Color3.fromRGB(255, 255, 255); hl.OutlineTransparency = 0; hl.Parent = player.Character
        table.insert(ESPObjects, hl)
    end
end

local function CreateRoleESP()
    for _, obj in pairs(ESPObjects) do if typeof(obj) == "Instance" and obj.Name == "EtherealRoleHL" then pcall(function() obj:Destroy() end) end end
    if Settings.SheriffESP then local s = FindSheriff(); if s then HighlightRole(s, Color3.fromRGB(0, 150, 255)) end end
    if Settings.MurdererESP then local m = FindMurderer(); if m then HighlightRole(m, Color3.fromRGB(255, 50, 50)) end end
end

local function GetClosestEnemyInFOV(fov)
    local best, bestDist = nil, fov or 9999
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local hum = player.Character:FindFirstChild("Humanoid")
            if head and hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if dist < bestDist then bestDist = dist; best = player end
                end
            end
        end
    end
    return best
end

local function FireWeapon() pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton1(Vector2.new()) end) end

-- ========== ESP ВКЛАДКА ==========
CreateSection(Pages["ESP"], "Role ESP")
CreateToggle(Pages["ESP"], "Sheriff ESP (Blue)", false, function(on) Settings.SheriffESP = on; CreateRoleESP() end)
CreateToggle(Pages["ESP"], "Murderer ESP (Red)", false, function(on) Settings.MurdererESP = on; CreateRoleESP() end)

CreateSection(Pages["ESP"], "Item ESP")
CreateToggle(Pages["ESP"], "Gun ESP (Yellow)", false, function(on)
    Settings.GunESP = on
    if on then
        if Connections.GunESP then Connections.GunESP:Disconnect() end
        Connections.GunESP = RunService.RenderStepped:Connect(function()
            if not Settings.GunESP then return end
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Tool") and not obj.Parent:IsA("Model") then
                    local name = obj.Name:lower()
                    if name:find("gun") or name:find("revolver") or name:find("pistol") then
                        if not obj:FindFirstChild("EtherealHighlight") then
                            local hl = Instance.new("Highlight"); hl.Name = "EtherealHighlight"; hl.FillColor = Color3.fromRGB(255, 255, 0); hl.FillTransparency = 0.5; hl.OutlineColor = Color3.fromRGB(255, 255, 255); hl.OutlineTransparency = 0; hl.Parent = obj
                        end
                    end
                end
            end
        end)
    else if Connections.GunESP then Connections.GunESP:Disconnect() end end
end)

CreateToggle(Pages["ESP"], "Coin ESP (Gold)", false, function(on)
    Settings.CoinESP = on
    if on then
        if Connections.CoinESP then Connections.CoinESP:Disconnect() end
        Connections.CoinESP = RunService.RenderStepped:Connect(function()
            if not Settings.CoinESP then return end
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local name = obj.Name:lower()
                    if name:find("coin") or name:find("crystal") or name:find("gem") then
                        if not obj:FindFirstChild("EtherealHighlight") then
                            local hl = Instance.new("Highlight"); hl.Name = "EtherealHighlight"; hl.FillColor = Color3.fromRGB(255, 200, 0); hl.FillTransparency = 0.5; hl.OutlineColor = Color3.fromRGB(255, 255, 255); hl.OutlineTransparency = 0; hl.Parent = obj
                        end
                    end
                end
            end
        end)
    else if Connections.CoinESP then Connections.CoinESP:Disconnect() end end
end)

-- ========== COMBAT ВКЛАДКА ==========
CreateSection(Pages["Combat"], "Aimbot")
CreateToggle(Pages["Combat"], "Enable Aimbot", false, function(on)
    Settings.Aimbot = on
    if on then
        if not FOVCircle then local c = Drawing.new("Circle"); c.Radius = Settings.AimbotFOV; c.Color = Color3.fromRGB(0, 255, 200); c.Thickness = 1.5; c.Transparency = 0.7; c.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2); FOVCircle = c end
        if Connections.Aim then Connections.Aim:Disconnect() end
        Connections.Aim = RunService.RenderStepped:Connect(function()
            if not Settings.Aimbot then if FOVCircle then FOVCircle:Remove(); FOVCircle = nil end return end
            local target = GetClosestEnemyInFOV(Settings.AimbotFOV)
            if target and target.Character then
                local aimPart = target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
                if aimPart then
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, aimPart.Position), Settings.AimbotSmoothness)
                    if Settings.AutoFire then FireWeapon() end
                end
            end
        end)
    else if Connections.Aim then Connections.Aim:Disconnect() end end
end)
CreateSlider(Pages["Combat"], "Aimbot FOV", 40, 400, 120, function(v) Settings.AimbotFOV = v; if FOVCircle then FOVCircle.Radius = v end end)
CreateSlider(Pages["Combat"], "Aimbot Smoothness", 0.05, 1, 1, function(v) Settings.AimbotSmoothness = v end)
CreateToggle(Pages["Combat"], "AutoFire", false, function(on) Settings.AutoFire = on end)

CreateSection(Pages["Combat"], "Silent Aim")
CreateToggle(Pages["Combat"], "Enable Silent Aim", false, function(on) Settings.SilentAim = on end)
CreateSlider(Pages["Combat"], "Silent FOV", 40, 400, 120, function(v) Settings.SilentAimFOV = v end)

CreateSection(Pages["Combat"], "Knife Aimbot")
CreateToggle(Pages["Combat"], "Enable Knife Aimbot", false, function(on)
    Settings.KnifeAimbot = on
    if on then
        if not KnifeFOVCircle then local c = Drawing.new("Circle"); c.Radius = Settings.KnifeAimbotFOV; c.Color = Color3.fromRGB(255, 50, 50); c.Thickness = 1.5; c.Transparency = 0.5; c.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2); KnifeFOVCircle = c end
        if Connections.KnifeAim then Connections.KnifeAim:Disconnect() end
        Connections.KnifeAim = RunService.RenderStepped:Connect(function()
            if not Settings.KnifeAimbot then if KnifeFOVCircle then KnifeFOVCircle:Remove(); KnifeFOVCircle = nil end return end
            local target = FindMurderer()
            if target and target.Character then
                local head = target.Character:FindFirstChild("Head")
                if head then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if dist < Settings.KnifeAimbotFOV then
                            Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
                            if Settings.KnifeAutoStab then FireWeapon() end
                        end
                    end
                end
            end
        end)
    else if Connections.KnifeAim then Connections.KnifeAim:Disconnect() end end
end)
CreateSlider(Pages["Combat"], "Knife FOV", 20, 200, 60, function(v) Settings.KnifeAimbotFOV = v; if KnifeFOVCircle then KnifeFOVCircle.Radius = v end end)
CreateToggle(Pages["Combat"], "Auto Stab", false, function(on) Settings.KnifeAutoStab = on end)

-- ========== MOVE ВКЛАДКА ==========
CreateSection(Pages["Move"], "Movement")
CreateToggle(Pages["Move"], "Fly", false, function(on)
    Settings.Fly = on
    if on then
        if Connections.Fly then Connections.Fly:Disconnect() end
        local char = LocalPlayer.Character; if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart"); local hum = char:FindFirstChild("Humanoid")
        if root and hum then
            local bg = Instance.new("BodyGyro"); bg.P = 9e4; bg.maxTorque = Vector3.new(9e9, 9e9, 9e9); bg.CFrame = root.CFrame; bg.Parent = root
            local bv = Instance.new("BodyVelocity"); bv.maxForce = Vector3.new(9e9, 9e9, 9e9); bv.Parent = root
            Connections.Fly = RunService.RenderStepped:Connect(function()
                if not Settings.Fly then bg:Destroy(); bv:Destroy(); Connections.Fly:Disconnect(); hum.PlatformStand = false; return end
                hum.PlatformStand = true; bv.Velocity = Camera.CFrame.LookVector * Settings.FlySpeed; bg.CFrame = Camera.CFrame
            end)
        end
    else
        if Connections.Fly then Connections.Fly:Disconnect() end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.PlatformStand = false end
    end
end)
CreateSlider(Pages["Move"], "Fly Speed", 10, 200, 50, function(v) Settings.FlySpeed = v end)

CreateToggle(Pages["Move"], "NoClip", false, function(on)
    Settings.NoClip = on
    if on then
        if Connections.NC then Connections.NC:Disconnect() end
        Connections.NC = RunService.Stepped:Connect(function()
            if not Settings.NoClip then return end
            if LocalPlayer.Character then for _, p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
        end)
    else if Connections.NC then Connections.NC:Disconnect() end end
end)

CreateToggle(Pages["Move"], "Speed Hack", false, function(on)
    Settings.SpeedHack = on
    if on then
        if Connections.Spd then Connections.Spd:Disconnect() end
        Connections.Spd = RunService.RenderStepped:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = Settings.SpeedValue end
        end)
    else
        if Connections.Spd then Connections.Spd:Disconnect() end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = 16 end
    end
end)
CreateSlider(Pages["Move"], "Walk Speed", 16, 300, 50, function(v) Settings.SpeedValue = v end)

CreateToggle(Pages["Move"], "Infinite Jump", false, function(on)
    Settings.InfiniteJump = on
    if on then
        if Connections.Jmp then Connections.Jmp:Disconnect() end
        Connections.Jmp = UserInputService.JumpRequest:Connect(function()
            if not Settings.InfiniteJump then return end
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else if Connections.Jmp then Connections.Jmp:Disconnect() end end
end)

-- ========== MISC ВКЛАДКА ==========
CreateSection(Pages["Misc"], "Auto Collect")
CreateToggle(Pages["Misc"], "Auto Collect Coins", false, function(on)
    Settings.AutoCollect = on
    if on then
        if Connections.ACC then Connections.ACC:Disconnect() end
        Connections.ACC = RunService.RenderStepped:Connect(function()
            if not Settings.AutoCollect then return end
            local myChar = LocalPlayer.Character; if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("gem")) then
                    if (myChar.HumanoidRootPart.Position - obj.Position).Magnitude < Settings.AutoCollectRange then myChar.HumanoidRootPart.CFrame = CFrame.new(obj.Position + Vector3.new(0,3,0)) end
                end
            end
        end)
    else if Connections.ACC then Connections.ACC:Disconnect() end end
end)
CreateSlider(Pages["Misc"], "Collect Range", 10, 100, 30, function(v) Settings.AutoCollectRange = v end)

CreateToggle(Pages["Misc"], "God Mode", false, function(on)
    Settings.GodMode = on
    if on then
        if Connections.GM then Connections.GM:Disconnect() end
        Connections.GM = RunService.RenderStepped:Connect(function()
            if not Settings.GodMode then return end
            local myChar = LocalPlayer.Character
            if myChar and myChar:FindFirstChild("Humanoid") then myChar.Humanoid.Health = myChar.Humanoid.MaxHealth; myChar.Humanoid.MaxHealth = 999999 end
        end)
    else if Connections.GM then Connections.GM:Disconnect() end end
end)

-- ========== TROLL ВКЛАДКА (FLING) ==========
local selectedFlingTarget = nil

local FlingMenuBtn = Instance.new("TextButton")
FlingMenuBtn.Size = UDim2.new(1, 0, 0, 40)
FlingMenuBtn.BackgroundColor3 = Color3.fromRGB(35, 15, 45)
FlingMenuBtn.Text = "Enable Fling Menu"
FlingMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingMenuBtn.Font = Enum.Font.GothamBold
FlingMenuBtn.TextSize = 13
FlingMenuBtn.BorderSizePixel = 0
FlingMenuBtn.Parent = Pages["Troll"] -- ИСПРАВЛЕНО
Instance.new("UICorner", FlingMenuBtn).CornerRadius = UDim.new(0, 8)

local FlingFrame = Instance.new("Frame")
FlingFrame.Size = UDim2.new(1, 0, 0, 150)
FlingFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
FlingFrame.BorderSizePixel = 0
FlingFrame.Visible = false
FlingFrame.Parent = Pages["Troll"] -- ИСПРАВЛЕНО
Instance.new("UICorner", FlingFrame).CornerRadius = UDim.new(0, 6)

local FlingScroll = Instance.new("ScrollingFrame")
FlingScroll.Size = UDim2.new(1, -10, 1, -40)
FlingScroll.Position = UDim2.new(0, 5, 0, 5)
FlingScroll.BackgroundTransparency = 1
FlingScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
FlingScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
FlingScroll.ScrollBarThickness = 2
FlingScroll.Parent = FlingFrame
local FlingLayout = Instance.new("UIListLayout")
FlingLayout.Parent = FlingScroll
FlingLayout.Padding = UDim.new(0, 4)

local FlingStartBtn = Instance.new("TextButton")
FlingStartBtn.Size = UDim2.new(1, -10, 0, 30)
FlingStartBtn.Position = UDim2.new(0, 5, 1, -35)
FlingStartBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
FlingStartBtn.Text = "START FLING"
FlingStartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingStartBtn.Font = Enum.Font.GothamBold
FlingStartBtn.TextSize = 12
FlingStartBtn.BorderSizePixel = 0
FlingStartBtn.Parent = FlingFrameInstance.new("UICorner", FlingStartBtn).CornerRadius = UDim.new(0, 6)

FlingMenuBtn.MouseButton1Click:Connect(function()
    PlayClick()
    FlingFrame.Visible = not FlingFrame.Visible
    if FlingFrame.Visible then
        for _, child in ipairs(FlingScroll:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -5, 0, 25)
                btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                btn.Text = plr.Name
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 10
                btn.BorderSizePixel = 0
                btn.Parent = FlingScroll
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
                btn.MouseButton1Click:Connect(function()
                    PlayClick()
                    selectedFlingTarget = plr
                end)
            end
        end
    end
end)

-- Сама функция Флинга (SkidFling)
local function SkidFling(TargetPlayer)
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    local TCharacter = TargetPlayer.Character
    if not TCharacter then return end
    local THumanoid, TRootPart, THead, Accessory, Handle
    if TCharacter:FindFirstChildOfClass("Humanoid") then THumanoid = TCharacter:FindFirstChildOfClass("Humanoid") end
    if THumanoid and THumanoid.RootPart then TRootPart = THumanoid.RootPart end
    if TCharacter:FindFirstChild("Head") then THead = TCharacter.Head end
    if TCharacter:FindFirstChildOfClass("Accessory") then Accessory = TCharacter:FindFirstChildOfClass("Accessory") end
    if Accessory and Accessory:FindFirstChild("Handle") then Handle = Accessory.Handle end

    if Character and Humanoid and RootPart then
        if RootPart.Velocity.Magnitude < 50 then getgenv().OldPos = RootPart.CFrame end
        if THumanoid and THumanoid.Sit then return end
        if THead then workspace.CurrentCamera.CameraSubject = THead end
        local FPos = function(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end
        local SFBasePart = function(BasePart)
            local TimeToWait = 2
            local Time = tick()
            local Angle = 0
            repeat
                if RootPart and THumanoid then
                    if BasePart.Velocity.Magnitude < 50 then
                        Angle = Angle + 100
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                end
            until Time + TimeToWait < tick()
        end
        workspace.FallenPartsDestroyHeight = 0/0
        local BV = Instance.new("BodyVelocity")
        BV.Parent = RootPart
        BV.Velocity = Vector3.new(0, 0, 0)
        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        if TRootPart then SFBasePart(TRootPart)
        elseif THead then SFBasePart(THead)
        elseif Handle then SFBasePart(Handle) end
        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = Humanoid
        if getgenv().OldPos then
            repeat
                RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
                Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
                Humanoid:ChangeState("GettingUp")
                for _, part in pairs(Character:GetChildren()) do
                    if part:IsA("BasePart") then part.Velocity, part.RotVelocity = Vector3.new(), Vector3.new() end
                end
                task.wait()
            until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
            workspace.FallenPartsDestroyHeight = getgenv().FPDH
        end
    end
end

FlingStartBtn.MouseButton1Click:Connect(function()
    PlayClick()
    if selectedFlingTarget and selectedFlingTarget.Character then
        SkidFling(selectedFlingTarget)
    else
        print("Сначала выбери игрока в списке!")
    end
end)

-- ========== УПРАВЛЕНИЕ МЕНЮ ==========
ToggleBtn.MouseButton1Click:Connect(function()
    PlayClick()
    MainFrame.Visible = not MainFrame.Visible
    if MainFrame.Visible then
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 320, 0, 400)}):Play()
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    PlayClick()
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.wait(0.3)
    MainFrame.Visible = false
end)

-- ДРАГ
local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
TitleBar.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

print("[ETHEREAL HUB] Monolith Mobile Edition Loaded Successfully!")
