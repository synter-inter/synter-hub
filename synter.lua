--[[
    lemon mm2 | PRO EDITION
    by:@Promtikdeepseek
    Part 1/4 - Core, Config, UI Library
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
-- 1. CONFIGURATION & STATE
-- ==========================================
local State = {
    IsOpen = true,
    CurrentTab = "ESP",
    ThemeName = "Red",
    Language = "ru",
    Dragging = false,
    Resizing = false,
}

local Config = {
    ESP = {
        Enabled = false,
        Box = true, CornerBox = false, FillBox = false,
        HealthBar = true, HealthBarSize = 3, HealthBarPos = "Left",
        Name = true, Distance = true, Role = true, Weapon = true,
        Skeleton = true, HeadDot = true, Tracer = false, TracerOrigin = "Bottom",
        Chams = true, ChamsGlow = 1, ChamsColor = Color3.fromRGB(255, 60, 60),
        RainbowChams = false, TeamCheck = false, MaxDist = 1500,
        Preview = true,
    },
    Aim = {
        Enabled = false,
        TargetRole = "Murder",
        TargetPart = "Head",
        Smoothness = 5,
        FOV = 150,
        DrawFOV = true,
        ShowFOV = true,
        WallCheck = true,
        VisibleOnly = true,
        Keybind = "MouseButton2",
        Prediction = 0.15,
        Resolver = true,
        AutoShoot = false,
    },
    Player = {
        Noclip = false,
        Fly = false,
        FlySpeed = 50,
        Speed = false,
        SpeedValue = 25,
        JumpPower = false,
        JumpValue = 50,
    },
    Visual = {
        Watermark = true,
        FPS = true,
        Ping = true,
    }
}

-- ==========================================
-- 2. THEMES & I18N
-- ==========================================
local Themes = {
    Red     = {Accent = Color3.fromRGB(255, 60, 60),  Bg = Color3.fromRGB(15, 15, 18),  Bg2 = Color3.fromRGB(22, 22, 26)},
    Blue    = {Accent = Color3.fromRGB(60, 140, 255), Bg = Color3.fromRGB(12, 15, 20),  Bg2 = Color3.fromRGB(18, 22, 30)},
    Purple  = {Accent = Color3.fromRGB(170, 80, 255), Bg = Color3.fromRGB(18, 12, 22),  Bg2 = Color3.fromRGB(26, 18, 32)},
    Green   = {Accent = Color3.fromRGB(60, 220, 120), Bg = Color3.fromRGB(10, 20, 15),  Bg2 = Color3.fromRGB(16, 28, 22)},
    Black   = {Accent = Color3.fromRGB(220, 220, 220),Bg = Color3.fromRGB(5, 5, 5),    Bg2 = Color3.fromRGB(12, 12, 12)},
}

local Strings = {
    ru = {
        esp="ESP", aim="Аимбот", player="Игрок", settings="Настройки",
        preview="Предпросмотр", visual="Визуал", target="Цель", mods="Моды",
        box="Квадрат", corner="Углы", fill="Заливка", hp="HP Бар", name="Имя",
        dist="Дистанция", role="Роль", weapon="Оружие", skel="Скелет", headDot="Точка",
        tracer="Трейсер", chams="Чамсы", rainbow="Радуга", team="Команда",
        aimbot="Включить Аим", part="Часть тела", smooth="Плавность", fov="FOV",
        drawFov="Рисовать FOV", wall="Сквозь стены", visible="Видимые", pred="Предсказание",
        noclip="Noclip", fly="Fly", speed="Speed Hack", jump="Jump Power",
    },
    en = {
        esp="ESP", aim="AimBot", player="Player", settings="Settings",
        preview="Preview", visual="Visual", target="Target", mods="Mods",
        box="Box", corner="Corner", fill="Fill", hp="HP Bar", name="Name",
        dist="Distance", role="Role", weapon="Weapon", skel="Skeleton", headDot="Head Dot",
        tracer="Tracer", chams="Chams", rainbow="Rainbow", team="Team",
        aimbot="Enable Aim", part="Target Part", smooth="Smoothness", fov="FOV",
        drawFov="Draw FOV", wall="WallCheck", visible="Visible", pred="Prediction",
        noclip="Noclip", fly="Fly", speed="Speed Hack", jump="Jump Power",
    }
}

local function L(k) return Strings[State.Language][k] or k end

-- ==========================================
-- 3. UI LIBRARY
-- ==========================================
local UI = {}

function UI.New(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

UI.ScreenGui = UI.New("ScreenGui", {
    Name = "lemon_pro", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = CoreGui
})

UI.Main = UI.New("Frame", {
    Name = "Main", Size = UDim2.fromOffset(500, 360), Position = UDim2.new(0.5, -250, 0.5, -180),
    BackgroundColor3 = Themes.Red.Bg, BorderSizePixel = 0, Parent = UI.ScreenGui
})
Instance.new("UICorner", UI.Main).CornerRadius = UDim.new(0, 8)
UI.Stroke = Instance.new("UIStroke", UI.Main)
UI.Stroke.Color = Themes.Red.Accent
UI.Stroke.Thickness = 1.5

UI.Topbar = UI.New("Frame", {
    Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Themes.Red.Bg2, BorderSizePixel = 0, Parent = UI.Main
})
Instance.new("UICorner", UI.Topbar).CornerRadius = UDim.new(0, 8)
UI.New("Frame", {Size = UDim2.new(1, 0, 0, 15), Position = UDim2.new(0, 0, 1, -15), BackgroundColor3 = Themes.Red.Bg2, BorderSizePixel = 0, Parent = UI.Topbar})

UI.Title = UI.New("TextLabel", {
    Text = "lemon", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Themes.Red.Accent,
    BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(0, 100, 1, 0),
    TextXAlignment = Enum.TextXAlignment.Left, Parent = UI.Topbar
})

UI.CloseBtn = UI.New("TextButton", {
    Text = "✕", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Color3.fromRGB(200, 200, 200),
    BackgroundTransparency = 1, Size = UDim2.fromOffset(32, 32), Position = UDim2.new(1, -32, 0, 0), Parent = UI.Topbar
})

UI.ResizeHandle = UI.New("TextButton", {
    Text = "", BackgroundTransparency = 1, Size = UDim2.fromOffset(20, 20), Position = UDim2.new(1, -20, 0, 0), Parent = UI.Main
})
UI.New("Frame", {Size = UDim2.fromOffset(6, 2), Position = UDim2.fromOffset(12, 6), BackgroundColor3 = Themes.Red.Accent, Parent = UI.ResizeHandle})
UI.New("Frame", {Size = UDim2.fromOffset(2, 6), Position = UDim2.fromOffset(12, 6), BackgroundColor3 = Themes.Red.Accent, Parent = UI.ResizeHandle})

UI.TabBar = UI.New("Frame", {
    Size = UDim2.new(0, 110, 1, -36), Position = UDim2.fromOffset(4, 36), BackgroundTransparency = 1, Parent = UI.Main
})
UI.Content = UI.New("Frame", {
    Size = UDim2.new(1, -118, 1, -40), Position = UDim2.fromOffset(114, 36), BackgroundTransparency = 1, Parent = UI.Main
})

UI.Pages = {}
UI.TabButtons = {}

function UI.MakeTab(id, name)
    local btn = UI.New("TextButton", {
        Size = UDim2.new(1, -4, 0, 30), Position = UDim2.new(0, 2, 0, #UI.TabButtons * 34),
        BackgroundColor3 = Themes.Red.Bg2, BackgroundTransparency = 1, Text = name,
        Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = Color3.fromRGB(180, 180, 180),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = UI.TabBar
    })
    local pad = Instance.new("UIPadding", btn)
    pad.PaddingLeft = UDim.new(0, 10)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local page = UI.New("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 2, ScrollBarImageColor3 = Themes.Red.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false, Parent = UI.Content
    })
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    UI.Pages[id] = page
    UI.TabButtons[id] = btn

    btn.MouseButton1Click:Connect(function()
        for k, p in pairs(UI.Pages) do p.Visible = (k == id) end
        for k, b in pairs(UI.TabButtons) do
            b.BackgroundTransparency = (k == id) and 0.8 or 1
            b.TextColor3 = (k == id) and Themes[State.ThemeName].Accent or Color3.fromRGB(180, 180, 180)
        end
    end)

    return page
end

-- ==========================================
-- 4. WIDGETS (Кнопки, Слайдеры, Тогглы)
-- ==========================================
local Widgets = {}

function Widgets.Toggle(parent, text, key, tbl, callback)
    local f = UI.New("Frame", {Size = UDim2.new(1, -8, 0, 28), BackgroundColor3 = Themes[State.ThemeName].Bg2, Parent = parent})
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    
    local lbl = UI.New("TextLabel", {
        Text = text, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Color3.fromRGB(220, 220, 220),
        BackgroundTransparency = 1, Size = UDim2.new(1, -60, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = f
    })
    local pad = Instance.new("UIPadding", lbl)
    pad.PaddingLeft = UDim.new(0, 10)

    local sw = UI.New("TextButton", {
        Text = "", BackgroundColor3 = tbl[key] and Themes[State.ThemeName].Accent or Color3.fromRGB(50, 50, 55),
        Size = UDim2.fromOffset(34, 18), Position = UDim2.new(1, -42, 0.5, -9), Parent = f
    })
    Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)

    local dot = UI.New("Frame", {
        Size = UDim2.fromOffset(14, 14), Position = tbl[key] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255), Parent = sw
    })
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    sw.MouseButton1Click:Connect(function()
        tbl[key] = not tbl[key]
        sw.BackgroundColor3 = tbl[key] and Themes[State.ThemeName].Accent or Color3.fromRGB(50, 50, 55)
        dot.Position = tbl[key] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        if callback then callback(tbl[key]) end
    end)
end

function Widgets.Slider(parent, text, key, tbl, min, max, callback)
    local f = UI.New("Frame", {Size = UDim2.new(1, -8, 0, 42), BackgroundColor3 = Themes[State.ThemeName].Bg2, Parent = parent})
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)

    local lbl = UI.New("TextLabel", {
        Text = text .. ": " .. tostring(tbl[key]), Font = Enum.Font.Gotham, TextSize = 11,
        TextColor3 = Color3.fromRGB(220, 220, 220), BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 16),
        Position = UDim2.fromOffset(10, 4), TextXAlignment = Enum.TextXAlignment.Left, Parent = f
    })

    local bar = UI.New("TextButton", {
        Size = UDim2.new(1, -20, 0, 4), Position = UDim2.fromOffset(10, 28),
        BackgroundColor3 = Color3.fromRGB(50, 50, 55), Text = "", Parent = f
    })
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local fill = UI.New("Frame", {
        Size = UDim2.fromScale((tbl[key] - min) / (max - min), 1), BackgroundColor3 = Themes[State.ThemeName].Accent, Parent = bar
    })
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

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
            if callback then callback(val) end
        end
    end)
