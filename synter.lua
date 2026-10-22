--[[
    lemon PRO mm2 v5.0
    by:@Promtikdeepseek
    Part 1/5 - Core, UI Framework, Animations, Widgets
]]

local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local CoreGui            = game:GetService("CoreGui")
local Workspace          = game:GetService("Workspace")
local TweenService       = game:GetService("TweenService")
local HttpService        = game:GetService("HttpService")
local StarterGui         = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ==========================================
-- 1. CONFIGURATION & THEMES
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
        DrawFOV = true, WallCheck = true, Prediction = 0.15, Keybind = "MouseButton2"
    },
    Player = {
        Noclip = false, Fly = false, FlySpeed = 50, Speed = false, SpeedValue = 25, Jump = false, JumpValue = 50
    }
}

local State = {
    Theme = "Red", Lang = "ru", CurrentTab = "ESP",
    Dragging = false, Resizing = false, IsOpen = false
}

local Themes = {
    Red = {Ac = Color3.fromRGB(255, 60, 60), Bg = Color3.fromRGB(15, 15, 18), Bg2 = Color3.fromRGB(22, 22, 26), Stroke = Color3.fromRGB(50, 50, 60)},
    Blue = {Ac = Color3.fromRGB(60, 140, 255), Bg = Color3.fromRGB(12, 15, 20), Bg2 = Color3.fromRGB(18, 22, 30), Stroke = Color3.fromRGB(40, 50, 70)},
    Green = {Ac = Color3.fromRGB(60, 220, 120), Bg = Color3.fromRGB(10, 20, 15), Bg2 = Color3.fromRGB(16, 28, 22), Stroke = Color3.fromRGB(30, 60, 40)},
    Black = {Ac = Color3.fromRGB(220, 220, 220), Bg = Color3.fromRGB(5, 5, 5), Bg2 = Color3.fromRGB(12, 12, 12), Stroke = Color3.fromRGB(30, 30, 30)},
}

local function GetText(key)
    local lang = {
        ru = {esp="ESP", aim="Аим", player="Игрок", set="Настройки"},
        en = {esp="ESP", aim="Aim", player="Player", set="Settings"}
    }
    return lang[State.Lang][key] or key
end

-- ==========================================
-- 2. UI LIBRARY BASE
-- ==========================================
local UI = {}

function UI.Create(class, properties)
    local inst = Instance.new(class)
    for k, v in pairs(properties) do
        inst[k] = v
    end
    return inst
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
UI.Screen = UI.Create("ScreenGui", {
    Name = "lemon_v5",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    Parent = CoreGui
})

-- Кнопка для телефона (Слева)
UI.ToggleBtn = UI.Create("TextButton", {
    Size = UDim2.fromOffset(50, 50),
    Position = UDim2.new(0, 15, 0.4, 0),
    BackgroundColor3 = Themes[State.Theme].Bg,
    Text = "L",
    TextColor3 = Themes[State.Theme].Ac,
    Font = Enum.Font.GothamBold,
    TextSize = 22,
    Parent = UI.Screen
})
UI.Corner(25, UI.ToggleBtn)
local toggleStroke = UI.Stroke(Themes[State.Theme].Ac, 2, UI.ToggleBtn)

-- Главное окно
UI.Main = UI.Create("Frame", {
    Size = UDim2.fromOffset(500, 360),
    Position = UDim2.new(0.5, -250, 0.5, -180),
    BackgroundColor3 = Themes[State.Theme].Bg,
    Visible = false,
    Parent = UI.Screen
})
UI.Corner(8, UI.Main)
UI.MainStroke = UI.Stroke(Themes[State.Theme].Ac, 1.5, UI.Main)

-- Шапка (за нее таскаем)
UI.Topbar = UI.Create("Frame", {
    Size = UDim2.new(1, 0, 0, 34),
    BackgroundColor3 = Themes[State.Theme].Bg2,
    Parent = UI.Main
})
UI.Corner(8, UI.Topbar)
-- Скрываем нижние углы шапки
UI.Create("Frame", {
    Size = UDim2.new(1, 0, 0, 17),
    Position = UDim2.new(0, 0, 1, -17),
    BackgroundColor3 = Themes[State.Theme].Bg2,
    BorderSizePixel = 0,
    Parent = UI.Topbar
})

UI.Title = UI.Create("TextLabel", {
    Text = "lemon",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = Themes[State.Theme].Ac,
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(12, 0),
    Size = UDim2.new(0, 100, 1, 0),
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = UI.Topbar
})

UI.Close = UI.Create("TextButton", {
    Text = "✕",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = Color3.fromRGB(200, 200, 200),
    BackgroundTransparency = 1,
    Size = UDim2.fromOffset(34, 34),
    Position = UDim2.new(1, -34, 0, 0),
    Parent = UI.Topbar
})

-- Маркер ресайза (Правый верхний угол)
UI.Resize = UI.Create("TextButton", {
    Text = "",
    BackgroundTransparency = 1,
    Size = UDim2.fromOffset(20, 20),
    Position = UDim2.new(1, -20, 0, 0),
    Parent = UI.Main
})
UI.Create("Frame", {Size = UDim2.fromOffset(8, 2), Position = UDim2.fromOffset(10, 6), BackgroundColor3 = Themes[State.Theme].Ac, Parent = UI.Resize})
UI.Create("Frame", {Size = UDim2.fromOffset(2, 8), Position = UDim2.fromOffset(10, 6), BackgroundColor3 = Themes[State.Theme].Ac, Parent = UI.Resize})

-- Меню (Слева)
UI.TabBar = UI.Create("Frame", {
    Size = UDim2.new(0, 110, 1, -38),
    Position = UDim2.fromOffset(4, 38),
    BackgroundTransparency = 1,
    Parent = UI.Main
})

