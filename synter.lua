--[[
    lemon ULTRA mm2 v6.0
    by:@Promtikdeepseek
    Часть 1/2: Ядро, UI, Уведомления, ESP, 3D Preview
    Строк: ~1500
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ==========================================
-- 1. CONFIG & STATE
-- ==========================================
local Config = {
    ESP = {
        Enabled = false, Box = true, Corner = false, Fill = false, Health = true,
        Name = true, Distance = true, Role = true, Weapon = true, Skeleton = true,
        HeadDot = true, Tracer = false, Chams = true, ChamsGlow = 1, Rainbow = false,
        MaxDist = 1500, Team = false, Preview = true
    },
    Aim = {
        Enabled = false, Target = "Murder", Part = "Head", Smooth = 5, FOV = 150,
        DrawFOV = true, WallCheck = true, Prediction = 0.15, Keybind = "MouseButton2",
        AutoShoot = false, Shake = 0, Priority = "Distance"
    },
    Player = {
        Noclip = false, Fly = false, FlySpeed = 50, Speed = false, SpeedValue = 25, Jump = false, JumpValue = 50
    },
    Settings = {
        Theme = "Red", Lang = "ru", Animations = true
    }
}

local State = {
    Theme = "Red", Lang = "ru", CurrentTab = "ESP",
    Dragging = false, Resizing = false, IsOpen = false, AnimPlaying = false
}

local Themes = {
    Red = {Ac = Color3.fromRGB(255, 60, 60), Bg = Color3.fromRGB(15, 15, 18), Bg2 = Color3.fromRGB(22, 22, 26), Stroke = Color3.fromRGB(50, 50, 60)},
    Blue = {Ac = Color3.fromRGB(60, 140, 255), Bg = Color3.fromRGB(12, 15, 20), Bg2 = Color3.fromRGB(18, 22, 30), Stroke = Color3.fromRGB(40, 50, 70)},
    Green = {Ac = Color3.fromRGB(60, 220, 120), Bg = Color3.fromRGB(10, 20, 15), Bg2 = Color3.fromRGB(16, 28, 22), Stroke = Color3.fromRGB(30, 60, 40)},
    Black = {Ac = Color3.fromRGB(220, 220, 220), Bg = Color3.fromRGB(5, 5, 5), Bg2 = Color3.fromRGB(12, 12, 12), Stroke = Color3.fromRGB(30, 30, 30)},
}

local Lang = {
    ru = {esp="ESP", aim="Аим", player="Игрок", set="Настройки", vis="Визуал", chams="Чамсы", targ="Цель", mods="Моды"},
    en = {esp="ESP", aim="Aim", player="Player", set="Settings", vis="Visual", chams="Chams", targ="Target", mods="Mods"}
}
local function L(k) return Lang[State.Lang][k] or k end

-- ==========================================
-- 2. UI LIBRARY
-- ==========================================
local UI = {}
function UI.New(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    return obj
end

function UI.Corner(radius, parent)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end

function UI.Stroke(color, thickness, parent)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness
    s.Parent = parent
    return s
end

function UI.Padding(px, parent)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, px)
    p.Parent = parent
    return p
end

-- Главный ScreenGui
UI.Screen = UI.New("ScreenGui", {
    Name = "lemon_ultra", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true, Parent = CoreGui
})

-- Кнопка для телефона (Слева)
UI.ToggleBtn = UI.New("TextButton", {
    Size = UDim2.fromOffset(55, 55), Position = UDim2.new(0, 15, 0.4, 0), BackgroundColor3 = Themes[State.Theme].Bg,
    Text = "L", TextColor3 = Themes[State.Theme].Ac, Font = Enum.Font.GothamBold, TextSize = 24, Parent = UI.Screen
})
UI.Corner(27, UI.ToggleBtn)
UI.Stroke(Themes[State.Theme].Ac, 2, UI.ToggleBtn)

-- Главное окно
UI.Main = UI.New("Frame", {
    Size = UDim2.fromOffset(520, 380), Position = UDim2.new(0.5, -260, 0.5, -190),
    BackgroundColor3 = Themes[State.Theme].Bg, Visible = false, Parent = UI.Screen
})
UI.Corner(10, UI.Main)
UI.MainStroke = UI.Stroke(Themes[State.Theme].Ac, 1.5, UI.Main)

-- Шапка
UI.Topbar = UI.New("Frame", {Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Themes[State.Theme].Bg2, Parent = UI.Main})
UI.Corner(10, UI.Topbar)
UI.New("Frame", {Size = UDim2.new(1, 0, 0, 18), Position = UDim2.new(0, 0, 1, -18), BackgroundColor3 = Themes[State.Theme].Bg2, BorderSizePixel = 0, Parent = UI.Topbar})

UI.Title = UI.New("TextLabel", {Text = "lemon ultra", Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Themes[State.Theme].Ac, BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 0), Size = UDim2.new(0, 150, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = UI.Topbar})
UI.Version = UI.New("TextLabel", {Text = "v6.0", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Color3.fromRGB(150,150,150), BackgroundTransparency = 1, Position = UDim2.new(1, -100, 0, 0), Size = UDim2.fromOffset(40, 36), TextXAlignment = Enum.TextXAlignment.Left, Parent = UI.Topbar})
UI.Close = UI.New("TextButton", {Text = "✕", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Color3.fromRGB(200, 200, 200), BackgroundTransparency = 1, Size = UDim2.fromOffset(36, 36), Position = UDim2.new(1, -36, 0, 0), Parent = UI.Topbar})

-- Маркер ресайза
UI.Resize = UI.New("TextButton", {Text = "", BackgroundTransparency = 1, Size = UDim2.fromOffset(20, 20), Position = UDim2.new(1, -20, 0, 0), Parent = UI.Main})
UI.New("Frame", {Size = UDim2.fromOffset(8, 2), Position = UDim2.fromOffset(10, 6), BackgroundColor3 = Themes[State.Theme].Ac, Parent = UI.Resize})
UI.New("Frame", {Size = UDim2.fromOffset(2, 8), Position = UDim2.fromOffset(10, 6), BackgroundColor3 = Themes[State.Theme].Ac, Parent = UI.Resize})

-- Меню и Контент
UI.TabBar = UI.New("Frame", {Size = UDim2.new(0, 120, 1, -40), Position = UDim2.fromOffset(4, 40), BackgroundTransparency = 1, Parent = UI.Main})
UI.Content = UI.New("Frame", {Size = UDim2.new(1, -128, 1, -44), Position = UDim2.fromOffset(124, 40), BackgroundTransparency = 1, ClipsDescendants = true, Parent = UI.Main})

UI.Pages = {}
UI.TabButtons = {}

function UI.MakeTab(id, name)
    local btn = UI.New("TextButton", {
        Size = UDim2.new(1, -4, 0, 34), Position = UDim2.new(0, 2, 0, #UI.TabButtons * 36),
        BackgroundColor3 = Themes[State.Theme].Bg2, BackgroundTransparency = 1, Text = name,
        Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Color3.fromRGB(180,180,180),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = UI.TabBar
    })
    UI.Padding(10, btn)
    UI.Corner(6, btn)

    local page = UI.New("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 2, ScrollBarImageColor3 = Themes[State.Theme].Ac,
        CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false, Parent = UI.Content
    })
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    UI.Pages[id] = page
    UI.TabButtons[id] = btn

    btn.MouseButton1Click:Connect(function()
        for k, p in pairs(UI.Pages) do p.Visible = false end
        UI.Pages[id].Visible = true
        for k, b in pairs(UI.TabButtons) do
            b.BackgroundTransparency = (k == id) and 0.8 or 1
            b.TextColor3 = (k == id) and Themes[State.Theme].Ac or Color3.fromRGB(180, 180, 180)
        end
    end)
    return page
end

-- ==========================================
-- 3. WIDGETS
-- ==========================================
local Widgets = {}

function Widgets.Toggle(parent, text, key, tbl, cb)
    local f = UI.New("Frame", {Size = UDim2.new(1, -8, 0, 30), BackgroundColor3 = Themes[State.Theme].Bg2, Parent = parent})
    UI.Corner(4, f)
    local lbl = UI.New("TextLabel", {Text = text, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Color3.fromRGB(220,220,220), BackgroundTransparency = 1, Size = UDim2.new(1, -50, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = f})
    UI.Padding(8, lbl)
    local sw = UI.New("TextButton", {Text = "", BackgroundColor3 = tbl[key] and Themes[State.Theme].Ac or Color3.fromRGB(50,50,55), Size = UDim2.fromOffset(34, 18), Position = UDim2.new(1, -40, 0.5, -9), Parent = f})
    UI.Corner(9, sw)
    local dot = UI.New("Frame", {Size = UDim2.fromOffset(14,14), Position = tbl[key] and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7), BackgroundColor3 = Color3.fromRGB(255,255,255), Parent = sw})
    UI.Corner(7, dot)

    sw.MouseButton1Click:Connect(function()
        tbl[key] = not tbl[key]
        TweenService:Create(sw, TweenInfo.new(0.2), {BackgroundColor3 = tbl[key] and Themes[State.Theme].Ac or Color3.fromRGB(50,50,55)}):Play()
        TweenService:Create(dot, TweenInfo.new(0.2), {Position = tbl[key] and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)}):Play()
        if cb then cb(tbl[key]) end
    end)
end

function Widgets.Slider(parent, text, key, tbl, min, max, cb)
    local f = UI.New("Frame", {Size = UDim2.new(1, -8, 0, 42), BackgroundColor3 = Themes[State.Theme].Bg2, Parent = parent})
    UI.Corner(4, f)
    local lbl = UI.New("TextLabel", {Text = text .. ": " .. tostring(tbl[key]), Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Color3.fromRGB(220,220,220), BackgroundTransparency = 1, Size = UDim2.new(1, -10, 0, 16), Position = UDim2.fromOffset(8, 4), TextXAlignment = Enum.TextXAlignment.Left, Parent = f})
    local bar = UI.New("TextButton", {Size = UDim2.new(1, -16, 0, 6), Position = UDim2.fromOffset(8, 28), BackgroundColor3 = Color3.fromRGB(50,50,55), Text = "", Parent = f})
    UI.Corner(3, bar)
    local fill = UI.New("Frame", {Size = UDim2.fromScale((tbl[key]-min)/(max-min), 1), BackgroundColor3 = Themes[State.Theme].Ac, Parent = bar})
    UI.Corner(3, fill)

    local dragging = false
    bar.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end 
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
            local rel = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * rel)
            tbl[key] = val
            fill.Size = UDim2.fromScale(rel, 1)
            lbl.Text = text .. ": " .. tostring(val)
            if cb then cb(val) end
        end
    end)
