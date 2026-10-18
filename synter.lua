-- ============================================================================
-- ZENIT V7 // ULTIMATE TITAN FRAMEWORK (MOBILE EDITION)
-- 22 Вкладки, расширенный ESP, Анти-Войд, Сервер-Хоп и куча всего.
-- ============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ============================================================================
-- СЕКЦИЯ 1: КОНФИГУРАЦИЯ
-- ============================================================================
local Config = {
    Combat = {
        Aimbot = { 
            Enabled = false, Mode = "Camera", Smoothness = 15, FOV = 200, FOVEnabled = true, 
            AimPart = "Head", Prediction = true, WallCheck = false, TeamCheck = true, Snap = false,
            FOVColor = Color3.fromRGB(170, 0, 255), FOVThickness = 1, ShowTargetInfo = false
        },
        Hitbox = { Enabled = false, Size = 15, Transparency = 1, TeamCheck = true }
    },
    Visuals = {
        ESP = { 
            Enabled = false, Boxes = true, BoxFilled = false, BoxThickness = 1,
            Names = true, Distance = true, Health = true, HealthBarType = "Side",
            Tracers = false, Skeleton = false, Chams = false, MaxDistance = 1000, TextSize = 14,
            Colors = {
                Box = Color3.fromRGB(170, 0, 255), Name = Color3.fromRGB(255, 255, 255),
                Distance = Color3.fromRGB(200, 200, 200), Health = Color3.fromRGB(0, 255, 0),
                Tracer = Color3.fromRGB(170, 0, 255), Skeleton = Color3.fromRGB(255, 255, 255),
                Chams = Color3.fromRGB(170, 0, 255)
            },
            Bones = { Head = true, Torso = true, LeftArm = true, RightArm = true, LeftLeg = true, RightLeg = true }
        },
        World = { Fullbright = false, AntiLag = false, NoFog = false, Ambient = Color3.fromRGB(70, 70, 70) },
        Aura = { Type = "None", Size = 5, Speed = 2, Rate = 500, Brightness = 5, Range = 25 },
        Crosshair = { Enabled = false, Color = Color3.fromRGB(0, 255, 0), Size = 5, Thickness = 1, Gap = 0 }
    },
    Player = { 
        WalkSpeed = 16, JumpPower = 50, FlyEnabled = false, FlySpeed = 50, 
        Noclip = false, InfJump = false, HipHeight = 2, AntiVoid = false
    },
    Misc = { AntiAFK = true, FPSBoost = false, ChatSpam = false, ChatSpamText = "Zenit V7 on top!" }
}

-- ============================================================================
-- СЕКЦИЯ 2: ОТРИСОВКА (Создается ДО UI)
-- ============================================================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1; FOVCircle.NumSides = 60; FOVCircle.Radius = Config.Combat.Aimbot.FOV; FOVCircle.Filled = false; FOVCircle.Color = Config.Combat.Aimbot.FOVColor; FOVCircle.Visible = false

local CrosshairLines = {
    Top = Drawing.new("Line"), Bottom = Drawing.new("Line"), Left = Drawing.new("Line"), Right = Drawing.new("Line")
}
for _, line in pairs(CrosshairLines) do line.Visible = false; line.Thickness = 1; line.Color = Config.Visuals.Crosshair.Color end

-- ============================================================================
-- СЕКЦИЯ 3: ИНИЦИАЛИЗАЦИЯ UI (22 Вкладки)
-- ============================================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Zenit V7 // Titan",
    LoadingTitle = "Инициализация 22 модулей...",
    LoadingSubtitle = "by Promtik",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local Tabs = {
    Combat = Window:CreateTab("Combat", 4483362458),
    Aimbot = Window:CreateTab("Aimbot", 4483362458),
    Hitbox = Window:CreateTab("Hitbox", 4483362458),
    Visuals = Window:CreateTab("Visuals", 4483362458),
    ESP = Window:CreateTab("ESP", 4483362458),
    ESPColors = Window:CreateTab("ESP Colors", 4483362458),
    ESPSkeleton = Window:CreateTab("Skeleton", 4483362458),
    Aura = Window:CreateTab("Aura FX", 4483362458),
    Player = Window:CreateTab("Player", 4483362458),
    Movement = Window:CreateTab("Movement", 4483362458),
    Teleport = Window:CreateTab("Teleport", 4483362458),
    Server = Window:CreateTab("Server", 4483362458),
    World = Window:CreateTab("World", 4483362458),
    Lighting = Window:CreateTab("Lighting", 4483362458),
    Camera = Window:CreateTab("Camera", 4483362458),
    Crosshair = Window:CreateTab("Crosshair", 4483362458),
    Exploits = Window:CreateTab("Exploits", 4483362458),
    Scripts = Window:CreateTab("Scripts", 4483362458),
    Config = Window:CreateTab("Config", 4483362458),
    Settings = Window:CreateTab("Settings", 4483362458),
    Misc = Window:CreateTab("Misc", 4483362458),
    Troll = Window:CreateTab("Troll", 4483362458)
}

