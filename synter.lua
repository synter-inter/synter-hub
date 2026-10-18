-- ============================================================================
-- ZENIT V5 // TITAN FRAMEWORK (MOBILE EDITION)
-- Огромный модульный хаб. Построен для стабильности и максимального функционала.
-- ============================================================================

-- Секция 1: Инициализация сервисов
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Секция 2: Глобальные переменные и состояния
local GlobalState = {
    IsLoaded = false,
    ConfigName = "ZenitV5_Config",
    Version = "5.0.0-Titan",
    StartupTime = os.time()
}

-- Секция 3: Конфигурация (Огромная таблица)
local Config = {
    Combat = {
        Aimbot = {
            Enabled = false,
            Mode = "Camera", -- Camera, Mouse, Silent
            Smoothness = 15,
            FOV = 200,
            FOVEnabled = true,
            FOVColor = Color3.fromRGB(170, 0, 255),
            AimPart = "Head",
            Prediction = true,
            WallCheck = false,
            TeamCheck = true,
            Resolver = false
        },
        Hitbox = {
            Enabled = false,
            Size = 15,
            Transparency = 1,
            TeamCheck = true
        }
    },
    Visuals = {
        ESP = {
            Enabled = false,
            Boxes = true,
            Names = true,
            Distance = true,
            Health = true,
            Tracers = false,
            Skeleton = false,
            Chams = false,
            MaxDistance = 1000,
            Color = Color3.fromRGB(170, 0, 255)
        },
        World = {
            Fullbright = false,
            NoFog = false,
            AntiLag = false,
            TimeOfDay = 14,
            Gravity = 196.2
        },
        Aura = {
            Type = "None",
            Size = 5,
            Speed = 2,
            Rate = 500,
            Brightness = 5,
            Range = 25
        },
        Crosshair = {
            Enabled = false,
            Color = Color3.fromRGB(0, 255, 0),
            Size = 5
        }
    },
    Player = {
        WalkSpeed = 16,
        JumpPower = 50,
        FlyEnabled = false,
        FlySpeed = 50,
        Noclip = false,
        InfJump = false
    },
    Misc = {
        AntiAFK = true,
        FPSUnlocker = true,
        AutoRejoin = false
    }
}

-- Секция 4: Инициализация Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Zenit V5 // Titan",
    LoadingTitle = "Загрузка модулей...",
    LoadingSubtitle = "by Promtik",
    ConfigurationSaving = { Enabled = true, FolderName = "ZenitV5", FileName = "Config" },
    KeySystem = false
})

-- Секция 5: Создание вкладок (7 вкладок)
local Tabs = {
    Combat = Window:CreateTab("Combat", 4483362458),
    Visuals = Window:CreateTab("Visuals", 4483362458),
    Aura = Window:CreateTab("Aura FX", 4483362458),
    Player = Window:CreateTab("Player", 4483362458),
    Teleport = Window:CreateTab("Teleport", 4483362458),
    World = Window:CreateTab("World", 4483362458),
    Settings = Window:CreateTab("Settings", 4483362458)
}

-- Секция 6: UI - Combat (Аимбот и Хитбоксы)
Tabs.Combat:CreateSection("Aimbot Configuration")

Tabs.Combat:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(Value) Config.Combat.Aimbot.Enabled = Value end,
})

Tabs.Combat:CreateDropdown({
    Name = "Aim Mode",
    Options = {"Camera", "Mouse", "Silent"},
    CurrentOption = {"Camera"},
    Flag = "AimModeDrop",
    Callback = function(Option) Config.Combat.Aimbot.Mode = type(Option) == "table" and Option[1] or Option end,
})

Tabs.Combat:CreateDropdown({
    Name = "Target Part",
    Options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "Nearest"},
    CurrentOption = {"Head"},
    Flag = "AimPartDrop",
    Callback = function(Option) Config.Combat.Aimbot.AimPart = type(Option) == "table" and Option[1] or Option end,
})

Tabs.Combat:CreateSlider({
    Name = "Smoothness",
    Range = {1, 100},
    Increment = 1,
    Suffix = "%",
    CurrentValue = 15,
    Flag = "AimSmoothSlider",
    Callback = function(Value) Config.Combat.Aimbot.Smoothness = Value end,
})

