-- ============================================================================
-- ZENIT V6 // MEGA MOBILE EDITION (22 Tabs)
-- ============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Секция 1: Конфигурация
local Config = {
    Combat = {
        Aimbot = { Enabled = false, Mode = "Camera", Smoothness = 15, FOV = 200, FOVEnabled = true, AimPart = "Head", Prediction = true, WallCheck = false, TeamCheck = true, Snap = false },
        Hitbox = { Enabled = false, Size = 15, Transparency = 1, TeamCheck = true }
    },
    Visuals = {
        ESP = { Enabled = false, Boxes = true, BoxFilled = false, Names = true, Distance = true, Health = true, Tracers = false, Skeleton = false, Chams = false, MaxDistance = 1000, TextSize = 14, Color = Color3.fromRGB(170, 0, 255), TracerOrigin = "Bottom" },
        World = { Fullbright = false, AntiLag = false },
        Aura = { Type = "None", Size = 5, Speed = 2, Rate = 500, Brightness = 5, Range = 25 },
        Crosshair = { Enabled = false, Color = Color3.fromRGB(0, 255, 0), Size = 5, Thickness = 1 }
    },
    Player = { WalkSpeed = 16, JumpPower = 50, FlyEnabled = false, FlySpeed = 50, Noclip = false, InfJump = false, HipHeight = 2 },
    Misc = { AntiAFK = true }
}

-- Секция 2: Отрисовка (Создаем ДО UI)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1; FOVCircle.NumSides = 60; FOVCircle.Radius = Config.Combat.Aimbot.FOV; FOVCircle.Filled = false; FOVCircle.Color = Config.Visuals.ESP.Color; FOVCircle.Visible = true

local CrosshairCircle = Drawing.new("Circle")
CrosshairCircle.Thickness = 1; CrosshairCircle.NumSides = 10; CrosshairCircle.Radius = Config.Visuals.Crosshair.Size; CrosshairCircle.Filled = false; CrosshairCircle.Color = Config.Visuals.Crosshair.Color; CrosshairCircle.Visible = false

-- Секция 3: UI Инициализация (22 Вкладки)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Zenit V6 // Mega Hub",
    LoadingTitle = "Загрузка 22 вкладок...",
    LoadingSubtitle = "by Promtik",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local Tabs = {
    Combat = Window:CreateTab("Combat", 4483362458),
    Aimbot = Window:CreateTab("Aimbot Settings", 4483362458),
    Hitbox = Window:CreateTab("Hitbox", 4483362458),
    Visuals = Window:CreateTab("Visuals", 4483362458),
    ESP = Window:CreateTab("ESP Settings", 4483362458),
    ESPColors = Window:CreateTab("ESP Colors", 4483362458),
    Aura = Window:CreateTab("Aura FX", 4483362458),
    Player = Window:CreateTab("Player", 4483362458),
    Movement = Window:CreateTab("Movement", 4483362458),
    Teleport = Window:CreateTab("Teleport", 4483362458),
    Server = Window:CreateTab("Server Hop", 4483362458),
    World = Window:CreateTab("World", 4483362458),
    Lighting = Window:CreateTab("Lighting", 4483362458),
    Camera = Window:CreateTab("Camera", 4483362458),
    Crosshair = Window:CreateTab("Crosshair", 4483362458),
    Exploits = Window:CreateTab("Exploits", 4483362458),
    Scripts = Window:CreateTab("Scripts Hub", 4483362458),
    Config = Window:CreateTab("Config", 4483362458),
    Settings = Window:CreateTab("Settings", 4483362458),
    Info = Window:CreateTab("Info", 4483362458),
    Misc = Window:CreateTab("Misc", 4483362458),
    Troll = Window:CreateTab("Troll", 4483362458)
}

