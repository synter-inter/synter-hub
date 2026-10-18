-- ============================================================================
-- ZENIT x EXUNYS // ULTIMATE MOBILE HUB (Aimbot V3 + ESP)
-- ============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============================================================================
-- 1. ЗАГРУЗКА БИБЛИОТЕК EXUNYS
-- ============================================================================
-- Загружаем Aimbot V3
local Aimbot = loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/Aimbot-V3/main/src/Aimbot.lua"))()
Aimbot.Load()
task.wait(1) -- Даем время на инициализацию

-- Загружаем ESP
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/Exunys-ESP/main/src/ESP.lua"))()
ESP.Load()
task.wait(1)

-- Базовые настройки (если библиотеки загрузились)
if ExunysDeveloperAimbot then
    ExunysDeveloperAimbot.Settings.Aimbot.Toggle = true 
    ExunysDeveloperAimbot.Settings.Aimbot.TeamCheck = true
    ExunysDeveloperAimbot.Settings.Aimbot.VisibleCheck = true
    ExunysDeveloperAimbot.Settings.FOV.Enabled = true
    ExunysDeveloperAimbot.Settings.FOV.Radius = 150
end

if ExunysDeveloperESP then
    ExunysDeveloperESP.Settings.Enabled = true
    ExunysDeveloperESP.Settings.Players.Boxes.Enabled = true
    ExunysDeveloperESP.Settings.Players.Names.Enabled = true
    ExunysDeveloperESP.Settings.Players.Health.Enabled = true
end

-- ============================================================================
-- 2. КОНФИГУРАЦИЯ (Аура и Мувмент)
-- ============================================================================
local Config = {
    Aura = { 
        Type = "None", Size = 5, Speed = 2, Rate = 500,
        Colors = {
            Void = {Main = Color3.fromRGB(120, 0, 255), Sub = Color3.fromRGB(50, 0, 100), Light = Color3.fromRGB(150, 0, 255)},
            Toxic = {Main = Color3.fromRGB(0, 255, 50), Sub = Color3.fromRGB(0, 100, 20), Light = Color3.fromRGB(0, 255, 100)},
            Inferno = {Main = Color3.fromRGB(255, 50, 0), Sub = Color3.fromRGB(100, 0, 0), Light = Color3.fromRGB(255, 100, 0)},
            Ice = {Main = Color3.fromRGB(0, 200, 255), Sub = Color3.fromRGB(0, 50, 100), Light = Color3.fromRGB(100, 200, 255)}
        }
    },
    Player = { Speed = 16, Jump = 50, InfJump = false, Noclip = false }
}

-- ============================================================================
-- 3. ИНИЦИАЛИЗАЦИЯ UI (Rayfield)
-- ============================================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "Zenit x Exunys",
    LoadingTitle = "Загрузка Exunys Modules...",
    LoadingSubtitle = "by Promtik",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local CombatTab = Window:CreateTab("Combat (Aimbot V3)", 4483362458)
local VisualsTab = Window:CreateTab("Visuals (ESP)", 4483362458)
local AuraTab = Window:CreateTab("Aura FX", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)

-- ============================================================================
-- 4. UI: COMBAT (Aimbot V3)
-- ============================================================================
CombatTab:CreateSection("Aimbot Settings")
CombatTab:CreateToggle({ Name = "Enable Aimbot", CurrentValue = false, Flag = "AimEn", Callback = function(v) if ExunysDeveloperAimbot then ExunysDeveloperAimbot.Settings.Aimbot.Enabled = v end end })
CombatTab:CreateToggle({ Name = "Show FOV Circle", CurrentValue = true, Flag = "AimFOVShow", Callback = function(v) if ExunysDeveloperAimbot then ExunysDeveloperAimbot.Settings.FOV.Enabled = v end end })
CombatTab:CreateSlider({ Name = "Smoothness", Range = {0.01, 1}, Increment = 0.01, CurrentValue = 0.2, Flag = "AimSm", Callback = function(v) if ExunysDeveloperAimbot then ExunysDeveloperAimbot.Settings.Aimbot.Smoothness = v end end })
CombatTab:CreateSlider({ Name = "FOV Radius", Range = {50, 1000}, Increment = 10, CurrentValue = 150, Flag = "AimFov", Callback = function(v) if ExunysDeveloperAimbot then ExunysDeveloperAimbot.Settings.FOV.Radius = v end end })
CombatTab:CreateDropdown({ Name = "Target Part", Options = {"Head", "HumanoidRootPart", "UpperTorso"}, CurrentOption = {"Head"}, Flag = "AimPt", Callback = function(o) if ExunysDeveloperAimbot then ExunysDeveloperAimbot.Settings.Aimbot.Part = (type(o) == "table" and o[1] or o) end end })
CombatTab:CreateToggle({ Name = "Prediction", CurrentValue = true, Flag = "AimPred", Callback = function(v) if ExunysDeveloperAimbot then ExunysDeveloperAimbot.Settings.Aimbot.Prediction = v and 0.15 or 0 end end })
CombatTab:CreateToggle({ Name = "Team Check", CurrentValue = true, Flag = "AimTeam", Callback = function(v) if ExunysDeveloperAimbot then ExunysDeveloperAimbot.Settings.Aimbot.TeamCheck = v end end })
CombatTab:CreateToggle({ Name = "Wall Check", CurrentValue = false, Flag = "AimWall", Callback = function(v) if ExunysDeveloperAimbot then ExunysDeveloperAimbot.Settings.Aimbot.VisibleCheck = v end end })