Tabs.Combat:CreateSlider({
    Name = "FOV Radius",
    Range = {50, 1000},
    Increment = 10,
    Suffix = "px",
    CurrentValue = 200,
    Flag = "AimFOVSlider",
    Callback = function(Value)
        Config.Combat.Aimbot.FOV = Value
        if FOVCircle then FOVCircle.Radius = Value end
    end,
})

Tabs.Combat:CreateToggle({
    Name = "Velocity Prediction",
    CurrentValue = true,
    Flag = "PredictToggle",
    Callback = function(Value) Config.Combat.Aimbot.Prediction = Value end,
})

Tabs.Combat:CreateToggle({
    Name = "Wall Check (Ignore behind walls)",
    CurrentValue = false,
    Flag = "WallCheckToggle",
    Callback = function(Value) Config.Combat.Aimbot.WallCheck = Value end,
})

Tabs.Combat:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Flag = "TeamCheckToggle",
    Callback = function(Value) Config.Combat.Aimbot.TeamCheck = Value end,
})

Tabs.Combat:CreateSection("Hitbox Expander")

Tabs.Combat:CreateToggle({
    Name = "Enable Hitbox Expander",
    CurrentValue = false,
    Flag = "HitboxToggle",
    Callback = function(Value) Config.Combat.Hitbox.Enabled = Value end,
})

Tabs.Combat:CreateSlider({
    Name = "Hitbox Size",
    Range = {5, 50},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 15,
    Flag = "HitboxSizeSlider",
    Callback = function(Value) Config.Combat.Hitbox.Size = Value end,
})

-- Секция 7: UI - Visuals (ESP и Крестик)
Tabs.Visuals:CreateSection("ESP Settings")

Tabs.Visuals:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(Value) Config.Visuals.ESP.Enabled = Value end,
})

Tabs.Visuals:CreateToggle({
    Name = "Boxes",
    CurrentValue = true,
    Flag = "ESPBoxToggle",
    Callback = function(Value) Config.Visuals.ESP.Boxes = Value end,
})

Tabs.Visuals:CreateToggle({
    Name = "Names",
    CurrentValue = true,
    Flag = "ESPNameToggle",
    Callback = function(Value) Config.Visuals.ESP.Names = Value end,
})

Tabs.Visuals:CreateToggle({
    Name = "Health Bars",
    CurrentValue = true,
    Flag = "ESPHealthToggle",
    Callback = function(Value) Config.Visuals.ESP.Health = Value end,
})

Tabs.Visuals:CreateToggle({
    Name = "Distance",
    CurrentValue = true,
    Flag = "ESPDistToggle",
    Callback = function(Value) Config.Visuals.ESP.Distance = Value end,
})

Tabs.Visuals:CreateToggle({
    Name = "Tracers (Lines)",
    CurrentValue = false,
    Flag = "ESPTracersToggle",
    Callback = function(Value) Config.Visuals.ESP.Tracers = Value end,
})

Tabs.Visuals:CreateToggle({
    Name = "Skeleton",
    CurrentValue = false,
    Flag = "ESPSkelToggle",
    Callback = function(Value) Config.Visuals.ESP.Skeleton = Value end,
})

Tabs.Visuals:CreateToggle({
    Name = "Chams (Highlights)",
    CurrentValue = false,
    Flag = "ESPChamsToggle",
    Callback = function(Value) Config.Visuals.ESP.Chams = Value end,
})

Tabs.Visuals:CreateColorPicker({
    Name = "ESP Color",
    Color = Color3.fromRGB(170, 0, 255),
    Flag = "ESPColorPicker",
    Callback = function(Value) Config.Visuals.ESP.Color = Value end,
})

Tabs.Visuals:CreateSection("Crosshair")

Tabs.Visuals:CreateToggle({
    Name = "Enable Crosshair",
    CurrentValue = false,
    Flag = "CrosshairToggle",
    Callback = function(Value)
        Config.Visuals.Crosshair.Enabled = Value
        if CrosshairCircle then CrosshairCircle.Visible = Value end
    end,
})

-- Секция 8: UI - Aura FX
Tabs.Aura:CreateSection("Aura Configuration")