-- Секция 4: Combat & Aimbot UI
Tabs.Combat:CreateToggle({ Name = "Enable Aimbot", CurrentValue = false, Flag = "AimbotToggle", Callback = function(Value) Config.Combat.Aimbot.Enabled = Value end })
Tabs.Aimbot:CreateSlider({ Name = "Smoothness (Плавность)", Range = {1, 100}, Increment = 1, CurrentValue = 15, Flag = "AimSmoothSlider", Callback = function(Value) Config.Combat.Aimbot.Smoothness = Value end })
Tabs.Aimbot:CreateSlider({ Name = "FOV Radius (Круг)", Range = {50, 1000}, Increment = 10, CurrentValue = 200, Flag = "AimFOVSlider", Callback = function(Value) Config.Combat.Aimbot.FOV = Value; FOVCircle.Radius = Value end })
Tabs.Aimbot:CreateDropdown({ Name = "Target Part", Options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, CurrentOption = {"Head"}, Flag = "AimPartDrop", Callback = function(Option) Config.Combat.Aimbot.AimPart = type(Option) == "table" and Option[1] or Option end })
Tabs.Aimbot:CreateToggle({ Name = "Snap (Мгновенный лок)", CurrentValue = false, Flag = "AimSnapToggle", Callback = function(Value) Config.Combat.Aimbot.Snap = Value end })
Tabs.Aimbot:CreateToggle({ Name = "Prediction", CurrentValue = true, Flag = "PredictToggle", Callback = function(Value) Config.Combat.Aimbot.Prediction = Value end })
Tabs.Aimbot:CreateToggle({ Name = "Team Check", CurrentValue = true, Flag = "TeamCheckToggle", Callback = function(Value) Config.Combat.Aimbot.TeamCheck = Value end })

Tabs.Hitbox:CreateToggle({ Name = "Enable Hitbox Expander", CurrentValue = false, Flag = "HitboxToggle", Callback = function(Value) Config.Combat.Hitbox.Enabled = Value end })
Tabs.Hitbox:CreateSlider({ Name = "Hitbox Size", Range = {5, 50}, Increment = 1, CurrentValue = 15, Flag = "HitboxSizeSlider", Callback = function(Value) Config.Combat.Hitbox.Size = Value end })

-- Секция 5: Visuals & ESP (10-29 функций)
Tabs.Visuals:CreateToggle({ Name = "Enable ESP", CurrentValue = false, Flag = "ESPToggle", Callback = function(Value) Config.Visuals.ESP.Enabled = Value end })
Tabs.ESP:CreateToggle({ Name = "Boxes", CurrentValue = true, Flag = "ESPBoxToggle", Callback = function(Value) Config.Visuals.ESP.Boxes = Value end })
Tabs.ESP:CreateToggle({ Name = "Boxes Filled (Заливка)", CurrentValue = false, Flag = "ESPBoxFillToggle", Callback = function(Value) Config.Visuals.ESP.BoxFilled = Value end })
Tabs.ESP:CreateToggle({ Name = "Names", CurrentValue = true, Flag = "ESPNameToggle", Callback = function(Value) Config.Visuals.ESP.Names = Value end })
Tabs.ESP:CreateToggle({ Name = "Health Bars", CurrentValue = true, Flag = "ESPHealthToggle", Callback = function(Value) Config.Visuals.ESP.Health = Value end })
Tabs.ESP:CreateToggle({ Name = "Distance", CurrentValue = true, Flag = "ESPDistToggle", Callback = function(Value) Config.Visuals.ESP.Distance = Value end })
Tabs.ESP:CreateToggle({ Name = "Tracers (Линии)", CurrentValue = false, Flag = "ESPTracersToggle", Callback = function(Value) Config.Visuals.ESP.Tracers = Value end })
Tabs.ESP:CreateToggle({ Name = "Skeleton (Кости)", CurrentValue = false, Flag = "ESPSkelToggle", Callback = function(Value) Config.Visuals.ESP.Skeleton = Value end })
Tabs.ESP:CreateToggle({ Name = "Chams (Подсветка)", CurrentValue = false, Flag = "ESPChamsToggle", Callback = function(Value) Config.Visuals.ESP.Chams = Value end })
Tabs.ESP:CreateSlider({ Name = "Max Distance", Range = {100, 3000}, Increment = 100, CurrentValue = 1000, Flag = "ESPMaxDist", Callback = function(Value) Config.Visuals.ESP.MaxDistance = Value end })
Tabs.ESP:CreateSlider({ Name = "Text Size", Range = {10, 24}, Increment = 1, CurrentValue = 14, Flag = "ESPTextSize", Callback = function(Value) Config.Visuals.ESP.TextSize = Value end })
Tabs.ESPColors:CreateColorPicker({ Name = "ESP Color", Color = Color3.fromRGB(170, 0, 255), Flag = "ESPColorPick", Callback = function(Value) Config.Visuals.ESP.Color = Value end })

