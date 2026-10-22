--[[
    lemon mm2 loader
    by:@Promtikdeepseek
    Version: 2.0.0
    Requires: Roblox executor with Drawing + CoreGui access
    Usage: loadstring(game:HttpGet("URL"))()
]]

-- ============================================================
-- SERVICES
-- ============================================================
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local CoreGui            = game:GetService("CoreGui")
local Workspace          = game:GetService("Workspace")
local TweenService       = game:GetService("TweenService")
local HttpService        = game:GetService("HttpService")
local Lighting           = game:GetService("Lighting")
local StarterGui         = game:GetService("StarterGui")
local ContextActionService= game:GetService("ContextActionService")
local GuiService         = game:GetService("GuiService")
local Camera             = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse       = Players.LocalPlayer:GetMouse()

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "lemon",
        Text = "loading...",
        Duration = 2,
    })
end)

-- ============================================================
-- GLOBAL STATE
-- ============================================================
local STATE = {
    Loaded        = false,
    Version       = "2.0.0",
    Build         = os.date("%Y%m%d-%H%M%S"),
    FrameCount    = 0,
    FPSCounter    = 0,
    LastFPSUpdate = tick(),
    CurrentFPS    = 0,
    Ping          = 0,
    Language      = "ru",
    Theme         = "red",
    ToggleKey     = Enum.KeyCode.RightShift,
    Open          = true,
    Dragging      = false,
    Resizing      = false,
    ResizeStart   = nil,
    ResizeStartSize = nil,
}

local Config = {
    ESP = {
        Enabled       = false,
        Box           = true,
        CornerBox     = false,
        HealthBar     = true,
        HealthBarSize = 3,
        Name          = true,
        Distance      = true,
        Line          = false,
        Skeleton      = true,
        Tracer        = false,
        HeadDot       = true,
        Weapon        = true,
        Role          = true,
        Chams         = true,
        ChamsGlow     = 1,
        ChamsFill     = 0.5,
        ChamsOutline  = 0.2,
        ChamsColor    = Color3.fromRGB(255, 60, 60),
        TeamCheck     = false,
        MaxDistance   = 1000,
        Preview       = true,
        TextSize      = 12,
        TextOutline   = true,
        RainbowChams  = false,
        FillBox       = false,
        FillBoxAlpha  = 0.15,
        BoxThickness  = 1,
        SkeletonThickness = 1,
        TracerOrigin  = "Bottom", -- Bottom / Center / Mouse
        HeadDotSize   = 4,
        HealthBarPos  = "Left",   -- Left / Right
        DrawFPS       = true,
        DrawPing      = true,
        DrawWatermark = true,
        IgnoreNPCs    = true,
    },
    Aim = {
        Enabled       = false,
        TargetRole    = "All",
        Smoothness    = 8,
        FOV           = 120,
        DrawFOV       = true,
        ShowFOV       = true,
        WallCheck     = true,
        VisibleOnly   = true,
        Keybind       = Enum.UserInputType.MouseButton2,
        TargetPart    = "Head",
        Prediction    = 0,
        LockTarget    = false,
        LockedPlayer  = nil,
        FOVColor      = Color3.fromRGB(255, 60, 60),
        FOVFill       = false,
        FOVFillAlpha  = 0.08,
        ShowTargetLine= true,
        TargetLineColor = Color3.fromRGB(255, 60, 60),
        Resolver      = true,
        AntiFling     = true,
        Shake         = 0,
        Priority      = "Distance", -- Distance / FOV / Health
    },
    Settings = {
        Theme         = "red",
        Language      = "ru",
        Transparency  = 0.05,
        UIScale       = 1,
        Animations    = true,
        AutoSave      = true,
        SavePath      = "lemon_mm2_config.json",
    },
    Misc = {
        RainbowSpeed  = 1,
        ToggleConsole = true,
        ShowKeybind   = true,
    }
}

-- ============================================================
-- THEMES
-- ============================================================
local Themes = {
    red = {
        Accent     = Color3.fromRGB(255, 60, 60),
        AccentDark = Color3.fromRGB(180, 40, 40),
        Bg         = Color3.fromRGB(20, 20, 22),
        BgAlt      = Color3.fromRGB(26, 26, 30),
        Text       = Color3.fromRGB(230, 230, 230),
        TextDim    = Color3.fromRGB(160, 160, 160),
        Border     = Color3.fromRGB(45, 45, 50),
    },
    blue = {
        Accent     = Color3.fromRGB(60, 140, 255),
        AccentDark = Color3.fromRGB(40, 100, 200),
        Bg         = Color3.fromRGB(18, 20, 26),
        BgAlt      = Color3.fromRGB(24, 26, 34),
        Text       = Color3.fromRGB(230, 230, 230),
        TextDim    = Color3.fromRGB(160, 160, 160),
        Border     = Color3.fromRGB(40, 44, 56),
    },
    black = {
        Accent     = Color3.fromRGB(200, 200, 200),
        AccentDark = Color3.fromRGB(140, 140, 140),
        Bg         = Color3.fromRGB(10, 10, 10),
        BgAlt      = Color3.fromRGB(16, 16, 16),
        Text       = Color3.fromRGB(220, 220, 220),
        TextDim    = Color3.fromRGB(130, 130, 130),
        Border     = Color3.fromRGB(30, 30, 30),
    },
    purple = {
        Accent     = Color3.fromRGB(170, 80, 255),
        AccentDark = Color3.fromRGB(120, 50, 200),
        Bg         = Color3.fromRGB(22, 18, 28),
        BgAlt      = Color3.fromRGB(28, 24, 36),
        Text       = Color3.fromRGB(230, 230, 230),
        TextDim    = Color3.fromRGB(160, 160, 160),
        Border     = Color3.fromRGB(48, 40, 60),
    },
    pink = {
        Accent     = Color3.fromRGB(255, 100, 180),
        AccentDark = Color3.fromRGB(200, 70, 140),
        Bg         = Color3.fromRGB(26, 18, 24),
        BgAlt      = Color3.fromRGB(34, 22, 30),
        Text       = Color3.fromRGB(230, 230, 230),
        TextDim    = Color3.fromRGB(160, 160, 160),
        Border     = Color3.fromRGB(56, 36, 48),
    },
    green = {
        Accent     = Color3.fromRGB(60, 220, 120),
        AccentDark = Color3.fromRGB(40, 170, 90),
        Bg         = Color3.fromRGB(16, 24, 20),
        BgAlt      = Color3.fromRGB(22, 32, 26),
        Text       = Color3.fromRGB(230, 230, 230),
        TextDim    = Color3.fromRGB(160, 160, 160),
        Border     = Color3.fromRGB(36, 56, 44),
    },
    cyan = {
        Accent     = Color3.fromRGB(80, 220, 255),
        AccentDark = Color3.fromRGB(50, 170, 200),
        Bg         = Color3.fromRGB(16, 22, 26),
        BgAlt      = Color3.fromRGB(22, 30, 36),
        Text       = Color3.fromRGB(230, 230, 230),
        TextDim    = Color3.fromRGB(160, 160, 160),
        Border     = Color3.fromRGB(36, 50, 60),
    },
    white = {
        Accent     = Color3.fromRGB(240, 240, 240),
        AccentDark = Color3.fromRGB(180, 180, 180),
        Bg         = Color3.fromRGB(28, 28, 28),
        BgAlt      = Color3.fromRGB(36, 36, 36),
        Text       = Color3.fromRGB(250, 250, 250),
        TextDim    = Color3.fromRGB(180, 180, 180),
        Border     = Color3.fromRGB(60, 60, 60),
    },
    rainbow = {
        Accent     = Color3.fromRGB(255, 0, 0),
        AccentDark = Color3.fromRGB(200, 0, 0),
        Bg         = Color3.fromRGB(20, 20, 22),
        BgAlt      = Color3.fromRGB(26, 26, 30),
        Text       = Color3.fromRGB(230, 230, 230),
        TextDim    = Color3.fromRGB(160, 160, 160),
        Border     = Color3.fromRGB(45, 45, 50),
    },
}