Tabs.Aura:CreateDropdown({
    Name = "Aura Style",
    Options = {"None", "Void (Purple)", "Toxic (Green)", "Inferno (Red)", "Ice (Blue)", "Galaxy (Pink)"},
    CurrentOption = {"None"},
    Flag = "AuraDrop",
    Callback = function(Option)
        Config.Visuals.Aura.Type = type(Option) == "table" and Option[1] or Option
        UpdateAura()
    end,
})

Tabs.Aura:CreateSlider({
    Name = "Aura Size",
    Range = {1, 30},
    Increment = 0.5,
    Suffix = "studs",
    CurrentValue = 5,
    Flag = "AuraSizeSlider",
    Callback = function(Value)
        Config.Visuals.Aura.Size = Value
        UpdateAura()
    end,
})

Tabs.Aura:CreateSlider({
    Name = "Rotation Speed",
    Range = {0.1, 10},
    Increment = 0.1,
    Suffix = "x",
    CurrentValue = 2,
    Flag = "AuraSpeedSlider",
    Callback = function(Value) Config.Visuals.Aura.Speed = Value end,
})

Tabs.Aura:CreateSlider({
    Name = "Particle Rate",
    Range = {50, 5000},
    Increment = 50,
    Suffix = "rate",
    CurrentValue = 500,
    Flag = "AuraRateSlider",
    Callback = function(Value)
        Config.Visuals.Aura.Rate = Value
        UpdateAura()
    end,
})

-- Секция 9: UI - Player (Движение)
Tabs.Player:CreateSection("Movement Settings")

Tabs.Player:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 1000},
    Increment = 1,
    Suffix = "spd",
    CurrentValue = 16,
    Flag = "SpeedSlider",
    Callback = function(Value)
        Config.Player.WalkSpeed = Value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end,
})

Tabs.Player:CreateSlider({
    Name = "JumpPower",
    Range = {50, 1000},
    Increment = 5,
    Suffix = "pwr",
    CurrentValue = 50,
    Flag = "JumpSlider",
    Callback = function(Value)
        Config.Player.JumpPower = Value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = Value
            LocalPlayer.Character.Humanoid.UseJumpPower = true
        end
    end,
})

Tabs.Player:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfJumpToggle",
    Callback = function(Value) Config.Player.InfJump = Value end,
})

Tabs.Player:CreateToggle({
    Name = "Noclip (No Collision)",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(Value) Config.Player.Noclip = Value end,
})

Tabs.Player:CreateToggle({
    Name = "Fly (Mobile)",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(Value)
        Config.Player.FlyEnabled = Value
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            if Value then
                local bg = Instance.new("BodyVelocity", hrp)
                bg.Name = "ZenitFly"
                bg.Velocity = Vector3.zero
                bg.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            else
                if hrp:FindFirstChild("ZenitFly") then hrp.ZenitFly:Destroy() end
            end
        end
    end,
})

-- Секция 10: UI - Teleport
Tabs.Teleport:CreateSection("Teleportation")

Tabs.Teleport:CreateButton({
    Name = "Teleport to Mouse",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hit = Mouse.Hit
            if hit then
                char.HumanoidRootPart.CFrame = CFrame.new(hit.Position + Vector3.new(0, 3, 0))
            end
        end
    end,
})

-- Секция 11: UI - World (Окружение)
Tabs.World:CreateSection("Environment")

Tabs.World:CreateToggle({
    Name = "Fullbright (No Shadows)",
    CurrentValue = false,
    Flag = "FullbrightToggle",
    Callback = function(Value)
        Config.Visuals.World.Fullbright = Value
        if Value then
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 2
        else
            Lighting.Ambient = Color3.fromRGB(70, 70, 70)
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            Lighting.Brightness = 1
        end
    end,
})

Tabs.World:CreateToggle({
    Name = "Anti-Lag (Remove Textures)",
    CurrentValue = false,
    Flag = "AntiLagToggle",
    Callback = function(Value)
        Config.Visuals.World.AntiLag = Value
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = Value and 1 or 0
            end
        end
    end,
})

Tabs.World:CreateSlider({
    Name = "Time of Day",
    Range = {0, 24},
    Increment = 1,
    Suffix = "hr",
    CurrentValue = 14,
    Flag = "TimeSlider",
    Callback = function(Value)
        Config.Visuals.World.TimeOfDay = Value
        Lighting.TimeOfDay = string.format("%02d:00:00", Value)
    end,
})