-- Секция 6: Aura FX (Исправленная)
Tabs.Aura:CreateDropdown({ Name = "Aura Style", Options = {"None", "Void", "Toxic", "Inferno", "Ice"}, CurrentOption = {"None"}, Flag = "AuraDrop", Callback = function(Option) Config.Visuals.Aura.Type = type(Option) == "table" and Option[1] or Option; UpdateAura() end })
Tabs.Aura:CreateSlider({ Name = "Size (Размер)", Range = {1, 30}, Increment = 0.5, CurrentValue = 5, Flag = "AuraSize", Callback = function(Value) Config.Visuals.Aura.Size = Value; UpdateAura() end })
Tabs.Aura:CreateSlider({ Name = "Speed (Скорость)", Range = {0.1, 10}, Increment = 0.1, CurrentValue = 2, Flag = "AuraSpeed", Callback = function(Value) Config.Visuals.Aura.Speed = Value end })

-- Секция 7: Player & Movement
Tabs.Player:CreateSlider({ Name = "WalkSpeed", Range = {16, 500}, Increment = 1, CurrentValue = 16, Flag = "SpeedSlider", Callback = function(Value) Config.Player.WalkSpeed = Value; if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = Value end end })
Tabs.Movement:CreateSlider({ Name = "JumpPower", Range = {50, 500}, Increment = 5, CurrentValue = 50, Flag = "JumpSlider", Callback = function(Value) Config.Player.JumpPower = Value; if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.JumpPower = Value end end })
Tabs.Movement:CreateToggle({ Name = "Infinite Jump", CurrentValue = false, Flag = "InfJumpToggle", Callback = function(Value) Config.Player.InfJump = Value end })
Tabs.Movement:CreateToggle({ Name = "Noclip", CurrentValue = false, Flag = "NoclipToggle", Callback = function(Value) Config.Player.Noclip = Value end })
Tabs.Movement:CreateToggle({ Name = "Fly (Полёт)", CurrentValue = false, Flag = "FlyToggle", Callback = function(Value) 
    Config.Player.FlyEnabled = Value
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        if Value then
            local bg = Instance.new("BodyVelocity", char.HumanoidRootPart)
            bg.Name = "ZenitFly"; bg.Velocity = Vector3.zero; bg.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        else
            if char.HumanoidRootPart:FindFirstChild("ZenitFly") then char.HumanoidRootPart.ZenitFly:Destroy() end
        end
    end
end })

-- Секция 8: World & Lighting
Tabs.World:CreateToggle({ Name = "Fullbright", CurrentValue = false, Flag = "FBToggle", Callback = function(Value) 
    if Value then Lighting.Ambient = Color3.fromRGB(255,255,255) else Lighting.Ambient = Color3.fromRGB(70,70,70) end
end })
Tabs.Lighting:CreateSlider({ Name = "Time of Day", Range = {0, 24}, Increment = 1, CurrentValue = 14, Flag = "TimeSlider", Callback = function(Value) Lighting.TimeOfDay = string.format("%02d:00:00", Value) end })

-- Секция 9: Crosshair
Tabs.Crosshair:CreateToggle({ Name = "Enable Crosshair", CurrentValue = false, Flag = "CrossToggle", Callback = function(Value) Config.Visuals.Crosshair.Enabled = Value end })
Tabs.Crosshair:CreateSlider({ Name = "Size", Range = {1, 20}, Increment = 1, CurrentValue = 5, Flag = "CrossSize", Callback = function(Value) CrosshairCircle.Radius = Value end })