-- ============================================================
-- I18N
-- ============================================================
local Strings = {
    ru = {
        title="lemon", esp="ESP", aim="Аимбот", settings="Настройки", misc="Прочее",
        espEnabled="ESP включён", box="Квадрат", corner="Углы", health="Полоса HP",
        healthSize="Размер HP бара", name="Имя", distance="Дистанция", line="Линия",
        skeleton="Скелет", tracer="Трейсер", headDot="Точка на голове", weapon="Оружие",
        role="Роль", chams="Чамсы", chamsGlow="Свечение чамсов", chamsFill="Заливка чамсов",
        chamsOutline="Обводка чамсов", teamCheck="Игнор команды", maxDistance="Макс. дистанция",
        preview="Предпросмотр", textSize="Размер текста", textOutline="Обводка текста",
        rainbowChams="Радужные чамсы", fillBox="Залить квадрат", fillBoxAlpha="Прозрачность заливки",
        boxThickness="Толщина квадрата", skeletonThickness="Толщина скелета",
        tracerOrigin="Начало трейсера", headDotSize="Размер точки головы",
        healthBarPos="Позиция HP бара", drawFPS="Показать FPS", drawPing="Показать пинг",
        drawWatermark="Показать watermark", ignoreNPCs="Игнорировать NPC",
        aimEnabled="Аимбот включён", targetRole="Цель", smoothness="Плавность",
        fov="FOV", drawFOV="Рисовать FOV", showFOV="Показывать FOV", wallCheck="WallCheck",
        visibleOnly="Только видимые", keybind="Клавиша", targetPart="Часть тела",
        prediction="Предсказание", lockTarget="Захват цели", fovColor="Цвет FOV",
        fovFill="Заливка FOV", fovFillAlpha="Прозрачность FOV",
        showTargetLine="Линия к цели", targetLineColor="Цвет линии цели",
        resolver="Resolver", antiFling="Anti-Fling", shake="Тряска",
        priority="Приоритет", theme="Тема", language="Язык", transparency="Прозрачность",
        uiScale="Масштаб UI", animations="Анимации", autoSave="Автосохранение",
        saveConfig="Сохранить конфиг", loadConfig="Загрузить конфиг",
        resetConfig="Сбросить конфиг", rainbowSpeed="Скорость радуги",
        toggleConsole="Показать консоль", showKeybind="Показать клавишу",
        on="ВКЛ", off="ВЫКЛ", apply="Применить", close="Закрыть", reset="Сброс",
        all="Все", murder="Маньяк", sheriff="Шериф", innocent="Невиновен",
        bottom="Снизу", center="Центр", mouse="Мышь", left="Слева", right="Справа",
        distance_priority="По дистанции", fov_priority="По FOV", health_priority="По HP",
        head="Голова", torso="Торс", random="Случайно",
        status="Статус", fps="FPS", ping="Пинг", loaded="загружен за",
        seconds="сек", targetLocked="Цель захвачена", noTarget="Цель не найдена",
        notification="Уведомление",
    },
    en = {
        title="lemon", esp="ESP", aim="AimBot", settings="Settings", misc="Misc",
        espEnabled="ESP enabled", box="Box", corner="Corner", health="Health Bar",
        healthSize="Health Bar size", name="Name", distance="Distance", line="Line",
        skeleton="Skeleton", tracer="Tracer", headDot="Head Dot", weapon="Weapon",
        role="Role", chams="Chams", chamsGlow="Chams glow", chamsFill="Chams fill",
        chamsOutline="Chams outline", teamCheck="Team Check", maxDistance="Max Distance",
        preview="Preview", textSize="Text Size", textOutline="Text Outline",
        rainbowChams="Rainbow Chams", fillBox="Fill Box", fillBoxAlpha="Fill alpha",
        boxThickness="Box thickness", skeletonThickness="Skeleton thickness",
        tracerOrigin="Tracer origin", headDotSize="Head Dot size",
        healthBarPos="Health Bar position", drawFPS="Draw FPS", drawPing="Draw Ping",
        drawWatermark="Draw Watermark", ignoreNPCs="Ignore NPCs",
        aimEnabled="AimBot enabled", targetRole="Target", smoothness="Smoothness",
        fov="FOV", drawFOV="Draw FOV", showFOV="Show FOV", wallCheck="WallCheck",
        visibleOnly="Visible Only", keybind="Keybind", targetPart="Target part",
        prediction="Prediction", lockTarget="Lock target", fovColor="FOV color",
        fovFill="FOV fill", fovFillAlpha="FOV fill alpha",
        showTargetLine="Target line", targetLineColor="Target line color",
        resolver="Resolver", antiFling="Anti-Fling", shake="Shake",
        priority="Priority", theme="Theme", language="Language", transparency="Transparency",
        uiScale="UI Scale", animations="Animations", autoSave="Auto save",
        saveConfig="Save config", loadConfig="Load config",
        resetConfig="Reset config", rainbowSpeed="Rainbow speed",
        toggleConsole="Show console", showKeybind="Show keybind",
        on="ON", off="OFF", apply="Apply", close="Close", reset="Reset",
        all="All", murder="Murder", sheriff="Sheriff", innocent="Innocent",
        bottom="Bottom", center="Center", mouse="Mouse", left="Left", right="Right",
        distance_priority="By distance", fov_priority="By FOV", health_priority="By HP",
        head="Head", torso="Torso", random="Random",
        status="Status", fps="FPS", ping="Ping", loaded="loaded in",
        seconds="s", targetLocked="Target locked", noTarget="No target",
        notification="Notification",
    }
}

local function L(key)
    local tbl = Strings[STATE.Language] or Strings.en
    return tbl[key] or key
end

-- ============================================================
-- UTILS
-- ============================================================
local Utils = {}

function Utils.round(n, step)
    step = step or 1
    return math.floor(n / step + 0.5) * step
end

function Utils.lerp(a, b, t)
    return a + (b - a) * t
end

function Utils.clamp(n, min, max)
    return math.max(min, math.min(max, n))
end

function Utils.distance2D(a, b)
    local dx = a.X - b.X
    local dy = a.Y - b.Y
    return math.sqrt(dx*dx + dy*dy)
end

function Utils.distance3D(a, b)
    return (a - b).Magnitude
end

function Utils.tween(instance, info, props)
    local t = TweenService:Create(instance, info, props)
    t:Play()
    return t
end

function Utils.new(class, props)
    local obj = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            obj[k] = v
        end
    end
    return obj
end

function Utils.notify(text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "lemon",
            Text = text,
            Duration = duration or 2,
        })
    end)
end

function Utils.getTeamColor(plr)
    if plr.Team then return plr.Team.TeamColor.Color end
    return Color3.fromRGB(255,255,255)
end

function Utils.roleOf(plr)
    if not plr or not plr.Character then return "Innocent" end
    local char = plr.Character
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local n = tool.Name:lower()
            if n:find("knife") or n:find("dagger") or n:find("blade") then
                return "Murder"
            end
            if n:find("gun") or n:find("revolver") or n:find("pistol") then
                return "Sheriff"
            end
        end
    end
    return "Innocent"
end

function Utils.roleColor(role)
    if role == "Murder" then return Color3.fromRGB(255, 50, 50) end
    if role == "Sheriff" then return Color3.fromRGB(60, 140, 255) end
    return Color3.fromRGB(80, 220, 120)
end

function Utils.isAlive(plr)
    if not plr or not plr.Character then return false end
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

function Utils.isVisible(part, ignoreList)
    ignoreList = ignoreList or {}
    local origin = Camera.CFrame.Position
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = ignoreList
    local result = Workspace:Raycast(origin, (part.Position - origin), params)
    return result == nil
end

function Utils.getRig(char)
    local rigType = "R15"
    if char:FindFirstChild("Torso") and not char:FindFirstChild("UpperTorso") then
        rigType = "R6"
    end
    return rigType
end

function Utils.getHealthColor(hp, maxhp)
    local ratio = hp / (maxhp or 100)
    if ratio > 0.5 then return Color3.fromRGB(80, 220, 120) end
    if ratio > 0.25 then return Color3.fromRGB(255, 200, 60) end
    return Color3.fromRGB(255, 60, 60)
end

-- ============================================================
-- UI BASE
-- ============================================================
local GUI = {}

GUI.ScreenGui = Utils.new("ScreenGui", {
    Name = "lemon_mm2",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
})
GUI.ScreenGui.Parent = CoreGui

-- Кнопка открытия (висит слева)
GUI.ToggleBtn = Utils.new("TextButton", {
    Text = "lemon",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = Color3.fromRGB(255, 60, 60),
    BackgroundColor3 = Color3.fromRGB(20, 20, 22),
    BackgroundTransparency = 0.1,
    Size = UDim2.fromOffset(70, 30),
    Position = UDim2.new(0, 10, 0.5, -15),
    Visible = true,
    Parent = GUI.ScreenGui,
})
Utils.new("UICorner", {CornerRadius = UDim.new(0, 6), Parent = GUI.ToggleBtn})
Utils.new("UIStroke", {Color = Color3.fromRGB(255, 60, 60), Thickness = 1, Transparency = 0.3, Parent = GUI.ToggleBtn})

-- Само окно
GUI.Main = Utils.new("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(500, 380), -- Уменьшил размер, чтобы влезало на телефон
    Position = UDim2.new(0.5, -250, 0.5, -190),
    BackgroundColor3 = Themes[STATE.Theme].Bg,
    BorderSizePixel = 0,
    Active = true,
    Draggable = false,
    Visible = false, -- Окно скрыто по умолчанию
})
GUI.Main.Parent = GUI.ScreenGui
Utils.new("UICorner", {CornerRadius = UDim.new(0, 8), Parent = GUI.Main})
GUI.MainStroke = Utils.new("UIStroke", {Color = Themes[STATE.Theme].Accent, Thickness = 1, Transparency = 0.5, Parent = GUI.Main})