-- Контент (Справа) - ClipsDescendants чтобы не вылезало за края
UI.Content = UI.Create("Frame", {
    Size = UDim2.new(1, -118, 1, -42),
    Position = UDim2.fromOffset(114, 38),
    BackgroundTransparency = 1,
    ClipsDescendants = true,
    Parent = UI.Main
})

UI.Pages = {}
UI.TabButtons = {}

-- ==========================================
-- 3. UI TABS (Фикс слипания)
-- ==========================================
function UI.MakeTab(id, name)
    local btn = UI.Create("TextButton", {
        Size = UDim2.new(1, -4, 0, 34),
        Position = UDim2.new(0, 2, 0, #UI.TabButtons * 36),
        BackgroundColor3 = Themes[State.Theme].Bg2,
        BackgroundTransparency = 1,
        Text = name,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(180, 180, 180),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = UI.TabBar
    })
    UI.Padding(10, btn)
    UI.Corner(6, btn)

    -- Каждая страница создается в отдельном ScrollingFrame
    local page = UI.Create("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Themes[State.Theme].Ac,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = UI.Content
    })
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    UI.Pages[id] = page
    UI.TabButtons[id] = btn

    btn.MouseButton1Click:Connect(function()
        State.CurrentTab = id
        -- СКРЫВАЕМ ВСЕ ВКЛАДКИ
        for k, p in pairs(UI.Pages) do 
            p.Visible = false 
        end
        -- ПОКАЗЫВАЕМ ТОЛЬКО ВЫБРАННУЮ
        UI.Pages[id].Visible = true
        
        for k, b in pairs(UI.TabButtons) do
            if k == id then
                b.BackgroundTransparency = 0.8
                b.TextColor3 = Themes[State.Theme].Ac
            else
                b.BackgroundTransparency = 1
                b.TextColor3 = Color3.fromRGB(180, 180, 180)
            end
        end
    end)
    return page
end

-- ==========================================
-- 4. WIDGETS (Виджеты с анимациями)
-- ==========================================
local Widgets = {}

function Widgets.Toggle(parent, text, key, tbl, cb)
    local f = UI.Create("Frame", {Size = UDim2.new(1, -8, 0, 30), BackgroundColor3 = Themes[State.Theme].Bg2, Parent = parent})
    UI.Corner(4, f)
    
    local lbl = UI.Create("TextLabel", {Text = text, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Color3.fromRGB(220,220,220), BackgroundTransparency = 1, Size = UDim2.new(1, -50, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = f})
    UI.Padding(8, lbl)
    
    local sw = UI.Create("TextButton", {Text = "", BackgroundColor3 = tbl[key] and Themes[State.Theme].Ac or Color3.fromRGB(50,50,55), Size = UDim2.fromOffset(34, 18), Position = UDim2.new(1, -40, 0.5, -9), Parent = f})
    UI.Corner(9, sw)
    
    local dot = UI.Create("Frame", {Size = UDim2.fromOffset(14,14), Position = tbl[key] and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7), BackgroundColor3 = Color3.fromRGB(255,255,255), Parent = sw})
    UI.Corner(7, dot)

    sw.MouseButton1Click:Connect(function()
        tbl[key] = not tbl[key]
        TweenService:Create(sw, TweenInfo.new(0.2), {BackgroundColor3 = tbl[key] and Themes[State.Theme].Ac or Color3.fromRGB(50,50,55)}):Play()
        TweenService:Create(dot, TweenInfo.new(0.2), {Position = tbl[key] and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)}):Play()
        if cb then cb() end
    end)
end

function Widgets.Slider(parent, text, key, tbl, min, max, cb)
    local f = UI.Create("Frame", {Size = UDim2.new(1, -8, 0, 42), BackgroundColor3 = Themes[State.Theme].Bg2, Parent = parent})
    UI.Corner(4, f)
    
    local lbl = UI.Create("TextLabel", {Text = text .. ": " .. tostring(tbl[key]), Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Color3.fromRGB(220,220,220), BackgroundTransparency = 1, Size = UDim2.new(1, -10, 0, 16), Position = UDim2.fromOffset(8, 4), TextXAlignment = Enum.TextXAlignment.Left, Parent = f})
    
    local bar = UI.Create("TextButton", {Size = UDim2.new(1, -16, 0, 6), Position = UDim2.fromOffset(8, 28), BackgroundColor3 = Color3.fromRGB(50,50,55), Text = "", Parent = f})
    UI.Corner(3, bar)
    
    local fill = UI.Create("Frame", {Size = UDim2.fromScale((tbl[key]-min)/(max-min), 1), BackgroundColor3 = Themes[State.Theme].Ac, Parent = bar})
    UI.Corner(3, fill)

    local dragging = false
    bar.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then 
            dragging = false 
        end 
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
    local f = UI.Create("Frame", {Size = UDim2.new(1, -8, 0, 30), BackgroundColor3 = Themes[State.Theme].Bg2, Parent = parent})
    UI.Corner(4, f)
    
    local btn = UI.Create("TextButton", {Text = text .. ": " .. tostring(tbl[key]), Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Color3.fromRGB(220,220,220), BackgroundTransparency = 1, Size = UDim2.fromScale(1,1), TextXAlignment = Enum.TextXAlignment.Left, Parent = f})
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
    local s = UI.Create("TextLabel", {Text = text, Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Themes[State.Theme].Ac, BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 22), TextXAlignment = Enum.TextXAlignment.Left, Parent = parent})
    UI.Padding(4, s)
end