-- ============================================================================
-- СЕКЦИЯ 12: ЛОГИКА ESP (Сложная система отрисовки)
-- ============================================================================
local ESPObjects = {}

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Config.Visuals.ESP.Color
    box.Thickness = 1
    box.Filled = false
    
    local name = Drawing.new("Text")
    name.Visible = false
    name.Color = Color3.fromRGB(255, 255, 255)
    name.Size = 14
    name.Center = true
    name.Outline = true
    
    local dist = Drawing.new("Text")
    dist.Visible = false
    dist.Color = Color3.fromRGB(200, 200, 200)
    dist.Size = 12
    dist.Center = true
    dist.Outline = true
    
    local hBg = Drawing.new("Square")
    hBg.Visible = false
    hBg.Color = Color3.fromRGB(0, 0, 0)
    hBg.Filled = true
    
    local hFill = Drawing.new("Square")
    hFill.Visible = false
    hFill.Color = Color3.fromRGB(0, 255, 0)
    hFill.Filled = true
    
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = Config.Visuals.ESP.Color
    tracer.Thickness = 1

    local chams = Instance.new("Highlight")
    chams.Parent = player.Character
    chams.FillColor = Config.Visuals.ESP.Color
    chams.FillTransparency = 1
    chams.OutlineColor = Color3.fromRGB(255, 255, 255)
    chams.Enabled = false
    
    local skelLines = {}
    for i = 1, 6 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = Color3.fromRGB(255, 255, 255)
        line.Thickness = 1
        table.insert(skelLines, line)
    end
    
    ESPObjects[player] = {
        Box = box, Name = name, Dist = dist, HealthBg = hBg, 
        HealthFill = hFill, Tracer = tracer, Chams = chams, Skel = skelLines
    }
end

-- Слушатели событий для ESP
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

Players.PlayerRemoving:Connect(function(p)
    if ESPObjects[p] then
        for k, v in pairs(ESPObjects[p]) do
            if k == "Skel" then
                for _, line in pairs(v) do line:Remove() end
            elseif k == "Chams" then
                v:Destroy()
            else
                v:Remove()
            end
        end
        ESPObjects[p] = nil
    end
end)

-- Отрисовка скелета
local function DrawLine(lineObj, p1, p2)
    local v1, on1 = Camera:WorldToViewportPoint(p1)
    local v2, on2 = Camera:WorldToViewportPoint(p2)
    if on1 and on2 then
        lineObj.From = Vector2.new(v1.X, v1.Y)
        lineObj.To = Vector2.new(v2.X, v2.Y)
        lineObj.Visible = true
    else
        lineObj.Visible = false
    end
end

-- ============================================================================
-- СЕКЦИЯ 13: ЛОГИКА АУРЫ (Частицы, свет, свечение)
-- ============================================================================
local AuraFolder, AuraAttachment, AuraAngle = nil, nil, 0
local AuraLights = {}