-- ============================================================================
-- СЕКЦИЯ 4: UI - COMBAT
-- ============================================================================
Tabs.Combat:CreateSection("General Combat")
Tabs.Combat:CreateToggle({ Name = "Enable Aimbot", CurrentValue = false, Flag = "AimbotToggle", Callback = function(Value) Config.Combat.Aimbot.Enabled = Value end })
Tabs.Combat:CreateToggle({ Name = "Enable Hitbox", CurrentValue = false, Flag = "HitboxToggleMain", Callback = function(Value) Config.Combat.Hitbox.Enabled = Value end })
Tabs.Combat:CreateToggle({ Name = "Show Target Info (Debug)", CurrentValue = false, Flag = "AimInfoToggle", Callback = function(Value) Config.Combat.Aimbot.ShowTargetInfo = Value end })

-- ============================================================================
-- СЕКЦИЯ 5: UI - AIMBOT SETTINGS
-- ============================================================================
Tabs.Aimbot:CreateSection("Camera Settings")
Tabs.Aimbot:CreateSlider({ Name = "Smoothness", Range = {1, 100}, Increment = 1, CurrentValue = 15, Flag = "AimSmooth", Callback = function(Value) Config.Combat.Aimbot.Smoothness = Value end })
Tabs.Aimbot:CreateSlider({ Name = "FOV Radius", Range = {50, 1000}, Increment = 10, CurrentValue = 200, Flag = "AimFOV", Callback = function(Value) Config.Combat.Aimbot.FOV = Value; FOVCircle.Radius = Value end })
Tabs.Aimbot:CreateDropdown({ Name = "Target Bone", Options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, CurrentOption = {"Head"}, Flag = "AimPart", Callback = function(Option) Config.Combat.Aimbot.AimPart = type(Option) == "table" and Option[1] or Option end })
Tabs.Aimbot:CreateToggle({ Name = "Snap (Instant Lock)", CurrentValue = false, Flag = "AimSnap", Callback = function(Value) Config.Combat.Aimbot.Snap = Value end })
Tabs.Aimbot:CreateToggle({ Name = "Prediction", CurrentValue = true, Flag = "AimPredict", Callback = function(Value) Config.Combat.Aimbot.Prediction = Value end })
Tabs.Aimbot:CreateToggle({ Name = "Team Check", CurrentValue = true, Flag = "AimTeam", Callback = function(Value) Config.Combat.Aimbot.TeamCheck = Value end })
Tabs.Aimbot:CreateToggle({ Name = "Wall Check", CurrentValue = false, Flag = "AimWall", Callback = function(Value) Config.Combat.Aimbot.WallCheck = Value end })
Tabs.Aimbot:CreateToggle({ Name = "Show FOV Circle", CurrentValue = false, Flag = "AimFOVShow", Callback = function(Value) Config.Combat.Aimbot.FOVEnabled = Value end })

-- ============================================================================
-- СЕКЦИЯ 6: UI - HITBOX
-- ============================================================================
Tabs.Hitbox:CreateSlider({ Name = "Hitbox Size", Range = {5, 50}, Increment = 1, CurrentValue = 15, Flag = "HitboxSize", Callback = function(Value) Config.Combat.Hitbox.Size = Value end })

-- ============================================================================
-- СЕКЦИЯ 7: UI - VISUALS
-- ============================================================================
Tabs.Visuals:CreateToggle({ Name = "Enable ESP", CurrentValue = false, Flag = "ESPEnable", Callback = function(Value) Config.Visuals.ESP.Enabled = Value end })
Tabs.Visuals:CreateToggle({ Name = "Enable Crosshair", CurrentValue = false, Flag = "CrossEnable", Callback = function(Value) Config.Visuals.Crosshair.Enabled = Value end })

