-- synter hub v1.0
-- android / delta · aim · esp · movement · snow · preview

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")
local function cam() return workspace.CurrentCamera end
local function vp()  return cam().ViewportSize end
local function getChar() return LP.Character end
local function getHum() local c=getChar() return c and c:FindFirstChildOfClass("Humanoid") end
local isTouch = UserInputService.TouchEnabled

for _, n in ipairs({"SynterHub","SynterFovGui"}) do
    local g = PG:FindFirstChild(n); if g then pcall(function() g:Destroy() end) end
end
if _G.SynterCleanup then pcall(_G.SynterCleanup) end
pcall(function() RunService:UnbindFromRenderStep("SynterAimLoop") end)

local track = {}
local function addTrack(c) table.insert(track, c); return c end

-- ============================================================
-- КОНФИГ
-- ============================================================
local C = {
    Enabled=false, AlwaysAim=isTouch, Smoothness=0.65, FOV=150,
    MaxDist=500, DrawFOV=true, AimHeld=false, TeamCheck=true, IgnoreFriends=true,

    ESP=false, ESPMode="void", ESPHealth=true, ESPBox=true, ESPSkeleton=true,
    ESPTracers=true, ESPName=true,

    Noclip=false, Fly=false, FlySpeed=60, FlyAura=true, FlyAnim=true, FlyTilt=true,
    FlyAnimR15=616006541, FlyAnimR6=616005863,

    SpeedHack=16, SpeedOn=false,
    AntiAFK=true, AutoJump=false, JumpPower=50,

    Snow=true,

    theme="dark", cornersStyle="rounded",
    scale=1.00,
}

local state = { currentTab="aim" }
local offsetFromCenter = Vector2.new(0, 0)

-- ============================================================
-- ПАЛИТРА
-- ============================================================
local BG = {
    dark     = Color3.fromRGB(18, 20, 31),
    midnight = Color3.fromRGB(8, 9, 18),
    slate    = Color3.fromRGB(30, 34, 48),
}
local WIN_R   = { sharp=6, rounded=18, pill=30 }
local ROW_R   = { sharp=4, rounded=12, pill=22 }
local INNER_R = { sharp=3, rounded=9,  pill=16 }

local WHITE   = Color3.new(1,1,1)
local ON_TEXT = Color3.fromRGB(11, 13, 24)
local TEXT    = Color3.fromRGB(238, 240, 250)
local MUTED   = Color3.fromRGB(139, 144, 168)
local SOFT    = Color3.fromRGB(170, 176, 200)
local TAB_IDLE= Color3.fromRGB(124, 130, 155)
local OFF     = Color3.fromRGB(52, 55, 66)

local PRESETS = { "#a3e635", "#22d3ee", "#a78bfa", "#fb7185", "#fbbf24", "#60a5fa", "#f8fafc" }

local ACCENT    = Color3.fromHex("#a3e635")
local ESP_COLOR = Color3.fromHex("#22d3ee")
local FOV_COLOR = Color3.fromHex("#f8fafc")

local function parseHex(s)
    if type(s) ~= "string" then return nil end
    s = s:gsub("#",""):gsub("0x",""):gsub("0X",""):gsub("%s","")
    if #s ~= 6 then return nil end
    local r = tonumber(s:sub(1,2),16); local g = tonumber(s:sub(3,4),16); local b = tonumber(s:sub(5,6),16)
    if not (r and g and b) then return nil end
    return Color3.fromRGB(r,g,b)
end

-- ============================================================
-- FOV GUI + ESP LAYER + SNOW
-- ============================================================
local fovGui = Instance.new("ScreenGui")
fovGui.Name = "SynterFovGui"
fovGui.ResetOnSpawn = false; fovGui.IgnoreGuiInset = true
fovGui.DisplayOrder = 998; fovGui.Parent = PG

local snowLayer = Instance.new("Frame")
snowLayer.Name = "SnowLayer"
snowLayer.Size = UDim2.new(1,0,1,0)
snowLayer.BackgroundTransparency = 1; snowLayer.BorderSizePixel = 0
snowLayer.Active = false; snowLayer.ZIndex = 0; snowLayer.Parent = fovGui

local espLayer = Instance.new("Frame")
espLayer.Name = "ESPLayer"
espLayer.Size = UDim2.new(1,0,1,0)
espLayer.BackgroundTransparency = 1; espLayer.BorderSizePixel = 0
espLayer.Active = false; espLayer.ZIndex = 3; espLayer.Parent = fovGui

local snowFlakes = {}
do
    local v = vp()
    for i = 1, 60 do
        local f = Instance.new("Frame")
        f.BackgroundColor3 = WHITE
        f.BackgroundTransparency = 0.15 + math.random() * 0.5
        f.BorderSizePixel = 0; f.Active = false; f.ZIndex = 1
        f.Parent = snowLayer
        Instance.new("UICorner", f).CornerRadius = UDim.new(1,0)
        local sz = 2 + math.random() * 4
        f.Size = UDim2.fromOffset(sz, sz)
        snowFlakes[i] = {
            gui=f, x=math.random()*v.X, y=math.random()*v.Y, size=sz,
            speed=20+math.random()*40+sz*4, amp=8+math.random()*18,
            freq=0.5+math.random()*1.2, phase=math.random()*math.pi*2,
        }
    end
end
local snowTime = 0

local fovFrame = Instance.new("Frame")
fovFrame.AnchorPoint = Vector2.new(0.5,0.5)
fovFrame.Position = UDim2.new(0.5,0,0.5,0)
fovFrame.BackgroundTransparency = 1; fovFrame.BorderSizePixel = 0
fovFrame.Visible = false; fovFrame.ZIndex = 4; fovFrame.Parent = fovGui
Instance.new("UICorner", fovFrame).CornerRadius = UDim.new(1,0)
local fovStroke = Instance.new("UIStroke", fovFrame); fovStroke.Thickness = 1.6

local fovPulse = 0
local function updateFovCircle(dt)
    fovPulse = (fovPulse + (dt or 0)*2) % (math.pi*2)
    local pulse = 1 + math.sin(fovPulse)*0.04
    fovFrame.Position = UDim2.new(0.5,0,0.5,0)
    fovFrame.Size = UDim2.new(0, C.FOV*2*pulse, 0, C.FOV*2*pulse)
    fovFrame.Visible = C.DrawFOV
    fovStroke.Color = FOV_COLOR
    fovStroke.Thickness = 1.6 + math.sin(fovPulse)*0.4
end

-- ============================================================
-- AIM
-- ============================================================
local friends = {}
local function refreshFriends()
    friends = {}
    pcall(function()
        local ok, list = pcall(function() return LP:GetFriendsOnline() end)
        if ok and type(list) == "table" then
            for _, f in ipairs(list) do if f.VisitorId then friends[f.VisitorId] = true end end
        end
    end)
end

local function isEnemy(plr)
    if C.TeamCheck and LP.Team and plr.Team and LP.Team == plr.Team then return false end
    if C.IgnoreFriends and friends[plr.UserId] then return false end
    return true
end

local function wallClear(targetChar, targetPos)
    local c = cam()
    local origin = c.CFrame.Position
    local dir = targetPos - origin
    local filter = { c }
    local mine = getChar()
    if mine then table.insert(filter, mine) end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    for _ = 1, 6 do
        params.FilterDescendantsInstances = filter
        local r = workspace:Raycast(origin, dir, params)
        if not r then return true end
        local hit = r.Instance
        if hit:IsDescendantOf(targetChar) then return true end
        if hit.Transparency >= 0.9 or not hit.CanCollide then
            table.insert(filter, hit)
        else
            return false
        end
    end
    return false
end

local lockedTarget, lockLost = nil, 0

local function aimPartOf(char)
    return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end

local function pickBest()
    local best, bestDist = nil, C.FOV
    local myChar = getChar()
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myPos = myRoot and myRoot.Position or cam().CFrame.Position
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character and isEnemy(plr) then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local part = aimPartOf(plr.Character)
            if hum and hum.Health > 0 and part then
                if (part.Position - myPos).Magnitude <= C.MaxDist then
                    local sp, on = cam():WorldToViewportPoint(part.Position)
                    if on and sp.Z > 0 then
                        local size = vp()
                        local d = (Vector2.new(sp.X,sp.Y) - Vector2.new(size.X/2,size.Y/2)).Magnitude
                        if d < bestDist and wallClear(plr.Character, part.Position) then
                            bestDist = d
                            best = part
                        end
                    end
                end
            end
        end
    end
    return best
end

local function findTarget()
    if lockedTarget then
        local parent = lockedTarget.Parent
        local hum = parent and parent:FindFirstChildOfClass("Humanoid")
        if parent and hum and hum.Health > 0 then
            local sp, on = cam():WorldToViewportPoint(lockedTarget.Position)
            if on and sp.Z > 0 then
                local size = vp()
                local d = (Vector2.new(sp.X,sp.Y) - Vector2.new(size.X/2,size.Y/2)).Magnitude
                if d < C.FOV and wallClear(parent, lockedTarget.Position) then
                    lockLost = 0
                    return lockedTarget
                end
            end
        end
        lockLost = lockLost + 1
        if lockLost < 6 then return lockedTarget end
        lockedTarget = nil; lockLost = 0
    end
    local best = pickBest()
    if best then lockedTarget = best; lockLost = 0 end
    return best
end

-- ============================================================
-- ESP MODES
-- ============================================================
local espTracked = {}
local hue = 0