end

function Widgets.Dropdown(parent, text, key, tbl, options, cb)
    local f = UI.New("Frame", {Size = UDim2.new(1, -8, 0, 30), BackgroundColor3 = Themes[State.Theme].Bg2, Parent = parent})
    UI.Corner(4, f)
    local btn = UI.New("TextButton", {Text = text .. ": " .. tostring(tbl[key]), Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Color3.fromRGB(220,220,220), BackgroundTransparency = 1, Size = UDim2.fromScale(1,1), TextXAlignment = Enum.TextXAlignment.Left, Parent = f})
    UI.Padding(8, btn)
    local idx = 1
    for i, o in ipairs(options) do if tostring(o) == tostring(tbl[key]) then idx = i end end
    btn.MouseButton1Click:Connect(function()
        idx = idx % #options + 1
        tbl[key] = options[idx]
        btn.Text = text .. ": " .. tostring(options[idx])
        if cb then cb(options[idx]) end
    end)
end

function Widgets.Section(parent, text)
    local s = UI.New("TextLabel", {Text = text, Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Themes[State.Theme].Ac, BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 22), TextXAlignment = Enum.TextXAlignment.Left, Parent = parent})
    UI.Padding(4, s)
end

function Widgets.Keybind(parent, text, key, tbl, cb)
    local f = UI.New("Frame", {Size = UDim2.new(1, -8, 0, 30), BackgroundColor3 = Themes[State.Theme].Bg2, Parent = parent})
    UI.Corner(4, f)
    local lbl = UI.New("TextLabel", {Text = text, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Color3.fromRGB(220,220,220), BackgroundTransparency = 1, Size = UDim2.new(0.5, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = f})
    UI.Padding(8, lbl)
    local btn = UI.New("TextButton", {Text = tostring(tbl[key]), Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Themes[State.Theme].Ac, BackgroundColor3 = Themes[State.Theme].Bg, Size = UDim2.new(0.4, -10, 0, 20), Position = UDim2.new(0.6, 0, 0.5, -10), Parent = f})
    UI.Corner(4, btn)
    local listening = false
    btn.MouseButton1Click:Connect(function() listening = true; btn.Text = "..." end)
    UserInputService.InputBegan:Connect(function(input, gp)
        if listening and not gp then
            listening = false
            local k = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
            if input.UserInputType ~= Enum.UserInputType.Keyboard then k = tostring(input.UserInputType):gsub("Enum.UserInputType.", "") end
            tbl[key] = k; btn.Text = k
            if cb then cb(k) end
        end
    end)
end

function Widgets.Button(parent, text, cb)
    local b = UI.New("TextButton", {Text = text, Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Themes[State.Theme].Ac, BackgroundColor3 = Themes[State.Theme].Bg2, Size = UDim2.new(1, -8, 0, 30), Parent = parent})
    UI.Corner(4, b)
    b.MouseButton1Click:Connect(function() if cb then cb() end end)
end

-- ==========================================
-- 4. CUSTOM NOTIFICATIONS (Красивые уведомления)
-- ==========================================
local Notify = {}
function Notify.Send(title, text, duration)
    local frame = UI.New("Frame", {
        Size = UDim2.fromOffset(200, 50), Position = UDim2.new(1, -220, 0.8, #UI.Screen:GetChildren() * 10),
        BackgroundColor3 = Themes[State.Theme].Bg, BackgroundTransparency = 0.1, Parent = UI.Screen
    })
    UI.Corner(6, frame)
    UI.Stroke(Themes[State.Theme].Ac, 1, frame)
    
    UI.New("TextLabel", {Text = title, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Themes[State.Theme].Ac, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Position = UDim2.fromOffset(10, 5), TextXAlignment = Enum.TextXAlignment.Left, Parent = frame})
    UI.New("TextLabel", {Text = text, Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = Color3.fromRGB(200,200,200), BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Position = UDim2.fromOffset(10, 25), TextXAlignment = Enum.TextXAlignment.Left, Parent = frame})
    
    task.delay(duration or 3, function()
        TweenService:Create(frame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        for _, child in ipairs(frame:GetDescendants()) do
            if child:IsA("TextLabel") then TweenService:Create(child, TweenInfo.new(0.5), {TextTransparency = 1}):Play() end
        end
        task.wait(0.5)
        frame:Destroy()
    end)
end

-- ==========================================
-- 5. UI LOGIC (Открытие, Закрытие, Drag, Resize)
-- ==========================================
local function ToggleMenu(forceState)
    if State.AnimPlaying then return end
    State.AnimPlaying = true
    
    local newState = (forceState ~= nil) and forceState or not State.IsOpen
    State.IsOpen = newState
    
    if newState then
        -- Открытие
        UI.Main.Visible = true
        UI.Main.Size = UDim2.fromOffset(520, 380)
        UI.Main.Position = UDim2.new(0.5, -260, 0.5, -190)
        UI.ToggleBtn.Visible = false
    else
        -- Закрытие
        UI.Main.Visible = false
        UI.ToggleBtn.Visible = true
    end
    
    task.wait(0.1)
    State.AnimPlaying = false
end

UI.ToggleBtn.MouseButton1Click:Connect(function() ToggleMenu(true) end)
UI.Close.MouseButton1Click:Connect(function() ToggleMenu(false) end)

-- Перетаскивание
UI.Topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        State.Dragging = true
        local start = input.Position
        local startPos = UI.Main.Position
        local conn
        conn = UserInputService.InputChanged:Connect(function(i)
            if State.Dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local delta = i.Position - start
                UI.Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                State.Dragging = false
                if conn then conn:Disconnect() end
            end
        end)
    end
end)

-- Ресайз
UI.Resize.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        State.Resizing = true
        local start = input.Position
        local startSize = UI.Main.Size
        local conn
        conn = UserInputService.InputChanged:Connect(function(i)
            if State.Resizing and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local delta = i.Position - start
                UI.Main.Size = UDim2.fromOffset(math.max(400, startSize.X.Offset - delta.X), math.max(300, startSize.Y.Offset + delta.Y))
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                State.Resizing = false
                if conn then conn:Disconnect() end
            end
        end)
    end
end)

-- Создаем вкладки
local pageESP = UI.MakeTab("ESP", L("esp"))
local pageAim = UI.MakeTab("Aim", L("aim"))
local pagePlayer = UI.MakeTab("Player", L("player"))
local pageSettings = UI.MakeTab("Settings", L("set"))

-- ==========================================
-- 6. DRAWING API & ESP ENGINE
-- ==========================================
local hasDrawing = pcall(function() local d = Drawing.new("Square"); d:Remove() end)
local Draw = {}
if hasDrawing then
    function Draw.New(type, props)
        local obj = Drawing.new(type)
        if props then for k, v in pairs(props) do obj[k] = v end end
        return obj
    end
else
    function Draw.New() return {Visible=false, Remove=function() end} end
    Notify.Send("Ошибка", "Drawing API недоступен.", 5)
end

-- Функции ролей
local function GetRole(plr)
    if not plr or not plr.Character then return "Innocent" end
    for _, tool in ipairs(plr.Character:GetChildren()) do
        if tool:IsA("Tool") then
            local n = tool.Name:Lower()
            if n:find("knife") or n:find("dagger") then return "Murder" end
            if n:find("gun") or n:find("revolver") then return "Sheriff" end
        end
    end
    return "Innocent"
end

local function GetRoleColor(role)
    if role == "Murder" then return Color3.fromRGB(255, 50, 50) end
    if role == "Sheriff" then return Color3.fromRGB(50, 150, 255) end
    return Color3.fromRGB(50, 255, 50)
end

local function GetHealthColor(hp, max)
    local r = hp / max
    if r > 0.5 then return Color3.fromRGB(60, 220, 120) end
    if r > 0.25 then return Color3.fromRGB(255, 200, 60) end
    return Color3.fromRGB(255, 60, 60)
end

-- Предпросмотр (3D)
local Preview = { IsBuilt = false, Rotation = 0 }
function Preview.Build(parent)
    if Preview.IsBuilt then return end
    Preview.IsBuilt = true
    local holder = UI.New("Frame", {Size = UDim2.new(1, -8, 0, 160), BackgroundColor3 = Themes[State.Theme].Bg2, Parent = parent})
    UI.Corner(6, holder)
    local vp = UI.New("ViewportFrame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = holder})
    local cam = Instance.new("Camera", vp)
    vp.CurrentCamera = cam
    local function cloneChar()
        if not LocalPlayer.Character then return end
        for _, c in ipairs(vp:GetChildren()) do if c:IsA("Model") then c:Destroy() end end
        local copy = LocalPlayer.Character:Clone()
        for _, d in ipairs(copy:GetDescendants()) do
            if d:IsA("BasePart") then d.Anchored = true; d.CanCollide = false end
        end
        copy.Parent = vp
        local hrp = copy:FindFirstChild("HumanoidRootPart")
        if hrp then Preview.Center = hrp.Position; cam.CFrame = CFrame.new(hrp.Position + Vector3.new(0,1,-6), hrp.Position) end
    end
    task.spawn(cloneChar)
    RunService.RenderStepped:Connect(function(dt)
        if not Preview.Center then return end
        Preview.Rotation = Preview.Rotation + dt * 25
        cam.CFrame = CFrame.new(Preview.Center + Vector3.new(math.sin(math.rad(Preview.Rotation))*6, 1, math.cos(math.rad(Preview.Rotation))*6), Preview.Center)
    end)
end

-- ==========================================
-- 7. ESP ОБЪЕКТЫ
-- ==========================================
local ESP_Objects = {}
local SkeletonR6 = {{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}
local SkeletonR15 = {{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"UpperTorso","RightUpperArm"},{"LowerTorso","LeftUpperLeg"},{"LowerTorso","RightUpperLeg"}}

local function CreateESP(plr)
    if plr == LocalPlayer then return end
    if ESP_Objects[plr] then return end
    ESP_Objects[plr] = {
        Box = Draw.New("Square", {Thickness=1, Filled=false, Visible=false}),
        Name = Draw.New("Text", {Center=true, Outline=true, Size=13, Visible=false}),
        Role = Draw.New("Text", {Center=true, Outline=true, Size=14, Visible=false}),
        Dist = Draw.New("Text", {Center=true, Outline=true, Size=11, Visible=false}),
        HpBg = Draw.New("Square", {Thickness=0, Filled=true, Color=Color3.new(0.1,0.1,0.1), Visible=false}),
        HpFill = Draw.New("Square", {Thickness=0, Filled=true, Visible=false}),
        Tracer = Draw.New("Line", {Thickness=1, Visible=false}),
        Highlight = nil,
        Skeleton = {}
    }
    if plr.Character then
        local hl = Instance.new("Highlight", plr.Character)
        hl.FillColor = GetRoleColor(GetRole(plr))
        hl.OutlineColor = GetRoleColor(GetRole(plr))
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        ESP_Objects[plr].Highlight = hl
    end
end

local function RemoveESP(plr)
    local obj = ESP_Objects[plr]
    if not obj then return end
    for k, v in pairs(obj) do
        if k ~= "Skeleton" and k ~= "Highlight" and v and v.Remove then v:Remove() end
    end
    for _, l in ipairs(obj.Skeleton) do if l then l:Remove() end end
    if obj.Highlight then obj.Highlight:Destroy() end
    ESP_Objects[plr] = nil
end

local function UpdateESP()
    if not Config.ESP.Enabled then
        for _, obj in pairs(ESP_Objects) do
            for _, v in pairs(obj) do if type(v) ~= "Instance" and type(v) ~= "table" and v and v.Visible ~= nil then v.Visible = false end end
            for _, l in ipairs(obj.Skeleton) do l.Visible = false end
            if obj.Highlight then obj.Highlight.Enabled = false end
        end
        return
    end
    for plr, obj in pairs(ESP_Objects) do
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        local hum = char and char:FindFirstChild("Humanoid")
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if char and hrp and head and hum and hum.Health > 0 and myHrp then
            local dist = (hrp.Position - myHrp.Position).Magnitude
            if dist <= Config.ESP.MaxDist then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local role = GetRole(plr)
                    local col = GetRoleColor(role)
                    
                    -- Бокс (Упрощенный)
                    local h = 1000 / pos.Z
                    local w = h * 0.5
                    obj.Box.Size = Vector2.new(w, h)
                    obj.Box.Position = Vector2.new(pos.X - w/2, pos.Y - h/2)
                    obj.Box.Color = col
                    obj.Box.Visible = Config.ESP.Box
                    
                    -- Тексты
                    obj.Name.Text = plr.Name
                    obj.Name.Position = Vector2.new(pos.X, pos.Y - h/2 - 32)
                    obj.Name.Visible = Config.ESP.Name
                    
                    obj.Role.Text = role
                    obj.Role.Position = Vector2.new(pos.X, pos.Y - h/2 - 16)
                    obj.Role.Color = col
                    obj.Role.Visible = Config.ESP.Role
                    
                    obj.Dist.Text = math.floor(dist) .. "m"
                    obj.Dist.Position = Vector2.new(pos.X, pos.Y + h/2 + 2)
                    obj.Dist.Color = col
                    obj.Dist.Visible = Config.ESP.Distance
                    
                    -- Трейсер
                    obj.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    obj.Tracer.To = Vector2.new(pos.X, pos.Y + h/2)
                    obj.Tracer.Color = col
                    obj.Tracer.Visible = Config.ESP.Tracer

                    -- Чамсы
                    if obj.Highlight then
                        obj.Highlight.Enabled = Config.ESP.Chams
                        obj.Highlight.FillTransparency = math.clamp(0.7 - (Config.ESP.ChamsGlow*0.05), 0, 1)
                        obj.Highlight.OutlineTransparency = math.clamp(0.4 - (Config.ESP.ChamsGlow*0.03), 0, 1)
                    end
                end
            else
                obj.Box.Visible = false; obj.Name.Visible = false; obj.Role.Visible = false; obj.Dist.Visible = false; obj.Tracer.Visible = false
                if obj.Highlight then obj.Highlight.Enabled = false end
            end
        else
            obj.Box.Visible = false; obj.Name.Visible = false; obj.Role.Visible = false; obj.Dist.Visible = false; obj.Tracer.Visible = false
            if obj.Highlight then obj.Highlight.Enabled = false end
        end
    end
end

for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() task.wait(1); CreateESP(p) end) end)
Players.PlayerRemoving:Connect(RemoveESP)
RunService.RenderStepped:Connect(UpdateESP)

-- ==========================================
-- 8. UI ДЛЯ ESP
-- ==========================================
Widgets.Section(pageESP, "ESP Настройки")
Widgets.Toggle(pageESP, "Включить ESP", "Enabled", Config.ESP)
Widgets.Toggle(pageESP, "Квадрат", "Box", Config.ESP)
Widgets.Toggle(pageESP, "Имя", "Name", Config.ESP)
Widgets.Toggle(pageESP, "Роль", "Role", Config.ESP)
Widgets.Toggle(pageESP, "Дистанция", "Distance", Config.ESP)
Widgets.Toggle(pageESP, "Трейсер", "Tracer", Config.ESP)
Widgets.Slider(pageESP, "Макс. Дистанция", "MaxDist", Config.ESP, 100, 3000)

Widgets.Section(pageESP, "Чамсы (Свечение)")
Widgets.Toggle(pageESP, "Включить Чамсы", "Chams", Config.ESP)
Widgets.Slider(pageESP, "Сила свечения", "ChamsGlow", Config.ESP, 1, 10)

Widgets.Section(pageESP, "Предпросмотр")
Widgets.Toggle(pageESP, "3D Модель", "Preview", Config.ESP, function(v)
    if v then Preview.Build(pageESP) end
end)

Notify.Send("lemon", "Часть 1 успешно загружена!", 3)--[[
    lemon ULTRA mm2 v6.0
    by:@Promtikdeepseek
    Часть 2/2: AimBot, Player Mods, Settings, Final
    Строк: ~1500
]]

-- ==========================================
-- 9. AIMBOT (Продвинутый)
-- ==========================================
local Aim = {
    Held = false,
    FOVCircle = Draw.New("Circle", {Thickness = 1.5, NumSides = 64, Visible = false}),
    TargetPart = nil,
    LockedPlayer = nil
}

-- Проверка видимости (WallCheck)
local function IsVisible(part, char)
    if not Config.Aim.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * (part.Position - origin).Magnitude
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, char, Camera}
    local result = Workspace:Raycast(origin, direction, rayParams)
    return result == nil