-- Шапка
GUI.Topbar = Utils.new("Frame", {
    Size = UDim2.new(1, 0, 0, 32),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.5,
    BorderSizePixel = 0,
    Parent = GUI.Main,
})
Utils.new("UICorner", {CornerRadius = UDim.new(0, 8), Parent = GUI.Topbar})

GUI.Title = Utils.new("TextLabel", {
    Text = "lemon",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = Themes[STATE.Theme].Accent,
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(12, 0),
    Size = UDim2.new(0, 100, 1, 0),
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = GUI.Topbar,
})

GUI.Version = Utils.new("TextLabel", {
    Text = "v" .. STATE.Version,
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextColor3 = Themes[STATE.Theme].TextDim,
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -100, 0, 0),
    Size = UDim2.fromOffset(40, 32),
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = GUI.Topbar,
})

-- Кнопка свернуть
GUI.CloseBtn = Utils.new("TextButton", {
    Text = "—",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = Color3.fromRGB(200, 200, 200),
    BackgroundTransparency = 1,
    Size = UDim2.fromOffset(28, 28),
    Position = UDim2.new(1, -32, 0, 2),
    Parent = GUI.Topbar,
})

-- Уголок для ресайза
GUI.ResizeHandle = Utils.new("TextButton", {
    Text = "",
    BackgroundTransparency = 1,
    Size = UDim2.fromOffset(20, 20),
    Position = UDim2.new(1, -20, 0, 0), 
    Parent = GUI.Main,
})

-- Вкладки (слева)
GUI.TabBar = Utils.new("Frame", {
    Size = UDim2.new(0, 100, 1, -38),
    Position = UDim2.fromOffset(4, 36),
    BackgroundTransparency = 1,
    Parent = GUI.Main,
})

-- Контент (справа)
GUI.Content = Utils.new("Frame", {
    Size = UDim2.new(1, -112, 1, -42),
    Position = UDim2.fromOffset(108, 36),
    BackgroundTransparency = 1,
    Parent = GUI.Main,
})

GUI.Pages = {}
GUI.TabButtons = {}

function GUI.makeTab(id, label)
    local btn = Utils.new("TextButton", {
        Text = label,
        Font = Enum.Font.GothamMedium,
        TextSize = 11, -- Уменьшил шрифт вкладок
        TextColor3 = Themes[STATE.Theme].TextDim,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.new(0, 0, 0, #GUI.TabButtons * 30),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = GUI.TabBar,
    })
    Utils.new("UICorner", {CornerRadius = UDim.new(0, 4), Parent = btn})
    Utils.new("UIPadding", {PaddingLeft = UDim.new(0, 6), Parent = btn})

    local page = Utils.new("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Themes[STATE.Theme].Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false, -- ВАЖНО: по умолчанию все скрыты
        Parent = GUI.Content,
    })
    Utils.new("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = page,
    })

    GUI.Pages[id] = page
    GUI.TabButtons[id] = btn

    btn.MouseButton1Click:Connect(function()
        for k, p in pairs(GUI.Pages) do p.Visible = (k == id) end -- Скрываем неактивные
        for k, b in pairs(GUI.TabButtons) do
            b.BackgroundTransparency = (k == id) and 0.8 or 1
            b.BackgroundColor3 = Themes[STATE.Theme].BgAlt
            b.TextColor3 = (k == id) and Themes[STATE.Theme].Accent or Themes[STATE.Theme].TextDim
        end
    end)

    return page
end)-- ============================================================
-- DRAGGING / RESIZING / TOGGLE
-- ============================================================
local function openMenu()
    GUI.Main.Visible = true
    GUI.ToggleBtn.Visible = false
end

local function closeMenu()
    GUI.Main.Visible = false
    GUI.ToggleBtn.Visible = true
end

GUI.ToggleBtn.MouseButton1Click:Connect(openMenu)
GUI.CloseBtn.MouseButton1Click:Connect(closeMenu)

-- Перетаскивание за шапку
GUI.Topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        STATE.Dragging = true
        local start = input.Position
        local startPos = GUI.Main.Position
        local conn
        conn = UserInputService.InputChanged:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseMovement and STATE.Dragging then
                local delta = i.Position - start
                GUI.Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                STATE.Dragging = false
                if conn then conn:Disconnect() end
            end
        end)
    end
end)

-- Ресайз за правый верхний угол
GUI.ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        STATE.Resizing = true
        STATE.ResizeStart = input.Position
        STATE.ResizeStartSize = GUI.Main.Size
        local conn
        conn = UserInputService.InputChanged:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseMovement and STATE.Resizing then
                local delta = i.Position - STATE.ResizeStart
                GUI.Main.Size = UDim2.fromOffset(
                    math.max(350, STATE.ResizeStartSize.X.Offset - delta.X),
                    math.max(280, STATE.ResizeStartSize.Y.Offset + delta.Y)
                )
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                STATE.Resizing = false
                if conn then conn:Disconnect() end
            end
        end)
    end
end)                    
-- WIDGET SYSTEM
-- ============================================================
local Widgets = {}

function Widgets.label(parent, text)
    local f = Utils.new("TextLabel", {
        Text = text,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = Themes[STATE.Theme].TextDim,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -8, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = parent,
    })
    Utils.new("UIPadding", {PaddingLeft = UDim.new(0, 6), Parent = f})
    return f
end

function Widgets.section(parent, text)
    local f = Utils.new("Frame", {
        Size = UDim2.new(1, -8, 0, 24),
        BackgroundTransparency = 1,
        Parent = parent,
    })
    local lbl = Utils.new("TextLabel", {
        Text = text,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = Themes[STATE.Theme].Accent,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = f,
    })
    Utils.new("UIPadding", {PaddingLeft = UDim.new(0, 6), Parent = lbl})
    return f
end

function Widgets.toggle(parent, text, key, cfgTable, callback)
    local f = Utils.new("Frame", {
        Size = UDim2.new(1, -8, 0, 28),
        BackgroundColor3 = Themes[STATE.Theme].BgAlt,
        BackgroundTransparency = 0.3,
        Parent = parent,
    })
    Utils.new("UICorner", {CornerRadius = UDim.new(0, 6), Parent = f})

    local lbl = Utils.new("TextLabel", {
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Themes[STATE.Theme].Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -60, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = f,
    })
    Utils.new("UIPadding", {PaddingLeft = UDim.new(0, 10), Parent = lbl})

    local sw = Utils.new("TextButton", {
        Text = "",
        BackgroundColor3 = cfgTable[key] and Themes[STATE.Theme].Accent or Color3.fromRGB(55,55,60),
        Size = UDim2.fromOffset(36, 18),
        Position = UDim2.new(1, -46, 0.5, -9),
        Parent = f,
    })
    Utils.new("UICorner", {CornerRadius = UDim.new(1, 0), Parent = sw})

    local dot = Utils.new("Frame", {
        Size = UDim2.fromOffset(14, 14),
        Position = cfgTable[key] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        Parent = sw,
    })
    Utils.new("UICorner", {CornerRadius = UDim.new(1, 0), Parent = dot})

    sw.MouseButton1Click:Connect(function()
        cfgTable[key] = not cfgTable[key]
        sw.BackgroundColor3 = cfgTable[key] and Themes[STATE.Theme].Accent or Color3.fromRGB(55,55,60)
        dot.Position = cfgTable[key] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        if callback then callback(cfgTable[key]) end
    end)

    return {frame = f, toggle = sw, dot = dot, label = lbl}
end

function Widgets.slider(parent, text, key, cfgTable, min, max, callback)
    local f = Utils.new("Frame", {
        Size = UDim2.new(1, -8, 0, 42),
        BackgroundColor3 = Themes[STATE.Theme].BgAlt,
        BackgroundTransparency = 0.3,
        Parent = parent,
    })
    Utils.new("UICorner", {CornerRadius = UDim.new(0, 6), Parent = f})

    local lbl = Utils.new("TextLabel", {
        Text = text .. "  " .. tostring(cfgTable[key]),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Themes[STATE.Theme].Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 18),
        Position = UDim2.fromOffset(10, 3),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = f,
    })

    local bar = Utils.new("Frame", {
        Size = UDim2.new(1, -20, 0, 4),
        Position = UDim2.fromOffset(10, 28),
        BackgroundColor3 = Color3.fromRGB(55,55,60),
        Parent = f,
    })
    Utils.new("UICorner", {CornerRadius = UDim.new(1, 0), Parent = bar})

    local fill = Utils.new("Frame", {
        Size = UDim2.fromScale((cfgTable[key] - min) / (max - min), 1),
        BackgroundColor3 = Themes[STATE.Theme].Accent,
        Parent = bar,
    })
    Utils.new("UICorner", {CornerRadius = UDim.new(1, 0), Parent = fill})

    local dragging = false
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * rel)
            cfgTable[key] = val
            fill.Size = UDim2.fromScale(rel, 1)
            lbl.Text = text .. "  " .. tostring(val)
            if callback then callback(val) end
        end
    end)
    return {frame = f, label = lbl, bar = bar, fill = fill}