local MODES = {
    void    = { fill=Color3.fromRGB(0,0,0),       outline=Color3.fromRGB(160,60,255),
                light=Color3.fromRGB(140,60,255), bright=2.4, range=14,
                body=Color3.fromRGB(0,0,0),       mat=Enum.Material.SmoothPlastic, fillT=0, outlineT=0 },
    blood   = { fill=Color3.fromRGB(60,0,0),      outline=Color3.fromRGB(220,25,25),
                light=Color3.fromRGB(220,25,25), bright=2.2, range=13,
                body=Color3.fromRGB(40,0,0),      mat=Enum.Material.Neon, fillT=0.05, outlineT=0 },
    glow    = { fill=Color3.fromRGB(255,245,200), outline=Color3.fromRGB(255,235,140),
                light=Color3.fromRGB(255,240,180), bright=2.6, range=15,
                body=Color3.fromRGB(255,240,200), mat=Enum.Material.Neon, fillT=0.35, outlineT=0 },
    fire    = { fill=Color3.fromRGB(255,90,0),    outline=Color3.fromRGB(255,200,0),
                light=Color3.fromRGB(255,120,0), bright=2.8, range=16,
                body=Color3.fromRGB(255,80,0),    mat=Enum.Material.Neon, fillT=0.1, outlineT=0 },
    frost   = { fill=Color3.fromRGB(180,230,255), outline=Color3.fromRGB(80,180,255),
                light=Color3.fromRGB(140,210,255), bright=2.4, range=14,
                body=Color3.fromRGB(180,230,255), mat=Enum.Material.Neon, fillT=0.2, outlineT=0 },
    toxic   = { fill=Color3.fromRGB(30,180,40),   outline=Color3.fromRGB(150,255,80),
                light=Color3.fromRGB(60,220,60), bright=2.4, range=14,
                body=Color3.fromRGB(20,120,30),   mat=Enum.Material.Neon, fillT=0.15, outlineT=0 },
    plasma  = { fill=Color3.fromRGB(255,50,220),  outline=Color3.fromRGB(255,180,255),
                light=Color3.fromRGB(255,80,220), bright=2.8, range=16,
                body=Color3.fromRGB(255,30,200),  mat=Enum.Material.Neon, fillT=0.1, outlineT=0 },
    galaxy  = { fill=Color3.fromRGB(40,15,90),    outline=Color3.fromRGB(200,80,255),
                light=Color3.fromRGB(150,60,255), bright=2.6, range=15,
                body=Color3.fromRGB(25,8,60),     mat=Enum.Material.Neon, fillT=0.05, outlineT=0 },
    ghost   = { fill=Color3.fromRGB(230,240,255), outline=Color3.fromRGB(200,220,255),
                light=Color3.fromRGB(220,230,255), bright=1.8, range=12,
                body=nil, mat=nil, fillT=0.55, outlineT=0.3 },
    rainbow = { fill=nil, outline=nil, light=nil, bright=2.4, range=14,
                body=nil, mat=Enum.Material.Neon, fillT=0.15, outlineT=0 },
    default = { fill=Color3.fromRGB(255,50,50),   outline=Color3.fromRGB(255,255,255),
                light=Color3.fromRGB(255,60,60), bright=1.6, range=10,
                body=nil, mat=nil, fillT=0.5, outlineT=0 },
    gold    = { fill=Color3.fromRGB(255,200,40),  outline=Color3.fromRGB(255,240,180),
                light=Color3.fromRGB(255,215,90), bright=2.6, range=15,
                body=Color3.fromRGB(255,200,40),  mat=Enum.Material.Neon, fillT=0.15, outlineT=0 },
    emerald = { fill=Color3.fromRGB(20,220,140),  outline=Color3.fromRGB(180,255,220),
                light=Color3.fromRGB(40,240,160), bright=2.4, range=14,
                body=Color3.fromRGB(15,180,110),  mat=Enum.Material.Neon, fillT=0.1, outlineT=0 },
    crimson = { fill=Color3.fromRGB(180,20,40),   outline=Color3.fromRGB(255,120,140),
                light=Color3.fromRGB(220,40,70),  bright=2.4, range=14,
                body=Color3.fromRGB(140,15,30),   mat=Enum.Material.Neon, fillT=0.1, outlineT=0 },
    shadow  = { fill=Color3.fromRGB(10,10,20),    outline=Color3.fromRGB(90,90,140),
                light=Color3.fromRGB(60,60,110),  bright=1.6, range=12,
                body=Color3.fromRGB(15,15,30),    mat=Enum.Material.SmoothPlastic, fillT=0.15, outlineT=0.4 },
    lava    = { fill=Color3.fromRGB(200,30,0),    outline=Color3.fromRGB(255,150,30),
                light=Color3.fromRGB(255,100,20), bright=2.8, range=16,
                body=Color3.fromRGB(180,25,0),    mat=Enum.Material.Neon, fillT=0.05, outlineT=0 },
}

local bodySnapshots = {}
local function snapshotBody(char)
    if bodySnapshots[char] then return end
    local snap = {}
    for _, p in ipairs(char:GetChildren()) do
        if p:IsA("BasePart") then
            table.insert(snap, { part=p, color=p.Color, material=p.Material })
        end
    end
    bodySnapshots[char] = snap
end
local function restoreBody(char)
    local snap = bodySnapshots[char]; if not snap then return end
    for _, e in ipairs(snap) do
        if e.part and e.part.Parent then
            pcall(function() e.part.Color = e.color end)
            pcall(function() e.part.Material = e.material end)
        end
    end
    bodySnapshots[char] = nil
end
local function applyBodyMode(char, mode, rainbowCol)
    local cfg = MODES[mode]
    if not cfg or not cfg.body then restoreBody(char); return end
    snapshotBody(char)
    local col = cfg.body
    if mode == "rainbow" and rainbowCol then col = rainbowCol end
    for _, p in ipairs(char:GetChildren()) do
        if p:IsA("BasePart") then
            pcall(function()
                if cfg.mat and p.Material ~= cfg.mat then p.Material = cfg.mat end
                if col and p.Color ~= col then p.Color = col end
            end)
        end
    end
end
local function applyHighlightMode(entry, mode, rainbowCol)
    local cfg = MODES[mode]; if not cfg then return end
    local h, l = entry.highlight, entry.light
    if h and h.Parent then
        local fill, outline = cfg.fill, cfg.outline
        if mode == "rainbow" and rainbowCol then
            fill = rainbowCol
            outline = rainbowCol:Lerp(Color3.new(1,1,1), 0.45)
        end
        h.FillColor = fill; h.OutlineColor = outline
        h.FillTransparency = cfg.fillT; h.OutlineTransparency = cfg.outlineT
    end
    if l and l.Parent then
        local lc = cfg.light
        if mode == "rainbow" and rainbowCol then lc = rainbowCol end
        l.Color = lc; l.Brightness = cfg.bright
        l.Range = cfg.range; l.Shadows = false
    end
end

-- HEALTH BAR
local function makeHealthBar(hrp)
    local bb = Instance.new("BillboardGui")
    bb.Name="SynterHB"; bb.Adornee=hrp
    bb.Size=UDim2.new(0,80,0,32); bb.StudsOffset=Vector3.new(3.4,0.6,0)
    bb.AlwaysOnTop=true; bb.MaxDistance=1500; bb.LightInfluence=0
    bb.Parent=hrp
    local label = Instance.new("TextLabel")
    label.Size=UDim2.new(1,0,0,14); label.BackgroundTransparency=1
    label.Text="100"; label.TextColor3=WHITE
    label.Font=Enum.Font.GothamBold; label.TextSize=12
    label.TextStrokeTransparency=0.2; label.TextStrokeColor3=Color3.new(0,0,0)
    label.Parent=bb
    local barBg = Instance.new("Frame")
    barBg.Size=UDim2.new(1,0,0,8); barBg.Position=UDim2.new(0,0,0,18)
    barBg.BackgroundColor3=Color3.fromRGB(14,14,20)
    barBg.BorderSizePixel=0; barBg.Parent=bb
    Instance.new("UICorner",barBg).CornerRadius=UDim.new(1,0)
    local s = Instance.new("UIStroke", barBg)
    s.Color=Color3.new(0,0,0); s.Thickness=1.2
    local fill = Instance.new("Frame")
    fill.Size=UDim2.new(1,-2,1,-2); fill.Position=UDim2.new(0,1,0,1)
    fill.BackgroundColor3=Color3.fromRGB(60,220,90)
    fill.BorderSizePixel=0; fill.Parent=barBg
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    return { billboard=bb, fill=fill, label=label }
end
local function updateHealthBar(hb, hum)
    if not hb or not hb.billboard or not hb.billboard.Parent then return end
    local maxH = math.max(hum.MaxHealth, 1)
    local ratio = math.clamp(hum.Health/maxH, 0, 1)
    hb.fill.Size = UDim2.new(ratio, -2, 1, -2)
    local col
    if ratio > 0.5 then
        col = Color3.fromRGB(60,220,90):Lerp(Color3.fromRGB(255,210,60), (1-ratio)*2)
    else
        col = Color3.fromRGB(255,210,60):Lerp(Color3.fromRGB(230,40,40), 1-ratio*2)
    end
    hb.fill.BackgroundColor3 = col
    hb.label.Text = tostring(math.floor(hum.Health + 0.5)) .. " / " .. tostring(math.floor(maxH))
end

-- NAME
local function makeNameTag(hrp)
    local bb = Instance.new("BillboardGui")
    bb.Name="SynterName"; bb.Adornee=hrp
    bb.Size=UDim2.new(0,140,0,18); bb.StudsOffset=Vector3.new(0,3.4,0)
    bb.AlwaysOnTop=true; bb.MaxDistance=800; bb.LightInfluence=0
    bb.Parent=hrp
    local l = Instance.new("TextLabel")
    l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1
    l.Text=""; l.TextColor3=WHITE
    l.Font=Enum.Font.GothamBold; l.TextSize=12
    l.TextStrokeTransparency=0.15; l.TextStrokeColor3=Color3.new(0,0,0)
    l.Parent=bb
    return { billboard=bb, label=l }