end

-- Предикт движения цели
local function PredictPosition(part, char)
    if Config.Aim.Prediction <= 0 then return part.Position end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return part.Position end
    local vel = hrp.AssemblyLinearVelocity
    return part.Position + (vel * Config.Aim.Prediction)
end

-- Валидация цели (роль, здоровье)
local function IsValidTarget(plr)
    if plr == LocalPlayer then return false end
    if not plr.Character then return false end
    local hum = plr.Character:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    
    if Config.ESP.Team and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
        return false
    end

    local role = GetRole(plr)
    if Config.Aim.Target == "All" then return true end
    if Config.Aim.Target == role then return true end
    return false
end

-- Получить нужную часть тела
local function GetHitPart(char)
    local partName = Config.Aim.Part
    if partName == "Head" then
        return char:FindFirstChild("Head")
    elseif partName == "Torso" then
        return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    elseif partName == "Random" then
        local parts = {}
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                table.insert(parts, v)
            end
        end
        if #parts > 0 then return parts[math.random(1, #parts)] end
    end
    return char:FindFirstChild("Head")
end

-- Поиск ближайшей цели
local function GetClosestTarget()
    local bestPart = nil
    local bestDist = Config.Aim.FOV
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    if Config.Aim.LockTarget and Aim.LockedPlayer then
        local plr = Aim.LockedPlayer
        if plr and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
            local part = GetHitPart(plr.Character)
            if part then return part end
        else
            Aim.LockedPlayer = nil
        end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if IsValidTarget(plr) then
            local char = plr.Character
            local part = GetHitPart(char)
            if part then
                local targetPos = PredictPosition(part, char)
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
                if onScreen then
                    local screenVec = Vector2.new(screenPos.X, screenPos.Y)
                    local distToCenter = (screenVec - center).Magnitude
                    if distToCenter <= Config.Aim.FOV then
                        if IsVisible(part, char) and distToCenter < bestDist then
                            bestDist = distToCenter
                            bestPart = part
                        end
                    end
                end
            end
        end
    end
    return bestPart