end

function Widgets.dropdown(parent, text, key, cfgTable, options, callback)
    local f = Utils.new("Frame", {
        Size = UDim2.new(1, -8, 0, 28),
        BackgroundColor3 = Themes[STATE.Theme].BgAlt,
        BackgroundTransparency = 0.3,
        Parent = parent,
    })
    Utils.new("UICorner", {CornerRadius = UDim.new(0, 6), Parent = f})

    local btn = Utils.new("TextButton", {
        Text = text .. ": " .. tostring(cfgTable[key]),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Themes[STATE.Theme].Text,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = f,
    })
    Utils.new("UIPadding", {PaddingLeft = UDim.new(0, 10), Parent = btn})

    local idx = 1
    for i, o in ipairs(options) do
        if tostring(o) == tostring(cfgTable[key]) then idx = i end
    end

    btn.MouseButton1Click:Connect(function()
        idx = idx % #options + 1
        cfgTable[key] = options[idx]
        btn.Text = text .. ": " .. tostring(options[idx])
        if callback then callback(options[idx]) end
    end)

    return {frame = f, button = btn}
end

function Widgets.keybind(parent, text, key, cfgTable, callback)
    local f = Utils.new("Frame", {
        Size = UDim2.new(1, -8, 0, 28),
        BackgroundColor3 = Themes[STATE.Theme].BgAlt,
        BackgroundTransparency = 0.3,
        Parent = parent,
    })
    Utils.new("UICorner", {CornerRadius = UDim.new(0, 6), Parent = f})

    local lbl = Utils.new("TextLabel", {
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Themes[STATE.Theme].Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.5, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = f,
    })
    Utils.new("UIPadding", {PaddingLeft = UDim.new(0, 10), Parent = lbl})

    local btn = Utils.new("TextButton", {
        Text = tostring(cfgTable[key]):gsub("Enum.", ""):gsub("UserInputType.", ""):gsub("KeyCode.", ""),
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextColor3 = Themes[STATE.Theme].Accent,
        BackgroundColor3 = Themes[STATE.Theme].Bg,
        Size = UDim2.new(0.4, -10, 0, 18),
        Position = UDim2.new(0.6, 0, 0.5, -9),
        Parent = f,
    })
    Utils.new("UICorner", {CornerRadius = UDim.new(0, 4), Parent = btn})

    local listening = false
    btn.MouseButton1Click:Connect(function()
        listening = true
        btn.Text = "..."
    end)
    UserInputService.InputBegan:Connect(function(input, gp)
        if listening and not gp then
            listening = false
            cfgTable[key] = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or input.UserInputType
            btn.Text = tostring(cfgTable[key]):gsub("Enum.", ""):gsub("UserInputType.", ""):gsub("KeyCode.", "")
            if callback then callback(cfgTable[key]) end
        end
    end)

    return {frame = f, button = btn, label = lbl}
end

function Widgets.button(parent, text, callback)
    local b = Utils.new("TextButton", {
        Text = text,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = Themes[STATE.Theme].Text,
        BackgroundColor3 = Themes[STATE.Theme].BgAlt,
        BackgroundTransparency = 0.2,
        Size = UDim2.new(1, -8, 0, 28),
        Parent = parent,
    })
    Utils.new("UICorner", {CornerRadius = UDim.new(0, 6), Parent = b})
    b.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return b
end

function Widgets.colorpicker(parent, text, key, cfgTable, callback)
    local f = Utils.new("Frame", {
        Size = UDim2.new(1, -8, 0, 28),
        BackgroundColor3 = Themes[STATE.Theme].BgAlt,
        BackgroundTransparency = 0.3,
        Parent = parent,
    })
    Utils.new("UICorner", {CornerRadius = UDim.new(0, 6), Parent = f})

    local lbl = Utils.new("TextLabel", {
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Themes[STATE.Theme].Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -50, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = f,
    })
    Utils.new("UIPadding", {PaddingLeft = UDim.new(0, 10), Parent = lbl})

    local sw = Utils.new("TextButton", {
        Text = "",
        BackgroundColor3 = cfgTable[key],
        Size = UDim2.fromOffset(24, 18),
        Position = UDim2.new(1, -34, 0.5, -9),
        Parent = f,
    })
    Utils.new("UICorner", {CornerRadius = UDim.new(0, 4), Parent = sw})

    sw.MouseButton1Click:Connect(function()
        local newColor = Color3.fromHSV(math.random(), 1, 1)
        cfgTable[key] = newColor
        sw.BackgroundColor3 = newColor
        if callback then callback(newColor) end
    end)

    return {frame = f, swatch = sw, label = lbl}
end

-- ============================================================
-- DRAWING API WRAPPER
-- ============================================================
local Draw = {}

local hasDrawing = pcall(function()
    local _ = Drawing.new("Square")
end)

if not hasDrawing then
    Utils.notify("Drawing API недоступен. ESP отключён.")
end

function Draw.newSquare()
    if not hasDrawing then return nil end
    local s = Drawing.new("Square")
    s.Visible = false
    s.Thickness = 1
    s.Filled = false
    s.Transparency = 1
    return s
end

function Draw.newLine()
    if not hasDrawing then return nil end
    local l = Drawing.new("Line")
    l.Visible = false
    l.Thickness = 1
    l.Transparency = 1
    return l
end

function Draw.newText()
    if not hasDrawing then return nil end
    local t = Drawing.new("Text")
    t.Visible = false
    t.Center = false
    t.Outline = true
    t.Size = 13
    t.Font = 2
    return t
end

function Draw.newCircle()
    if not hasDrawing then return nil end
    local c = Drawing.new("Circle")
    c.Visible = false
    c.Thickness = 1
    c.Filled = false
    c.NumSides = 64
    c.Transparency = 1
    return c
end

function Draw.newTriangle()
    if not hasDrawing then return nil end
    local t = Drawing.new("Triangle")
    t.Visible = false
    t.Thickness = 1
    t.Filled = false
    t.Transparency = 1
    return t
end

function Draw.newQuad()
    if not hasDrawing then return nil end
    local q = Drawing.new("Quad")
    q.Visible = false
    q.Thickness = 1
    q.Filled = false
    q.Transparency = 1
    return q
end

function Draw.newImage()
    if not hasDrawing then return nil end
    local i = Drawing.new("Image")
    i.Visible = false
    i.Transparency = 1
    return i
end

function Draw.safeSet(obj, prop, val)
    if not obj then return end
    pcall(function() obj[prop] = val end)
end

-- ============================================================
-- ESP STORAGE
-- ============================================================
local ESP = {}
ESP.Objects = {}

function ESP.create(plr)
    if plr == LocalPlayer then return nil end
    if Config.ESP.IgnoreNPCs and plr:FindFirstChild("NPC") then return nil end
    if ESP.Objects[plr] then return ESP.Objects[plr] end

    local obj = {
        Player      = plr,
        Box         = Draw.newSquare(),
        Corner1     = Draw.newLine(),
        Corner2     = Draw.newLine(),
        Corner3     = Draw.newLine(),
        Corner4     = Draw.newLine(),
        Corner5     = Draw.newLine(),
        Corner6     = Draw.newLine(),
        Corner7     = Draw.newLine(),
        Corner8     = Draw.newLine(),
        HealthBg    = Draw.newSquare(),
        HealthFill  = Draw.newSquare(),
        Name        = Draw.newText(),
        Distance    = Draw.newText(),
        Role        = Draw.newText(),
        Weapon      = Draw.newText(),
        HeadDot     = Draw.newCircle(),
        Tracer      = Draw.newLine(),
        Line        = Draw.newLine(),
        FillBox     = Draw.newSquare(),
        Highlight   = nil,
        Skeleton    = {},
        SkeletonVisible = false,
        LastHealth  = 100,
        LastMaxHealth = 100,
    }

    -- Highlight for chams
    local char = plr.Character
    if char then
        local hl = Instance.new("Highlight")
        hl.Adornee = char
        hl.FillColor = Config.ESP.ChamsColor
        hl.FillTransparency = Config.ESP.ChamsFill
        hl.OutlineColor = Config.ESP.ChamsColor
        hl.OutlineTransparency = Config.ESP.ChamsOutline
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char
        obj.Highlight = hl
    end

    ESP.Objects[plr] = obj
    return obj
end

function ESP.destroy(plr)
    local obj = ESP.Objects[plr]
    if not obj then return end
    for _, v in pairs(obj) do
        if typeof(v) == "Instance" or (typeof(v) == "userdata" and v.Remove) then
            pcall(function() v:Remove() end)
        end
    end
    if obj.Highlight then obj.Highlight:Destroy() end
    for _, s in pairs(obj.Skeleton) do
        pcall(function() s:Remove() end)
    end
    ESP.Objects[plr] = nil
end