end
local function updateNameTag(nt, plr, hrp)
    if not nt or not nt.billboard or not nt.billboard.Parent then return end
    local myChar = getChar()
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local dist = "?"
    if myRoot then dist = tostring(math.floor((hrp.Position - myRoot.Position).Magnitude)) end
    nt.label.Text = plr.Name .. " [" .. dist .. "m]"
end

-- TRACERS
local tracerCache = {}
local function getTracer(plr)
    local t = tracerCache[plr]
    if t and t.Parent then return t end
    local f = Instance.new("Frame")
    f.AnchorPoint = Vector2.new(0.5, 0); f.BorderSizePixel = 0
    f.Visible = false; f.ZIndex = 2; f.Parent = espLayer
    tracerCache[plr] = f
    return f
end
local function updateTracer(plr, screenPos, color)
    local t = getTracer(plr); if not t then return end
    if not screenPos then t.Visible = false; return end
    local size = vp()
    local fromX, fromY = size.X / 2, size.Y
    local toX, toY = screenPos.X, screenPos.Y
    local dx, dy = toX - fromX, toY - fromY
    local len = math.sqrt(dx*dx + dy*dy)
    t.Size = UDim2.fromOffset(math.max(len, 1), 1.4)
    t.Position = UDim2.fromOffset((fromX+toX)/2, (fromY+toY)/2)
    t.Rotation = math.deg(math.atan2(dy, dx))
    t.BackgroundColor3 = color; t.Visible = true
end
local function clearTracer(plr)
    local t = tracerCache[plr]
    if t then pcall(function() t:Destroy() end); tracerCache[plr] = nil end
end

-- BOX / SKELETON
local SKELETON_R15 = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}
local SKELETON_R6 = {
    {"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},
    {"Torso","Left Leg"},{"Torso","Right Leg"},
}
local function mkLineFrame()
    local f = Instance.new("Frame")
    f.AnchorPoint=Vector2.new(0.5,0.5); f.BorderSizePixel=0
    f.Visible=false; f.ZIndex=2; f.Parent=espLayer
    return f
end
local function setLine(f,a,b,color,th)
    local d = b - a
    f.Size = UDim2.fromOffset(math.max(d.Magnitude,1), th)
    f.Position = UDim2.fromOffset((a.X+b.X)/2, (a.Y+b.Y)/2)
    f.Rotation = math.deg(math.atan2(d.Y, d.X))
    f.BackgroundColor3 = color; f.Visible = true
end
local function mkBoxFrame()
    local f = Instance.new("Frame")
    f.BackgroundTransparency=1; f.BorderSizePixel=0
    f.Visible=false; f.ZIndex=2; f.Parent=espLayer
    local s = Instance.new("UIStroke", f); s.Thickness = 1.6
    return f, s
end
local function hideOverlay(entry)
    if entry.box then entry.box.Visible = false end
    if entry.skel then for _, l in pairs(entry.skel) do l.Visible = false end end
end
local function updateOverlay(entry, char, color)
    if not C.ESPBox and not C.ESPSkeleton then hideOverlay(entry); return end
    local c = cam()

    -- 3D AABB по прямым частям тела (без аксессуаров и HRP)
    local minP, maxP = nil, nil
    for _, p in ipairs(char:GetChildren()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            local half = p.Size / 2
            if not minP then
                minP = p.Position - half; maxP = p.Position + half
            else
                minP = Vector3.new(math.min(minP.X, p.Position.X - half.X),
                                   math.min(minP.Y, p.Position.Y - half.Y),
                                   math.min(minP.Z, p.Position.Z - half.Z))
                maxP = Vector3.new(math.max(maxP.X, p.Position.X + half.X),
                                   math.max(maxP.Y, p.Position.Y + half.Y),
                                   math.max(maxP.Z, p.Position.Z + half.Z))
            end
        end
    end
    if not minP then hideOverlay(entry); return end

    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
    for xi=0,1 do for yi=0,1 do for zi=0,1 do
        local v = Vector3.new(xi==0 and minP.X or maxP.X,
                              yi==0 and minP.Y or maxP.Y,
                              zi==0 and minP.Z or maxP.Z)
        local sp, on = c:WorldToViewportPoint(v)
        if on and sp.Z > 0 then
            minX = math.min(minX, sp.X); minY = math.min(minY, sp.Y)
            maxX = math.max(maxX, sp.X); maxY = math.max(maxY, sp.Y)
        end
    end end end
    if minX == math.huge then hideOverlay(entry); return end

    if C.ESPBox then
        if not entry.box then entry.box, entry.boxStroke = mkBoxFrame() end
        entry.box.Position = UDim2.fromOffset(minX, minY)
        entry.box.Size = UDim2.fromOffset(maxX - minX, maxY - minY)
        entry.boxStroke.Color = color
        entry.box.Visible = true
    elseif entry.box then
        entry.box.Visible = false
    end

    if C.ESPSkeleton then
        entry.skel = entry.skel or {}
        local conns = char:FindFirstChild("UpperTorso") and SKELETON_R15 or SKELETON_R6
        for i, pair in ipairs(conns) do
            local p1, p2 = char:FindFirstChild(pair[1]), char:FindFirstChild(pair[2])
            local line = entry.skel[i]; local shown = false
            if p1 and p2 then
                local s1 = c:WorldToViewportPoint(p1.Position)
                local s2 = c:WorldToViewportPoint(p2.Position)
                if s1.Z > 0 and s2.Z > 0 then
                    if not line then line = mkLineFrame(); entry.skel[i] = line end
                    setLine(line, Vector2.new(s1.X,s1.Y), Vector2.new(s2.X,s2.Y), color, 1.6)
                    shown = true
                end
            end
            if not shown and line then line.Visible = false end
        end
    elseif entry.skel then
        for _, l in pairs(entry.skel) do l.Visible = false end
    end
end

local function safeDestroy(o) if o then pcall(function() o:Destroy() end) end end
local function clearESP(plr)
    local e = espTracked[plr]; if not e then return end
    if e.char then restoreBody(e.char) end
    safeDestroy(e.highlight); safeDestroy(e.light)
    if e.health then safeDestroy(e.health.billboard) end
    if e.nametag then safeDestroy(e.nametag.billboard) end
    safeDestroy(e.box)
    if e.skel then for _, l in pairs(e.skel) do safeDestroy(l) end end
    espTracked[plr] = nil
    clearTracer(plr)
end
local function ensureESP(plr, char, hrp)
    local entry = espTracked[plr]
    if entry and entry.char ~= char then clearESP(plr); entry = nil end
    if not entry then entry = { char = char }; espTracked[plr] = entry end
    if not (entry.highlight and entry.highlight.Parent == char) then
        safeDestroy(entry.highlight)
        local h = Instance.new("Highlight")
        h.Name="SynterHL"; h.Adornee=char
        h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent=char; entry.highlight = h
    end
    if not (entry.light and entry.light.Parent == hrp) then
        safeDestroy(entry.light)
        local l = Instance.new("PointLight")
        l.Name="SynterLight"; l.Parent = hrp
        entry.light = l
    end
    return entry
end
local function updateOne(plr, rainbowCol)
    local char = plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not (char and hum and hrp) or hum.Health <= 0 then
        if espTracked[plr] then clearESP(plr) end
        return
    end
    local entry = ensureESP(plr, char, hrp)
    applyHighlightMode(entry, C.ESPMode, rainbowCol)
    applyBodyMode(char, C.ESPMode, rainbowCol)
    if C.ESPMode == "glow" and entry.light then
        entry.light.Brightness = 2.2 + math.sin(hue*math.pi*6)*0.6
    end
    if C.ESPHealth then
        if not (entry.health and entry.health.billboard.Parent == hrp) then
            if entry.health then safeDestroy(entry.health.billboard) end
            entry.health = makeHealthBar(hrp)
        end
        updateHealthBar(entry.health, hum)
    elseif entry.health then
        safeDestroy(entry.health.billboard); entry.health = nil
    end
    if C.ESPName then
        if not (entry.nametag and entry.nametag.billboard.Parent == hrp) then
            if entry.nametag then safeDestroy(entry.nametag.billboard) end
            entry.nametag = makeNameTag(hrp)
        end
        updateNameTag(entry.nametag, plr, hrp)
    elseif entry.nametag then
        safeDestroy(entry.nametag.billboard); entry.nametag = nil
    end
    local color = ESP_COLOR
    if C.ESPMode == "rainbow" then color = rainbowCol end
    updateOverlay(entry, char, color)
    if C.ESPTracers then
        local sp, on = cam():WorldToViewportPoint(hrp.Position)
        if on and sp.Z > 0 then
            updateTracer(plr, Vector2.new(sp.X, sp.Y), color)
        else
            updateTracer(plr, nil, color)
        end
    else
        updateTracer(plr, nil, color)
    end
end
local function updateESP(dt)
    local toRemove = nil
    for plr in pairs(espTracked) do
        if not plr.Parent then
            toRemove = toRemove or {}; table.insert(toRemove, plr)
        end
    end
    if toRemove then for _, plr in ipairs(toRemove) do clearESP(plr) end end
    for plr in pairs(tracerCache) do
        if not plr.Parent or not espTracked[plr] then clearTracer(plr) end
    end
    if not C.ESP then
        local all = {}
        for plr in pairs(espTracked) do table.insert(all, plr) end
        for _, plr in ipairs(all) do clearESP(plr) end
        for plr in pairs(tracerCache) do clearTracer(plr) end
        return
    end
    hue = (hue + dt*0.22) % 1
    local rainbowCol = Color3.fromHSV(hue, 0.9, 1)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then pcall(updateOne, plr, rainbowCol) end
    end
end
addTrack(Players.PlayerRemoving:Connect(function(plr) clearESP(plr) end))

-- NOCLIP
addTrack(RunService.Stepped:Connect(function()
    if not C.Noclip then return end
    local char = getChar(); if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.CanCollide then
            pcall(function() p.CanCollide = false end)
        end
    end
end))

-- FLY
local flyBV = nil
local function ensureFlyBV()
    local root = getChar() and getChar():FindFirstChild("HumanoidRootPart")
    if not root then return end
    if flyBV and flyBV.Parent == root then return end
    if flyBV then flyBV:Destroy() end
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e5,1e5,1e5)
    flyBV.Velocity = Vector3.new(0,0,0)
    flyBV.Parent = root
end
local function stopFlyBV() if flyBV then flyBV:Destroy(); flyBV = nil end end

local function clearFlyAura()
    local a = _G._synterAura; if not a then return end
    for _, obj in ipairs({a.trail,a.particles,a.light,a.a0,a.a1,a.hl}) do
        pcall(function() if obj and obj.Parent then obj:Destroy() end end)
    end
    _G._synterAura = nil
end
local function ensureFlyAura()
    local char = getChar(); if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
    if _G._synterAura and _G._synterAura.root == root and _G._synterAura.root.Parent then return end
    clearFlyAura()
    local a0 = Instance.new("Attachment"); a0.Position=Vector3.new(0.85,0.4,1); a0.Parent=root
    local a1 = Instance.new("Attachment"); a1.Position=Vector3.new(-0.85,0.4,1); a1.Parent=root
    local trail = Instance.new("Trail")
    trail.Attachment0=a0; trail.Attachment1=a1
    trail.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,245,120)),
        ColorSequenceKeypoint.new(0.4, Color3.fromRGB(120,200,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(60,110,255)),
    })
    trail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,0.1),
        NumberSequenceKeypoint.new(0.6,0.5),
        NumberSequenceKeypoint.new(1,1),
    })
    trail.Lifetime=0.55; trail.MinLength=0
    trail.WidthScale = NumberSequence.new({
        NumberSequenceKeypoint.new(0,1.4), NumberSequenceKeypoint.new(1,0),
    })
    trail.FaceCamera=true; trail.LightEmission=1; trail.LightInfluence=0
    trail.Parent=root
    local particles = Instance.new("ParticleEmitter")
    particles.Rate=90; particles.Lifetime=NumberRange.new(0.4,0.9)
    particles.Speed=NumberRange.new(18,34); particles.SpreadAngle=Vector2.new(25,25)
    particles.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,240,90)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(140,210,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80,140,255)),
    })
    particles.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0,0.65), NumberSequenceKeypoint.new(1,0),
    })
    particles.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,0.15), NumberSequenceKeypoint.new(1,1),
    })
    particles.LightEmission=1; particles.LightInfluence=0
    particles.Rotation=NumberRange.new(0,360); particles.RotSpeed=NumberRange.new(-120,120)
    particles.Parent=root
    local light = Instance.new("PointLight")
    light.Color=Color3.fromRGB(255,220,110); light.Brightness=3.2
    light.Range=16; light.Shadows=false; light.Parent=root
    local hl = Instance.new("Highlight")
    hl.Adornee=char
    hl.FillColor=Color3.fromRGB(255,240,120); hl.FillTransparency=0.85
    hl.OutlineColor=Color3.fromRGB(120,200,255); hl.OutlineTransparency=0
    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent=char
    _G._synterAura = { root=root, trail=trail, particles=particles, light=light, a0=a0, a1=a1, hl=hl }