-- ============================================================================
-- СЕКЦИЯ 8: UI - ESP SETTINGS (12+ функций)
-- ============================================================================
Tabs.ESP:CreateSection("ESP Elements")
Tabs.ESP:CreateToggle({ Name = "Boxes", CurrentValue = true, Flag = "ESPBox", Callback = function(Value) Config.Visuals.ESP.Boxes = Value end })
Tabs.ESP:CreateToggle({ Name = "Filled Boxes", CurrentValue = false, Flag = "ESPBoxFill", Callback = function(Value) Config.Visuals.ESP.BoxFilled = Value end })
Tabs.ESP:CreateSlider({ Name = "Box Thickness", Range = {1, 5}, Increment = 1, CurrentValue = 1, Flag = "ESPBoxThick", Callback = function(Value) Config.Visuals.ESP.BoxThickness = Value end })
Tabs.ESP:CreateToggle({ Name = "Names", CurrentValue = true, Flag = "ESPName", Callback = function(Value) Config.Visuals.ESP.Names = Value end })
Tabs.ESP:CreateToggle({ Name = "Distance", CurrentValue = true, Flag = "ESPDist", Callback = function(Value) Config.Visuals.ESP.Distance = Value end })
Tabs.ESP:CreateToggle({ Name = "Health Bars", CurrentValue = true, Flag = "ESPHealth", Callback = function(Value) Config.Visuals.ESP.Health = Value end })
Tabs.ESP:CreateDropdown({ Name = "Health Bar Type", Options = {"Side", "Top"}, CurrentOption = {"Side"}, Flag = "ESPHealthType", Callback = function(Option) Config.Visuals.ESP.HealthBarType = type(Option) == "table" and Option[1] or Option end })
Tabs.ESP:CreateToggle({ Name = "Tracers", CurrentValue = false, Flag = "ESPTracer", Callback = function(Value) Config.Visuals.ESP.Tracers = Value end })
Tabs.ESP:CreateToggle({ Name = "Chams (Highlight)", CurrentValue = false, Flag = "ESPChams", Callback = function(Value) Config.Visuals.ESP.Chams = Value end })
Tabs.ESP:CreateToggle({ Name = "Skeleton", CurrentValue = false, Flag = "ESPSkel", Callback = function(Value) Config.Visuals.ESP.Skeleton = Value end })
Tabs.ESP:CreateSlider({ Name = "Max Distance", Range = {100, 3000}, Increment = 100, CurrentValue = 1000, Flag = "ESPMaxDist", Callback = function(Value) Config.Visuals.ESP.MaxDistance = Value end })
Tabs.ESP:CreateSlider({ Name = "Text Size", Range = {10, 24}, Increment = 1, CurrentValue = 14, Flag = "ESPTextSize", Callback = function(Value) Config.Visuals.ESP.TextSize = Value end })

-- ============================================================================
-- СЕКЦИЯ 9: UI - ESP COLORS
-- ============================================================================
Tabs.ESPColors:CreateColorPicker({ Name = "Box Color", Color = Color3.fromRGB(170, 0, 255), Flag = "CBox", Callback = function(Value) Config.Visuals.ESP.Colors.Box = Value end })
Tabs.ESPColors:CreateColorPicker({ Name = "Name Color", Color = Color3.fromRGB(255, 255, 255), Flag = "CName", Callback = function(Value) Config.Visuals.ESP.Colors.Name = Value end })
Tabs.ESPColors:CreateColorPicker({ Name = "Distance Color", Color = Color3.fromRGB(200, 200, 200), Flag = "CDist", Callback = function(Value) Config.Visuals.ESP.Colors.Distance = Value end })
Tabs.ESPColors:CreateColorPicker({ Name = "Tracer Color", Color = Color3.fromRGB(170, 0, 255), Flag = "CTracer", Callback = function(Value) Config.Visuals.ESP.Colors.Tracer = Value end })
Tabs.ESPColors:CreateColorPicker({ Name = "Skeleton Color", Color = Color3.fromRGB(255, 255, 255), Flag = "CSkel", Callback = function(Value) Config.Visuals.ESP.Colors.Skeleton = Value end })
Tabs.ESPColors:CreateColorPicker({ Name = "Chams Color", Color = Color3.fromRGB(170, 0, 255), Flag = "CChams", Callback = function(Value) Config.Visuals.ESP.Colors.Chams = Value end })