end

function Widgets.Dropdown(parent, text, key, tbl, options, callback)
    local f = UI.New("Frame", {Size = UDim2.new(1, -8, 0, 28), BackgroundColor3 = Themes[State.ThemeName].Bg2, Parent = parent})
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)

    local btn = UI.New("TextButton", {
        Text = text .. ": " .. tostring(tbl[key]), Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Color3.fromRGB(220, 220, 220),
        BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Left, Parent = f
    })
    local pad = Instance.new("UIPadding", btn)
    pad.PaddingLeft = UDim.new(0, 10)

    local idx = 1
    for i, o in ipairs(options) do if tostring(o) == tostring(tbl[key]) then idx = i end end

    btn.MouseButton1Click:Connect(function()
        idx = idx % #options + 1
        tbl[key] = options[idx]
        btn.Text = text .. ": " .. tostring(options[idx])
        if callback then callback(options[idx]) end
    end)
end

function Widgets.Keybind(parent, text, key, tbl, callback)
    local f = UI.New("Frame", {Size = UDim2.new(1, -8, 0, 28), BackgroundColor3 = Themes[State.ThemeName].Bg2, Parent = parent})
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)

    local lbl = UI.New("TextLabel", {
        Text = text, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Color3.fromRGB(220, 220, 220),
        BackgroundTransparency = 1, Size = UDim2.new(0.5, 0, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = f
    })
    local pad = Instance.new("UIPadding", lbl)
    pad.PaddingLeft = UDim.new(0, 10)

    local btn = UI.New("TextButton", {
        Text = tostring(tbl[key]), Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = Themes[State.ThemeName].Accent,
        BackgroundColor3 = Themes[State.ThemeName].Bg, Size = UDim2.new(0.4, -10, 0, 18), Position = UDim2.new(0.6, 0, 0.5, -9), Parent = f
    })
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local listening = false
    btn.MouseButton1Click:Connect(function() listening = true; btn.Text = "..." end)
    UserInputService.InputBegan:Connect(function(input, gp)
        if listening and not gp then
            listening = false
            local k = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
            if input.UserInputType ~= Enum.UserInputType.Keyboard then k = tostring(input.UserInputType):gsub("Enum.UserInputType.", "") end
            tbl[key] = k
            btn.Text = k
        end
    end)
end

function Widgets.Section(parent, text)
    local f = UI.New("TextLabel", {
        Text = text, Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Themes[State.ThemeName].Accent,
        BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 24), TextXAlignment = Enum.TextXAlignment.Left, Parent = parent
    })
    local pad = Instance.new("UIPadding", f)
    pad.PaddingLeft = UDim.new(0, 4)