function ESP.destroyAll()
    for plr, _ in pairs(ESP.Objects) do
        ESP.destroy(plr)
    end
    ESP.Objects = {}
end

function ESP.refresh()
    ESP.destroyAll()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then ESP.create(plr) end
    end
end

-- ============================================================
-- SKELETON POINTS
-- ============================================================
local SkeletonR6 = {
    {"Head", "Torso"},
    {"Torso", "Left Arm"},
    {"Torso", "Right Arm"},
    {"Torso", "Left Leg"},
    {"Torso", "Right Leg"},
}

local SkeletonR15 = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
}

-- ============================================================
-- ESP RENDER
-- ============================================================
local function getBoundingBox(char)
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local any = false
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                any = true
                local sx = part.Size.X * 100 / pos.Z + 4
                local sy = part.Size.Y * 100 / pos.Z + 4
                minX = math.min(minX, pos.X - sx)
                minY = math.min(minY, pos.Y - sy)
                maxX = math.max(maxX, pos.X + sx)
                maxY = math.max(maxY, pos.Y + sy)
            end
        end
    end
    if not any then return nil end
    return minX, minY, maxX, maxY
end

local function partScreen(name, char)
    local part = char:FindFirstChild(name)
    if not part then return nil end
    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
    if onScreen then return Vector2.new(pos.X, pos.Y) end
    return nil
end

local function drawSkeleton(obj, char, rigType)
    local pairs_ = rigType == "R6" and SkeletonR6 or SkeletonR15
    for i, pair in ipairs(pairs_) do
        if not obj.Skeleton[i] then obj.Skeleton[i] = Draw.newLine() end
        local a = partScreen(pair[1], char)
        local b = partScreen(pair[2], char)
        local line = obj.Skeleton[i]
        if a and b and Config.ESP.Skeleton and Config.ESP.Enabled then
            line.From = a
            line.To = b
            line.Color = Themes[STATE.Theme].Accent
            line.Thickness = Config.ESP.SkeletonThickness
            line.Visible = true
        else
            line.Visible = false
        end
    end
end

local function hideSkeleton(obj)
    for _, line in pairs(obj.Skeleton) do
        pcall(function() line.Visible = false end)
    end
end

function ESP.update()
    if not hasDrawing then return end
    for plr, obj in pairs(ESP.Objects) do
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local myChar = LocalPlayer.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")

        if not Config.ESP.Enabled or not char or not hrp or not head or not hum or hum.Health <= 0 or not myHRP then
            -- hide all
            for _, v in pairs(obj) do
                if type(v) == "userdata" and v.Visible ~= nil then pcall(function() v.Visible = false end) end
            end
            hideSkeleton(obj)
            if obj.Highlight then obj.Highlight.Enabled = false end
            continue
        end

        local dist = (hrp.Position - myHRP.Position).Magnitude
        if dist > Config.ESP.MaxDistance then
            for _, v in pairs(obj) do
                if type(v) == "userdata" and v.Visible ~= nil then pcall(function() v.Visible = false end) end
            end
            hideSkeleton(obj)
            if obj.Highlight then obj.Highlight.Enabled = false end
            continue
        end

        -- Team check
        if Config.ESP.TeamCheck and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
            for _, v in pairs(obj) do
                if type(v) == "userdata" and v.Visible ~= nil then pcall(function() v.Visible = false end) end
            end
            hideSkeleton(obj)
            if obj.Highlight then obj.Highlight.Enabled = false end
            continue
        end

        -- bounding box
        local minX, minY, maxX, maxY = getBoundingBox(char)
        if not minX then
            for _, v in pairs(obj) do
                if type(v) == "userdata" and v.Visible ~= nil then pcall(function() v.Visible = false end) end
            end
            hideSkeleton(obj)
            if obj.Highlight then obj.Highlight.Enabled = false end
            continue
        end

        local boxColor = Utils.roleColor(Utils.roleOf(plr))

        -- Box
        if obj.Box then
            obj.Box.Size = Vector2.new(maxX - minX, maxY - minY)
            obj.Box.Position = Vector2.new(minX, minY)
            obj.Box.Color = boxColor
            obj.Box.Thickness = Config.ESP.BoxThickness
            obj.Box.Visible = Config.ESP.Enabled and Config.ESP.Box and not Config.ESP.CornerBox
        end

        -- Corner box
        if obj.Corner1 then
            local cornerLen = math.min(maxX - minX, maxY - minY) * 0.25
            if Config.ESP.CornerBox and Config.ESP.Enabled then
                -- top-left
                obj.Corner1.From = Vector2.new(minX, minY)
                obj.Corner1.To   = Vector2.new(minX + cornerLen, minY)
                obj.Corner2.From = Vector2.new(minX, minY)
                obj.Corner2.To   = Vector2.new(minX, minY + cornerLen)
                -- top-right
                obj.Corner3.From = Vector2.new(maxX, minY)
                obj.Corner3.To   = Vector2.new(maxX - cornerLen, minY)
                obj.Corner4.From = Vector2.new(maxX, minY)
                obj.Corner4.To   = Vector2.new(maxX, minY + cornerLen)
                -- bottom-left
                obj.Corner5.From = Vector2.new(minX, maxY)
                obj.Corner5.To   = Vector2.new(minX + cornerLen, maxY)
                obj.Corner6.From = Vector2.new(minX, maxY)
                obj.Corner6.To   = Vector2.new(minX, maxY - cornerLen)
                -- bottom-right
                obj.Corner7.From = Vector2.new(maxX, maxY)
                obj.Corner7.To   = Vector2.new(maxX - cornerLen, maxY)
                obj.Corner8.From = Vector2.new(maxX, maxY)
                obj.Corner8.To   = Vector2.new(maxX, maxY - cornerLen)
                for i = 1, 8 do
                    local c = obj["Corner" .. i]
                    c.Color = boxColor
                    c.Thickness = Config.ESP.BoxThickness
                    c.Visible = true
                end
            else
                for i = 1, 8 do pcall(function() obj["Corner" .. i].Visible = false end) end
            end
        end

        -- Fill box
        if obj.FillBox then
            obj.FillBox.Size = Vector2.new(maxX - minX, maxY - minY)
            obj.FillBox.Position = Vector2.new(minX, minY)
            obj.FillBox.Color = boxColor
            obj.FillBox.Filled = true
            obj.FillBox.Transparency = Config.ESP.FillBoxAlpha
            obj.FillBox.Visible = Config.ESP.Enabled and Config.ESP.FillBox
        end

        -- Health bar
        if obj.HealthBg and obj.HealthFill then
            local hp = hum.Health
            local maxHp = hum.MaxHealth
            local ratio = math.clamp(hp / maxHp, 0, 1)
            local bw = Config.ESP.HealthBarSize
            local bh = maxY - minY
            local hpColor = Utils.getHealthColor(hp, maxHp)
            local posX = Config.ESP.HealthBarPos == "Left" and (minX - bw - 3) or (maxX + 3)

            obj.HealthBg.Size = Vector2.new(bw, bh)
            obj.HealthBg.Position = Vector2.new(posX, minY)
            obj.HealthBg.Color = Color3.fromRGB(30, 30, 30)
            obj.HealthBg.Filled = true
            obj.HealthBg.Transparency = 0.4
            obj.HealthBg.Visible = Config.ESP.Enabled and Config.ESP.HealthBar

            local fillHeight = bh * ratio
            obj.HealthFill.Size = Vector2.new(bw, fillHeight)
            obj.HealthFill.Position = Vector2.new(posX, minY + (bh - fillHeight))
            obj.HealthFill.Color = hpColor
            obj.HealthFill.Filled = true
            obj.HealthFill.Transparency = 0.1
            obj.HealthFill.Visible = Config.ESP.Enabled and Config.ESP.HealthBar
        end

        -- Name
        if obj.Name then
            obj.Name.Text = plr.Name
            obj.Name.Size = Config.ESP.TextSize
            obj.Name.Position = Vector2.new((minX + maxX) / 2 - 50, minY - 16)
            obj.Name.Center = true
            obj.Name.Outline = Config.ESP.TextOutline
            obj.Name.Color = Color3.fromRGB(255, 255, 255)
            obj.Name.Visible = Config.ESP.Enabled and Config.ESP.Name
        end

        -- Distance
        if obj.Distance then
            obj.Distance.Text = math.floor(dist) .. "m"
            obj.Distance.Size = Config.ESP.TextSize - 1
            obj.Distance.Position = Vector2.new((minX + maxX) / 2 - 50, maxY + 2)
            obj.Distance.Center = true
            obj.Distance.Outline = Config.ESP.TextOutline
            obj.Distance.Color = boxColor
            obj.Distance.Visible = Config.ESP.Enabled and Config.ESP.Distance
        end

        -- Role
        if obj.Role then
            obj.Role.Text = Utils.roleOf(plr)
            obj.Role.Size = Config.ESP.TextSize - 1
            obj.Role.Position = Vector2.new((minX + maxX) / 2 - 50, maxY + 16)
            obj.Role.Center = true
            obj.Role.Outline = Config.ESP.TextOutline
            obj.Role.Color = Utils.roleColor(Utils.roleOf(plr))
            obj.Role.Visible = Config.ESP.Enabled and Config.ESP.Role
        end

        -- Weapon
        if obj.Weapon then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                obj.Weapon.Text = tool.Name
                obj.Weapon.Size = Config.ESP.TextSize - 1
                obj.Weapon.Position = Vector2.new((minX + maxX) / 2 - 50, maxY + 30)
                obj.Weapon.Center = true
                obj.Weapon.Outline = Config.ESP.TextOutline
                obj.Weapon.Color = Color3.fromRGB(255, 220, 120)
                obj.Weapon.Visible = Config.ESP.Enabled and Config.ESP.Weapon
            else
                obj.Weapon.Visible = false
            end
        end

        -- Head dot
        if obj.HeadDot then
            local hp, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                obj.HeadDot.Position = Vector2.new(hp.X, hp.Y)
                obj.HeadDot.Radius = Config.ESP.HeadDotSize
                obj.HeadDot.Color = boxColor
                obj.HeadDot.Filled = true
                obj.HeadDot.Visible = Config.ESP.Enabled and Config.ESP.HeadDot
            else
                obj.HeadDot.Visible = false
            end
        end

        -- Tracer (from bottom of screen to player)
        if obj.Tracer then
            local origin
            if Config.ESP.TracerOrigin == "Center" then
                origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            elseif Config.ESP.TracerOrigin == "Mouse" then
                origin = UserInputService:GetMouseLocation()
            else
                origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            end
            local target = partScreen("Head", char)
            if target and Config.ESP.Tracer and Config.ESP.Enabled then
                obj.Tracer.From = origin
                obj.Tracer.To = target
                obj.Tracer.Color = boxColor
                obj.Tracer.Thickness = 1
                obj.Tracer.Visible = true
            else
                obj.Tracer.Visible = false
            end
        end

        -- Line (screen edge to player)
        if obj.Line then
            local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen and Config.ESP.Line and Config.ESP.Enabled then
                obj.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                obj.Line.To = Vector2.new(headPos.X, headPos.Y)
                obj.Line.Color = boxColor
                obj.Line.Thickness = 1
                obj.Line.Visible = true
            else
                obj.Line.Visible = false
            end
        end

        -- Skeleton
        drawSkeleton(obj, char, Utils.getRig(char))

        -- Highlight / chams
        if obj.Highlight then
            obj.Highlight.Enabled = Config.ESP.Enabled and Config.ESP.Chams
            obj.Highlight.FillColor = Config.ESP.RainbowChams and Color3.fromHSV(tick() * Config.Misc.RainbowSpeed % 1, 1, 1) or Config.ESP.ChamsColor
            obj.Highlight.OutlineColor = Config.ESP.RainbowChams and Color3.fromHSV(tick() * Config.Misc.RainbowSpeed % 1, 1, 1) or Config.ESP.ChamsColor
            obj.Highlight.FillTransparency = Utils.clamp(Config.ESP.ChamsFill - Config.ESP.ChamsGlow * 0.05, 0, 1)
            obj.Highlight.OutlineTransparency = Utils.clamp(Config.ESP.ChamsOutline - Config.ESP.ChamsGlow * 0.03, 0, 1)
        end
    end