end

local flyAnimTrack, flyAnimChar, flyAnimLoading = nil, nil, false
local function stopFlyAnim()
    if flyAnimTrack then pcall(function() flyAnimTrack:Stop(0.15) end); flyAnimTrack = nil end
    flyAnimChar = nil
end
local function tryPlayAnim(hum, animId)
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. tostring(animId)
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then animator = Instance.new("Animator"); animator.Parent = hum end
    local ok, tA = pcall(function() return animator:LoadAnimation(anim) end)
    if ok and tA then
        tA.Priority=Enum.AnimationPriority.Action4; tA.Looped=true
        pcall(function() tA:Play(0.1) end); task.wait(0.2)
        if tA.IsPlaying then return tA end
    end
    local ok2, tB = pcall(function() return hum:LoadAnimation(anim) end)
    if ok2 and tB then
        tB.Priority=Enum.AnimationPriority.Action4; tB.Looped=true
        pcall(function() tB:Play(0.1) end); task.wait(0.2)
        if tB.IsPlaying then return tB end
    end
    return nil
end
local function ensureFlyAnim()
    local char = getChar(); if not char then stopFlyAnim(); return end
    if flyAnimLoading then return end
    if flyAnimChar == char and flyAnimTrack and flyAnimTrack.IsPlaying then return end
    stopFlyAnim()
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local animId = char:FindFirstChild("UpperTorso") and C.FlyAnimR15 or C.FlyAnimR6
    if not animId then return end
    flyAnimLoading = true
    task.spawn(function()
        local ok, tA = pcall(tryPlayAnim, hum, animId)
        if ok and tA then
            if C.Fly and C.FlyAnim then flyAnimTrack = tA; flyAnimChar = char
            else pcall(function() tA:Stop(0.1) end) end
        end
        task.wait(1); flyAnimLoading = false
    end)
end
local function applyFlyTilt(dt)
    if not C.FlyTilt or not C.Fly then return end
    local char = getChar(); if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    local look = cam().CFrame.LookVector
    local flat = Vector3.new(look.X, 0, look.Z)
    if flat.Magnitude < 0.01 then return end
    flat = flat.Unit
    local targetYaw = math.atan2(-flat.X, -flat.Z)
    local pitch = math.asin(math.clamp(look.Y, -1, 1))
    local targetPitch = math.clamp(pitch * 0.5, -0.6, 0.6)
    hum.AutoRotate = false
    local cur = root.CFrame
    local desired = CFrame.new(cur.Position) * CFrame.Angles(0, targetYaw, 0) * CFrame.Angles(targetPitch, 0, 0)
    root.CFrame = cur:Lerp(desired, math.clamp(dt * 6, 0, 1))
end

local lastActivity = tick()
addTrack(UserInputService.InputBegan:Connect(function() lastActivity = tick() end))
addTrack(RunService.Heartbeat:Connect(function()
    if C.AntiAFK and tick() - lastActivity >= 60 then
        local hum = getHum()
        if hum then pcall(function() hum.Jump = true end) end
        lastActivity = tick()
    end
    if C.AutoJump then
        local hum = getHum()
        if hum and hum.FloorMaterial ~= Enum.Material.Air and hum.Health > 0 then
            pcall(function() hum.Jump = true end)
        end
    end
end))

addTrack(RunService.Heartbeat:Connect(function(dt)
    if C.Fly then
        ensureFlyBV()
        if C.FlyAura then ensureFlyAura() else clearFlyAura() end
        if C.FlyAnim then ensureFlyAnim() else stopFlyAnim() end
        applyFlyTilt(dt)
        if flyBV then
            local hum = getHum(); local c = cam()
            if hum and c then
                local md = hum.MoveDirection
                local mag = md.Magnitude
                local lookY = c.CFrame.LookVector.Y
                local vel = md * C.FlySpeed + Vector3.new(0, lookY * C.FlySpeed * mag, 0)
                flyBV.Velocity = flyBV.Velocity:Lerp(vel, math.clamp(dt*12, 0, 1))
            end
        end
    else
        stopFlyBV(); clearFlyAura(); stopFlyAnim()
        local hum = getHum()
        if hum then hum.AutoRotate = true end
    end
    local hum = getHum()
    if hum then
        if C.SpeedOn and C.SpeedHack ~= hum.WalkSpeed then hum.WalkSpeed = C.SpeedHack end
        if C.JumpPower ~= 50 and hum.UseJumpPower and hum.JumpPower ~= C.JumpPower then
            hum.JumpPower = C.JumpPower
        end
    end
end))

-- ============================================================
-- UI HELPERS
-- ============================================================
local refreshers = {}
local function onRefresh(fn) table.insert(refreshers, fn) end
local function refreshAll() for _, fn in ipairs(refreshers) do fn() end end

local function new(class, props, children)
    local inst = Instance.new(class)
    local parent = nil
    for k, v in pairs(props) do
        if k == "Parent" then parent = v else inst[k] = v end
    end
    if children then for _, c in ipairs(children) do c.Parent = inst end end
    if parent then inst.Parent = parent end
    return inst
end
local function corner(p, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,r); c.Parent = p; return c end
local function stroke(p, color, th, tr)
    local s = Instance.new("UIStroke")
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Color = color; s.Thickness = th; s.Transparency = tr
    s.Parent = p; return s
end
local function padding(p, t, r, b, l)
    local u = Instance.new("UIPadding")
    u.PaddingTop=UDim.new(0,t); u.PaddingRight=UDim.new(0,r)
    u.PaddingBottom=UDim.new(0,b); u.PaddingLeft=UDim.new(0,l)
    u.Parent = p; return u
end
local function makeLabel(parent, text, size, font, color, position, dimension)
    return new("TextLabel", {
        BackgroundTransparency = 1, Text = text, TextSize = size,
        Font = font, TextColor3 = color,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Position = position, Size = dimension, Parent = parent,
    })
end

-- ============================================================
-- ОКНО
-- ============================================================
local gui = new("ScreenGui", {
    Name = "SynterHub",
    ResetOnSpawn = false, IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 100, Parent = PG,
})

local window = new("Frame", {
    Name = "Window",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(540, 656),
    BorderSizePixel = 0, Parent = gui,
})
local winCorner = corner(window, WIN_R.rounded)
local winStroke = stroke(window, ACCENT, 1, 0.75)
local uiScale = new("UIScale", { Parent = window })