function Widgets.Keybind(parent, text, key, tbl, cb)
    local f = UI.Create("Frame", {Size = UDim2.new(1, -8, 0, 30), BackgroundColor3 = Themes[State.Theme].Bg2, Parent = parent})
    UI.Corner(4, f)
    
    local lbl = UI.Create("TextLabel", {Text = text, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = Color3.fromRGB(220,220,220), BackgroundTransparency = 1, Size = UDim2.new(0.5, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = f})
    UI.Padding(8, lbl)
    
    local btn = UI.Create("TextButton", {Text = tostring(tbl[key]), Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Themes[State.Theme].Ac, BackgroundColor3 = Themes[State.Theme].Bg, Size = UDim2.new(0.4, -10, 0, 20), Position = UDim2.new(0.6, 0, 0.5, -10), Parent = f})
    UI.Corner(4, btn)

    local listening = false
    btn.MouseButton1Click:Connect(function() 
        listening = true
        btn.Text = "..." 
    end)
    UserInputService.InputBegan:Connect(function(input, gp)
        if listening and not gp then
            listening = false
            local k = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
            if input.UserInputType ~= Enum.UserInputType.Keyboard then 
                k = tostring(input.UserInputType):gsub("Enum.UserInputType.", "") 
            end
            tbl[key] = k
            btn.Text = k
            if cb then cb(k) end
        end
    end)
end

-- ==========================================
-- 5. UI LOGIC (Drag, Resize, Toggle)
-- ==========================================
UI.ToggleBtn.MouseButton1Click:Connect(function() 
    State.IsOpen = not State.IsOpen
    UI.Main.Visible = State.IsOpen 
    UI.ToggleBtn.Visible = not State.IsOpen
end)

UI.Close.MouseButton1Click:Connect(function() 
    State.IsOpen = false
    UI.Main.Visible = false
    UI.ToggleBtn.Visible = true
end)

-- Перетаскивание окна за шапку (Поддержка Touch)
UI.Topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        State.Dragging = true
        local start = input.Position
        local startPos = UI.Main.Position
        
        local dragConn
        dragConn = UserInputService.InputChanged:Connect(function(i)
            if State.Dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local delta = i.Position - start
                UI.Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        
        local endConn
        endConn = UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                State.Dragging = false
                dragConn:Disconnect()
                endConn:Disconnect()
            end
        end)
    end
end)

-- Изменение размера окна (Поддержка Touch)
UI.Resize.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        State.Resizing = true
        local start = input.Position
        local startSize = UI.Main.Size
        
        local resizeConn
        resizeConn = UserInputService.InputChanged:Connect(function(i)
            if State.Resizing and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local delta = i.Position - start
                UI.Main.Size = UDim2.fromOffset(
                    math.max(400, startSize.X.Offset - delta.X),
                    math.max(300, startSize.Y.Offset + delta.Y)
                )
            end
        end)
        
        local endConn
        endConn = UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                State.Resizing = false
                resizeConn:Disconnect()
                endConn:Disconnect()
            end
        end)
    end
end)

-- Создаем сами вкладки
local pageESP = UI.MakeTab("ESP", GetText("esp"))
local pageAim = UI.MakeTab("Aim", GetText("aim"))
local pagePlayer = UI.MakeTab("Player", GetText("player"))
local pageSettings = UI.MakeTab("Settings", GetText("set"))

-- Включаем вкладку ESP по умолчанию
UI.Pages["ESP"].Visible = true
UI.TabButtons["ESP"].BackgroundTransparency = 0.8
UI.TabButtons["ESP"].TextColor3 = Themes[State.Theme].Ac-- ============================================================
-- ЧАСТЬ 2 / 5: ESP, CHAMS, PREVIEW, ROLE COLORS
-- ============================================================

-- Проверка Drawing API
local hasDrawing = pcall(function() 
    local d = Drawing.new("Square") 
    d:Remove() 
end)

local Draw = {}
if hasDrawing then
    function Draw.New(type, props)
        local obj = Drawing.new(type)
        if props then for k, v in pairs(props) do obj[k] = v end end
        return obj
    end
else
    -- Заглушка чтобы скрипт не крашился на мобилках без Drawing
    function Draw.New() return {Visible=false, Remove=function() end} end
    pcall(function() StarterGui:SetCore("SendNotification", {Title="lemon", Text="Drawing API недоступен, ESP не будет рисоваться.", Duration=5}) end)
end

-- ============================================================
-- ПРЕДПРОСМОТР (3D МОДЕЛЬКА В UI)
-- ============================================================
local Preview = { Model = nil, Camera = nil, Center = nil, Rotation = 0, IsBuilt = false }

function Preview.Build(parent)
    if Preview.IsBuilt then return end
    Preview.IsBuilt = true

    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -8, 0, 160)
    holder.BackgroundColor3 = Themes[State.Theme].Bg2
    holder.BackgroundTransparency = 0.4
    holder.Parent = parent
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", holder)
    stroke.Color = Themes[State.Theme].Ac

    local viewport = Instance.new("ViewportFrame")
    viewport.Size = UDim2.fromScale(1, 1)
    viewport.BackgroundTransparency = 1
    viewport.Parent = holder

    local cam = Instance.new("Camera")
    cam.FieldOfView = 40
    viewport.CurrentCamera = cam
    Preview.Camera = cam

    local function cloneChar()
        if Preview.Model then Preview.Model:Destroy() end
        if not LocalPlayer.Character then return end

        local copy = LocalPlayer.Character:Clone()
        for _, d in ipairs(copy:GetDescendants()) do
            if d:IsA("BasePart") then
                d.Anchored = true
                d.CanCollide = false
            elseif d:IsA("Script") or d:IsA("LocalScript") or d:IsA("Highlight") then
                d:Destroy()
            end
        end
        copy.Parent = viewport
        Preview.Model = copy

        local hrp = copy:FindFirstChild("HumanoidRootPart")
        if hrp then
            Preview.Center = hrp.Position
            cam.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 1, -6), hrp.Position)
        end
    end

    LocalPlayer.CharacterAdded:Connect(function() task.wait(1); cloneChar() end)

    -- Вращение камеры
    RunService.RenderStepped:Connect(function(dt)
        if not Preview.Model or not Preview.Center then return end
        Preview.Rotation = Preview.Rotation + dt * 25
        local rad = math.rad(Preview.Rotation)
        local dist = 6
        local offset = Vector3.new(math.sin(rad) * dist, 1, math.cos(rad) * dist)
        Preview.Camera.CFrame = CFrame.new(Preview.Center + offset, Preview.Center)
    end)

    task.wait(0.5)
    cloneChar()