-- ============================================================================
-- 5. UI: VISUALS (Exunys ESP)
-- ============================================================================
VisualsTab:CreateSection("ESP Settings")
VisualsTab:CreateToggle({ Name = "Enable ESP", CurrentValue = false, Flag = "EspEn", Callback = function(v) if ExunysDeveloperESP then ExunysDeveloperESP.Settings.Enabled = v end end })
VisualsTab:CreateToggle({ Name = "Boxes", CurrentValue = true, Flag = "EspBox", Callback = function(v) if ExunysDeveloperESP then ExunysDeveloperESP.Settings.Players.Boxes.Enabled = v end end })
VisualsTab:CreateToggle({ Name = "Names", CurrentValue = true, Flag = "EspName", Callback = function(v) if ExunysDeveloperESP then ExunysDeveloperESP.Settings.Players.Names.Enabled = v end end })
VisualsTab:CreateToggle({ Name = "Health Bars", CurrentValue = true, Flag = "EspHp", Callback = function(v) if ExunysDeveloperESP then ExunysDeveloperESP.Settings.Players.Health.Enabled = v end end })
VisualsTab:CreateToggle({ Name = "Distance", CurrentValue = true, Flag = "EspDist", Callback = function(v) if ExunysDeveloperESP then ExunysDeveloperESP.Settings.Players.Distance.Enabled = v end end })
VisualsTab:CreateToggle({ Name = "Tracers", CurrentValue = false, Flag = "EspTr", Callback = function(v) if ExunysDeveloperESP then ExunysDeveloperESP.Settings.Players.Tracers.Enabled = v end end })
VisualsTab:CreateToggle({ Name = "Skeleton", CurrentValue = false, Flag = "EspSkel", Callback = function(v) if ExunysDeveloperESP then ExunysDeveloperESP.Settings.Players.Skeletons.Enabled = v end end })
VisualsTab:CreateToggle({ Name = "Chams (Highlight)", CurrentValue = false, Flag = "EspCham", Callback = function(v) 
    -- Exunys ESP не делает Chams, поэтому мы включим его через Highlight отдельно (ниже в цикле)
    Config.ESPChams = v 
end })
VisualsTab:CreateColorPicker({ Name = "ESP Color", Color = Color3.fromRGB(170, 0, 255), Flag = "EspClr", Callback = function(v) 
    if ExunysDeveloperESP then 
        ExunysDeveloperESP.Settings.Players.Boxes.Color = v 
        ExunysDeveloperESP.Settings.Players.Names.Color = v
        ExunysDeveloperESP.Settings.Players.Tracers.Color = v
        ExunysDeveloperESP.Settings.Players.Skeletons.Color = v
    end 
end })

-- ============================================================================
-- 6. UI: AURA
-- ============================================================================
AuraTab:CreateSection("Aura Configuration")
AuraTab:CreateDropdown({ Name = "Aura Style", Options = {"None", "Void", "Toxic", "Inferno", "Ice"}, CurrentOption = {"None"}, Flag = "AuraDrop", Callback = function(o) Config.Aura.Type = type(o) == "table" and o[1] or o; UpdateAura() end })
AuraTab:CreateSlider({ Name = "Aura Size", Range = {1, 20}, Increment = 0.5, CurrentValue = 5, Flag = "AuraSize", Callback = function(v) Config.Aura.Size = v; UpdateAura() end })
AuraTab:CreateSlider({ Name = "Rotation Speed", Range = {0.1, 10}, Increment = 0.1, CurrentValue = 2, Flag = "AuraSpeed", Callback = function(v) Config.Aura.Speed = v end })
AuraTab:CreateSlider({ Name = "Particle Rate", Range = {100, 2000}, Increment = 50, CurrentValue = 500, Flag = "AuraRate", Callback = function(v) Config.Aura.Rate = v; UpdateAura() end })