-- ============================================================================
-- СЕКЦИЯ 10: UI - SKELETON BONES
-- ============================================================================
Tabs.ESPSkeleton:CreateSection("Skeleton Bones")
Tabs.ESPSkeleton:CreateToggle({ Name = "Head -> Torso", CurrentValue = true, Flag = "BoneHead", Callback = function(Value) Config.Visuals.ESP.Bones.Head = Value end })
Tabs.ESPSkeleton:CreateToggle({ Name = "Left Arm", CurrentValue = true, Flag = "BoneLArm", Callback = function(Value) Config.Visuals.ESP.Bones.LeftArm = Value end })
Tabs.ESPSkeleton:CreateToggle({ Name = "Right Arm", CurrentValue = true, Flag = "BoneRArm", Callback = function(Value) Config.Visuals.ESP.Bones.RightArm = Value end })
Tabs.ESPSkeleton:CreateToggle({ Name = "Left Leg", CurrentValue = true, Flag = "BoneLLeg", Callback = function(Value) Config.Visuals.ESP.Bones.LeftLeg = Value end })
Tabs.ESPSkeleton:CreateToggle({ Name = "Right Leg", CurrentValue = true, Flag = "BoneRLeg", Callback = function(Value) Config.Visuals.ESP.Bones.RightLeg = Value end })

-- ============================================================================
-- СЕКЦИЯ 11: UI - AURA FX
-- ============================================================================
Tabs.Aura:CreateDropdown({ Name = "Aura Style", Options = {"None", "Void", "Toxic", "Inferno", "Ice"}, CurrentOption = {"None"}, Flag = "AuraDrop", Callback = function(Option) Config.Visuals.Aura.Type = type(Option) == "table" and Option[1] or Option; UpdateAura() end })
Tabs.Aura:CreateSlider({ Name = "Aura Size", Range = {1, 30}, Increment = 0.5, CurrentValue = 5, Flag = "AuraSize", Callback = function(Value) Config.Visuals.Aura.Size = Value; UpdateAura() end })
Tabs.Aura:CreateSlider({ Name = "Rotation Speed", Range = {0.1, 10}, Increment = 0.1, CurrentValue = 2, Flag = "AuraSpeed", Callback = function(Value) Config.Visuals.Aura.Speed = Value end })
Tabs.Aura:CreateSlider({ Name = "Particle Rate", Range = {50, 2000}, Increment = 50, CurrentValue = 500, Flag = "AuraRate", Callback = function(Value) Config.Visuals.Aura.Rate = Value; UpdateAura() end })

-- ============================================================================
-- СЕКЦИЯ 12: UI - PLAYER & MOVEMENT
-- ============================================================================
Tabs.Player:CreateSlider({ Name = "WalkSpeed", Range = {16, 500}, Increment = 1, CurrentValue = 16, Flag = "Speed", Callback = function(Value) Config.Player.WalkSpeed = Value; if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = Value end end })
Tabs.Player:CreateSlider({ Name = "JumpPower", Range = {50, 500}, Increment = 5, CurrentValue = 50, Flag = "Jump", Callback = function(Value) Config.Player.JumpPower = Value; if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.JumpPower = Value end end })
Tabs.Player:CreateSlider({ Name = "HipHeight", Range = {0, 10}, Increment = 0.1, CurrentValue = 2, Flag = "Hip", Callback = function(Value) Config.Player.HipHeight = Value; if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.HipHeight = Value end end })

Tabs.Movement:CreateToggle({ Name = "Infinite Jump", CurrentValue = false, Flag = "InfJump", Callback = function(Value) Config.Player.InfJump = Value end })
Tabs.Movement:CreateToggle({ Name = "Noclip", CurrentValue = false, Flag = "Noclip", Callback = function(Value) Config.Player.Noclip = Value end })
Tabs.Movement:CreateToggle({ Name = "Anti-Void", CurrentValue = false, Flag = "AntiVoid", Callback = function(Value) Config.Player.AntiVoid = Value end })
Tabs.Movement:CreateToggle({ Name = "Fly", CurrentValue = false, Flag = "Fly", Callback = function(Value) 
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
Tabs.Movement:CreateSlider({ Name = "Fly Speed", Range = {10, 200}, Increment = 10, CurrentValue = 50, Flag = "FlySpeed", Callback = function(Value) Config.Player.FlySpeed = Value end })

-- ============================================================================
-- СЕКЦИЯ 13: UI - TELEPORT & SERVER
-- ============================================================================
Tabs.Teleport:CreateButton({ Name = "Teleport to Mouse", Callback = function() if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0,3,0)) end end })

local TPList = {}
Tabs.Teleport:CreateDropdown({ Name = "Teleport to Player", Options = {}, CurrentOption = {"None"}, Flag = "TPPlayer", Callback = function(Option)
    local name = type(Option) == "table" and Option[1] or Option
    for _, p in pairs(Players:GetPlayers()) do if p.Name == name and p.Character then LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0) end end
end })
task.spawn(function() while task.wait(5) do local list = {} for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(list, p.Name) end end Tabs.Teleport:RefreshDropdown("TPPlayer", list) end end)