end

-- ============================================================
-- БАЗА ESP
-- ============================================================
local ESP_Objects = {}

local SkeletonR6 = {
    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
    {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
}

local SkeletonR15 = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}
}

local function GetRigType(char)
    if char:FindFirstChild("Torso") and not char:FindFirstChild("UpperTorso") then return "R6" end
    return "R15"
end

-- Определение роли (по оружию в руках)
local function GetRole(plr)
    if not plr or not plr.Character then return "Innocent" end
    for _, tool in ipairs(plr.Character:GetChildren()) do
        if tool:IsA("Tool") then
            local n = tool.Name:Lower()
            if n:find("knife") or n:find("dagger") or n:find("blade") then return "Murder" end
            if n:find("gun") or n:find("revolver") or n:find("pistol") then return "Sheriff" end
        end
    end
    return "Innocent"
end

-- Цвета ролей (Зеленый, Красный, Синий)
local function GetRoleColor(role)
    if role == "Murder" then return Color3.fromRGB(255, 50, 50) end   -- Красный
    if role == "Sheriff" then return Color3.fromRGB(50, 150, 255) end  -- Синий
    return Color3.fromRGB(50, 255, 50)                                 -- Зеленый
end

-- Цвет здоровья
local function GetHealthColor(hp, max)
    local r = hp / max
    if r > 0.5 then return Color3.fromRGB(60, 220, 120) end
    if r > 0.25 then return Color3.fromRGB(255, 200, 60) end
    return Color3.fromRGB(255, 60, 60)
end

-- Отрисовка Бокса вокруг персонажа
local function GetBoundingBox(char)
    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
    local onScreen = false
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local pos, vis = Camera:WorldToViewportPoint(part.Position)
            if vis then
                onScreen = true
                local sx = part.Size.X * 100 / pos.Z
                local sy = part.Size.Y * 100 / pos.Z
                minX = math.min(minX, pos.X - sx)
                minY = math.min(minY, pos.Y - sy)
                maxX = math.max(maxX, pos.X + sx)
                maxY = math.max(maxY, pos.Y + sy)
            end
        end
    end
    if not onScreen then return nil end
    return Vector2.new(minX, minY), Vector2.new(maxX, maxY)
end

-- Инициализация объектов ESP
local function CreateESP(plr)
    if plr == LocalPlayer then return end
    if ESP_Objects[plr] then return end

    local obj = {
        Box = Draw.New("Square", {Thickness = 1, Filled = false, Visible = false}),
        Fill = Draw.New("Square", {Thickness = 0, Filled = true, Visible = false}),
        HealthBg = Draw.New("Square", {Thickness = 0, Filled = true, Color = Color3.fromRGB(30,30,30), Visible = false}),
        HealthFill = Draw.New("Square", {Thickness = 0, Filled = true, Visible = false}),
        Name = Draw.New("Text", {Center = true, Outline = true, Size = 13, Visible = false}),
        RoleTxt = Draw.New("Text", {Center = true, Outline = true, Size = 14, Visible = false}), -- Увеличенный текст роли
        Dist = Draw.New("Text", {Center = true, Outline = true, Size = 11, Visible = false}),
        HeadDot = Draw.New("Circle", {Thickness = 0, Filled = true, Visible = false}),
        Tracer = Draw.New("Line", {Thickness = 1, Visible = false}),
        Skeleton = {},
        Highlight = nil
    }

    if plr.Character then
        local hl = Instance.new("Highlight")
        hl.Adornee = plr.Character
        hl.FillColor = GetRoleColor(GetRole(plr))
        hl.OutlineColor = GetRoleColor(GetRole(plr))
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0.2
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = plr.Character
        obj.Highlight = hl
    end

    ESP_Objects[plr] = obj
end

-- Удаление
local function RemoveESP(plr)
    local obj = ESP_Objects[plr]
    if not obj then return end
    for k, v in pairs(obj) do
        if k ~= "Skeleton" and k ~= "Highlight" and v and v.Remove then v:Remove() end
    end
    for _, line in ipairs(obj.Skeleton) do if line and line.Remove then line:Remove() end end
    if obj.Highlight then obj.Highlight:Destroy() end
    ESP_Objects[plr] = nil
end