function UpdateAura()
    if AuraFolder then AuraFolder:Destroy() end
    table.clear(AuraLights)
    if Config.Visuals.Aura.Type == "None" then return end

    local char = LocalPlayer.Character
    local torso = char and (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart"))
    if not torso then return end

    AuraFolder = Instance.new("Folder")
    AuraFolder.Name = "ZenitAura"
    AuraFolder.Parent = torso
    
    AuraAttachment = Instance.new("Attachment")
    AuraAttachment.Name = "Center"
    AuraAttachment.Parent = torso

    local function CreateEmitter(tex, size, speed, c1, c2)
        local e = Instance.new("ParticleEmitter")
        e.Texture = tex
        e.Rate = Config.Visuals.Aura.Rate
        e.LightEmission = 1
        e.LightInfluence = 0
        e.Lifetime = NumberRange.new(1, 2.5)
        e.Speed = NumberRange.new(speed, speed * 2)
        e.SpreadAngle = Vector2.new(360, 360)
        e.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, size), NumberSequenceKeypoint.new(1, 0)})
        e.Color = ColorSequence.new(c1, c2)
        e.Rotation = NumberRange.new(0, 360)
        e.Parent = AuraAttachment
    end

    local light = Instance.new("PointLight")
    light.Brightness = Config.Visuals.Aura.Brightness
    light.Range = Config.Visuals.Aura.Range

    if Config.Visuals.Aura.Type == "Void (Purple)" then
        CreateEmitter("rbxassetid://243098098", 8, 12, Color3.fromRGB(120, 0, 255), Color3.fromRGB(40, 0, 80))
        CreateEmitter("rbxassetid://2416027981", 5, 18, Color3.fromRGB(200, 100, 255), Color3.fromRGB(100, 0, 255))
        light.Color = Color3.fromRGB(120, 0, 255)
    elseif Config.Visuals.Aura.Type == "Toxic (Green)" then
        CreateEmitter("rbxassetid://243098098", 8, 12, Color3.fromRGB(0, 255, 50), Color3.fromRGB(0, 80, 20))
        CreateEmitter("rbxassetid://2416027981", 5, 18, Color3.fromRGB(150, 255, 150), Color3.fromRGB(0, 200, 0))
        light.Color = Color3.fromRGB(0, 255, 50)
    elseif Config.Visuals.Aura.Type == "Inferno (Red)" then
        CreateEmitter("rbxassetid://243098098", 8, 12, Color3.fromRGB(255, 50, 0), Color3.fromRGB(80, 0, 0))
        CreateEmitter("rbxassetid://2416027981", 5, 18, Color3.fromRGB(255, 200, 0), Color3.fromRGB(255, 50, 0))
        light.Color = Color3.fromRGB(255, 50, 0)
    elseif Config.Visuals.Aura.Type == "Ice (Blue)" then
        CreateEmitter("rbxassetid://243098098", 8, 12, Color3.fromRGB(0, 200, 255), Color3.fromRGB(0, 50, 100))
        CreateEmitter("rbxassetid://2416027981", 5, 18, Color3.fromRGB(150, 240, 255), Color3.fromRGB(0, 150, 255))
        light.Color = Color3.fromRGB(0, 200, 255)
    elseif Config.Visuals.Aura.Type == "Galaxy (Pink)" then
        CreateEmitter("rbxassetid://243098098", 8, 12, Color3.fromRGB(255, 0, 150), Color3.fromRGB(0, 0, 255))
        CreateEmitter("rbxassetid://2416027981", 5, 18, Color3.fromRGB(255, 150, 255), Color3.fromRGB(0, 150, 255))
        light.Color = Color3.fromRGB(255, 0, 150)
    end
    
    light.Parent = AuraAttachment
    table.insert(AuraLights, light)
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    UpdateAura()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Config.Player.WalkSpeed
        LocalPlayer.Character.Humanoid.JumpPower = Config.Player.JumpPower
    end
end)

-- ============================================================================
-- СЕКЦИЯ 14: АИМБОТ И FOV (Математика наведения)
-- ============================================================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 60
FOVCircle.Radius = Config.Combat.Aimbot.FOV
FOVCircle.Filled = false
FOVCircle.Color = Config.Combat.Aimbot.FOVColor
FOVCircle.Transparency = 1
FOVCircle.Visible = true

local CrosshairCircle = Drawing.new("Circle")
CrosshairCircle.Thickness = 1
CrosshairCircle.NumSides = 10
CrosshairCircle.Radius = Config.Visuals.Crosshair.Size
CrosshairCircle.Filled = false
CrosshairCircle.Color = Config.Visuals.Crosshair.Color
CrosshairCircle.Visible = false

local function IsVisible(part)
    local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000)
    local hit, _ = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, part.Parent})
    return hit and hit:IsDescendantOf(part.Parent)
end