Tabs.Server:CreateButton({ Name = "Server Hop (Find New Server)", Callback = function()
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local success, response = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
    if success and response and response.data then
        for _, server in pairs(response.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer); break end
        end
    end
end })

-- ============================================================================
-- СЕКЦИЯ 14: UI - WORLD & LIGHTING
-- ============================================================================
Tabs.World:CreateToggle({ Name = "Fullbright", CurrentValue = false, Flag = "FB", Callback = function(Value) 
    if Value then Lighting.Ambient = Color3.fromRGB(255,255,255) else Lighting.Ambient = Config.Visuals.World.Ambient end
end })
Tabs.World:CreateToggle({ Name = "Remove Fog", CurrentValue = false, Flag = "NoFog", Callback = function(Value) 
    if Value then Lighting.FogEnd = 100000 else Lighting.FogEnd = 1000 end
end })
Tabs.World:CreateToggle({ Name = "Anti-Lag (Remove Textures)", CurrentValue = false, Flag = "AntiLag", Callback = function(Value) 
    for _, v in pairs(Workspace:GetDescendants()) do if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = Value and 1 or 0 end end
end })

Tabs.Lighting:CreateSlider({ Name = "Time of Day", Range = {0, 24}, Increment = 1, CurrentValue = 14, Flag = "Time", Callback = function(Value) Lighting.TimeOfDay = string.format("%02d:00:00", Value) end })

-- ============================================================================
-- СЕКЦИЯ 15: UI - CAMERA & CROSSHAIR
-- ============================================================================
Tabs.Camera:CreateSlider({ Name = "Camera FOV", Range = {40, 120}, Increment = 1, CurrentValue = 70, Flag = "CamFOV", Callback = function(Value) Camera.FieldOfView = Value end })
Tabs.Crosshair:CreateSlider({ Name = "Crosshair Size", Range = {1, 20}, Increment = 1, CurrentValue = 5, Flag = "CrossSize", Callback = function(Value) Config.Visuals.Crosshair.Size = Value end })
Tabs.Crosshair:CreateSlider({ Name = "Crosshair Gap", Range = {0, 20}, Increment = 1, CurrentValue = 0, Flag = "CrossGap", Callback = function(Value) Config.Visuals.Crosshair.Gap = Value end })
Tabs.Crosshair:CreateColorPicker({ Name = "Crosshair Color", Color = Color3.fromRGB(0, 255, 0), Flag = "CrossColor", Callback = function(Value) Config.Visuals.Crosshair.Color = Value end })

-- ============================================================================
-- СЕКЦИЯ 16: UI - MISC & TROLL
-- ============================================================================
Tabs.Misc:CreateToggle({ Name = "Anti-AFK", CurrentValue = true, Flag = "AntiAFK", Callback = function(Value) Config.Misc.AntiAFK = Value end })
Tabs.Misc:CreateToggle({ Name = "Chat Spam", CurrentValue = false, Flag = "ChatSpam", Callback = function(Value) Config.Misc.ChatSpam = Value end })
Tabs.Misc:CreateInput({ Name = "Chat Spam Text", CurrentValue = "Zenit V7 on top!", Flag = "ChatText", Callback = function(Value) Config.Misc.ChatSpamText = Value end })

Tabs.Troll:CreateButton({ Name = "Freeze All Players", Callback = function() for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character then local h = p.Character:FindFirstChild("Humanoid"); if h then h.WalkSpeed = 0; h.JumpPower = 0 end end end end })
Tabs.Troll:CreateButton({ Name = "Unfreeze All Players", Callback = function() for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character then local h = p.Character:FindFirstChild("Humanoid"); if h then h.WalkSpeed = 16; h.JumpPower = 50 end end end end })

-- ============================================================================
-- СЕКЦИЯ 17: ЛОГИКА ESP (Огромный блок)
-- ============================================================================
local ESPObjects = {}

local function CreateESP(player)
    if player == LocalPlayer then return end
    local draw = { 
        Box = Drawing.new("Square"), Name = Drawing.new("Text"), Dist = Drawing.new("Text"), 
        HealthBg = Drawing.new("Square"), HealthFill = Drawing.new("Square"), Tracer = Drawing.new("Line"), 
        Skel = {}, Chams = nil 
    }
    
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