end

-- ==========================================
-- 5. UI LOGIC (Открытие, Закрытие, Перетаскивание)
-- ==========================================
UI.CloseBtn.MouseButton1Click:Connect(function()
    UI.ScreenGui.Enabled = not UI.ScreenGui.Enabled
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        UI.ScreenGui.Enabled = not UI.ScreenGui.Enabled
    end
end)

-- Drag
UI.Topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        State.Dragging = true
        local start = input.Position
        local startPos = UI.Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then State.Dragging = false end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if State.Dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local delta = i.Position - start
                UI.Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end
end)

-- Resize
UI.ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        State.Resizing = true
        local start = input.Position
        local startSize = UI.Main.Size
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then State.Resizing = false end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if State.Resizing and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local delta = i.Position - start
                UI.Main.Size = UDim2.fromOffset(
                    math.max(400, startSize.X.Offset - delta.X),
                    math.max(300, startSize.Y.Offset + delta.Y)
                )
            end
        end)
    end
end)

-- Создаем вкладки
local pageESP = UI.MakeTab("ESP", L("esp"))
local pageAim = UI.MakeTab("Aim", L("aim"))
local pagePlayer = UI.MakeTab("Player", L("player"))
local pageSettings = UI.MakeTab("Settings", L("settings"))-- ============================================================
-- ЧАСТЬ 2: ESP, PREVIEW, CHAMS
-- ============================================================