-- ============================================================================
-- 7. UI: PLAYER
-- ============================================================================
PlayerTab:CreateSection("Movement")
PlayerTab:CreateSlider({ Name = "WalkSpeed", Range = {16, 300}, Increment = 1, CurrentValue = 16, Flag = "Spd", Callback = function(v) if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end end })
PlayerTab:CreateSlider({ Name = "JumpPower", Range = {50, 500}, Increment = 5, CurrentValue = 50, Flag = "Jmp", Callback = function(v) if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.JumpPower = v end end })
PlayerTab:CreateToggle({ Name = "Infinite Jump", CurrentValue = false, Flag = "InfJmp", Callback = function(v) Config.Player.InfJump = v end })
PlayerTab:CreateToggle({ Name = "Noclip", CurrentValue = false, Flag = "Noclip", Callback = function(v) Config.Player.Noclip = v end })

-- ============================================================================
-- 8. ЛОГИКА АУРЫ (Наш кастомный VFX)
-- ============================================================================
local AuraFolder, AuraAttachment, AuraAngle = nil, nil, 0

local function CreateAuraVFX(parent, size, rate, colorData)
    local att = Instance.new("Attachment", parent)
    local smoke = Instance.new("ParticleEmitter", att)
    smoke.Texture = "rbxassetid://243098098"; smoke.Rate = rate; smoke.LightEmission = 1; smoke.LightInfluence = 0
    smoke.Lifetime = NumberRange.new(0.8, 1.5); smoke.Speed = NumberRange.new(2, 5); smoke.SpreadAngle = Vector2.new(360, 360)
    smoke.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, size), NumberSequenceKeypoint.new(1, 0)})
    smoke.Color = ColorSequence.new(colorData.Main, colorData.Sub)
    smoke.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1)})
    
    local sparks = Instance.new("ParticleEmitter", att)
    sparks.Texture = "rbxassetid://2416027981"; sparks.Rate = rate / 2; sparks.LightEmission = 1
    sparks.Lifetime = NumberRange.new(0.5, 1); sparks.Speed = NumberRange.new(5, 10); sparks.SpreadAngle = Vector2.new(360, 360)
    sparks.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, size/2), NumberSequenceKeypoint.new(1, 0)})
    sparks.Color = ColorSequence.new(colorData.Light, colorData.Main)
    
    local light = Instance.new("PointLight", att); light.Brightness = 5; light.Range = size * 2; light.Color = colorData.Light
    return att
end

function UpdateAura()
    if AuraFolder then AuraFolder:Destroy() end
    local char = LocalPlayer.Character
    if not char or Config.Aura.Type == "None" then return end
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
    if not torso then return end
    
    local colorData = Config.Aura.Colors[Config.Aura.Type]
    local glow = Instance.new("Highlight", char)
    glow.Name = "AuraGlow"; glow.Adornee = char; glow.FillColor = colorData.Main; glow.FillTransparency = 0.4
    
    AuraFolder = Instance.new("Folder", torso)
    AuraAttachment = CreateAuraVFX(torso, Config.Aura.Size, Config.Aura.Rate, colorData)
end
LocalPlayer.CharacterAdded:Connect(function() task.wait(1); UpdateAura() end)

-- ============================================================================
-- 9. ГЛАВНЫЙ ЦИКЛ (Только Аура, Noclip и Chams)
-- ============================================================================
-- Exunys ESP и Aimbot работают сами по себе (внутри себя), мы им не мешаем.
RunService.RenderStepped:Connect(function(dt)
    -- Noclip
    if Config.Player.Noclip and LocalPlayer.Character then
        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
    end

    -- Вращение Ауры
    if AuraAttachment and AuraAttachment.Parent then
        AuraAngle += dt * Config.Aura.Speed
        local r = Config.Aura.Size
        AuraAttachment.Position = Vector3.new(math.cos(AuraAngle) * r, math.sin(AuraAngle * 2) * (r/2), math.sin(AuraAngle) * r)
    end

    -- Chams (Дополнительный модуль, так как Exunys его не делает)
    if Config.ESPChams ~= nil then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hl = p.Character:FindFirstChild("ZenitChams") or Instance.new("Highlight", p.Character)
                hl.Name = "ZenitChams"
                hl.FillColor = ExunysDeveloperESP and ExunysDeveloperESP.Settings.Players.Boxes.Color or Color3.fromRGB(170, 0, 255)
                hl.Enabled = Config.ESPChams
            end
        end
    end
end)

-- ============================================================================
-- 10. ОБРАБОТЧИКИ
-- ============================================================================
UserInputService.JumpRequest:Connect(function()
    if Config.Player.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

StarterGui:SetCore("SendNotification", { Title = "Zenit x Exunys", Text = "Aimbot V3 и ESP библиотеки загружены!", Duration = 5 })