local function DrawLine(lineObj, p1, p2)
    local v1, on1 = Camera:WorldToViewportPoint(p1)
    local v2, on2 = Camera:WorldToViewportPoint(p2)
    if on1 and on2 then lineObj.From = Vector2.new(v1.X, v1.Y); lineObj.To = Vector2.new(v2.X, v2.Y); lineObj.Visible = true else lineObj.Visible = false end
end

-- ============================================================================
-- СЕКЦИЯ 18: ЛОГИКА АУРЫ
-- ============================================================================
local AuraFolder, AuraAttachment, AuraAngle = nil, nil, 0
function UpdateAura()
    if AuraFolder then AuraFolder:Destroy() end
    local char = LocalPlayer.Character; if not char then return end
    local oldGlow = char:FindFirstChild("AuraGlow"); if oldGlow then oldGlow:Destroy() end
    if Config.Visuals.Aura.Type == "None" then return end

    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
    if not torso then return end

    local glow = Instance.new("Highlight"); glow.Name = "AuraGlow"; glow.Parent = char; glow.Adornee = char; glow.FillTransparency = 0.3; glow.OutlineTransparency = 1
    AuraFolder = Instance.new("Folder"); AuraFolder.Name = "ZenitAura"; AuraFolder.Parent = torso
    AuraAttachment = Instance.new("Attachment"); AuraAttachment.Name = "Center"; AuraAttachment.Parent = torso

    local function CreateEmitter(tex, size, speed, c1, c2)
        local e = Instance.new("ParticleEmitter")
        e.Texture = tex; e.Rate = Config.Visuals.Aura.Rate; e.LightEmission = 1; e.LightInfluence = 0
        e.Lifetime = NumberRange.new(0.8, 2); e.Speed = NumberRange.new(speed, speed * 1.5)
        e.SpreadAngle = Vector2.new(360, 360); e.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, size), NumberSequenceKeypoint.new(1, 0)})
        e.Color = ColorSequence.new(c1, c2); e.Rotation = NumberRange.new(0, 360); e.Parent = AuraAttachment
    end

    local light = Instance.new("PointLight"); light.Brightness = Config.Visuals.Aura.Brightness; light.Range = Config.Visuals.Aura.Range
    if Config.Visuals.Aura.Type == "Void" then CreateEmitter("rbxassetid://243098098", 12, 15, Color3.fromRGB(120, 0, 255), Color3.fromRGB(40, 0, 80)); light.Color = Color3.fromRGB(120, 0, 255); glow.FillColor = Color3.fromRGB(80, 0, 150)
    elseif Config.Visuals.Aura.Type == "Toxic" then CreateEmitter("rbxassetid://243098098", 12, 15, Color3.fromRGB(0, 255, 50), Color3.fromRGB(0, 80, 20)); light.Color = Color3.fromRGB(0, 255, 50); glow.FillColor = Color3.fromRGB(0, 150, 0)
    elseif Config.Visuals.Aura.Type == "Inferno" then CreateEmitter("rbxassetid://243098098", 12, 15, Color3.fromRGB(255, 50, 0), Color3.fromRGB(80, 0, 0)); light.Color = Color3.fromRGB(255, 50, 0); glow.FillColor = Color3.fromRGB(200, 0, 0)
    elseif Config.Visuals.Aura.Type == "Ice" then CreateEmitter("rbxassetid://243098098", 12, 15, Color3.fromRGB(0, 200, 255), Color3.fromRGB(0, 50, 100)); light.Color = Color3.fromRGB(0, 200, 255); glow.FillColor = Color3.fromRGB(0, 100, 200) end
    light.Parent = AuraAttachment
end

-- ============================================================================
-- СЕКЦИЯ 19: АИМБОТ ЛОГИКА (ФИКС КАМЕРЫ)
-- ============================================================================
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
                    if mag <= Config.Combat.Aimbot.FOV and mag < dist then dist = mag; closest = part end
                end
            end
        end
    end
    return closest
end

-- Фикс: Используем BindToRenderStep с приоритетом камеры
RunService:BindToRenderStep("ZenitCamera", Enum.RenderPriority.Camera.Value + 1, function(dt)
    if Config.Combat.Aimbot.Enabled then
        local target = GetTarget()
        if target then
            local targetPos = target.Position
            if Config.Combat.Aimbot.Prediction then targetPos = targetPos + (target.Velocity * 0.16) end
            local lookAt = CFrame.lookAt(Camera.CFrame.Position, targetPos)
            if Config.Combat.Aimbot.Snap then Camera.CFrame = lookAt
            else
                local smoothFactor = math.clamp((Config.Combat.Aimbot.Smoothness / 100) * 15 * dt, 0, 1)
                Camera.CFrame = Camera.CFrame:Lerp(lookAt, smoothFactor)
            end
        end
    end
end)