local function updateScale()
    local vs = vp()
    uiScale.Scale = math.clamp(math.min((vs.X - 40)/540, (vs.Y - 40)/656), 0.4, 1) * C.scale
end
updateScale()
addTrack(cam():GetPropertyChangedSignal("ViewportSize"):Connect(updateScale))

-- SIDEBAR
local sidebar = new("Frame", { BackgroundTransparency=1, Size=UDim2.new(0,84,1,0), Parent=window })
new("Frame", {
    BackgroundColor3=WHITE, BackgroundTransparency=0.94,
    BorderSizePixel=0, Position=UDim2.fromOffset(84,0),
    Size=UDim2.new(0,1,1,0), Parent=window,
})
local logo = new("Frame", {
    BorderSizePixel=0, Position=UDim2.fromOffset(22,18),
    Size=UDim2.fromOffset(40,40), Parent=sidebar,
})
corner(logo, 12)
new("TextLabel", {
    BackgroundTransparency=1, Size=UDim2.fromScale(1,1),
    Text="S", Font=Enum.Font.GothamBold, TextSize=20,
    TextColor3=ON_TEXT, Parent=logo,
})
local tabList = new("Frame", {
    BackgroundTransparency=1, Position=UDim2.fromOffset(10,72),
    Size=UDim2.new(0,64,1,-110), Parent=sidebar,
})
new("UIListLayout", { Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder, Parent=tabList })
new("TextLabel", {
    BackgroundTransparency=1, AnchorPoint=Vector2.new(0.5,1),
    Position=UDim2.new(0.5,0,1,-14), Size=UDim2.fromOffset(60,16),
    Text="v1.0", Font=Enum.Font.RobotoMono, TextSize=10.5,
    TextColor3=Color3.fromRGB(107,112,137), Parent=sidebar,
})

-- MAIN
local main = new("Frame", {
    BackgroundTransparency=1, Position=UDim2.fromOffset(85,0),
    Size=UDim2.new(1,-85,1,0), Parent=window,
})
local header = new("Frame", { BackgroundTransparency=1, Size=UDim2.new(1,0,0,84), Parent=main })
local titleLabel = makeLabel(header, "", 22, Enum.Font.GothamBold,
    Color3.fromRGB(244,245,251), UDim2.fromOffset(24,20), UDim2.new(1,-190,0,28))
local subLabel = makeLabel(header, "", 12.5, Enum.Font.Gotham, MUTED,
    UDim2.fromOffset(24,50), UDim2.new(1,-190,0,18))
local content = new("Frame", {
    BackgroundTransparency=1, Position=UDim2.fromOffset(0,84),
    Size=UDim2.new(1,0,1,-128), Parent=main,
})
local footer = new("Frame", {
    BackgroundTransparency=1, AnchorPoint=Vector2.new(0,1),
    Position=UDim2.new(0,0,1,0), Size=UDim2.new(1,0,0,44), Parent=main,
})
new("Frame", {
    BackgroundColor3=WHITE, BackgroundTransparency=0.94,
    BorderSizePixel=0, Size=UDim2.new(1,0,0,1), Parent=footer,
})
makeLabel(footer, "SYNTER · HUB", 11.5, Enum.Font.GothamBold, SOFT,
    UDim2.fromOffset(24,0), UDim2.new(0.5,0,1,0))

local closeBtn = new("TextButton", {
    AutoButtonColor=false, BorderSizePixel=0, Text="✕",
    Font=Enum.Font.GothamBold, TextSize=13, TextColor3=WHITE,
    AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,-14,0,20),
    Size=UDim2.fromOffset(28,28), BackgroundColor3=Color3.fromRGB(230,70,90),
    Parent=header,
})
corner(closeBtn, 8)
local minBtn = new("TextButton", {
    AutoButtonColor=false, BorderSizePixel=0, Text="–",
    Font=Enum.Font.GothamBold, TextSize=16, TextColor3=WHITE,
    AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,-48,0,20),
    Size=UDim2.fromOffset(28,28), BackgroundColor3=Color3.fromRGB(240,175,65),
    Parent=header,
})
corner(minBtn, 8)

-- ICONS
local function buildIcon(kind, parent)
    local box = new("Frame", {
        BackgroundTransparency=1, AnchorPoint=Vector2.new(0.5,0),
        Position=UDim2.new(0.5,0,0,9), Size=UDim2.fromOffset(22,22),
        Parent=parent,
    })
    local fills, strs = {}, {}
    local function rect(x,y,w,h,r,rot)
        local f = new("Frame", {
            BorderSizePixel=0, Position=UDim2.fromOffset(x,y),
            Size=UDim2.fromOffset(w,h), Rotation=rot or 0, Parent=box,
        })
        if r then corner(f, r) end
        table.insert(fills, f)
    end
    local function ring(x,y,w,h,r,th)
        local f = new("Frame", {
            BackgroundTransparency=1, BorderSizePixel=0,
            Position=UDim2.fromOffset(x,y), Size=UDim2.fromOffset(w,h),
            Parent=box,
        })
        corner(f, r)
        table.insert(strs, stroke(f, WHITE, th, 0))
    end
    if kind == "aim" then
        ring(3,3,16,16,8,1.6)
        rect(10,0,2,5); rect(10,17,2,5); rect(0,10,5,2); rect(17,10,5,2)
    elseif kind == "esp" then
        ring(0,5,22,12,6,1.6); rect(8,8,6,6,3)
    elseif kind == "move" then
        ring(7,7,8,8,4,1.6)
        for i=0,7 do
            local a = math.rad(i*45)
            local cx = 11 + math.sin(a)*8.5
            local cy = 11 - math.cos(a)*8.5
            rect(cx-1, cy-2, 2, 4, nil, i*45)
        end
    elseif kind == "theme" then
        rect(4,8,14,14,7); rect(6.5,1,9,9,1.5,45)
    end
    return function(color)
        for _, f in ipairs(fills) do f.BackgroundColor3 = color end
        for _, s in ipairs(strs) do s.Color = color end
    end
end

-- TABS
local TABS = {
    { id="aim",   label="Аим",    sub="Наведение и захват цели",  icon="aim" },
    { id="esp",   label="ESP",    sub="Подсветка игроков",       icon="esp" },
    { id="move",  label="Движ.",  sub="Перемещение и утилиты",   icon="move" },
    { id="cfg",   label="Настр.", sub="Тема и оформление",       icon="theme" },
}

local pages = {}
for _, tab in ipairs(TABS) do
    local page = new("ScrollingFrame", {
        Name = tab.id, AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        ScrollBarImageColor3 = WHITE, ScrollBarImageTransparency = 0.85,
        ScrollBarThickness = 4, Size = UDim2.fromScale(1,1),
        Visible = false, Parent = content,
    })
    padding(page, 2, 20, 18, 24)
    new("UIListLayout", { Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder, Parent=page })
    pages[tab.id] = page
end

local currentTab = "aim"

local function rowBase(page, height, order, isButton)
    local row = new(isButton and "TextButton" or "Frame", {
        BackgroundColor3 = WHITE,
        BackgroundTransparency = 0.96,
        BorderSizePixel = 0,
        LayoutOrder = order,
        Size = UDim2.new(1, 0, 0, height),
        Parent = page,
    })
    if isButton then row.Text = ""; row.AutoButtonColor = false end
    local c = corner(row, ROW_R.rounded)
    stroke(row, WHITE, 1, 0.93)
    onRefresh(function() c.CornerRadius = UDim.new(0, ROW_R[C.cornersStyle] or ROW_R.rounded) end)
    return row
end

local function buildToggle(page, def, order)
    local row = rowBase(page, 50, order, true)
    makeLabel(row, def.label, 14, Enum.Font.GothamBold, TEXT, UDim2.fromOffset(16,8), UDim2.new(1,-90,0,18))
    makeLabel(row, def.desc or "", 11.5, Enum.Font.Gotham, MUTED, UDim2.fromOffset(16,27), UDim2.new(1,-90,0,16))
    local tf = new("Frame", {
        AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,-16,0.5,0),
        Size=UDim2.fromOffset(42,24), BorderSizePixel=0, Parent=row,
    })
    corner(tf, 12)
    local knob = new("Frame", {
        BackgroundColor3=WHITE, BorderSizePixel=0,
        Position=UDim2.fromOffset(3,3), Size=UDim2.fromOffset(18,18), Parent=tf,
    })
    corner(knob, 9)
    onRefresh(function()
        local on = C[def.key]
        tf.BackgroundColor3 = on and ACCENT or OFF
        knob.Position = UDim2.fromOffset(on and 21 or 3, 3)
    end)
    row.MouseButton1Click:Connect(function()
        C[def.key] = not C[def.key]
        if def.onChanged then pcall(def.onChanged, C[def.key]) end
        refreshAll()
    end)
end