-- Цикл обновления ESP
local function UpdateESP()
    if not Config.ESP.Enabled then
        -- Скрываем все если выключено
        for _, obj in pairs(ESP_Objects) do
            for k, v in pairs(obj) do
                if k ~= "Skeleton" and k ~= "Highlight" and v and v.Visible ~= nil then v.Visible = false end
            end
            for _, line in ipairs(obj.Skeleton) do if line then line.Visible = false end end
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
                local tl, br = GetBoundingBox(char)
                if tl and br then
                    local role = GetRole(plr)
                    local color = GetRoleColor(role)
                    local w, h = br.X - tl.X, br.Y - tl.Y
                    local midX = (tl.X + br.X) / 2

                    -- Box
                    obj.Box.Size = Vector2.new(w, h)
                    obj.Box.Position = tl
                    obj.Box.Color = color
                    obj.Box.Visible = Config.ESP.Box

                    -- Fill
                    if Config.ESP.Fill then
                        obj.Fill.Size = Vector2.new(w, h)
                        obj.Fill.Position = tl
                        obj.Fill.Color = color
                        obj.Fill.Transparency = 0.5
                        obj.Fill.Visible = true
                    else obj.Fill.Visible = false end

                    -- Health Bar
                    if Config.ESP.Health then
                        local hpPct = hum.Health / hum.MaxHealth
                        local bW = 3
                        local bX = tl.X - bW - 3

                        obj.HealthBg.Size = Vector2.new(bW, h)
                        obj.HealthBg.Position = Vector2.new(bX, tl.Y)
                        obj.HealthBg.Visible = true

                        obj.HealthFill.Size = Vector2.new(bW, h * hpPct)
                        obj.HealthFill.Position = Vector2.new(bX, tl.Y + (h * (1 - hpPct)))
                        obj.HealthFill.Color = GetHealthColor(hum.Health, hum.MaxHealth)
                        obj.HealthFill.Visible = true
                    else
                        obj.HealthBg.Visible = false; obj.HealthFill.Visible = false
                    end

                    -- Текст: Имя
                    if Config.ESP.Name then
                        obj.Name.Text = plr.Name
                        obj.Name.Position = Vector2.new(midX, tl.Y - 32)
                        obj.Name.Color = Color3.fromRGB(255, 255, 255)
                        obj.Name.Visible = true
                    else obj.Name.Visible = false end

                    -- Текст: РОЛЬ (Прям над головой)
                    if Config.ESP.Role then
                        obj.RoleTxt.Text = role
                        obj.RoleTxt.Position = Vector2.new(midX, tl.Y - 16) -- Чуть ниже имени
                        obj.RoleTxt.Color = color
                        obj.RoleTxt.Size = 14 -- Жирный шрифт
                        obj.RoleTxt.Visible = true
                    else obj.RoleTxt.Visible = false end

                    -- Текст: Дистанция
                    if Config.ESP.Distance then
                        obj.Dist.Text = math.floor(dist) .. "m"
                        obj.Dist.Position = Vector2.new(midX, br.Y + 2)
                        obj.Dist.Color = color
                        obj.Dist.Visible = true
                    else obj.Dist.Visible = false end

                    -- Точка на голове
                    if Config.ESP.HeadDot then
                        local hp, vis = Camera:WorldToViewportPoint(head.Position)
                        if vis then
                            obj.HeadDot.Position = Vector2.new(hp.X, hp.Y)
                            obj.HeadDot.Radius = 4
                            obj.HeadDot.Color = color
                            obj.HeadDot.Visible = true
                        else obj.HeadDot.Visible = false end
                    else obj.HeadDot.Visible = false end

                    -- Трейсер
                    if Config.ESP.Tracer then
                        obj.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        obj.Tracer.To = Vector2.new(midX, br.Y)
                        obj.Tracer.Color = color
                        obj.Tracer.Visible = true
                    else obj.Tracer.Visible = false end

                    -- Скелет (Кости)
                    if Config.ESP.Skeleton then
                        local rig = GetRigType(char)
                        local bones = (rig == "R6") and SkeletonR6 or SkeletonR15
                        for i, bone in ipairs(bones) do
                            if not obj.Skeleton[i] then obj.Skeleton[i] = Draw.New("Line", {Thickness = 1}) end
                            local p1 = char:FindFirstChild(bone[1])
                            local p2 = char:FindFirstChild(bone[2])
                            if p1 and p2 then
                                local v1, on1 = Camera:WorldToViewportPoint(p1.Position)
                                local v2, on2 = Camera:WorldToViewportPoint(p2.Position)
                                if on1 and on2 then
                                    obj.Skeleton[i].From = Vector2.new(v1.X, v1.Y)
                                    obj.Skeleton[i].To = Vector2.new(v2.X, v2.Y)
                                    obj.Skeleton[i].Color = color
                                    obj.Skeleton[i].Visible = true
                                else obj.Skeleton[i].Visible = false end
                            else obj.Skeleton[i].Visible = false end
                        end
                    else
                        for _, line in ipairs(obj.Skeleton) do line.Visible = false end
                    end

                    -- Чамсы (Highlight)
                    if obj.Highlight then
                        obj.Highlight.Enabled = Config.ESP.Chams
                        obj.Highlight.FillColor = Config.ESP.Rainbow and Color3.fromHSV((tick() * 0.5) % 1, 1, 1) or color
                        obj.Highlight.OutlineColor = Config.ESP.Rainbow and Color3.fromHSV((tick() * 0.5) % 1, 1, 1) or color
                        obj.Highlight.FillTransparency = math.clamp(0.7 - (Config.ESP.ChamsGlow * 0.05), 0, 1)
                        obj.Highlight.OutlineTransparency = math.clamp(0.4 - (Config.ESP.ChamsGlow * 0.03), 0, 1)
                    end
                end
            else
                -- Игрок слишком далеко (Скрываем)
                for k, v in pairs(obj) do
                    if k ~= "Skeleton" and k ~= "Highlight" and v and v.Visible ~= nil then v.Visible = false end
                end
                for _, line in ipairs(obj.Skeleton) do line.Visible = false end
                if obj.Highlight then obj.Highlight.Enabled = false end
            end
        else
            -- Игрок мертв или модель не загрузилась
            for k, v in pairs(obj) do
                if k ~= "Skeleton" and k ~= "Highlight" and v and v.Visible ~= nil then v.Visible = false end
            end
            for _, line in ipairs(obj.Skeleton) do line.Visible = false end
            if obj.Highlight then obj.Highlight.Enabled = false end
        end
    end
end

-- Инициализация игроков
for _, plr in ipairs(Players:GetPlayers()) do CreateESP(plr) end
Players.PlayerAdded:Connect(function(plr) 
    plr.CharacterAdded:Connect(function() task.wait(0.5); CreateESP(plr) end) 
end)
Players.PlayerRemoving:Connect(RemoveESP)
RunService.RenderStepped:Connect(UpdateESP)