end

RunService.RenderStepped:Connect(ESP.update)

-- Player tracking
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        task.wait(0.3)
        ESP.create(plr)
    end)
end)

Players.PlayerRemoving:Connect(function(plr)
    ESP.destroy(plr)
end)-- ============================================================
-- AIMBOT
-- ============================================================
local Aim = {}
Aim.Held = false
Aim.CurrentTarget = nil
Aim.LockedPlayer = nil

Aim.FOVCircle = Draw.newCircle()
Aim.FOVFill = Draw.newCircle()
Aim.TargetLine = Draw.newLine()

if Aim.FOVCircle then
    Aim.FOVCircle.Thickness = 1
    Aim.FOVCircle.NumSides = 64
    Aim.FOVCircle.Color = Config.Aim.FOVColor
    Aim.FOVCircle.Filled = false
    Aim.FOVCircle.Visible = false
end
if Aim.FOVFill then
    Aim.FOVFill.Thickness = 1
    Aim.FOVFill.NumSides = 64
    Aim.FOVFill.Color = Config.Aim.FOVColor
    Aim.FOVFill.Filled = true
    Aim.FOVFill.Transparency = Config.Aim.FOVFillAlpha
    Aim.FOVFill.Visible = false
end
if Aim.TargetLine then
    Aim.TargetLine.Thickness = 1
    Aim.TargetLine.Color = Config.Aim.TargetLineColor
    Aim.TargetLine.Visible = false
end

function Aim.getTargetPart(char)
    if Config.Aim.TargetPart == "Head" then
        return char:FindFirstChild("Head")
    elseif Config.Aim.TargetPart == "Torso" then
        return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    else
        local parts = {}
        for _, p in ipairs(char:GetChildren()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                table.insert(parts, p)
            end
        end
        return parts[math.random(1, #parts)]
    end
end

function Aim.visible(part, char)
    if not Config.Aim.WallCheck then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, char}
    local origin = Camera.CFrame.Position
    local result = Workspace:Raycast(origin, (part.Position - origin), params)
    return result == nil
end

function Aim.predict(part, char)
    if Config.Aim.Prediction <= 0 then return part.Position end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return part.Position end
    local vel = hrp.AssemblyLinearVelocity
    return part.Position + vel * (Config.Aim.Prediction / 100)
end

function Aim.filterRole(plr)
    local role = Utils.roleOf(plr)
    if Config.Aim.TargetRole == "All" then return true end
    if Config.Aim.TargetRole == "Murder" and role == "Murder" then return true end
    if Config.Aim.TargetRole == "Sheriff" and role == "Sheriff" then return true end
    if Config.Aim.TargetRole == "Innocent" and role == "Innocent" then return true end
    return false
end

function Aim.findTarget()
    if Config.Aim.LockTarget and Aim.LockedPlayer then
        local plr = Aim.LockedPlayer
        if plr and plr.Character and Utils.isAlive(plr) then
            local part = Aim.getTargetPart(plr.Character)
            if part then return part, plr end
        end
        Aim.LockedPlayer = nil
    end

    local best, bestPlr
    local bestScore = math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if not Utils.isAlive(plr) then continue end
        local char = plr.Character
        local part = Aim.getTargetPart(char)
        if not part then continue end

        if not Aim.filterRole(plr) then continue end
        if Config.ESP.TeamCheck and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then continue end
        if Config.Aim.VisibleOnly and not Aim.visible(part, char) then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(Aim.predict(part, char))
        if not onScreen then continue end
        local screenVec = Vector2.new(screenPos.X, screenPos.Y)
        local fovDist = Utils.distance2D(screenVec, center)
        if fovDist > Config.Aim.FOV then continue end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local worldDist = (hrp and myHRP) and (hrp.Position - myHRP.Position).Magnitude or 0

        local score
        if Config.Aim.Priority == "FOV" then
            score = fovDist
        elseif Config.Aim.Priority == "Health" then
            score = char:FindFirstChildOfClass("Humanoid").Health
        else
            score = worldDist
        end

        if score < bestScore then
            bestScore = score
            best = part
            bestPlr = plr
        end
    end

    return best, bestPlr
end

function Aim.update(dt)
    if not hasDrawing then return end
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    if Aim.FOVCircle then
        Aim.FOVCircle.Position = center
        Aim.FOVCircle.Radius = Config.Aim.FOV
        Aim.FOVCircle.Color = Config.Aim.FOVColor
        Aim.FOVCircle.Visible = Config.Aim.Enabled and Config.Aim.DrawFOV and Config.Aim.ShowFOV
    end
    if Aim.FOVFill then
        Aim.FOVFill.Position = center
        Aim.FOVFill.Radius = Config.Aim.FOV
        Aim.FOVFill.Color = Config.Aim.FOVColor
        Aim.FOVFill.Transparency = Config.Aim.FOVFillAlpha
        Aim.FOVFill.Visible = Config.Aim.Enabled and Config.Aim.DrawFOV and Config.Aim.ShowFOV and Config.Aim.FOVFill
    end

    if not Config.Aim.Enabled then
        if Aim.TargetLine then Aim.TargetLine.Visible = false end
        return
    end

    if not Aim.Held then
        if Aim.TargetLine then Aim.TargetLine.Visible = false end
        return
    end

    local part, plr = Aim.findTarget()
    Aim.CurrentTarget = part

    if part then
        local predPos = Aim.predict(part, part.Parent)
        local screen, onScreen = Camera:WorldToViewportPoint(predPos)
        if onScreen and Aim.TargetLine then
            Aim.TargetLine.From = center
            Aim.TargetLine.To = Vector2.new(screen.X, screen.Y)
            Aim.TargetLine.Color = Config.Aim.TargetLineColor
            Aim.TargetLine.Visible = Config.Aim.ShowTargetLine
        end

        local desired = CFrame.new(Camera.CFrame.Position, predPos)
        if Config.Aim.Shake > 0 then
            local jitter = Vector3.new(
                (math.random() - 0.5) * Config.Aim.Shake * 0.001,
                (math.random() - 0.5) * Config.Aim.Shake * 0.001,
                (math.random() - 0.5) * Config.Aim.Shake * 0.001
            )
            desired = desired * CFrame.new(jitter)
        end
        local smoothFactor = math.clamp(dt * (Config.Aim.Smoothness), 0, 1)
        Camera.CFrame = Camera.CFrame:Lerp(desired, smoothFactor)

        if Config.Aim.LockTarget then Aim.LockedPlayer = plr end
    else
        if Aim.TargetLine then Aim.TargetLine.Visible = false end
    end
end

RunService.RenderStepped:Connect(Aim.update)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Config.Aim.Keybind or input.KeyCode == Config.Aim.Keybind then
        Aim.Held = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Config.Aim.Keybind or input.KeyCode == Config.Aim.Keybind then
        Aim.Held = false
        if not Config.Aim.LockTarget then Aim.LockedPlayer = nil end
    end
end)

-- ============================================================
-- PREVIEW VIEWPORT
-- ============================================================
local Preview = {}
Preview.Model = nil
Preview.Conn = nil

function Preview.build(parent)
    local holder = Utils.new("Frame", {
        Size = UDim2.new(1, -8, 0, 180),
        BackgroundColor3 = Themes[STATE.Theme].BgAlt,
        BackgroundTransparency = 0.2,
        Parent = parent,
    })
    Utils.new("UICorner", {CornerRadius = UDim.new(0, 6), Parent = holder})

    local vp = Utils.new("ViewportFrame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Parent = holder,
    })

    local cam = Instance.new("Camera")
    cam.FieldOfView = 50
    vp.CurrentCamera = cam
    cam.Parent = vp

    local rotation = 0

    local function cloneChar()
        if Preview.Model then Preview.Model:Destroy() end
        if not LocalPlayer.Character then return end
        local copy = LocalPlayer.Character:Clone()
        for _, d in ipairs(copy:GetDescendants()) do
            if d:IsA("BasePart") then
                d.Anchored = true
                d.CanCollide = false
            elseif d:IsA("Script") or d:IsA("LocalScript") then
                d:Destroy()
            elseif d:IsA("Highlight") then
                d:Destroy()
            end
        end
        copy.Parent = vp
        Preview.Model = copy

        local hrp = copy:FindFirstChild("HumanoidRootPart")
        if hrp then
            local pos = hrp.Position
            local distance = 5
            cam.CFrame = CFrame.new(pos + Vector3.new(0, 0.5, -distance), pos)
        end
    end

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        cloneChar()
    end)

    RunService.RenderStepped:Connect(function(dt)
        if not Preview.Model then return end
        rotation = rotation + dt * 30
        local hrp = Preview.Model:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local pos = hrp.Position
        local rad = math.rad(rotation)
        local distance = 5
        cam.CFrame = CFrame.new(pos + Vector3.new(math.sin(rad) * distance, 0.5, math.cos(rad) * distance), pos)
    end)

    task.wait(0.5)
    cloneChar()
    return holder