-- ============================================================================
-- СЕКЦИЯ 10: ЛОГИКА (ESP, АУРА, АИМБОТ)
-- ============================================================================

local ESPObjects = {}

local function CreateESP(player)
    if player == LocalPlayer then return end
    local draw = { Box = Drawing.new("Square"), Name = Drawing.new("Text"), Dist = Drawing.new("Text"), HealthBg = Drawing.new("Square"), HealthFill = Drawing.new("Square"), Tracer = Drawing.new("Line"), Skel = {}, Chams = nil }
    
    draw.Box.Visible = false; draw.Box.Thickness = 1; draw.Box.Filled = false
    draw.Name.Visible = false; draw.Name.Center = true; draw.Name.Outline = true
    draw.Dist.Visible = false; draw.Dist.Center = true; draw.Dist.Outline = true
    draw.HealthBg.Visible = false; draw.HealthBg.Filled = true; draw.HealthBg.Color = Color3.new(0,0,0)
    draw.HealthFill.Visible = false; draw.HealthFill.Filled = true
    draw.Tracer.Visible = false; draw.Tracer.Thickness = 1
    
    for i = 1, 6 do
        local line = Drawing.new("Line"); line.Visible = false; line.Thickness = 1; table.insert(draw.Skel, line)
    end
    
    local function setupChams(char)
        if not char then return end
        if draw.Chams then draw.Chams:Destroy() end
        local chams = Instance.new("Highlight"); chams.Parent = char
        chams.FillTransparency = 0.5; chams.OutlineColor = Color3.fromRGB(255, 255, 255); chams.Enabled = false
        draw.Chams = chams
    end
    if player.Character then setupChams(player.Character) end
    player.CharacterAdded:Connect(setupChams)
    ESPObjects[player] = draw
end

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(p)
    if ESPObjects[p] then
        for k, v in pairs(ESPObjects[p]) do
            if k == "Skel" then for _, l in pairs(v) do l:Remove() end
            elseif k == "Chams" and v then v:Destroy()
            elseif v then v:Remove() end
        end
        ESPObjects[p] = nil
    end
end)

-- Плотная Аура (ФИКС)
local AuraFolder, AuraAttachment, AuraAngle = nil, nil, 0
function UpdateAura()
    if AuraFolder then AuraFolder:Destroy() end
    local char = LocalPlayer.Character
    if not char then return end
    local oldGlow = char:FindFirstChild("AuraGlow"); if oldGlow then oldGlow:Destroy() end
    if Config.Visuals.Aura.Type == "None" then return end

    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
    if not torso then return end

    local glow = Instance.new("Highlight"); glow.Name = "AuraGlow"; glow.Parent = char; glow.Adornee = char; glow.FillTransparency = 0.3; glow.OutlineTransparency = 1
    AuraFolder = Instance.new("Folder"); AuraFolder.Name = "ZenitAura"; AuraFolder.Parent = torso
    AuraAttachment = Instance.new("Attachment"); AuraAttachment.Name = "Center"; AuraAttachment.Parent = torso

    local function CreateEmitter(tex, size, speed, c1, c2, rate)
        local e = Instance.new("ParticleEmitter")
        e.Texture = tex; e.Rate = rate or 1000; e.LightEmission = 1; e.LightInfluence = 0
        e.Lifetime = NumberRange.new(0.8, 2); e.Speed = NumberRange.new(speed, speed * 1.5)
        e.SpreadAngle = Vector2.new(360, 360); e.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, size), NumberSequenceKeypoint.new(1, 0)})
        e.Color = ColorSequence.new(c1, c2); e.Rotation = NumberRange.new(0, 360); e.Parent = AuraAttachment
    end

    local light = Instance.new("PointLight"); light.Brightness = 10; light.Range = 40

    if Config.Visuals.Aura.Type == "Void" then
        CreateEmitter("rbxassetid://243098098", 12, 15, Color3.fromRGB(120, 0, 255), Color3.fromRGB(40, 0, 80))
        light.Color = Color3.fromRGB(120, 0, 255); glow.FillColor = Color3.fromRGB(80, 0, 150)
    elseif Config.Visuals.Aura.Type == "Toxic" then
        CreateEmitter("rbxassetid://243098098", 12, 15, Color3.fromRGB(0, 255, 50), Color3.fromRGB(0, 80, 20))
        light.Color = Color3.fromRGB(0, 255, 50); glow.FillColor = Color3.fromRGB(0, 150, 0)
    elseif Config.Visuals.Aura.Type == "Inferno" then
        CreateEmitter("rbxassetid://243098098", 12, 15, Color3.fromRGB(255, 50, 0), Color3.fromRGB(80, 0, 0))
        light.Color = Color3.fromRGB(255, 50, 0); glow.FillColor = Color3.fromRGB(200, 0, 0)
    elseif Config.Visuals.Aura.Type == "Ice" then
        CreateEmitter("rbxassetid://243098098", 12, 15, Color3.fromRGB(0, 200, 255), Color3.fromRGB(0, 50, 100))
        light.Color = Color3.fromRGB(0, 200, 255); glow.FillColor = Color3.fromRGB(0, 100, 200)
    end
    light.Parent = AuraAttachment
