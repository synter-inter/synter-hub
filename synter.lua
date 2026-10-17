-- SYNTER HUB | Premium Edition
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Очистка прошлой сессии
if _G.SynterCleanup then pcall(_G.SynterCleanup) end

local Config = {
    Aimbot = false, AimbotKey = false, FOV = 150, Smoothness = 0.15,
    ESP = false, Chams = false,
    Snow = true, Lang = "ru", Theme = "Dark", Accent = Color3.fromRGB(0, 210, 255)
}

local T = {
    ru = { title="SYNTER", aim="Аимбот", esp="ESP", chams="Chams", snow="Снег", theme="Тема", lang="Язык", unload="Выгрузить", fov="Радиус FOV", smooth="Плавность" },
    en = { title="SYNTER", aim="Aimbot", esp="ESP", chams="Chams", snow="Snow", theme="Theme", lang="Language", unload="Unload", fov="FOV Radius", smooth="Smoothness" }
}

local Connections = {}
local Drawings = {}
local Highlights = {}
local gui, main, snowGui

-- ======================
-- UI & Snow
-- ======================
local function buildUI()
    gui = Instance.new("ScreenGui")
    gui.Name = "SynterHubUI"
    gui.ResetOnSpawn = false
    pcall(function() gui.Parent = gethui() end) 
    if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

    main = Instance.new("Frame")
    main.Size = UDim2.new(0, 280, 0, 380)
    main.Position = UDim2.new(0.5, -140, 0.5, -190)
    main.BackgroundColor3 = Config.Theme == "Dark" and Color3.fromRGB(15, 15, 20) or Color3.fromRGB(240, 240, 245)
    main.BorderSizePixel = 0
    main.Parent = gui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Config.Accent
    stroke.Thickness = 1.5

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = T[Config.Lang].title
    title.TextColor3 = Config.Accent
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = main

    -- Перетаскивание
    local dragging, dragInput, dragStart, startPos
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Компоненты
    local yPos = 50
    local function addToggle(textStr, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 35)
        btn.Position = UDim2.new(0, 10, 0, yPos)
        btn.BackgroundColor3 = Config.Theme == "Dark" and Color3.fromRGB(25, 25, 30) or Color3.fromRGB(255, 255, 255)
        btn.Text = textStr .. ": ВЫКЛ"
        btn.TextColor3 = Config.Theme == "Dark" and Color3.new(1,1,1) or Color3.new(0,0,0)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.Parent = main
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        
        local state = false
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.Text = textStr .. (state and ": ВКЛ" or ": ВЫКЛ")
            btn.BackgroundColor3 = state and Config.Accent or (Config.Theme == "Dark" and Color3.fromRGB(25, 25, 30) or Color3.fromRGB(255, 255, 255))
            btn.TextColor3 = state and Color3.new(0,0,0) or (Config.Theme == "Dark" and Color3.new(1,1,1) or Color3.new(0,0,0))
            callback(state)
        end)
        yPos = yPos + 40
    end

    addToggle(T[Config.Lang].aim, function(s) Config.Aimbot = s end)
    addToggle(T[Config.Lang].esp, function(s) Config.ESP = s end)
    addToggle(T[Config.Lang].chams, function(s) Config.Chams = s end)
    addToggle(T[Config.Lang].snow, function(s) Config.Snow = s; snowGui.Enabled = s end)
    
    -- Выгрузка
    local unload = Instance.new("TextButton")
    unload.Size = UDim2.new(1, -20, 0, 35)
    unload.Position = UDim2.new(0, 10, 1, -45)
    unload.BackgroundColor3 = Color3.fromRGB(200, 50, 60)
    unload.Text = T[Config.Lang].unload
    unload.TextColor3 = Color3.new(1,1,1)
    unload.Font = Enum.Font.GothamBold
    unload.Parent = main
    Instance.new("UICorner", unload).CornerRadius = UDim.new(0, 6)
    unload.MouseButton1Click:Connect(function() if _G.SynterCleanup then _G.SynterCleanup() end end)

    -- Снег (отдельный GUI, чтобы работал при свернутом меню)
    snowGui = Instance.new("ScreenGui")
    snowGui.Name = "SynterSnow"
    snowGui.IgnoreGuiInset = true
    snowGui.DisplayOrder = 999
    pcall(function() snowGui.Parent = gethui() end)
    if not snowGui.Parent then snowGui.Parent = LP:WaitForChild("PlayerGui") end

    for i = 1, 70 do
        local flake = Instance.new("Frame")
        flake.Size = UDim2.new(0, math.random(2, 5), 0, math.random(2, 5))
        flake.BackgroundColor3 = Color3.new(1,1,1)
        flake.BackgroundTransparency = math.random(20, 60) / 100
        flake.Position = UDim2.new(math.random(), 0, math.random(), 0)
        flake.Parent = snowGui
        Instance.new("UICorner", flake).CornerRadius = UDim.new(1, 0)
        
        task.spawn(function()
            while flake.Parent do
                local speed = math.random(2, 6)
                local sway = math.random(-3, 3)
                flake.Position = flake.Position + UDim2.new(sway / 1000, 0, speed / 100, 0)
                if flake.Position.Y.Scale > 1 then
                    flake.Position = UDim2.new(math.random(), 0, -0.1, 0)
                end
                task.wait(0.03)
            end
        end)
    end
end