-- Безопасная проверка Drawing API (для телефонов)
local hasDrawing = pcall(function() local d = Drawing.new("Square"); d:Remove() end)
local Draw = {}

if hasDrawing then
    function Draw.New(type, props)
        local obj = Drawing.new(type)
        if props then for k, v in pairs(props) do obj[k] = v end end
        return obj
    end
else
    -- Заглушки, если Drawing нет (чтобы скрипт не крашился)
    function Draw.New() return {Visible=false, Remove=function() end} end
end

-- ============================================================
-- 1. ПРЕДПРОСМОТР (PREVIEW VIEWPORT)
-- ============================================================
local Preview = {
    Model = nil,
    Camera = nil,
    Conn = nil,
    Rotation = 0,
}

function Preview.Build(parent)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -8, 0, 160)
    holder.BackgroundColor3 = Themes[State.ThemeName].Bg2
    holder.BackgroundTransparency = 0.4
    holder.Parent = parent
    Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", holder).Color = Themes[State.ThemeName].Accent

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

        -- Центрируем камеру на персонаже
        local hrp = copy:FindFirstChild("HumanoidRootPart")
        if hrp then
            Preview.Center = hrp.Position
            cam.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 1, -6), hrp.Position)
        end
    end

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        cloneChar()
    end)

    -- Вращение камеры вокруг модельки
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
    return holder
end

-- ============================================================
-- 2. ESP ДВИЖОК (DRAWING)
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

-- Создание объектов
local function CreateESP(plr)
    if plr == LocalPlayer then return end
    if ESP_Objects[plr] then return end

    local obj = {
        Box = Draw.New("Square", {Thickness = 1, Filled = false, Visible = false}),
        Fill = Draw.New("Square", {Thickness = 0, Filled = true, Visible = false}),
        HealthBg = Draw.New("Square", {Thickness = 0, Filled = true, Color = Color3.fromRGB(30,30,30), Visible = false}),
        HealthFill = Draw.New("Square", {Thickness = 0, Filled = true, Visible = false}),
        Name = Draw.New("Text", {Center = true, Outline = true, Size = 13, Visible = false}),
        Dist = Draw.New("Text", {Center = true, Outline = true, Size = 11, Visible = false}),
        Role = Draw.New("Text", {Center = true, Outline = true, Size = 11, Visible = false}),
        HeadDot = Draw.New("Circle", {Thickness = 0, Filled = true, Visible = false}),
        Tracer = Draw.New("Line", {Thickness = 1, Visible = false}),
        Skeleton = {},
        Highlight = nil
    }

    if plr.Character then
        local hl = Instance.new("Highlight")
        hl.Adornee = plr.Character
        hl.FillColor = Config.ESP.ChamsColor
        hl.OutlineColor = Config.ESP.ChamsColor
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0.2
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = plr.Character
        obj.Highlight = hl
    end

    ESP_Objects[plr] = obj
end

-- Очистка
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