-- ============================================================
-- UI ДЛЯ ESP
-- ============================================================
Widgets.Section(pageESP, "Настройки ESP")
Widgets.Toggle(pageESP, "Включить ESP", "Enabled", Config.ESP)
Widgets.Toggle(pageESP, "Квадрат", "Box", Config.ESP)
Widgets.Toggle(pageESP, "Заливка", "Fill", Config.ESP)
Widgets.Toggle(pageESP, "HP Бар", "Health", Config.ESP)
Widgets.Toggle(pageESP, "Имя", "Name", Config.ESP)
Widgets.Toggle(pageESP, "Роль (Текст)", "Role", Config.ESP)
Widgets.Toggle(pageESP, "Дистанция", "Distance", Config.ESP)
Widgets.Toggle(pageESP, "Точка на голове", "HeadDot", Config.ESP)
Widgets.Toggle(pageESP, "Скелет", "Skeleton", Config.ESP)
Widgets.Toggle(pageESP, "Трейсер", "Tracer", Config.ESP)
Widgets.Slider(pageESP, "Макс. Дистанция", "MaxDist", Config.ESP, 100, 3000)

Widgets.Section(pageESP, "Чамсы (Свечение)")
Widgets.Toggle(pageESP, "Включить Чамсы", "Chams", Config.ESP)
Widgets.Toggle(pageESP, "Радужные", "Rainbow", Config.ESP)
Widgets.Slider(pageESP, "Сила свечения", "ChamsGlow", Config.ESP, 1, 10)

Widgets.Section(pageESP, "Предпросмотр")
Widgets.Toggle(pageESP, "3D Модель", "Preview", Config.ESP, function(v)
    if v then Preview.Build(pageESP) end
end)-- ============================================================
-- ЧАСТЬ 3 / 5: AIMBOT, FOV, WALLCHECK, PREDICTION
-- ============================================================

local Aim = {
    Held = false,
    FOVCircle = Draw.New("Circle", {Thickness = 1.5, NumSides = 64, Visible = false}),
    Target = nil,
    TargetPart = nil,
    LockedPlayer = nil
}

-- ==========================================
-- 1. УТИЛИТЫ ДЛЯ АИМА
-- ==========================================

-- Проверка видимости (WallCheck) через Raycast
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

-- Предикт (учет движения цели)
local function PredictPosition(part, char)
    if Config.Aim.Prediction <= 0 then return part.Position end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return part.Position end
    
    -- Берем скорость цели и умножаем на коэффициент предсказания
    local vel = hrp.AssemblyLinearVelocity
    return part.Position + (vel * Config.Aim.Prediction)
end

-- Проверка роли цели
local function IsValidTarget(plr)
    if plr == LocalPlayer then return false end
    if not plr.Character then return false end
    local hum = plr.Character:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    
    -- Проверка команды (если включена в ESP)
    if Config.ESP.Team and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
        return false
    end

    -- Выбор роли для аима
    local role = GetRole(plr)
    if Config.Aim.Target == "All" then return true end
    if Config.Aim.Target == role then return true end
    
    return false
end

-- Получить нужную часть тела (Хитбокс)
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

-- ==========================================
-- 2. ПОИСК ЛУЧШЕЙ ЦЕЛИ
-- ==========================================
local function GetClosestTarget()
    local bestPart = nil
    local bestDist = Config.Aim.FOV
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- Если есть залоченная цель и она жива, держим её
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
                        -- WallCheck
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

-- ==========================================
-- 3. ОСНОВНОЙ ЦИКЛ АИМА
-- ==========================================
RunService.RenderStepped:Connect(function(dt)
    -- Рисуем FOV
    if Config.Aim.Enabled and Config.Aim.DrawFOV then
        Aim.FOVCircle.Visible = true
        Aim.FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        Aim.FOVCircle.Radius = Config.Aim.FOV
        Aim.FOVCircle.Color = Themes[State.Theme].Ac
    else
        Aim.FOVCircle.Visible = false
    end

    -- Логика наведения
    if Config.Aim.Enabled and Aim.Held then
        local targetPart = GetClosestTarget()
        
        if targetPart then
            Aim.TargetPart = targetPart
            local targetChar = targetPart.Parent
            local targetPos = PredictPosition(targetPart, targetChar)
            
            -- Вычисляем, куда должна повернуться камера
            local desiredCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
            
            -- Плавность
            local smoothFactor = math.clamp(dt * (15 / math.max(1, Config.Aim.Smooth)), 0, 1)
            
            -- Плавно интерполируем камеру
            Camera.CFrame = Camera.CFrame:Lerp(desiredCFrame, smoothFactor)
        else
            Aim.TargetPart = nil
        end
    end
end)

-- ==========================================
-- 4. ОБРАБОТКА ВВОДА (ПК + МОБИЛКИ)
-- ==========================================
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

-- ==========================================
-- 5. UI ДЛЯ ВКЛАДКИ AIM
-- ==========================================
Widgets.Section(pageAim, "Настройки Аима")
Widgets.Toggle(pageAim, "Включить Аимбот", "Enabled", Config.Aim)
Widgets.Keybind(pageAim, "Кнопка активации", "Keybind", Config.Aim)
Widgets.Dropdown(pageAim, "Роль цели", "Target", Config.Aim, {"All", "Murder", "Sheriff", "Innocent"})
Widgets.Dropdown(pageAim, "Часть тела", "Part", Config.Aim, {"Head", "Torso", "Random"})

Widgets.Section(pageAim, "Наведение")
Widgets.Slider(pageAim, "Плавность (1-10)", "Smooth", Config.Aim, 1, 10)
Widgets.Slider(pageAim, "Размер FOV", "FOV", Config.Aim, 20, 500)
Widgets.Slider(pageAim, "Предсказание", "Prediction", Config.Aim, 0, 1)
Widgets.Toggle(pageAim, "Рисовать FOV", "DrawFOV", Config.Aim)