local function GetTarget()
    local closest, dist = nil, math.huge
    local center = Camera.ViewportSize / 2
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if Config.Combat.Aimbot.TeamCheck and p.Team == LocalPlayer.Team then continue end
            
            local part = p.Character:FindFirstChild(Config.Combat.Aimbot.AimPart)
            if part and part.Parent then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if mag <= Config.Combat.Aimbot.FOV and mag < dist then
                        if Config.Combat.Aimbot.WallCheck then
                            if IsVisible(part) then
                                dist = mag
                                closest = part
                            end
                        else
                            dist = mag
                            closest = part
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- ============================================================================
-- СЕКЦИЯ 15: ЛОГИКА ХИТБОКСА
-- ============================================================================
local function ToggleHitbox(player, state)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if state then
        if not hrp:FindFirstChild("ZenitHitbox") then
            local hitbox = Instance.new("Part")
            hitbox.Name = "ZenitHitbox"
            hitbox.Size = Vector3.new(Config.Combat.Hitbox.Size, Config.Combat.Hitbox.Size, Config.Combat.Hitbox.Size)
            hitbox.Transparency = Config.Combat.Hitbox.Transparency
            hitbox.CanCollide = false
            hitbox.Massless = true
            hitbox.Parent = hrp
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = hrp
            weld.Part1 = hitbox
            weld.Parent = hitbox
        else
            hrp.ZenitHitbox.Size = Vector3.new(Config.Combat.Hitbox.Size, Config.Combat.Hitbox.Size, Config.Combat.Hitbox.Size)
        end
    else
        local hitbox = hrp:FindFirstChild("ZenitHitbox")
        if hitbox then hitbox:Destroy() end
    end
end

-- ============================================================================
-- СЕКЦИЯ 16: ОСНОВНОЙ ЦИКЛ (RenderStepped) - Сердце скрипта
-- ============================================================================
local lastUpdate = tick()