-- Обновление каждого кадра
local function UpdateESP()
    if not Config.ESP.Enabled then
        for _, obj in pairs(ESP_Objects) do
            if obj.Box then obj.Box.Visible = false end
            if obj.Name then obj.Name.Visible = false end
            if obj.Dist then obj.Dist.Visible = false end
            if obj.HealthBg then obj.HealthBg.Visible = false end
            if obj.HealthFill then obj.HealthFill.Visible = false end
            if obj.HeadDot then obj.HeadDot.Visible = false end
            if obj.Tracer then obj.Tracer.Visible = false end
            if obj.Role then obj.Role.Visible = false end
            if obj.Fill then obj.Fill.Visible = false end
            if obj.Highlight then obj.Highlight.Enabled = false end
            for _, line in ipairs(obj.Skeleton) do if line then line.Visible = false end end
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

                    -- Box
                    obj.Box.Size = Vector2.new(w, h)
                    obj.Box.Position = tl
                    obj.Box.Color = color
                    obj.Box.Visible = Config.ESP.Box

                    -- Fill
                    if Config.ESP.FillBox then
                        obj.Fill.Size = Vector2.new(w, h)
                        obj.Fill.Position = tl
                        obj.Fill.Color = color
                        obj.Fill.Transparency = 0.5
                        obj.Fill.Visible = true
                    else
                        obj.Fill.Visible = false
                    end

                    -- Health Bar
                    if Config.ESP.HealthBar then
                        local hpPct = hum.Health / hum.MaxHealth
                        local bW = Config.ESP.HealthBarSize
                        local bX = (Config.ESP.HealthBarPos == "Left") and (tl.X - bW - 3) or (br.X + 3)

                        obj.HealthBg.Size = Vector2.new(bW, h)
                        obj.HealthBg.Position = Vector2.new(bX, tl.Y)
                        obj.HealthBg.Visible = true

                        obj.HealthFill.Size = Vector2.new(bW, h * hpPct)
                        obj.HealthFill.Position = Vector2.new(bX, tl.Y + (h * (1 - hpPct)))
                        obj.HealthFill.Color = GetHealthColor(hum.Health, hum.MaxHealth)
                        obj.HealthFill.Visible = true
                    else
                        obj.HealthBg.Visible = false
                        obj.HealthFill.Visible = false
                    end

                    -- Texts
                    if Config.ESP.Name then
                        obj.Name.Text = plr.Name
                        obj.Name.Position = Vector2.new((tl.X + br.X) / 2, tl.Y - 16)
                        obj.Name.Color = Color3.fromRGB(255, 255, 255)
                        obj.Name.Visible = true
                    else obj.Name.Visible = false end

                    if Config.ESP.Distance then
                        obj.Dist.Text = math.floor(dist) .. "m"
                        obj.Dist.Position = Vector2.new((tl.X + br.X) / 2, br.Y + 2)
                        obj.Dist.Color = color
                        obj.Dist.Visible = true
                    else obj.Dist.Visible = false end

                    if Config.ESP.Role then
                        obj.Role.Text = role
                        obj.Role.Position = Vector2.new((tl.X + br.X) / 2, br.Y + 16)
                        obj.Role.Color = color
                        obj.Role.Visible = true
                    else obj.Role.Visible = false end

                    -- HeadDot
                    if Config.ESP.HeadDot then
                        local hp, vis = Camera:WorldToViewportPoint(head.Position)
                        if vis then
                            obj.HeadDot.Position = Vector2.new(hp.X, hp.Y)
                            obj.HeadDot.Radius = 4
                            obj.HeadDot.Color = color
                            obj.HeadDot.Visible = true
                        else obj.HeadDot.Visible = false end
                    else obj.HeadDot.Visible = false end

                    -- Tracer
                    if Config.ESP.Tracer then
                        local origin = (Config.ESP.TracerOrigin == "Bottom") and Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y) or Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                        obj.Tracer.From = origin
                        obj.Tracer.To = Vector2.new((tl.X + br.X) / 2, br.Y)
                        obj.Tracer.Color = color
                        obj.Tracer.Visible = true
                    else obj.Tracer.Visible = false end

                    -- Skeleton
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

                    -- Chams (Highlight)
                    if obj.Highlight then
                        obj.Highlight.Enabled = Config.ESP.Chams
                        if Config.ESP.RainbowChams then
                            local c = Color3.fromHSV((tick() * 0.5) % 1, 1, 1)
                            obj.Highlight.FillColor = c
                            obj.Highlight.OutlineColor = c
                        else
                            obj.Highlight.FillColor = Config.ESP.ChamsColor
                            obj.Highlight.OutlineColor = Config.ESP.ChamsColor
                        end
                        obj.Highlight.FillTransparency = math.clamp(0.8 - (Config.ESP.ChamsGlow * 0.1), 0, 1)
                        obj.Highlight.OutlineTransparency = math.clamp(0.5 - (Config.ESP.ChamsGlow * 0.05), 0, 1)
                    end
                end
            else
                -- Дистанция превышена, скрываем
                obj.Box.Visible = false
                obj.Fill.Visible = false
                obj.HealthBg.Visible = false
                obj.HealthFill.Visible = false
                obj.Name.Visible = false
                obj.Dist.Visible = false
                obj.Role.Visible = false
                obj.HeadDot.Visible = false
                obj.Tracer.Visible = false
                for _, line in ipairs(obj.Skeleton) do line.Visible = false end
                if obj.Highlight then obj.Highlight.Enabled = false end
            end
        else
            -- Мертв или нет персонажа
            obj.Box.Visible = false
            obj.Fill.Visible = false
            obj.HealthBg.Visible = false
            obj.HealthFill.Visible = false
            obj.Name.Visible = false
            obj.Dist.Visible = false
            obj.Role.Visible = false
            obj.HeadDot.Visible = false
            obj.Tracer.Visible = false
            for _, line in ipairs(obj.Skeleton) do line.Visible = false end
            if obj.Highlight then obj.Highlight.Enabled = false end
        end
    end