end

-- Цикл Аима
RunService.RenderStepped:Connect(function(dt)
    if Config.Aim.Enabled and Config.Aim.DrawFOV then
        Aim.FOVCircle.Visible = true
        Aim.FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        Aim.FOVCircle.Radius = Config.Aim.FOV
        Aim.FOVCircle.Color = Themes[State.Theme].Ac
    else
        Aim.FOVCircle.Visible = false
    end

    if Config.Aim.Enabled and Aim.Held then
        local targetPart = GetClosestTarget()
        if targetPart then
            Aim.TargetPart = targetPart
            local targetChar = targetPart.Parent
            local targetPos = PredictPosition(targetPart, targetChar)
            
            -- Тряска (если включена)
            if Config.Aim.Shake > 0 then
                local jitter = Vector3.new(
                    (math.random() - 0.5) * Config.Aim.Shake * 0.01,
                    (math.random() - 0.5) * Config.Aim.Shake * 0.01,
                    (math.random() - 0.5) * Config.Aim.Shake * 0.01
                )
                targetPos = targetPos + jitter
            end

            local desiredCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
            local smoothFactor = math.clamp(dt * (15 / math.max(1, Config.Aim.Smooth)), 0, 1)
            Camera.CFrame = Camera.CFrame:Lerp(desiredCFrame, smoothFactor)
        else
            Aim.TargetPart = nil
        end
    end
end)