-- ============================================================================
-- СЕКЦИЯ 20: ГЛАВНЫЙ ЦИКЛ (RenderStepped)
-- ============================================================================
RunService.RenderStepped:Connect(function(dt)
    -- Отрисовка FOV и Крестика
    FOVCircle.Position = Camera.ViewportSize / 2; FOVCircle.Visible = Config.Combat.Aimbot.FOVEnabled; FOVCircle.Color = Config.Combat.Aimbot.FOVColor
    CrosshairLines.Top.Visible = Config.Visuals.Crosshair.Enabled; CrosshairLines.Bottom.Visible = Config.Visuals.Crosshair.Enabled
    CrosshairLines.Left.Visible = Config.Visuals.Crosshair.Enabled; CrosshairLines.Right.Visible = Config.Visuals.Crosshair.Enabled
    
    local cx, cy = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2
    local gap, size = Config.Visuals.Crosshair.Gap, Config.Visuals.Crosshair.Size
    CrosshairLines.Top.From = Vector2.new(cx, cy - gap); CrosshairLines.Top.To = Vector2.new(cx, cy - gap - size)
    CrosshairLines.Bottom.From = Vector2.new(cx, cy + gap); CrosshairLines.Bottom.To = Vector2.new(cx, cy + gap + size)
    CrosshairLines.Left.From = Vector2.new(cx - gap, cy); CrosshairLines.Left.To = Vector2.new(cx - gap - size, cy)
    CrosshairLines.Right.From = Vector2.new(cx + gap, cy); CrosshairLines.Right.To = Vector2.new(cx + gap + size, cy)
    for _, l in pairs(CrosshairLines) do l.Color = Config.Visuals.Crosshair.Color end

    -- Anti-Void
    if Config.Player.AntiVoid and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        if LocalPlayer.Character.HumanoidRootPart.Position.Y < -50 then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0) -- Кидает наверх
        end
    end

    -- Noclip
    if Config.Player.Noclip and LocalPlayer.Character then
        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
    end

    -- Fly
    if Config.Player.FlyEnabled and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); local flyVel = hrp and hrp:FindFirstChild("ZenitFly")
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

    -- Вращение Ауры
    if AuraAttachment and AuraAttachment.Parent then
        AuraAngle = AuraAngle + (dt * Config.Visuals.Aura.Speed)
        local rad = Config.Visuals.Aura.Size
        AuraAttachment.Position = Vector3.new(math.cos(AuraAngle) * rad, math.sin(AuraAngle * 2) * (rad / 2), math.sin(AuraAngle) * rad)
    end

    -- Отрисовка ESP
    for player, draw in pairs(ESPObjects) do
        local char = player.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChild("Humanoid")
        local distToCam = hrp and (Camera.CFrame.Position - hrp.Position).Magnitude or 0

        if Config.Visuals.ESP.Enabled and hrp and hum and hum.Health > 0 and distToCam <= Config.Visuals.ESP.MaxDistance then
            local topPos = hrp.Position + Vector3.new(0, 2.5, 0); local botPos = hrp.Position - Vector3.new(0, 3, 0)
            local tVP, tVis = Camera:WorldToViewportPoint(topPos); local bVP, bVis = Camera:WorldToViewportPoint(botPos)

            if tVis or bVis then
                local h = math.abs(bVP.Y - tVP.Y); local w = h * 0.6; local x = (tVP.X + bVP.X) / 2 - w / 2; local y = tVP.Y
                
                -- Бокс
                draw.Box.Size = Vector2.new(w, h); draw.Box.Position = Vector2.new(x, y)
                draw.Box.Visible = Config.Visuals.ESP.Boxes; draw.Box.Color = Config.Visuals.ESP.Colors.Box
                draw.Box.Filled = Config.Visuals.ESP.BoxFilled; draw.Box.Thickness = Config.Visuals.ESP.BoxThickness
                
                -- Имя и Дистанция
                local d = math.floor(distToCam)
                draw.Name.Text = player.Name; draw.Name.Position = Vector2.new(x + w/2, y - 20)
                draw.Name.Visible = Config.Visuals.ESP.Names; draw.Name.Size = Config.Visuals.ESP.TextSize; draw.Name.Color = Config.Visuals.ESP.Colors.Name
                draw.Dist.Text = "[" .. d .. "m]"; draw.Dist.Position = Vector2.new(x + w/2, y - 6)
                draw.Dist.Visible = Config.Visuals.ESP.Distance; draw.Dist.Size = Config.Visuals.ESP.TextSize - 2; draw.Dist.Color = Config.Visuals.ESP.Colors.Distance

                -- Хелсбар
                local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                if Config.Visuals.ESP.HealthBarType == "Side" then
                    draw.HealthBg.Size = Vector2.new(3, h); draw.HealthBg.Position = Vector2.new(x - 6, y)
                    draw.HealthFill.Size = Vector2.new(3, h * hp); draw.HealthFill.Position = Vector2.new(x - 6, y + h - (h * hp))
                else
                    draw.HealthBg.Size = Vector2.new(w, 3); draw.HealthBg.Position = Vector2.new(x, y - 4)
                    draw.HealthFill.Size = Vector2.new(w * hp, 3); draw.HealthFill.Position = Vector2.new(x, y - 4)
                end
                draw.HealthBg.Visible = Config.Visuals.ESP.Health; draw.HealthFill.Visible = Config.Visuals.ESP.Health
                draw.HealthFill.Color = Color3.fromHSV(hp * 0.33, 1, 1)
                
                -- Трассеры
                draw.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y); draw.Tracer.To = Vector2.new(x + w / 2, y + h)
                draw.Tracer.Visible = Config.Visuals.ESP.Tracers; draw.Tracer.Color = Config.Visuals.ESP.Colors.Tracer
                
                -- Chams
                if draw.Chams then 
                    draw.Chams.Enabled = Config.Visuals.ESP.Chams
                    draw.Chams.FillColor = Config.Visuals.ESP.Colors.Chams
                end
                
                -- Скелет
                if Config.Visuals.ESP.Skeleton then
                    local head = char:FindFirstChild("Head"); local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                    local lArm = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm"); local rArm = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")
                    local lLeg = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg"); local rLeg = char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg")

                    if Config.Visuals.ESP.Bones.Head and head and torso then DrawLine(draw.Skel[1], head.Position, torso.Position) draw.Skel[1].Color = Config.Visuals.ESP.Colors.Skeleton else draw.Skel[1].Visible = false end
                    if Config.Visuals.ESP.Bones.LeftArm and torso and lArm then DrawLine(draw.Skel[2], torso.Position, lArm.Position) draw.Skel[2].Color = Config.Visuals.ESP.Colors.Skeleton else draw.Skel[2].Visible = false end
                    if Config.Visuals.ESP.Bones.RightArm and torso and rArm then DrawLine(draw.Skel[3], torso.Position, rArm.Position) draw.Skel[3].Color = Config.Visuals.ESP.Colors.Skeleton else draw.Skel[3].Visible = false end
                    if Config.Visuals.ESP.Bones.LeftLeg and torso and lLeg then DrawLine(draw.Skel[4], torso.Position, lLeg.Position) draw.Skel[4].Color = Config.Visuals.ESP.Colors.Skeleton else draw.Skel[4].Visible = false end
                    if Config.Visuals.ESP.Bones.RightLeg and torso and rLeg then DrawLine(draw.Skel[5], torso.Position, rLeg.Position) draw.Skel[5].Color = Config.Visuals.ESP.Colors.Skeleton else draw.Skel[5].Visible = false end
                else
                    for _, line in pairs(draw.Skel) do line.Visible = false end
                end
            else
                draw.Box.Visible = false; draw.Name.Visible = false; draw.Dist.Visible = false; draw.HealthBg.Visible = false; draw.HealthFill.Visible = false; draw.Tracer.Visible = false
                for _, line in pairs(draw.Skel) do line.Visible = false end
            end
        else
            draw.Box.Visible = false; draw.Name.Visible = false; draw.Dist.Visible = false; draw.HealthBg.Visible = false; draw.HealthFill.Visible = false; draw.Tracer.Visible = false
            for _, line in pairs(draw.Skel) do line.Visible = false end
        end
    end
end)

-- ============================================================================
-- СЕКЦИЯ 21: ФИНАЛЬНЫЕ ОБРАБОТЧИКИ
-- ============================================================================
UserInputService.JumpRequest:Connect(function()
    if Config.Player.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

LocalPlayer.Idled:Connect(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end)

task.spawn(function()
    while task.wait(2) do
        if Config.Misc.ChatSpam then
            game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents"):FindFirstChild("SayMessageRequest"):FireServer(Config.Misc.ChatSpamText, "All")
        end
    end
end)

StarterGui:SetCore("SendNotification", { Title = "Zenit V7", Text = "Загружено! Открывай меню.", Duration = 5 })