end

-- Инициализация ESP для игроков
for _, plr in ipairs(Players:GetPlayers()) do CreateESP(plr) end
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function() task.wait(0.5); CreateESP(plr) end)
end)
Players.PlayerRemoving:Connect(RemoveESP)

RunService.RenderStepped:Connect(UpdateESP)

-- ============================================================
-- 3. UI ДЛЯ ESP (Добавляем виджеты во вкладку ESP)
-- ============================================================
Widgets.Section(pageESP, "ESP Настройки")
Widgets.Toggle(pageESP, "Включить ESP", "Enabled", Config.ESP)
Widgets.Toggle(pageESP, "Квадрат", "Box", Config.ESP)
Widgets.Toggle(pageESP, "Заливка", "FillBox", Config.ESP)
Widgets.Toggle(pageESP, "HP Бар", "HealthBar", Config.ESP)
Widgets.Slider(pageESP, "Размер HP", "HealthBarSize", Config.ESP, 1, 8)
Widgets.Toggle(pageESP, "Имя", "Name", Config.ESP)
Widgets.Toggle(pageESP, "Дистанция", "Distance", Config.ESP)
Widgets.Toggle(pageESP, "Роль", "Role", Config.ESP)
Widgets.Toggle(pageESP, "Точка на голове", "HeadDot", Config.ESP)
Widgets.Toggle(pageESP, "Скелет", "Skeleton", Config.ESP)
Widgets.Toggle(pageESP, "Трейсер", "Tracer", Config.ESP)
Widgets.Slider(pageESP, "Макс. Дистанция", "MaxDist", Config.ESP, 100, 3000)

Widgets.Section(pageESP, "Чамсы (Свечение)")
Widgets.Toggle(pageESP, "Включить Чамсы", "Chams", Config.ESP)
Widgets.Toggle(pageESP, "Радужные", "RainbowChams", Config.ESP)
Widgets.Slider(pageESP, "Сила свечения", "ChamsGlow", Config.ESP, 1, 10)

Widgets.Section(pageESP, "Предпросмотр")
Widgets.Toggle(pageESP, "Показать 3D модель", "Preview", Config.ESP, function(v)
    if v then
        Preview.Build(pageESP)
    end
end)-- ============================================================
-- ЧАСТЬ 3: AIMBOT, FOV, WALLCHECK, PREDICTION
-- ============================================================

local Aim = {
    Held = false,
    FOVCircle = Draw.New("Circle", {Thickness = 1.5, NumSides = 64, Visible = false}),
    Target = nil,
    TargetPart = nil,
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
    return part.Position + (vel * (Config.Aim.Prediction / 100))
end

-- Проверка роли цели
local function IsValidTarget(plr)
    if plr == LocalPlayer then return false end
    if not plr.Character then return false end
    local hum = plr.Character:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    
    -- Проверка команды
    if Config.ESP.TeamCheck and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
        return false
    end

    -- Выбор роли для аима
    local role = GetRole(plr)
    if Config.Aim.TargetRole == "All" then return true end
    if Config.Aim.TargetRole == role then return true end
    
    return false
end

-- Получить нужную часть тела (Хитбокс)
local function GetHitPart(char)
    local partName = Config.Aim.TargetPart
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
    local ignoreList = {LocalPlayer.Character}

    for _, plr in ipairs(Players:GetPlayers()) do
        if IsValidTarget(plr) then
            local char = plr.Character
            local part = GetHitPart(char)
            
            if part then
                -- Берем позицию с учетом предикта
                local targetPos = PredictPosition(part, char)
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
                
                if onScreen then
                    local screenVec = Vector2.new(screenPos.X, screenPos.Y)
                    local distToCenter = (screenVec - center).Magnitude
                    
                    -- Проверка на FOV (круг)
                    if distToCenter <= Config.Aim.FOV then
                        -- Проверка на видимость (сквозь стены)
                        local visCheck = true
                        if Config.Aim.VisibleOnly then
                            visCheck = IsVisible(part, char)
                        end

                        if visCheck and distToCenter < bestDist then
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
        Aim.FOVCircle.Color = Themes[State.ThemeName].Accent
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
            
            -- Плавность (чем выше значение, тем медленнее/плавнее)
            local smoothFactor = math.clamp(dt * (15 / math.max(1, Config.Aim.Smoothness)), 0, 1)
            
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
    end
end)