local function buildSlider(page, def, order)
    local row = rowBase(page, 62, order, false)
    makeLabel(row, def.label, 14, Enum.Font.GothamBold, TEXT, UDim2.fromOffset(16,9), UDim2.new(0.6,0,0,18))
    local val = makeLabel(row, "", 12, Enum.Font.RobotoMono, ACCENT,
        UDim2.new(1,-16,0,9), UDim2.fromOffset(120,18))
    val.AnchorPoint = Vector2.new(1,0)
    val.TextXAlignment = Enum.TextXAlignment.Right
    local bar = new("Frame", {
        BackgroundColor3=OFF, BorderSizePixel=0,
        Position=UDim2.new(0,16,0,42), Size=UDim2.new(1,-32,0,6), Parent=row,
    })
    corner(bar,3)
    local fill = new("Frame", { BorderSizePixel=0, Size=UDim2.fromScale(0,1), Parent=bar })
    corner(fill,3)
    local knob = new("Frame", {
        AnchorPoint=Vector2.new(0.5,0.5), BackgroundColor3=WHITE, BorderSizePixel=0,
        Position=UDim2.new(0,0,0.5,0), Size=UDim2.fromOffset(14,14), Parent=bar,
    })
    corner(knob,7)
    local hit = new("TextButton", {
        Text="", BackgroundTransparency=1,
        Position=UDim2.new(0,10,0,34), Size=UDim2.new(1,-20,0,22), Parent=row,
    })
    local function setFromX(x)
        local a = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X,1), 0, 1)
        local raw = def.min + a * (def.max - def.min)
        local v = math.clamp(math.floor(raw/def.step + 0.5)*def.step, def.min, def.max)
        if C[def.key] ~= v then
            C[def.key] = v
            if def.onChanged then pcall(def.onChanged, v) end
            refreshAll()
        end
    end
    local dragging = false
    hit.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; page.ScrollingEnabled = false; setFromX(i.Position.X)
        end
    end)
    addTrack(UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then
            setFromX(i.Position.X)
        end
    end))
    addTrack(UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            if dragging then dragging = false; page.ScrollingEnabled = true end
        end
    end))
    onRefresh(function()
        local v = C[def.key]
        local a = (v - def.min) / (def.max - def.min)
        val.Text = tostring(v) .. (def.unit or "")
        val.TextColor3 = ACCENT
        fill.BackgroundColor3 = ACCENT
        fill.Size = UDim2.fromScale(a, 1)
        knob.Position = UDim2.new(a, 0, 0.5, 0)
    end)
end

local function buildSeg(page, def, order)
    local row = rowBase(page, 50, order, false)
    makeLabel(row, def.label, 14, Enum.Font.GothamBold, TEXT, UDim2.fromOffset(16,0), UDim2.new(0.4,0,1,0))
    local holder = new("Frame", {
        AnchorPoint=Vector2.new(1,0.5), AutomaticSize=Enum.AutomaticSize.X,
        BackgroundColor3=Color3.new(0,0,0), BackgroundTransparency=0.68,
        BorderSizePixel=0, Position=UDim2.new(1,-12,0.5,0),
        Size=UDim2.fromOffset(0,34), Parent=row,
    })
    corner(holder, 12)
    padding(holder, 3, 3, 3, 3)
    new("UIListLayout", {
        FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,4),
        SortOrder=Enum.SortOrder.LayoutOrder,
        VerticalAlignment=Enum.VerticalAlignment.Center, Parent=holder,
    })
    local entries = {}
    for i, opt in ipairs(def.opts) do
        local b = new("TextButton", {
            AutoButtonColor=false, BorderSizePixel=0, Font=Enum.Font.GothamBold,
            LayoutOrder=i, Size=UDim2.fromOffset(72,28), Text=opt.label,
            TextSize=12.5, Parent=holder,
        })
        local bc = corner(b, INNER_R.rounded)
        b.MouseButton1Click:Connect(function()
            C[def.key] = opt.value
            if def.onChanged then pcall(def.onChanged, opt.value) end
            refreshAll()
        end)
        table.insert(entries, { btn=b, c=bc, id=opt.value })
    end
    onRefresh(function()
        for _, e in ipairs(entries) do
            local sel = C[def.key] == e.id
            e.btn.BackgroundColor3 = ACCENT
            e.btn.BackgroundTransparency = sel and 0 or 1
            e.btn.TextColor3 = sel and ON_TEXT or SOFT
            e.c.CornerRadius = UDim.new(0, INNER_R[C.cornersStyle] or INNER_R.rounded)
        end
    end)
end

local function buildColor(page, def, order)
    local row = rowBase(page, 50, order, false)
    makeLabel(row, def.label, 14, Enum.Font.GothamBold, TEXT, UDim2.fromOffset(16,0), UDim2.new(0.4,0,1,0))
    local holder = new("Frame", {
        AnchorPoint=Vector2.new(1,0.5), AutomaticSize=Enum.AutomaticSize.X,
        BackgroundTransparency=1, Position=UDim2.new(1,-16,0.5,0),
        Size=UDim2.fromOffset(0,22), Parent=row,
    })
    new("UIListLayout", {
        FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,9),
        SortOrder=Enum.SortOrder.LayoutOrder, Parent=holder,
    })
    local swatches = {}
    for i, hex in ipairs(PRESETS) do
        local color = Color3.fromHex(hex)
        local b = new("TextButton", {
            AutoButtonColor=false, BackgroundColor3=color, BorderSizePixel=0,
            LayoutOrder=i, Size=UDim2.fromOffset(22,22), Text="", Parent=holder,
        })
        corner(b, 11)
        local ring = stroke(b, TEXT, 2, 1)
        b.MouseButton1Click:Connect(function()
            def.setter(color); refreshAll()
        end)
        table.insert(swatches, { ring=ring, hex=color:ToHex() })
    end
    onRefresh(function()
        local cur = def.getter():ToHex()
        for _, e in ipairs(swatches) do
            e.ring.Transparency = (cur == e.hex) and 0 or 1
        end
    end)
end

local function buildHex(page, def, order)
    local row = rowBase(page, 50, order, false)
    makeLabel(row, def.label, 14, Enum.Font.GothamBold, TEXT, UDim2.fromOffset(16,0), UDim2.new(0.4,0,1,0))
    local preview = new("Frame", {
        AnchorPoint=Vector2.new(1,0.5), BorderSizePixel=0,
        Position=UDim2.new(1,-16,0.5,0), Size=UDim2.fromOffset(28,28), Parent=row,
    })
    corner(preview, 8)
    local box = new("TextBox", {
        AnchorPoint=Vector2.new(1,0.5), BackgroundColor3=Color3.new(0,0,0),
        BackgroundTransparency=0.6, BorderSizePixel=0, ClearTextOnFocus=false,
        Font=Enum.Font.RobotoMono, PlaceholderText="#RRGGBB",
        Position=UDim2.new(1,-54,0.5,0), Size=UDim2.fromOffset(92,28),
        Text="", TextColor3=SOFT, TextSize=12, Parent=row,
    })
    corner(box, 8)
    box.FocusLost:Connect(function()
        local txt = box.Text:gsub("%s","")
        if txt:sub(1,1) ~= "#" then txt = "#" .. txt end
        local c = parseHex(txt)
        if c then def.setter(c) end
        refreshAll()
    end)
    onRefresh(function()
        box.Text = "#" .. def.getter():ToHex()
        preview.BackgroundColor3 = def.getter()
    end)
end

local function buildButton(page, def, order)
    local row = rowBase(page, 44, order, true)
    makeLabel(row, def.label, 14, Enum.Font.GothamBold, ACCENT, UDim2.fromOffset(16,0), UDim2.new(1,-32,1,0))
    row.MouseButton1Click:Connect(function() if def.onClick then pcall(def.onClick) end end)
end

local BUILDERS = {
    toggle=buildToggle, slider=buildSlider, seg=buildSeg,
    color=buildColor, hex=buildHex, button=buildButton,
}

-- ============================================================
-- ПРЕВЬЮ РЕАЛЬНОГО АВАТАРА
-- ============================================================
local previewRef = nil

local function buildAvatarPreview(parent)
    local char = getChar()
    local model = Instance.new("Model")
    model.Name = "SynterPreviewAvatar"
    if char then
        for _, obj in ipairs(char:GetChildren()) do
            local ok = false
            if obj:IsA("BasePart") then ok = true
            elseif obj:IsA("Decal") or obj:IsA("Texture") then ok = true
            elseif obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") then ok = true
            elseif obj:IsA("BodyColors") or obj:IsA("CharacterMesh") then ok = true
            elseif obj:IsA("Accessory") then ok = true
            elseif obj:IsA("Folder") then ok = true
            end
            if ok then local c = obj:Clone(); c.Parent = model end
        end
    end
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") then
            d.Anchored=true; d.CanCollide=false
            d.CanQuery=false; d.CanTouch=false; d.Massless=true
        elseif d:IsA("Script") or d:IsA("LocalScript") or d:IsA("Animator") then
            d:Destroy()
        end
    end
    if not model:FindFirstChildWhichIsA("BasePart") then
        local function mk(name, size, cf)
            local p = Instance.new("Part")
            p.Name=name; p.Size=size; p.CFrame=cf
            p.Color=Color3.fromRGB(200,200,215)
            p.Anchored=true; p.CanCollide=false; p.Parent=model
        end
        mk("Head", Vector3.new(0.7,0.7,0.7), CFrame.new(0,2.05,0))
        mk("UpperTorso", Vector3.new(1,0.9,0.55), CFrame.new(0,1.25,0))
        mk("LowerTorso", Vector3.new(1,0.6,0.55), CFrame.new(0,0.55,0))
        mk("LeftUpperArm", Vector3.new(0.45,0.75,0.45), CFrame.new(0.75,1.4,0))
        mk("LeftLowerArm", Vector3.new(0.4,0.7,0.4), CFrame.new(0.75,0.6,0))
        mk("RightUpperArm", Vector3.new(0.45,0.75,0.45), CFrame.new(-0.75,1.4,0))
        mk("RightLowerArm", Vector3.new(0.4,0.7,0.4), CFrame.new(-0.75,0.6,0))
        mk("LeftUpperLeg", Vector3.new(0.5,0.9,0.5), CFrame.new(0.3,0,0))
        mk("LeftLowerLeg", Vector3.new(0.45,0.85,0.45), CFrame.new(0.3,-0.9,0))
        mk("RightUpperLeg", Vector3.new(0.5,0.9,0.5), CFrame.new(-0.3,0,0))
        mk("RightLowerLeg", Vector3.new(0.45,0.85,0.45), CFrame.new(-0.3,-0.9,0))
    end
    local primary = model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("UpperTorso")
        or model:FindFirstChild("Torso")
        or model:FindFirstChildWhichIsA("BasePart")
    model.PrimaryPart = primary
    if primary then
        local anchor = primary.CFrame
        for _, d in ipairs(model:GetDescendants()) do
            if d:IsA("BasePart") then d.CFrame = anchor:ToObjectSpace(d.CFrame) end
        end
    end
    model.Parent = parent
    return model