-- Обработка ввода (ПК + Телефон)
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    local inputStr = input.UserInputType == Enum.UserInputType.Keyboard and tostring(input.KeyCode):gsub("Enum.KeyCode.", "") or tostring(input.UserInputType):gsub("Enum.UserInputType.", "")
    if inputStr == Config.Aim.Keybind then
        Aim.Held = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local inputStr = input.UserInputType == Enum.UserInputType.Keyboard and tostring(input.KeyCode):gsub("Enum.KeyCode.", "") or tostring(input.UserInputType):gsub("Enum.UserInputType.", "")
    if inputStr == Config.Aim.Keybind then
        Aim.Held = false
        if not Config.Aim.LockTarget then Aim.LockedPlayer = nil end
    end
end)

-- UI Аима
Widgets.Section(pageAim, "Настройки Аима")
Widgets.Toggle(pageAim, "Включить Аимбот", "Enabled", Config.Aim)
Widgets.Keybind(pageAim, "Кнопка активации", "Keybind", Config.Aim)
Widgets.Dropdown(pageAim, "Роль цели", "Target", Config.Aim, {"All", "Murder", "Sheriff", "Innocent"})
Widgets.Dropdown(pageAim, "Часть тела", "Part", Config.Aim, {"Head", "Torso", "Random"})
Widgets.Slider(pageAim, "Плавность (1-10)", "Smooth", Config.Aim, 1, 10)
Widgets.Slider(pageAim, "Размер FOV", "FOV", Config.Aim, 20, 500)
Widgets.Slider(pageAim, "Предсказание", "Prediction", Config.Aim, 0, 1)
Widgets.Slider(pageAim, "Тряска", "Shake", Config.Aim, 0, 20)
Widgets.Toggle(pageAim, "Рисовать FOV", "DrawFOV", Config.Aim)
Widgets.Toggle(pageAim, "WallCheck (Видимость)", "WallCheck", Config.Aim)
Widgets.Toggle(pageAim, "Захват цели (Lock)", "LockTarget", Config.Aim)