Widgets.Section(pageAim, "Проверки")
Widgets.Toggle(pageAim, "WallCheck (Видимость)", "WallCheck", Config.Aim)
Widgets.Toggle(pageAim, "Захват цели (Lock)", "LockTarget", Config.Aim)-- ============================================================
-- ЧАСТЬ 4 / 5: PLAYER MODS, SETTINGS, WATERMARK
-- ============================================================

-- ==========================================
-- 1. PLAYER MODS (FLY, NOCLIP, SPEED)
-- ==========================================
local function UpdatePlayerMods()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    
    if not hrp or not hum then return end

    -- Noclip
    if Config.Player.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end

    -- Speed Hack
    if Config.Player.Speed then
        hum.WalkSpeed = Config.Player.SpeedValue
    else
        if hum.WalkSpeed ~= 16 and hum.WalkSpeed ~= 0 then
            hum.WalkSpeed = 16
        end
    end

    -- Jump Power
    if Config.Player.Jump then
        hum.UseJumpPower = true
        hum.JumpPower = Config.Player.JumpValue
    end

    -- Fly
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

-- ==========================================
-- 2. UI ДЛЯ ИГРОКА
-- ==========================================
Widgets.Section(pagePlayer, "Движение")
Widgets.Toggle(pagePlayer, "Fly (Полет)", "Fly", Config.Player)
Widgets.Slider(pagePlayer, "Скорость полета", "FlySpeed", Config.Player, 10, 200)
Widgets.Toggle(pagePlayer, "Noclip (Сквозь стены)", "Noclip", Config.Player)
Widgets.Toggle(pagePlayer, "Speed Hack", "Speed", Config.Player)
Widgets.Slider(pagePlayer, "Скорость ходьбы", "SpeedValue", Config.Player, 16, 150)
Widgets.Toggle(pagePlayer, "Jump Power", "Jump", Config.Player)
Widgets.Slider(pagePlayer, "Сила прыжка", "JumpValue", Config.Player, 50, 300)

-- ==========================================
-- 3. НАСТРОЙКИ, ТЕМЫ, ЯЗЫК
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
    UI.ToggleBtn.UIStroke.Color = t.Ac
    
    for _, btn in pairs(UI.TabButtons) do
        btn.TextColor3 = (btn.BackgroundTransparency < 1) and t.Ac or Color3.fromRGB(180, 180, 180)
    end
    
    for _, page in pairs(UI.Pages) do
        page.ScrollBarImageColor3 = t.Ac
        for _, obj in ipairs(page:GetDescendants()) do
            if obj:IsA("Frame") and obj.BackgroundTransparency < 0.9 and obj.BackgroundColor3 ~= Color3.fromRGB(50,50,55) then
                obj.BackgroundColor3 = t.Bg2
            end
        end
    end
    
    if Aim.FOVCircle then Aim.FOVCircle.Color = t.Ac end
end

local function ApplyLanguage(lang)
    State.Lang = lang
    UI.TabButtons.ESP.Text = GetText("esp")
    UI.TabButtons.Aim.Text = GetText("aim")
    UI.TabButtons.Player.Text = GetText("player")
    UI.TabButtons.Settings.Text = GetText("set")
end

Widgets.Section(pageSettings, "Интерфейс")
Widgets.Dropdown(pageSettings, "Тема", "Theme", State, {"Red", "Blue", "Green", "Black"}, ApplyTheme)
Widgets.Dropdown(pageSettings, "Язык / Language", "Lang", State, {"ru", "en"}, ApplyLanguage)

Widgets.Section(pageSettings, "Информация")
local infoLabel = UI.Create("TextLabel", {
    Text = "lemon PRO v5.0\nby:@Promtikdeepseek\n\nDrawing API: " .. tostring(hasDrawing),
    Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Color3.fromRGB(180, 180, 180),
    BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 80), TextXAlignment = Enum.TextXAlignment.Left,
    Parent = pageSettings
})
local infoPad = Instance.new("UIPadding", infoLabel)
infoPad.PaddingLeft = UDim.new(0, 10)

-- ==========================================
-- 4. WATERMARK / FPS / PING
-- ==========================================
local Watermark = UI.Create("Frame", {
    Size = UDim2.fromOffset(150, 24), Position = UDim2.new(0, 10, 0, 10),
    BackgroundColor3 = Themes[State.Theme].Bg, BackgroundTransparency = 0.2,
    Parent = UI.Screen
})
Instance.new("UICorner", Watermark).CornerRadius = UDim.new(0, 4)
local wmStroke = Instance.new("UIStroke", Watermark)
wmStroke.Color = Themes[State.Theme].Ac

local WM_Text = UI.Create("TextLabel", {
    Text = "lemon | v5.0", Font = Enum.Font.GothamBold, TextSize = 11,
    TextColor3 = Themes[State.Theme].Ac, BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center,
    Parent = Watermark
})

local InfoLabel = UI.Create("TextLabel", {
    Text = "FPS: 60 | Ping: 0ms", Font = Enum.Font.Gotham, TextSize = 10,
    TextColor3 = Color3.fromRGB(200, 200, 200), BackgroundColor3 = Themes[State.Theme].Bg,
    BackgroundTransparency = 0.2, Size = UDim2.fromOffset(110, 18), Position = UDim2.new(0, 10, 0, 38),
    Parent = UI.Screen
})
Instance.new("UICorner", InfoLabel).CornerRadius = UDim.new(0, 4)

local frameCount = 0
local lastTime = tick()
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = tick()
    if now - lastTime >= 1 then
        local fps = frameCount
        local ping = 0
        pcall(function() ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) end)
        InfoLabel.Text = string.format("FPS: %d | Ping: %dms", fps, ping)
        frameCount = 0
        lastTime = now
    end
end)

-- ==========================================
-- 5. ФИНАЛЬНАЯ ИНИЦИАЛИЗАЦИЯ
-- ==========================================
ApplyTheme("Red")
ApplyLanguage("ru")