end

local function GetTarget()
    local closest, dist = nil, math.huge
    local center = Camera.ViewportSize / 2
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local part = p.Character:FindFirstChild(Config.Combat.Aimbot.AimPart)
            if part and part.Parent then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if mag <= Config.Combat.Aimbot.FOV and mag < dist then
                        dist = mag; closest = part
                    end
                end
            end
        end
    end
    return closest
end

local function DrawLine(lineObj, p1, p2)
    local v1, on1 = Camera:WorldToViewportPoint(p1)
    local v2, on2 = Camera:WorldToViewportPoint(p2)
    if on1 and on2 then lineObj.From = Vector2.new(v1.X, v1.Y); lineObj.To = Vector2.new(v2.X, v2.Y); lineObj.Visible = true else lineObj.Visible = false end
end

-- ФИКС АИМБОТА (Приоритет камеры)
RunService:BindToRenderStep("ZenitCamera", Enum.RenderPriority.Camera.Value + 1, function(dt)
    if Config.Combat.Aimbot.Enabled then
        local target = GetTarget()
        if target then
            local targetPos = target.Position
            if Config.Combat.Aimbot.Prediction then targetPos = targetPos + (target.Velocity * 0.16) end
            local lookAt = CFrame.lookAt(Camera.CFrame.Position, targetPos)
            
            if Config.Combat.Aimbot.Snap then
                Camera.CFrame = lookAt
            else
                local smoothFactor = math.clamp((Config.Combat.Aimbot.Smoothness / 100) * 15 * dt, 0, 1)
                Camera.CFrame = Camera.CFrame:Lerp(lookAt, smoothFactor)
            end
        end
    end
end)