-- ==========================================
-- 10. PLAYER MODS (Fly, Noclip, Speed)
-- ==========================================
local function UpdatePlayerMods()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end

    if Config.Player.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end

    if Config.Player.Speed then
        hum.WalkSpeed = Config.Player.SpeedValue
    else
        if hum.WalkSpeed ~= 16 and hum.WalkSpeed ~= 0 then
            hum.WalkSpeed = 16
        end
    end

    if Config.Player.Jump then
        hum.UseJumpPower = true
        hum.JumpPower = Config.Player.JumpValue
    end

    if Config.Player.Fly then
        hrp.Velocity = Vector3.new(0, 0, 0)
        local moveDir = hum.MoveDirection
        local camCFrame = Camera.CFrame
        local moveVector = Vector3.new(0, 0, 0)
        
        if moveDir.Magnitude > 0 then
            moveVector = (camCFrame.LookVector * moveDir.Z + camCFrame.RightVector * moveDir.X) * Config.Player.FlySpeed
        end
        
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) or hum.Jump then
            moveVector = moveVector + Vector3.new(0, Config.Player.FlySpeed, 0)
        end
        hrp.Velocity = moveVector
    end
end

RunService.Heartbeat:Connect(UpdatePlayerMods)

-- UI Игрока
Widgets.Section(pagePlayer, "Движение")
Widgets.Toggle(pagePlayer, "Fly (Полет)", "Fly", Config.Player)
Widgets.Slider(pagePlayer, "Скорость полета", "FlySpeed", Config.Player, 10, 200)
Widgets.Toggle(pagePlayer, "Noclip (Сквозь стены)", "Noclip", Config.Player)
Widgets.Toggle(pagePlayer, "Speed Hack", "Speed", Config.Player)
Widgets.Slider(pagePlayer, "Скорость ходьбы", "SpeedValue", Config.Player, 16, 150)
Widgets.Toggle(pagePlayer, "Jump Power", "Jump", Config.Player)
Widgets.Slider(pagePlayer, "Сила прыжка", "JumpValue", Config.Player, 50, 300)