RunService.RenderStepped:Connect(function(dt)
    -- FPS Counter & UI Update
    local currentTime = tick()
    if currentTime - lastUpdate > 1 then
        lastUpdate = currentTime
    end

    -- Позиционирование FOV и Крестика
    FOVCircle.Position = Camera.ViewportSize / 2
    FOVCircle.Visible = Config.Combat.Aimbot.FOVEnabled
    FOVCircle.Color = Config.Combat.Aimbot.FOVColor
    CrosshairCircle.Position = Camera.ViewportSize / 2
    CrosshairCircle.Visible = Config.Visuals.Crosshair.Enabled

    -- Noclip
    if Config.Player.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    -- Fly Logic
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
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0,1,0) end
            flyVel.Velocity = moveDir * Config.Player.FlySpeed
        end
    end

    -- Аура Вращение
    if AuraAttachment and AuraAttachment.Parent then
        AuraAngle = AuraAngle + (dt * Config.Visuals.Aura.Speed)
        local rad = Config.Visuals.Aura.Size
        AuraAttachment.Position = Vector3.new(
            math.cos(AuraAngle) * rad, 
            math.sin(AuraAngle * 2) * (rad / 2), 
            math.sin(AuraAngle) * rad
        )
    end

    -- Aimbot
    if Config.Combat.Aimbot.Enabled then
        local target = GetTarget()
        if target then
            local targetPos = target.Position
            if Config.Combat.Aimbot.Prediction then 
                targetPos += target.Velocity * 0.15 
            end
            local lookAt = CFrame.lookAt(Camera.CFrame.Position, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(lookAt, math.clamp(dt * (100 / Config.Combat.Aimbot.Smoothness) * 2, 0, 1))
        end
    end

    -- Hitbox Expander
    if Config.Combat.Hitbox.Enabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then 
                if not (Config.Combat.Hitbox.TeamCheck and p.Team == LocalPlayer.Team) then
                    ToggleHitbox(p, true) 
                end
            end
        end
    else
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then ToggleHitbox(p, false) end
        end
    end

    -- ESP Отрисовка
    for player, draw in pairs(ESPObjects) do
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        
        if Config.Visuals.ESP.Enabled and hrp and hum and hum.Health > 0 then
            local distToCam = (Camera.CFrame.Position - hrp.Position).Magnitude
            if distToCam <= Config.Visuals.ESP.MaxDistance then
                local topPos = hrp.Position + Vector3.new(0, 2.5, 0)
                local botPos = hrp.Position - Vector3.new(0, 3, 0)
                local tVP, tVis = Camera:WorldToViewportPoint(topPos)
                local bVP, bVis = Camera:WorldToViewportPoint(botPos)

                if tVis or bVis then
                    local h = math.abs(bVP.Y - tVP.Y)
                    local w = h * 0.6
                    local x = (tVP.X + bVP.X) / 2 - w / 2
                    local y = tVP.Y

                    draw.Box.Size = Vector2.new(w, h)
                    draw.Box.Position = Vector2.new(x, y)
                    draw.Box.Visible = Config.Visuals.ESP.Boxes
                    draw.Box.Color = Config.Visuals.ESP.Color
                    
                    local d = math.floor(distToCam)
                    draw.Name.Text = player.Name
                    draw.Name.Position = Vector2.new(x + w / 2, y - 20)
                    draw.Name.Visible = Config.Visuals.ESP.Names
                    
                    draw.Dist.Text = "[" .. d .. "m]"
                    draw.Dist.Position = Vector2.new(x + w / 2, y - 6)
                    draw.Dist.Visible = Config.Visuals.ESP.Distance
                    
                    local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    draw.HealthBg.Size = Vector2.new(3, h)
                    draw.HealthBg.Position = Vector2.new(x - 6, y)
                    draw.HealthBg.Visible = Config.Visuals.ESP.Health
                    
                    draw.HealthFill.Size = Vector2.new(3, h * hp)
                    draw.HealthFill.Position = Vector2.new(x - 6, y + h - (h * hp))
                    draw.HealthFill.Color = Color3.fromHSV(hp * 0.33, 1, 1)
                    draw.HealthFill.Visible = Config.Visuals.ESP.Health

                    draw.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    draw.Tracer.To = Vector2.new(x + w / 2, y + h)
                    draw.Tracer.Visible = Config.Visuals.ESP.Tracers
                    draw.Tracer.Color = Config.Visuals.ESP.Color
                    
                    draw.Chams.Enabled = Config.Visuals.ESP.Chams
                    if Config.Visuals.ESP.Chams then
                        draw.Chams.FillColor = Config.Visuals.ESP.Color
                        draw.Chams.FillTransparency = 0.5
                    end

                    -- Скелет
                    if Config.Visuals.ESP.Skeleton then
                        local head = char:FindFirstChild("Head")
                        local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                        local lArm = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm")
                        local rArm = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")
                        local lLeg = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg")
                        local rLeg = char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg")

                        if head and torso then DrawLine(draw.Skel[1], head.Position, torso.Position) else draw.Skel[1].Visible = false end
                        if torso and lArm then DrawLine(draw.Skel[2], torso.Position, lArm.Position) else draw.Skel[2].Visible = false end
                        if torso and rArm then DrawLine(draw.Skel[3], torso.Position, rArm.Position) else draw.Skel[3].Visible = false end
                        if torso and lLeg then DrawLine(draw.Skel[4], torso.Position, lLeg.Position) else draw.Skel[4].Visible = false end
                        if torso and rLeg then DrawLine(draw.Skel[5], torso.Position, rLeg.Position) else draw.Skel[5].Visible = false end
                    else
                        for _, line in pairs(draw.Skel) do line.Visible = false end
                    end
                else
                    draw.Box.Visible = false; draw.Name.Visible = false; draw.Dist.Visible = false
                    draw.HealthBg.Visible = false; draw.HealthFill.Visible = false; draw.Tracer.Visible = false
                    for _, line in pairs(draw.Skel) do line.Visible = false end
                end
            else
                draw.Box.Visible = false; draw.Name.Visible = false; draw.Dist.Visible = false
                draw.HealthBg.Visible = false; draw.HealthFill.Visible = false; draw.Tracer.Visible = false
                for _, line in pairs(draw.Skel) do line.Visible = false end
            end
        else
            draw.Box.Visible = false; draw.Name.Visible = false; draw.Dist.Visible = false
            draw.HealthBg.Visible = false; draw.HealthFill.Visible = false; draw.Tracer.Visible = false
            for _, line in pairs(draw.Skel) do line.Visible = false end
        end
    end
end)

-- Секция 17: Обработка прыжков и Anti-AFK
UserInputService.JumpRequest:Connect(function()
    if Config.Player.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

LocalPlayer.Idled:Connect(function()
    if Config.Misc.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- Секция 18: Финальная инициализация
StarterGui:SetCore("SendNotification", {
    Title = "Zenit V5 // Titan",
    Text = "Фреймворк успешно загружен! Открывай меню на RightShift.",
    Duration = 5
})

GlobalState.IsLoaded = true
print("Zenit V5 Framework Loaded. Lines of code: ~1050 (сжато).")