-- ==========================================
-- 5. UI ДЛЯ ВКЛАДКИ AIM
-- ==========================================
Widgets.Section(pageAim, "Настройки Аима")
Widgets.Toggle(pageAim, "Включить Аимбот", "Enabled", Config.Aim)
Widgets.Keybind(pageAim, "Кнопка активации", "Keybind", Config.Aim)
Widgets.Dropdown(pageAim, "Роль цели", "TargetRole", Config.Aim, {"All", "Murder", "Sheriff", "Innocent"})
Widgets.Dropdown(pageAim, "Часть тела", "TargetPart", Config.Aim, {"Head", "Torso", "Random"})

Widgets.Section(pageAim, "Наведение")
Widgets.Slider(pageAim, "Плавность (1-10)", "Smoothness", Config.Aim, 1, 10)
Widgets.Slider(pageAim, "Размер FOV", "FOV", Config.Aim, 20, 500)
Widgets.Slider(pageAim, "Предсказание", "Prediction", Config.Aim, 0, 50)
Widgets.Toggle(pageAim, "Рисовать FOV", "DrawFOV", Config.Aim)

Widgets.Section(pageAim, "Проверки")
Widgets.Toggle(pageAim, "Только видимые (WallCheck)", "VisibleOnly", Config.Aim)
Widgets.Toggle(pageAim, "Сквозь стены", "WallCheck", Config.Aim, function(v)
    -- Если "Сквозь стены" ВКЛ, значит WallCheck = false (игнорируем стены)
    -- Немного запутанная логика, поэтому синхронизируем:
    if v then
        Config.Aim.VisibleOnly = false
    end
end)-- ============================================================
-- ЧАСТЬ 4: PLAYER MODS, SETTINGS, WATERMARK, FINAL
-- ============================================================

-- ==========================================
-- 1. PLAYER MODS (FLY, NOCLIP, SPEED)
-- ==========================================
local FlyVelocity = nil

-- Логика полета
local function UpdateFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    
    if not hrp or not hum then return end

    if Config.Player.Fly then
        -- Отключаем гравитацию
        hrp.Velocity = Vector3.new(0, 0, 0)
        
        -- Получаем направление движения (куда смотрит камера/джойстик)
        local moveDir = hum.MoveDirection
        local camCFrame = Camera.CFrame
        
        -- Если на мобилке используется джойстик:
        local moveVector = Vector3.new(0, 0, 0)
        if moveDir.Magnitude > 0 then
            moveVector = (camCFrame.LookVector * moveDir.Z + camCFrame.RightVector * moveDir.X) * Config.Player.FlySpeed
        end
        
        -- Подъем вверх по кнопке прыжка (Space или Jump на телефоне)
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) or hum.Jump then
            moveVector = moveVector + Vector3.new(0, Config.Player.FlySpeed, 0)
        end

        hrp.Velocity = moveVector
    end
end

-- Логика Noclip
local function UpdateNoclip()
    if not Config.Player.Noclip then return end
    local char = LocalPlayer.Character
    if not char then return end
    
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end

-- Логика Speed и Jump
local function UpdateStats()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end

    if Config.Player.Speed then
        hum.WalkSpeed = Config.Player.SpeedValue
    else
        if hum.WalkSpeed ~= 16 and hum.WalkSpeed ~= 0 then
            hum.WalkSpeed = 16 -- Возвращаем дефолт при выключении
        end
    end

    if Config.Player.JumpPower then
        hum.JumpPower = Config.Player.JumpValue
        hum.UseJumpPower = true
    end
end

-- Общий цикл для Mods
RunService.Heartbeat:Connect(function()
    UpdateFly()
    UpdateNoclip()
    UpdateStats()
end)

-- ==========================================
-- 2. UI ДЛЯ PLAYER MODS
-- ==========================================
Widgets.Section(pagePlayer, "Движение")
Widgets.Toggle(pagePlayer, "Fly (Полет)", "Fly", Config.Player)
Widgets.Slider(pagePlayer, "Скорость полета", "FlySpeed", Config.Player, 10, 200)
Widgets.Toggle(pagePlayer, "Noclip (Сквозь стены)", "Noclip", Config.Player)
Widgets.Toggle(pagePlayer, "Speed Hack", "Speed", Config.Player)
Widgets.Slider(pagePlayer, "Скорость ходьбы", "SpeedValue", Config.Player, 16, 150)
Widgets.Toggle(pagePlayer, "Jump Power", "JumpPower", Config.Player)
Widgets.Slider(pagePlayer, "Сила прыжка", "JumpValue", Config.Player, 50, 300)