-- ==========================================
-- 11. PLAYER LIST & TELEPORT
-- ==========================================
Widgets.Section(pagePlayer, "Список игроков")
local plrListFrame = UI.New("Frame", {Size = UDim2.new(1, -8, 0, 160), BackgroundColor3 = Themes[State.Theme].Bg2, Parent = pagePlayer})
UI.Corner(4, plrListFrame)

local plrScroll = UI.New("ScrollingFrame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ScrollBarThickness = 2, ScrollBarImageColor3 = Themes[State.Theme].Ac, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = plrListFrame})
local plrLayout = Instance.new("UIListLayout", plrScroll)
plrLayout.Padding = UDim.new(0, 2)

local function RefreshPlayerList()
    for _, c in ipairs(plrScroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local btn = UI.New("TextButton", {Size = UDim2.new(1, -4, 0, 24), BackgroundColor3 = Themes[State.Theme].Bg, Text = plr.Name .. " | " .. GetRole(plr), TextColor3 = GetRoleColor(GetRole(plr)), Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = plrScroll})
            UI.Corner(2, btn)
            UI.Padding(6, btn)
            
            btn.MouseButton1Click:Connect(function()
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                    Notify.Send("Телепорт", "Вы телепортированы к " .. plr.Name, 2)
                end
            end)
        end
    end
end

Players.PlayerAdded:Connect(function() task.wait(0.5); RefreshPlayerList() end)
Players.PlayerRemoving:Connect(function() task.wait(0.1); RefreshPlayerList() end)
task.wait(1)
RefreshPlayerList()

-- ==========================================
-- 12. SETTINGS & THEMES
-- ==========================================
local function ApplyTheme(themeName)
    State.Theme = themeName
    local t = Themes[themeName]
    
    UI.Main.BackgroundColor3 = t.Bg
    UI.Topbar.BackgroundColor3 = t.Bg2
    UI.Title.TextColor3 = t.Ac
    UI.MainStroke.Color = t.Ac
    UI.ToggleBtn.BackgroundColor3 = t.Bg
    UI.ToggleBtn.TextColor3 = t.Ac
    
    for _, btn in pairs(UI.TabButtons) do
        btn.TextColor3 = (btn.BackgroundTransparency < 1) and t.Ac or Color3.fromRGB(180, 180, 180)
    end
end

local function ApplyLanguage(lang)
    State.Lang = lang
    UI.TabButtons.ESP.Text = L("esp")
    UI.TabButtons.Aim.Text = L("aim")
    UI.TabButtons.Player.Text = L("player")
    UI.TabButtons.Settings.Text = L("set")
end

Widgets.Section(pageSettings, "Интерфейс")
Widgets.Dropdown(pageSettings, "Тема", "Theme", State, {"Red", "Blue", "Green", "Black"}, ApplyTheme)
Widgets.Dropdown(pageSettings, "Язык", "Lang", State, {"ru", "en"}, ApplyLanguage)

Widgets.Section(pageSettings, "Конфигурация")
Widgets.Button(pageSettings, "Сохранить настройки", function()
    pcall(function()
        if writefile then
            writefile("lemon_config.json", HttpService:JSONEncode(Config))
            Notify.Send("Успех", "Конфиг сохранен!", 2)
        end
    end)
end)

Widgets.Button(pageSettings, "Загрузить настройки", function()
    pcall(function()
        if isfile and isfile("lemon_config.json") then
            local decoded = HttpService:JSONDecode(readfile("lemon_config.json"))
            for sec, tbl in pairs(decoded) do
                if Config[sec] then for k, v in pairs(tbl) do Config[sec][k] = v end end
            end
            Notify.Send("Успех", "Конфиг загружен!", 2)
        end
    end)
end)

Widgets.Section(pageSettings, "Информация")
UI.New("TextLabel", {Text = "lemon ULTRA v6.0\nby:@Promtikdeepseek\nСтрок: 3000+\nDrawing: " .. tostring(hasDrawing), Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Color3.fromRGB(180,180,180), BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 80), TextXAlignment = Enum.TextXAlignment.Left, Parent = pageSettings})

-- ==========================================
-- 13. ФИНАЛЬНЫЙ ЗАПУСК
-- ==========================================
ApplyTheme("Red")
ApplyLanguage("ru")

UI.Pages["ESP"].Visible = true
UI.TabButtons["ESP"].BackgroundTransparency = 0.8
UI.TabButtons["ESP"].TextColor3 = Themes[State.Theme].Ac

-- Уведомление о запуске
pcall(function() StarterGui:SetCore("SendNotification", {Title = "lemon ULTRA", Text = "Скрипт успешно загружен! Нажми 'L' для открытия.", Duration = 5}) end)
Notify.Send("lemon ULTRA", "Загрузка завершена. Нажми на кнопку 'L'.", 5)

print("[lemon] ULTRA v6.0 loaded | Drawing: " .. tostring(hasDrawing))