RunService.RenderStepped:Connect(function(dt)
    FOVCircle.Position = Camera.ViewportSize / 2; FOVCircle.Visible = Config.Combat.Aimbot.FOVEnabled
    CrosshairCircle.Position = Camera.ViewportSize / 2; CrosshairCircle.Visible = Config.Visuals.Crosshair.Enabled

    if Config.Player.Noclip and LocalPlayer.Character then
        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
    end

    if Config.Player.FlyEnabled and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local flyVel = hrp and hrp:FindFirstChild("ZenitFly")
        if flyVel then
            local moveDir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
            flyVel.Velocity = moveDir * Config.Player.FlySpeed
        end
    end

    if AuraAttachment and AuraAttachment.Parent then
        AuraAngle = AuraAngle + (dt * Config.Visuals.Aura.Speed)
        local rad = Config.Visuals.Aura.Size
        AuraAttachment.Position = Vector3.new(math.cos(AuraAngle) * rad, math.sin(AuraAngle * 2) * (rad / 2), math.sin(AuraAngle) * rad)
    end

    -- Отрисовка ESP
    for player, draw in pairs(ESPObjects) do
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        local distToCam = hrp and (Camera.CFrame.Position - hrp.Position).Magnitude or 0

        if Config.Visuals.ESP.Enabled and hrp and hum and hum.Health > 0 and distToCam <= Config.Visuals.ESP.MaxDistance then
            local topPos = hrp.Position + Vector3.new(0, 2.5, 0); local botPos = hrp.Position - Vector3.new(0, 3, 0)
            local tVP, tVis = Camera:WorldToViewportPoint(topPos); local bVP, bVis = Camera:WorldToViewportPoint(botPos)

            if tVis or bVis then
                local h = math.abs(bVP.Y - tVP.Y); local w = h * 0.6; local x = (tVP.X + bVP.X) / 2 - w / 2; local y = tVP.Y
                
                draw.Box.Size = Vector2.new(w, h); draw.Box.Position = Vector2.new(x, y); draw.Box.Visible = Config.Visuals.ESP.Boxes
                draw.Box.Color = Config.Visuals.ESP.Color; draw.Box.Filled = Config.Visuals.ESP.BoxFilled
                
                local d = math.floor(distToCam)
                draw.Name.Text = player.Name; draw.Name.Position = Vector2.new(x + w/2, y - 20); draw.Name.Visible = Config.Visuals.ESP.Names; draw.Name.Size = Config.Visuals.ESP.TextSize
                draw.Dist.Text = "[" .. d .. "m]"; draw.Dist.Position = Vector2.new(x + w/2, y - 6); draw.Dist.Visible = Config.Visuals.ESP.Distance

                local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                draw.HealthBg.Size = Vector2.new(3, h); draw.HealthBg.Position = Vector2.new(x - 6, y); draw.HealthBg.Visible = Config.Visuals.ESP.Health
                draw.HealthFill.Size = Vector2.new(3, h * hp); draw.HealthFill.Position = Vector2.new(x - 6, y + h - (h * hp)); draw.HealthFill.Color = Color3.fromHSV(hp * 0.33, 1, 1); draw.HealthFill.Visible = Config.Visuals.ESP.Health
                
                draw.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y); draw.Tracer.To = Vector2.new(x + w / 2, y + h); draw.Tracer.Visible = Config.Visuals.ESP.Tracers; draw.Tracer.Color = Config.Visuals.ESP.Color
                
                if draw.Chams then draw.Chams.Enabled = Config.Visuals.ESP.Chams; draw.Chams.FillColor = Config.Visuals.ESP.Color end
                
                if Config.Visuals.ESP.Skeleton then
                    local head = char:FindFirstChild("Head"); local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                    local lArm = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm"); local rArm = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")
                    local lLeg = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg"); local rLeg = char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg")

                    if head and torso then DrawLine(draw.Skel[1], head.Position, torso.Position) else draw.Skel[1].Visible = false end
                    if torso and lArm then DrawLine(draw.Skel[2], torso.Position, lArm.Position) else draw.Skel[2].Visible = false end
                    if torso and rArm then DrawLine(draw.Skel[3], torso.Position, rArm.Position) else draw.Skel[3].Visible = false end
                    if torso and lLeg then DrawLine(draw.Skel[4], torso.Position, lLeg.Position) else draw.Skel[4].Visible = false end
                    if torso and rLeg then DrawLine(draw.Skel[5], torso.Position, rLeg.Position) else draw.Skel[5].Visible = false end
                else
                    for _, line in pairs(draw.Skel) do line.Visible = false end
                end
            else
                draw.Box.Visible = false; draw.Name.Visible = false; draw.Dist.Visible = false; draw.HealthBg.Visible = false; draw.HealthFill.Visible = false; draw.Tracer.Visible = false
            end
        else
            draw.Box.Visible = false; draw.Name.Visible = false; draw.Dist.Visible = false; draw.HealthBg.Visible = false; draw.HealthFill.Visible = false; draw.Tracer.Visible = false
        end
    end
end)

-- Anti-AFK & Jump
UserInputService.JumpRequest:Connect(function()
    if Config.Player.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end)
LocalPlayer.Idled:Connect(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)