end

local function applyPreviewMode(model, mode)
    local oldH = model:FindFirstChildOfClass("Highlight"); if oldH then oldH:Destroy() end
    local oldL = model:FindFirstChild("SynterPreviewLight"); if oldL then oldL:Destroy() end

    -- сброс к BodyColors (или дефолт), чтобы режим всегда начинал с чистого
    local bc = model:FindFirstChildOfClass("BodyColors")
    local defaults = {
        Head = Color3.fromRGB(234, 184, 146),
        UpperTorso = Color3.fromRGB(234, 184, 146),
        LowerTorso = Color3.fromRGB(234, 184, 146),
        Torso      = Color3.fromRGB(234, 184, 146),
        ["LeftUpperArm"]  = Color3.fromRGB(234, 184, 146),
        ["LeftLowerArm"]  = Color3.fromRGB(234, 184, 146),
        ["LeftHand"]      = Color3.fromRGB(234, 184, 146),
        ["RightUpperArm"] = Color3.fromRGB(234, 184, 146),
        ["RightLowerArm"] = Color3.fromRGB(234, 184, 146),
        ["RightHand"]     = Color3.fromRGB(234, 184, 146),
        ["Left Arm"]      = Color3.fromRGB(234, 184, 146),
        ["Right Arm"]     = Color3.fromRGB(234, 184, 146),
        ["LeftUpperLeg"]  = Color3.fromRGB(80, 160, 60),
        ["LeftLowerLeg"]  = Color3.fromRGB(80, 160, 60),
        ["LeftFoot"]      = Color3.fromRGB(80, 160, 60),
        ["RightUpperLeg"] = Color3.fromRGB(80, 160, 60),
        ["RightLowerLeg"] = Color3.fromRGB(80, 160, 60),
        ["RightFoot"]     = Color3.fromRGB(80, 160, 60),
        ["Left Leg"]      = Color3.fromRGB(80, 160, 60),
        ["Right Leg"]     = Color3.fromRGB(80, 160, 60),
    }
    local map = {}
    if bc then
        map = {
            Head = bc.HeadColor3,
            UpperTorso = bc.TorsoColor3, LowerTorso = bc.TorsoColor3, Torso = bc.TorsoColor3,
            ["LeftUpperArm"] = bc.LeftArmColor3, ["LeftLowerArm"] = bc.LeftArmColor3, ["LeftHand"] = bc.LeftArmColor3, ["Left Arm"] = bc.LeftArmColor3,
            ["RightUpperArm"] = bc.RightArmColor3, ["RightLowerArm"] = bc.RightArmColor3, ["RightHand"] = bc.RightArmColor3, ["Right Arm"] = bc.RightArmColor3,
            ["LeftUpperLeg"] = bc.LeftLegColor3, ["LeftLowerLeg"] = bc.LeftLegColor3, ["LeftFoot"] = bc.LeftLegColor3, ["Left Leg"] = bc.LeftLegColor3,
            ["RightUpperLeg"] = bc.RightLegColor3, ["RightLowerLeg"] = bc.RightLegColor3, ["RightFoot"] = bc.RightLegColor3, ["Right Leg"] = bc.RightLegColor3,
        }
    end
    for name, col in pairs(defaults) do
        local p = model:FindFirstChild(name)
        if p and p:IsA("BasePart") then
            p.Color = map[name] or col
            p.Material = Enum.Material.SmoothPlastic
        end
    end
    -- остальные BasePart (аксессуары, меши) не трогаем в базу
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") and not defaults[p.Name] then
            p.Material = Enum.Material.SmoothPlastic
        end
    end

    local cfg = MODES[mode]; if not cfg then return end

    if cfg.body then
        for _, p in ipairs(model:GetDescendants()) do
            if p:IsA("BasePart") then
                pcall(function()
                    p.Color = cfg.body
                    p.Material = cfg.mat or Enum.Material.SmoothPlastic
                end)
            end
        end
    end

    local h = Instance.new("Highlight")
    h.Adornee = model
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.FillColor = cfg.fill or Color3.fromRGB(255,50,50)
    h.OutlineColor = cfg.outline or Color3.fromRGB(255,255,255)
    h.FillTransparency = cfg.fillT
    h.OutlineTransparency = cfg.outlineT
    h.Parent = model

    local l = Instance.new("PointLight")
    l.Name = "SynterPreviewLight"
    l.Color = cfg.light or Color3.fromRGB(255,60,60)
    l.Brightness = cfg.bright
    l.Range = cfg.range
    l.Shadows = false
    l.Parent = model.PrimaryPart or model
end

-- ============================================================
-- НАПОЛНЕНИЕ ВКЛАДОК
-- ============================================================
local function T(k, label, desc, onChanged)
    return { kind="toggle", key=k, label=label, desc=desc, onChanged=onChanged }
end
local function S(k, label, min, max, step, unit, onChanged)
    return { kind="slider", key=k, label=label, min=min, max=max, step=step, unit=unit, onChanged=onChanged }
end
local function G(k, label, opts, onChanged)
    return { kind="seg", key=k, label=label, opts=opts, onChanged=onChanged }
end
local function COLOR(label, getter, setter)
    return { kind="color", label=label, getter=getter, setter=setter }
end
local function HEX(label, getter, setter)
    return { kind="hex", label=label, getter=getter, setter=setter }
end
local function BTN(label, onClick)
    return { kind="button", label=label, onClick=onClick }
end

-- AIM
local aimDefs = {
    T("Enabled", "Аимбот", "Захват ближайшей цели"),
    T("AlwaysAim", "Всегда аимить", "Без удержания кнопки"),
    T("TeamCheck", "Игнор союзников", "Не наводиться на команду"),
    T("IgnoreFriends", "Игнор друзей", "Не наводиться на друзей"),
    S("Smoothness", "Плавность", 0.01, 0.95, 0.01, ""),
    S("FOV", "Радиус FOV", 20, 500, 5, "px", function(v) updateFovCircle(0) end),
    S("MaxDist", "Макс. дистанция", 50, 2000, 50, " st"),
    T("DrawFOV", "Показывать FOV", "Круг радиуса аима", function(v) updateFovCircle(0) end),
}
for i, def in ipairs(aimDefs) do BUILDERS[def.kind](pages.aim, def, i) end

-- ESP
local espDefs = {
    T("ESP", "Включить ESP", "Видеть игроков через стены"),
    T("ESPHealth", "Health bar", "Полоса HP справа"),
    T("ESPBox", "Box", "Рамка вокруг тела"),
    T("ESPSkeleton", "Skeleton", "Кости-линии"),
    T("ESPTracers", "Трассеры", "Линии от низа экрана"),
    T("ESPName", "Ник + дистанция", "Имя и метры над головой"),
}
for i, def in ipairs(espDefs) do BUILDERS[def.kind](pages.esp, def, i) end

-- setMode — с пересборкой превью
local function setMode(v)
    C.ESPMode = v
    local all = {}
    for plr in pairs(espTracked) do table.insert(all, plr) end
    for _, plr in ipairs(all) do clearESP(plr) end
    if previewRef and previewRef.model then
        pcall(applyPreviewMode, previewRef.model, v)
    end
    refreshAll()
end

local ESP_MODES_1 = {
    { value="void",    label="Void" },
    { value="blood",   label="Blood" },
    { value="glow",    label="Glow" },
}
local ESP_MODES_2 = {
    { value="fire",    label="Fire" },
    { value="frost",   label="Frost" },
    { value="toxic",   label="Toxic" },
}
local ESP_MODES_3 = {
    { value="plasma",  label="Plasma" },
    { value="galaxy",  label="Galaxy" },
    { value="gold",    label="Gold" },
}
local ESP_MODES_4 = {
    { value="emerald", label="Emerald" },
    { value="crimson", label="Crimson" },
    { value="lava",    label="Lava" },
}
local ESP_MODES_5 = {
    { value="shadow",  label="Shadow" },
    { value="ghost",   label="Ghost" },
    { value="rainbow", label="Rainbow" },
}
local baseOrder = #espDefs
BUILDERS.seg(pages.esp, G("ESPMode", "Режим · 1", ESP_MODES_1, setMode), baseOrder+1)
BUILDERS.seg(pages.esp, G("ESPMode", "Режим · 2", ESP_MODES_2, setMode), baseOrder+2)
BUILDERS.seg(pages.esp, G("ESPMode", "Режим · 3", ESP_MODES_3, setMode), baseOrder+3)
BUILDERS.seg(pages.esp, G("ESPMode", "Режим · 4", ESP_MODES_4, setMode), baseOrder+4)
BUILDERS.seg(pages.esp, G("ESPMode", "Режим · 5", ESP_MODES_5, setMode), baseOrder+5)

BUILDERS.color(pages.esp, COLOR("Цвет трассеров / box",
    function() return ESP_COLOR end,
    function(c) ESP_COLOR = c end), baseOrder+6)