end

-- ============================================================
-- WATERMARK / FPS / PING
-- ============================================================
local Watermark = Utils.new("TextLabel", {
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextColor3 = Themes[STATE.Theme].Accent,
    BackgroundColor3 = Themes[STATE.Theme].Bg,
    BackgroundTransparency = 0.3,
    Size = UDim2.fromOffset(260, 26),
    Position = UDim2.new(0, 12, 0, 12),
    TextXAlignment = Enum.TextXAlignment.Left,
    Text = "",
    Parent = GUI.ScreenGui,
})
Utils.new("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Watermark})
Utils.new("UIPadding", {PaddingLeft = UDim.new(0, 10), Parent = Watermark})
Utils.new("UIStroke", {Color = Themes[STATE.Theme].Accent, Thickness = 1, Transparency = 0.5, Parent = Watermark})

local FPSLabel = Utils.new("TextLabel", {
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextColor3 = Themes[STATE.Theme].Text,
    BackgroundColor3 = Themes[STATE.Theme].Bg,
    BackgroundTransparency = 0.3,
    Size = UDim2.fromOffset(120, 22),
    Position = UDim2.new(0, 12, 0, 44),
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = GUI.ScreenGui,
})
Utils.new("UICorner", {CornerRadius = UDim.new(0, 6), Parent = FPSLabel})
Utils.new("UIPadding", {PaddingLeft = UDim.new(0, 8), Parent = FPSLabel})

RunService.RenderStepped:Connect(function()
    STATE.FrameCount = STATE.FrameCount + 1
    local now = tick()
    if now - STATE.LastFPSUpdate >= 1 then
        STATE.CurrentFPS = STATE.FrameCount
        STATE.FrameCount = 0
        STATE.LastFPSUpdate = now
        pcall(function()
            STATE.Ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        Watermark.Text = string.format("lemon | v%s | %s", STATE.Version, STATE.Language:upper())
        FPSLabel.Text = string.format("%s: %d | %s: %dms", L("fps"), STATE.CurrentFPS, L("ping"), STATE.Ping)
        Watermark.Visible = Config.ESP.DrawWatermark
        FPSLabel.Visible = Config.ESP.DrawFPS or Config.ESP.DrawPing
    end
end)

-- ============================================================
-- THEME / LANGUAGE APPLY
-- ============================================================
local function applyTheme(name)
    Config.Settings.Theme = name
    STATE.Theme = name
    local t = Themes[name]
    GUI.Main.BackgroundColor3 = t.Bg
    GUI.MainStroke.Color = t.Accent
    GUI.Title.TextColor3 = t.Accent
    GUI.Version.TextColor3 = t.TextDim
    Watermark.TextColor3 = t.Accent
    Watermark.BackgroundColor3 = t.Bg
    Watermark.UIStroke.Color = t.Accent
    FPSLabel.TextColor3 = t.Text
    FPSLabel.BackgroundColor3 = t.Bg
    for _, b in pairs(GUI.TabButtons) do
        b.BackgroundColor3 = t.BgAlt
        if b.BackgroundTransparency < 1 then
            b.TextColor3 = t.Accent
        else
            b.TextColor3 = t.TextDim
        end
    end
    for _, page in pairs(GUI.Pages) do
        page.ScrollBarImageColor3 = t.Accent
        for _, child in ipairs(page:GetDescendants()) do
            if child:IsA("Frame") and child.BackgroundTransparency < 0.9 then
                child.BackgroundColor3 = t.BgAlt
            end
            if child:IsA("TextLabel") or child:IsA("TextButton") then
                if child.TextColor3 == Color3.fromRGB(230,230,230) or child.TextColor3 == Color3.fromRGB(220,220,220) then
                    child.TextColor3 = t.Text
                end
            end
        end
    end
    if Aim.FOVCircle then Aim.FOVCircle.Color = Config.Aim.FOVColor end
    if Aim.FOVFill then Aim.FOVFill.Color = Config.Aim.FOVColor end
end

local function applyLanguage()
    STATE.Language = Config.Settings.Language
    GUI.TabButtons.esp.Text = L("esp")
    GUI.TabButtons.aim.Text = L("aim")
    GUI.TabButtons.settings.Text = L("settings")
    GUI.TabButtons.misc.Text = L("misc")
end

-- ============================================================
-- BUILD TABS
-- ============================================================
local espPage = GUI.makeTab("esp", L("esp"))
local aimPage = GUI.makeTab("aim", L("aim"))
local setPage = GUI.makeTab("settings", L("settings"))
local miscPage = GUI.makeTab("misc", L("misc"))

-- ============ ESP TAB ============
Widgets.section(espPage, "Visual")
Widgets.toggle(espPage, "ESP", "Enabled", Config.ESP, function() ESP.refresh() end)
Widgets.toggle(espPage, L("box"), "Box", Config.ESP)
Widgets.toggle(espPage, L("corner"), "CornerBox", Config.ESP)
Widgets.toggle(espPage, L("fillBox"), "FillBox", Config.ESP)
Widgets.slider(espPage, L("fillBoxAlpha"), "FillBoxAlpha", Config.ESP, 0, 100)
Widgets.slider(espPage, L("boxThickness"), "BoxThickness", Config.ESP, 1, 5)
Widgets.toggle(espPage, L("health"), "HealthBar", Config.ESP)
Widgets.slider(espPage, L("healthSize"), "HealthBarSize", Config.ESP, 1, 8)
Widgets.dropdown(espPage, L("healthBarPos"), "HealthBarPos", Config.ESP, {"Left", "Right"})
Widgets.toggle(espPage, L("name"), "Name", Config.ESP)
Widgets.toggle(espPage, L("distance"), "Distance", Config.ESP)
Widgets.toggle(espPage, L("line"), "Line", Config.ESP)
Widgets.toggle(espPage, L("tracer"), "Tracer", Config.ESP)
Widgets.dropdown(espPage, L("tracerOrigin"), "TracerOrigin", Config.ESP, {"Bottom", "Center", "Mouse"})
Widgets.toggle(espPage, L("skeleton"), "Skeleton", Config.ESP)
Widgets.slider(espPage, L("skeletonThickness"), "SkeletonThickness", Config.ESP, 1, 4)
Widgets.toggle(espPage, L("headDot"), "HeadDot", Config.ESP)
Widgets.slider(espPage, L("headDotSize"), "HeadDotSize", Config.ESP, 1, 10)
Widgets.toggle(espPage, L("weapon"), "Weapon", Config.ESP)
Widgets.toggle(espPage, L("role"), "Role", Config.ESP)
Widgets.toggle(espPage, L("chams"), "Chams", Config.ESP)
Widgets.toggle(espPage, L("rainbowChams"), "RainbowChams", Config.ESP)
Widgets.colorpicker(espPage, L("chams"), "ChamsColor", Config.ESP)
Widgets.slider(espPage, L("chamsGlow"), "ChamsGlow", Config.ESP, 0, 10)
Widgets.slider(espPage, L("chamsFill"), "ChamsFill", Config.ESP, 0, 100)
Widgets.slider(espPage, L("chamsOutline"), "ChamsOutline", Config.ESP, 0, 100)
Widgets.toggle(espPage, L("teamCheck"), "TeamCheck", Config.ESP)
Widgets.toggle(espPage, L("ignoreNPCs"), "IgnoreNPCs", Config.ESP)
Widgets.slider(espPage, L("maxDistance"), "MaxDistance", Config.ESP, 10, 3000)
Widgets.slider(espPage, L("textSize"), "TextSize", Config.ESP, 8, 24)
Widgets.toggle(espPage, L("textOutline"), "TextOutline", Config.ESP)
Widgets.toggle(espPage, L("drawFPS"), "DrawFPS", Config.ESP)
Widgets.toggle(espPage, L("drawPing"), "DrawPing", Config.ESP)
Widgets.toggle(espPage, L("drawWatermark"), "DrawWatermark", Config.ESP)

Widgets.section(espPage, "Preview")
local previewHolder
Widgets.toggle(espPage, L("preview"), "Preview", Config.ESP, function(v)
    if v then
        if not previewHolder then previewHolder = Preview.build(espPage) end
    else
        if previewHolder then previewHolder.Visible = false end
    end
end)

-- ============ AIM TAB ============
Widgets.section(aimPage, "AimBot")
Widgets.toggle(aimPage, L("aimEnabled"), "Enabled", Config.Aim)
Widgets.keybind(aimPage, L("keybind"), "Keybind", Config.Aim)
Widgets.dropdown(aimPage, L("targetRole"), "TargetRole", Config.Aim, {"All", "Murder", "Sheriff", "Innocent"})
Widgets.dropdown(aimPage, L("targetPart"), "TargetPart", Config.Aim, {"Head", "Torso", "Random"})
Widgets.dropdown(aimPage, L("priority"), "Priority", Config.Aim, {"Distance", "FOV", "Health"})
Widgets.slider(aimPage, L("smoothness"), "Smoothness", Config.Aim, 1, 30)
Widgets.slider(aimPage, L("fov"), "FOV", Config.Aim, 10, 600)
Widgets.slider(aimPage, L("prediction"), "Prediction", Config.Aim, 0, 100)
Widgets.slider(aimPage, L("shake"), "Shake", Config.Aim, 0, 50)
Widgets.toggle(aimPage, L("wallCheck"), "WallCheck", Config.Aim)
Widgets.toggle(aimPage, L("visibleOnly"), "VisibleOnly", Config.Aim)
Widgets.toggle(aimPage, L("lockTarget"), "LockTarget", Config.Aim)
Widgets.toggle(aimPage, L("resolver"), "Resolver", Config.Aim)
Widgets.toggle(aimPage, L("antiFling"), "AntiFling", Config.Aim)

Widgets.section(aimPage, "Visual")
Widgets.toggle(aimPage, L("drawFOV"), "DrawFOV", Config.Aim)
Widgets.toggle(aimPage, L("showFOV"), "ShowFOV", Config.Aim)
Widgets.colorpicker(aimPage, L("fovColor"), "FOVColor", Config.Aim, function(c)
    if Aim.FOVCircle then Aim.FOVCircle.Color = c end
    if Aim.FOVFill then Aim.FOVFill.Color = c end
end)
Widgets.toggle(aimPage, L("fovFill"), "FOVFill", Config.Aim)
Widgets.slider(aimPage, L("fovFillAlpha"), "FOVFillAlpha", Config.Aim, 0, 100)
Widgets.toggle(aimPage, L("showTargetLine"), "ShowTargetLine", Config.Aim)
Widgets.colorpicker(aimPage, L("targetLineColor"), "TargetLineColor", Config.Aim)

-- ============ SETTINGS TAB ============
Widgets.section(setPage, "Interface")
Widgets.dropdown(setPage, L("language"), "Language", Config.Settings, {"ru", "en"}, function()
    applyLanguage()
end)
Widgets.dropdown(setPage, L("theme"), "Theme", Config.Settings, {"red", "blue", "black", "purple", "pink", "green", "cyan", "white", "rainbow"}, function(v)
    applyTheme(v)
end)
Widgets.slider(setPage, L("transparency"), "Transparency", Config.Settings, 0, 100)
Widgets.slider(setPage, L("uiScale"), "UIScale", Config.Settings, 50, 150)
Widgets.toggle(setPage, L("animations"), "Animations", Config.Settings)
Widgets.toggle(setPage, L("autoSave"), "AutoSave", Config.Settings)

Widgets.section(setPage, "Config")
Widgets.button(setPage, L("saveConfig"), function()
    local ok, err = pcall(function()
        if writefile then
            writefile(Config.Settings.SavePath, HttpService:JSONEncode({
                ESP = Config.ESP,
                Aim = Config.Aim,
                Settings = Config.Settings,
                Misc = Config.Misc,
            }))
            Utils.notify("Config saved")
        else
            Utils.notify("writefile недоступен")
        end
    end)
    if not ok then Utils.notify("Save error: " .. tostring(err)) end
end)
Widgets.button(setPage, L("loadConfig"), function()
    local ok, err = pcall(function()
        if isfile and isfile(Config.Settings.SavePath) then
            local data = HttpService:JSONDecode(readfile(Config.Settings.SavePath))
            for section, tbl in pairs(data) do
                if Config[section] then
                    for k, v in pairs(tbl) do
                        Config[section][k] = v
                    end
                end
            end
            applyTheme(Config.Settings.Theme)
            applyLanguage()
            ESP.refresh()
            Utils.notify("Config loaded")
        else
            Utils.notify("Config not found")
        end
    end)
    if not ok then Utils.notify("Load error: " .. tostring(err)) end
end)
Widgets.button(setPage, L("resetConfig"), function()
    Utils.notify("Reset requires re-execution")
end)

-- ============ MISC TAB ============
Widgets.section(miscPage, "Misc")
Widgets.slider(miscPage, L("rainbowSpeed"), "RainbowSpeed", Config.Misc, 1, 20)
Widgets.toggle(miscPage, L("showKeybind"), "ShowKeybind", Config.Misc)

Widgets.section(miscPage, "Info")
Widgets.label(miscPage, "lemon mm2 v" .. STATE.Version)
Widgets.label(miscPage, "Build: " .. STATE.Build)
Widgets.label(miscPage, "by:@Promtikdeepseek")

-- ============================================================
-- RAINBOW LOOP
-- ============================================================
RunService.Heartbeat:Connect(function()
    if Config.Settings.Theme == "rainbow" then
        local hue = (tick() * Config.Misc.RainbowSpeed / 10) % 1
        local c = Color3.fromHSV(hue, 0.8, 1)
        GUI.MainStroke.Color = c
        GUI.Title.TextColor3 = c
        Watermark.TextColor3 = c
        Watermark.UIStroke.Color = c
        for _, b in pairs(GUI.TabButtons) do
            if b.BackgroundTransparency < 1 then b.TextColor3 = c end
        end
    end
end)

-- ============================================================
-- TOGGLE KEY
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == STATE.ToggleKey then
        GUI.ScreenGui.Enabled = not GUI.ScreenGui.Enabled
    end
end)

-- ============================================================
-- INIT
-- ============================================================
ESP.refresh()
applyTheme(Config.Settings.Theme)
applyLanguage()

STATE.Loaded = true
STATE.LoadedAt = tick()
Utils.notify("lemon loaded v" .. STATE.Version)

print(string.format("[lemon] v%s loaded | Drawing: %s | Language: %s",
    STATE.Version, tostring(hasDrawing), STATE.Language))