-- Проверка, что вкладки не слиплись
for _, page in pairs(UI.Pages) do page.Visible = false end
UI.Pages["ESP"].Visible = true
UI.TabButtons["ESP"].BackgroundTransparency = 0.8
UI.TabButtons["ESP"].TextColor3 = Themes[State.Theme].Ac

pcall(function()
    StarterGui:SetCore("SendNotification", {Title = "lemon PRO", Text = "Скрипт успешно загружен!", Duration = 3})
end)

print("[lemon] PRO v5.0 loaded successfully | Drawing: " .. tostring(hasDrawing))-- ============================================================
-- ЧАСТЬ 5 / 5: PLAYER LIST, CONFIG SAVE, FINAL TOUCHES
-- ============================================================

-- ==========================================
-- 1. PLAYER LIST (Список игроков)
-- ==========================================
Widgets.Section(pagePlayer, "Список игроков")
local playerListContainer = UI.Create("Frame", {
    Size = UDim2.new(1, -8, 0, 150),
    BackgroundColor3 = Themes[State.Theme].Bg2,
    BackgroundTransparency = 0.3,
    Parent = pagePlayer
})
UI.Corner(4, playerListContainer)

local playerScroll = UI.Create("ScrollingFrame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = Themes[State.Theme].Ac,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Parent = playerListContainer
})

local playerLayout = Instance.new("UIListLayout", playerScroll)
playerLayout.Padding = UDim.new(0, 2)
playerLayout.SortOrder = Enum.SortOrder.Name

-- Функция обновления списка игроков
local function RefreshPlayerList()
    for _, child in ipairs(playerScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local btn = UI.Create("TextButton", {
                Size = UDim2.new(1, -4, 0, 24),
                BackgroundColor3 = Themes[State.Theme].Bg,
                Text = plr.Name,
                TextColor3 = Color3.fromRGB(200, 200, 200),
                Font = Enum.Font.Gotham,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = playerScroll
            })
            UI.Corner(2, btn)
            UI.Padding(6, btn)

            btn.MouseButton1Click:Connect(function()
                -- Телепорт к игроку или аим на него (по желанию)
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame
                    end
                end
            end)
        end
    end
end

Players.PlayerAdded:Connect(RefreshPlayerList)
Players.PlayerRemoving:Connect(function() task.wait(0.1); RefreshPlayerList() end)
task.wait(1)
RefreshPlayerList()

-- ==========================================
-- 2. CONFIG SAVE / LOAD
-- ==========================================
local function SaveConfig()
    local data = HttpService:JSONEncode(Config)
    pcall(function()
        if writefile then
            writefile("lemon_config.json", data)
            pcall(function() StarterGui:SetCore("SendNotification", {Title="lemon", Text="Конфиг сохранен!", Duration=2}) end)
        end
    end)
end

local function LoadConfig()
    pcall(function()
        if isfile and isfile("lemon_config.json") then
            local data = readfile("lemon_config.json")
            local decoded = HttpService:JSONDecode(data)
            for section, tbl in pairs(decoded) do
                if Config[section] then
                    for k, v in pairs(tbl) do
                        Config[section][k] = v
                    end
                end
            end
            pcall(function() StarterGui:SetCore("SendNotification", {Title="lemon", Text="Конфиг загружен!", Duration=2}) end)
        end
    end)
end

Widgets.Section(pageSettings, "Конфигурация")
local saveBtn = UI.Create("TextButton", {
    Size = UDim2.new(1, -8, 0, 30),
    BackgroundColor3 = Themes[State.Theme].Bg2,
    Text = "Сохранить настройки",
    TextColor3 = Themes[State.Theme].Ac,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    Parent = pageSettings
})
UI.Corner(4, saveBtn)
saveBtn.MouseButton1Click:Connect(SaveConfig)

local loadBtn = UI.Create("TextButton", {
    Size = UDim2.new(1, -8, 0, 30),
    BackgroundColor3 = Themes[State.Theme].Bg2,
    Text = "Загрузить настройки",
    TextColor3 = Themes[State.Theme].Ac,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    Parent = pageSettings
})
UI.Corner(4, loadBtn)
loadBtn.MouseButton1Click:Connect(LoadConfig)

-- ==========================================
-- 3. ANTI-CRASH SAFETY
-- ==========================================
-- Если скрипт запускается повторно, удаляем старый GUI
local oldGui = CoreGui:FindFirstChild("lemon_v5")
if oldGui then
    oldGui:Destroy()
end

-- Защита от нехватки памяти на телефонах (очистка мусора)
spawn(function()
    while task.wait(60) do
        pcall(function() collectgarbage("collect") end)
    end
end)

-- ==========================================
-- 4. RE-OPENING MENU BUTTON (для удобства на телефоне)
-- ==========================================
-- Создаем дубликат кнопки в правом нижнем углу, чтобы было удобно нажимать большим пальцем
local mobileBtn = UI.Create("TextButton", {
    Size = UDim2.fromOffset(45, 45),
    Position = UDim2.new(1, -60, 1, -100),
    BackgroundColor3 = Themes[State.Theme].Bg,
    Text = "L",
    TextColor3 = Themes[State.Theme].Ac,
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    Parent = UI.Screen
})
UI.Corner(22, mobileBtn)
local mobStroke = UI.Stroke(Themes[State.Theme].Ac, 2, mobileBtn)

mobileBtn.MouseButton1Click:Connect(function()
    State.IsOpen = not State.IsOpen
    UI.Main.Visible = State.IsOpen
    mobileBtn.Visible = not State.IsOpen
end)

-- Синхронизация кнопок
UI.ToggleBtn.MouseButton1Click:Connect(function()
    mobileBtn.Visible = not UI.Main.Visible
end)
UI.Close.MouseButton1Click:Connect(function()
    mobileBtn.Visible = true
end)

print("[lemon] Script successfully executed. Have fun!")