-- ==========================================
-- 3. НАСТРОЙКИ, ТЕМЫ, ЯЗЫК
-- ==========================================
local function ApplyTheme(themeName)
    State.ThemeName = themeName
    local t = Themes[themeName]
    
    UI.Main.BackgroundColor3 = t.Bg
    UI.Topbar.BackgroundColor3 = t.Bg2
    UI.Title.TextColor3 = t.Accent
    UI.Stroke.Color = t.Accent
    
    -- Красим вкладки
    for _, btn in pairs(UI.TabButtons) do
        btn.TextColor3 = (btn.BackgroundTransparency < 1) and t.Accent or Color3.fromRGB(180, 180, 180)
    end
    
    -- Красим все элементы внутри страниц
    for _, page in pairs(UI.Pages) do
        page.ScrollBarImageColor3 = t.Accent
        for _, obj in ipairs(page:GetDescendants()) do
            if obj:IsA("Frame") and obj.BackgroundTransparency < 0.9 then
                obj.BackgroundColor3 = t.Bg2
            end
            if obj:IsA("TextLabel") and obj.TextColor3 == Color3.fromRGB(220, 220, 220) then
                obj.TextColor3 = t.Bg2:Lerp(Color3.fromRGB(255,255,255), 0.8) -- Немного светлее фона
            end
        end
    end
    
    if Aim.FOVCircle then Aim.FOVCircle.Color = t.Accent end
end

local function ApplyLanguage(lang)
    State.Language = lang
    -- Перезаписываем текст вкладок
    UI.TabButtons.ESP.Text = L("esp")
    UI.TabButtons.Aim.Text = L("aim")
    UI.TabButtons.Player.Text = L("player")
    UI.TabButtons.Settings.Text = L("settings")
end

Widgets.Section(pageSettings, "Интерфейс")
Widgets.Dropdown(pageSettings, "Тема", "ThemeName", State, {"Red", "Blue", "Purple", "Green", "Black"}, ApplyTheme)
Widgets.Dropdown(pageSettings, "Язык", "Language", State, {"ru", "en"}, ApplyLanguage)

Widgets.Section(pageSettings, "Информация")
local infoLabel = UI.New("TextLabel", {
    Text = "lemon PRO v3.0\nby:@Promtikdeepseek\n\nBuild: 2026\nDrawing API: " .. tostring(hasDrawing),
    Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Color3.fromRGB(180, 180, 180),
    BackgroundTransparency = 1, Size = UDim2.new(1, -8, 0, 100), TextXAlignment = Enum.TextXAlignment.Left,
    Parent = pageSettings
})
local infoPad = Instance.new("UIPadding", infoLabel)
infoPad.PaddingLeft = UDim.new(0, 10)

-- ==========================================
-- 4. WATERMARK / FPS / PING
-- ==========================================
local Watermark = UI.New("Frame", {
    Size = UDim2.fromOffset(160, 26), Position = UDim2.new(0, 10, 0, 10),
    BackgroundColor3 = Themes[State.ThemeName].Bg, BackgroundTransparency = 0.2,
    Parent = UI.ScreenGui
})
Instance.new("UICorner", Watermark).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", Watermark).Color = Themes[State.ThemeName].Accent

local WM_Text = UI.New("TextLabel", {
    Text = "lemon | v3.0", Font = Enum.Font.GothamBold, TextSize = 11,
    TextColor3 = Themes[State.ThemeName].Accent, BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center,
    Parent = Watermark
})

local InfoLabel = UI.New("TextLabel", {
    Text = "FPS: 60 | Ping: 0ms", Font = Enum.Font.Gotham, TextSize = 10,
    TextColor3 = Color3.fromRGB(200, 200, 200), BackgroundColor3 = Themes[State.ThemeName].Bg,
    BackgroundTransparency = 0.2, Size = UDim2.fromOffset(120, 20), Position = UDim2.new(0, 10, 0, 40),
    Parent = UI.ScreenGui
})
Instance.new("UICorner", InfoLabel).CornerRadius = UDim.new(0, 4)

-- Счетчик кадров
local frameCount = 0
local lastTime = tick()
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = tick()
    if now - lastTime >= 1 then
        local fps = frameCount
        local ping = 0
        pcall(function()
            ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
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

-- Открытие первой вкладки по умолчанию
UI.TabButtons.ESP.MouseButton1Click:Fire() -- Эмулируем клик (может не работать, тогда вручную)
UI.Pages.ESP.Visible = true
UI.TabButtons.ESP.BackgroundTransparency = 0.8
UI.TabButtons.ESP.TextColor3 = Themes.Red.Accent

-- Уведомление
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "lemon PRO",
        Text = "Скрипт успешно загружен!",
        Duration = 3
    })
end)

print("[lemon] PRO v3.0 loaded successfully | Drawing: " .. tostring(hasDrawing))