-- ======================
-- Aimbot (Camera)
-- ======================
local function getTarget()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local best, dist = nil, Config.FOV
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local h = p.Character:FindFirstChild("Head")
            local hum = p.Character:FindFirstChild("Humanoid")
            if h and hum and hum.Health > 0 then
                local sp, on = Camera:WorldToViewportPoint(h.Position)
                if on and sp.Z > 0 then
                    local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if d < dist then dist = d; best = h end
                end
            end
        end
    end
    return best
end

table.insert(Connections, RunService:BindToRenderStep("SynterAim", Enum.RenderPriority.Camera.Value + 1, function(dt)
    if Config.Aimbot and Config.AimbotKey then
        local target = getTarget()
        if target then
            local desired = CFrame.lookAt(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(desired, math.clamp(1 - Config.Smoothness, 0.05, 1))
        end
    end
end))

-- Кнопка для мобилок и ПКМ для ПК
local aimBtn = Instance.new("TextButton")
aimBtn.Size = UDim2.new(0, 70, 0, 70)
aimBtn.Position = UDim2.new(1, -90, 1, -120)
aimBtn.BackgroundColor3 = Config.Accent
aimBtn.BackgroundTransparency = 0.5
aimBtn.Text = "AIM"
aimBtn.TextColor3 = Color3.new(1,1,1)
aimBtn.Font = Enum.Font.GothamBold
aimBtn.Visible = UserInputService.TouchEnabled
aimBtn.Parent = gui
Instance.new("UICorner", aimBtn).CornerRadius = UDim.new(1,0)

aimBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then Config.AimbotKey = true end end)
aimBtn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then Config.AimbotKey = false end end)
table.insert(Connections, UserInputService.InputBegan:Connect(function(i, gp)
    if not gp and i.UserInputType == Enum.UserInputType.MouseButton2 then Config.AimbotKey = true end
end))
table.insert(Connections, UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton2 then Config.AimbotKey = false end
end))

-- ======================
-- ESP & Chams (Top Tier)
-- ======================
local function mkLine()
    local l = Drawing.new("Line")
    l.Visible = false
    l.Thickness = 1.5
    return l
end

local espTracked = {}

local function updateVisuals()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            -- Chams
            if Config.Chams then
                if not Highlights[p] or not Highlights[p].Parent then
                    local hl = Instance.new("Highlight")
                    hl.Adornee = p.Character
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.FillColor = Config.Accent
                    hl.OutlineColor = Color3.new(1,1,1)
                    hl.FillTransparency = 0.6
                    hl.Parent = p.Character
                    Highlights[p] = hl
                end
            else
                if Highlights[p] then Highlights[p]:Destroy() Highlights[p] = nil end
            end

            -- ESP
            if Config.ESP then
                if not espTracked[p] then
                    espTracked[p] = { name = Drawing.new("Text"), box = mkLine(), top = mkLine(), bot = mkLine(), left = mkLine(), right = mkLine() }
                    espTracked[p].name.Center = true; espTracked[p].name.Outline = true; espTracked[p].name.Size = 14; espTracked[p].name.Font = 2
                end
                local d = espTracked[p]
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local tl = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.5, 0))
                    local br = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                    if tl.Z > 0 and br.Z > 0 then
                        local h = math.abs(tl.Y - br.Y)
                        local w = h * 0.6
                        local x, y = tl.X - w/2, tl.Y
                        
                        d.name.Text = p.Name
                        d.name.Position = Vector2.new(tl.X, tl.Y - 16)
                        d.name.Color = Config.Accent
                        d.name.Visible = true
                        
                        d.top.From = Vector2.new(x, y); d.top.To = Vector2.new(x+w, y)
                        d.bot.From = Vector2.new(x, br.Y); d.bot.To = Vector2.new(x+w, br.Y)
                        d.left.From = Vector2.new(x, y); d.left.To = Vector2.new(x, br.Y)
                        d.right.From = Vector2.new(x+w, y); d.right.To = Vector2.new(x+w, br.Y)
                        
                        d.top.Visible = true; d.bot.Visible = true; d.left.Visible = true; d.right.Visible = true
                        d.top.Color = Config.Accent; d.bot.Color = Config.Accent; d.left.Color = Config.Accent; d.right.Color = Config.Accent
                    else
                        d.name.Visible = false; d.top.Visible = false; d.bot.Visible = false; d.left.Visible = false; d.right.Visible = false
                    end
                end
            elseif espTracked[p] then
                espTracked[p].name:Remove(); espTracked[p].top:Remove(); espTracked[p].bot:Remove(); espTracked[p].left:Remove(); espTracked[p].right:Remove()
                espTracked[p] = nil
            end
        end
    end
end
table.insert(Connections, RunService.RenderStepped:Connect(updateVisuals))

-- ======================
-- Cleanup
-- ======================
_G.SynterCleanup = function()
    for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
    pcall(function() RunService:UnbindFromRenderStep("SynterAim") end)
    for _, hl in pairs(Highlights) do pcall(function() hl:Destroy() end) end
    for _, d in pairs(espTracked) do
        pcall(function() d.name:Remove() d.top:Remove() d.bot:Remove() d.left:Remove() d.right:Remove() end)
    end
    if gui then gui:Destroy() end
    if snowGui then snowGui:Destroy() end
    _G.SynterCleanup = nil
end

-- Запуск
buildUI()