-- ПРЕВЬЮ
do
    local vf = new("ViewportFrame", {
        Size = UDim2.new(1, 0, 0, 260),
        BackgroundColor3 = Color3.fromRGB(28, 30, 42),
        BorderSizePixel = 0,
        LayoutOrder = baseOrder+7,
        Ambient = Color3.fromRGB(180,180,200),
        LightColor = Color3.fromRGB(255,255,255),
        LightDirection = Vector3.new(-0.4,-1,-0.6),
        Parent = pages.esp,
    })
    corner(vf, 10)
    stroke(vf, WHITE, 1, 0.9)

    local model = buildAvatarPreview(vf)
    applyPreviewMode(model, C.ESPMode)

    local minY, maxY = math.huge, -math.huge
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") then
            local p = d.Position
            minY = math.min(minY, p.Y - d.Size.Y/2)
            maxY = math.max(maxY, p.Y + d.Size.Y/2)
        end
    end
    local height = maxY - minY
    local centerY = (minY + maxY) / 2
    if not height or height ~= height or height == math.huge or height <= 0 then
        height, centerY = 5, 0
    end
    local dist = height * 1.55

    local previewCam = Instance.new("Camera")
    previewCam.Parent = vf
    vf.CurrentCamera = previewCam
    previewCam.CFrame = CFrame.new(Vector3.new(0, centerY, -dist), Vector3.new(0, centerY, 0))
    previewRef = { model = model, camera = previewCam, vf = vf }
end

-- MOVEMENT
local moveDefs = {
    T("Noclip", "Noclip", "Проходить сквозь стены"),
    T("Fly", "Fly", "Джойстик ведёт, камера — высота"),
    T("FlyAura", "Аура полёта", "Жёлто-синий след, искры"),
    T("FlyAnim", "Анимация полёта", "Поза 616006541"),
    T("FlyTilt", "Наклон по направлению", "Корпус наклоняется"),
    S("FlySpeed", "Скорость полёта", 10, 300, 5, ""),
    T("SpeedOn", "Speedhack", "Изменение WalkSpeed"),
    S("SpeedHack", "WalkSpeed", 8, 300, 1, ""),
    T("AutoJump", "Авто-прыжок", "Прыгает сам"),
    T("AntiAFK", "Anti-AFK", "Не кикнет за простой"),
    S("JumpPower", "Сила прыжка", 30, 200, 5, ""),
}
for i, def in ipairs(moveDefs) do BUILDERS[def.kind](pages.move, def, i) end

-- SETTINGS
local cfgDefs = {
    G("theme", "Фон меню", {
        { value="dark",     label="Dark" },
        { value="midnight", label="Midnight" },
        { value="slate",    label="Slate" },
    }),
    G("cornersStyle", "Углы", {
        { value="sharp",   label="Sharp" },
        { value="rounded", label="Rounded" },
        { value="pill",    label="Pill" },
    }),
    COLOR("Цвет меню",
        function() return ACCENT end,
        function(c) ACCENT = c; winStroke.Color = c end),
    HEX("Свой hex", function() return ACCENT end,
        function(c) ACCENT = c; winStroke.Color = c end),
    COLOR("Цвет FOV",
        function() return FOV_COLOR end,
        function(c) FOV_COLOR = c end),
    S("scale", "Размер интерфейса", 0.5, 1.4, 0.05, "x",
        function(v) C.scale = v; updateScale() end),
    T("Snow", "Снег на экране", "Работает и при свёрнутом меню"),
    BTN("Сбросить настройки", function()
        C.Fly=false; C.Noclip=false; C.FlyAura=false
        C.SpeedOn=false; C.AutoJump=false
        C.Enabled=false; C.ESP=false
        C.Snow=true
        C.FlySpeed=60; C.SpeedHack=16; C.JumpPower=50
        ACCENT = Color3.fromHex("#a3e635")
        ESP_COLOR = Color3.fromHex("#22d3ee")
        FOV_COLOR = Color3.fromHex("#f8fafc")
        if previewRef and previewRef.model then
            pcall(applyPreviewMode, previewRef.model, C.ESPMode)
        end
        refreshAll()
        local hum = getHum()
        if hum then hum.WalkSpeed = 16; hum.AutoRotate = true end
    end),
}
for i, def in ipairs(cfgDefs) do BUILDERS[def.kind](pages.cfg, def, i) end

-- TAB BUTTONS
for i, tab in ipairs(TABS) do
    local btn = new("TextButton", {
        AutoButtonColor=false, BorderSizePixel=0, LayoutOrder=i,
        Size=UDim2.fromOffset(64,56), Text="", Parent=tabList,
    })
    local bc = corner(btn, ROW_R.rounded)
    local setIconColor = buildIcon(tab.icon, btn)
    local lab = new("TextLabel", {
        BackgroundTransparency=1, Font=Enum.Font.GothamBold,
        Position=UDim2.fromOffset(0,35), Size=UDim2.new(1,0,0,14),
        Text=tab.label, TextSize=10.5, Parent=btn,
    })
    btn.MouseButton1Click:Connect(function()
        currentTab = tab.id
        refreshAll()
    end)
    onRefresh(function()
        local active = currentTab == tab.id
        bc.CornerRadius = UDim.new(0, ROW_R[C.cornersStyle] or ROW_R.rounded)
        btn.BackgroundColor3 = ACCENT
        btn.BackgroundTransparency = active and 0.84 or 1
        local fg = active and ACCENT or TAB_IDLE
        lab.TextColor3 = fg
        setIconColor(fg)
    end)
end

-- HEADER / WINDOW / PAGES REFRESH
onRefresh(function()
    local bg = BG[C.theme] or BG.dark
    window.BackgroundColor3 = bg
    window.BackgroundTransparency = 0.06
    winCorner.CornerRadius = UDim.new(0, WIN_R[C.cornersStyle] or WIN_R.rounded)
    winStroke.Color = ACCENT
    logo.BackgroundColor3 = ACCENT

    local info
    for _, tab in ipairs(TABS) do
        if tab.id == currentTab then info = tab end
    end
    if info then
        titleLabel.Text = info.label
        subLabel.Text = info.sub
    end
    for id, page in pairs(pages) do
        page.Visible = (id == currentTab)
    end
end)

-- DRAG
do
    local dragging, dragStart, startPos = false, nil, nil
    header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = i.Position; startPos = window.Position
        end
    end)
    addTrack(UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                        startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end))
    addTrack(UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end))
end

-- CLOSE / MIN / HOTKEY
closeBtn.MouseButton1Click:Connect(function()
    if _G.SynterCleanup then _G.SynterCleanup() end
end)
minBtn.MouseButton1Click:Connect(function()
    window.Visible = false
end)
addTrack(UserInputService.InputBegan:Connect(function(i, processed)
    if processed then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        window.Visible = not window.Visible
    end
end))

-- MOBILE OPEN BUTTON
if isTouch then
    local openBtn = new("TextButton", {
        AutoButtonColor=false, BorderSizePixel=0,
        Font=Enum.Font.GothamBold, Position=UDim2.fromOffset(12,60),
        Size=UDim2.fromOffset(40,40), Text="S", TextColor3=ON_TEXT,
        TextSize=18, Parent=gui, Visible=false,
    })
    corner(openBtn, 12)
    onRefresh(function()
        openBtn.BackgroundColor3 = ACCENT
        openBtn.Visible = not window.Visible
    end)
    openBtn.MouseButton1Click:Connect(function()
        window.Visible = true
    end)
    addTrack(window:GetPropertyChangedSignal("Visible"):Connect(refreshAll))
end

-- RENDER LOOP
addTrack(RunService.RenderStepped:Connect(function(dt)
    if C.Snow then
        dt = math.min(dt, 0.1)
        local size = vp(); local W, H = size.X, size.Y
        snowTime = snowTime + dt
        for _, fl in ipairs(snowFlakes) do
            fl.y = fl.y + fl.speed * dt
            if fl.y > H + 5 then
                fl.y = -fl.size - math.random() * 30
                fl.x = math.random() * W
            end
            local px = fl.x + math.sin(snowTime * fl.freq + fl.phase) * fl.amp
            fl.gui.Position = UDim2.fromOffset(px, fl.y)
        end
    end
    pcall(updateFovCircle, dt)
    pcall(updateESP, dt)
end))

RunService:BindToRenderStep("SynterAimLoop", Enum.RenderPriority.Camera.Value + 1, function(dt)
    if not C.Enabled or not (C.AlwaysAim or C.AimHeld) then
        lockedTarget = nil; return
    end
    pcall(function()
        local c = cam(); if not c then return end
        local target = findTarget(); if not target then return end
        local cf = c.CFrame
        local desired = CFrame.lookAt(cf.Position, target.Position)
        local base = math.clamp(C.Smoothness, 0.01, 0.99)
        local alpha = math.clamp(1 - base ^ (dt*60), 0.04, 1)
        c.CFrame = cf:Lerp(desired, alpha)
    end)
end)

-- CLEANUP
_G.SynterCleanup = function()
    pcall(function() RunService:UnbindFromRenderStep("SynterAimLoop") end)
    stopFlyBV(); clearFlyAura(); stopFlyAnim()
    local hum = getHum()
    if hum then
        hum.AutoRotate = true
        hum.WalkSpeed = 16
        if hum.UseJumpPower then hum.JumpPower = 50 end
    end
    C.SpeedHack=16; C.SpeedOn=false; C.Enabled=false
    C.Fly=false; C.Noclip=false; C.AutoJump=false; C.AntiAFK=false
    for _, c in ipairs(track) do pcall(function() c:Disconnect() end) end
    local all = {}
    for plr in pairs(espTracked) do table.insert(all, plr) end
    for _, plr in ipairs(all) do clearESP(plr) end
    for plr in pairs(tracerCache) do clearTracer(plr) end
    bodySnapshots = {}
    pcall(function() fovGui:Destroy() end)
    pcall(function() gui:Destroy() end)
end

-- START
refreshFriends()
pcall(function() LP.FriendStatusChanged:Connect(refreshFriends) end)
refreshAll()
updateFovCircle(0)
addTrack(LP.CharacterAdded:Connect(function()
    task.wait(0.3); stopFlyAnim(); updateFovCircle(0)
end))
print("[Synter] loaded OK")
