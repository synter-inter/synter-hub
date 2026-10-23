-- [[FF: FLING+MM2 ESP+MUSIC+THEMES+AUTO]] by:@Promtikdeepseek
if getgenv().FFLoaded then return end
getgenv().FFLoaded=true
local P=game:GetService("Players")
local R=game:GetService("RunService")
local U=game:GetService("UserInputService")
local SS=game:GetService("SoundService")
local W=game:GetService("Workspace")
local T=game:GetService("TweenService")
local CP=game:GetService("ContentProvider")
local MS=game:GetService("MarketplaceService")
local LP=P.LocalPlayer

task.spawn(function()
  local s=Instance.new("Sound",SS) s.SoundId="rbxassetid://88180660912629";s:Play()
  task.wait(1.2)
  local b=Instance.new("Sound",SS) b.SoundId="rbxassetid://8867136699";b:Play()
end)

local TH={
 Green={bg=Color3.fromRGB(14,14,20),pn=Color3.fromRGB(26,26,34),ac=Color3.fromRGB(0,255,120),tx=Color3.fromRGB(240,240,240),sb=Color3.fromRGB(180,180,190),dc=""},
 Red={bg=Color3.fromRGB(20,12,14),pn=Color3.fromRGB(34,20,24),ac=Color3.fromRGB(255,70,90),tx=Color3.fromRGB(245,235,235),sb=Color3.fromRGB(190,160,165),dc=""},
 Blue={bg=Color3.fromRGB(10,14,22),pn=Color3.fromRGB(20,28,42),ac=Color3.fromRGB(70,150,255),tx=Color3.fromRGB(235,240,250),sb=Color3.fromRGB(160,180,210),dc=""},
 Astral={bg=Color3.fromRGB(14,10,26),pn=Color3.fromRGB(28,20,48),ac=Color3.fromRGB(180,110,255),tx=Color3.fromRGB(240,235,255),sb=Color3.fromRGB(185,165,220),dc="✨"},
 Crystal={bg=Color3.fromRGB(8,18,24),pn=Color3.fromRGB(16,32,42),ac=Color3.fromRGB(120,230,255),tx=Color3.fromRGB(230,250,255),sb=Color3.fromRGB(160,200,215),dc="💎"},
 Rainbow={bg=Color3.fromRGB(14,14,20),pn=Color3.fromRGB(26,26,34),ac=Color3.fromRGB(0,255,120),tx=Color3.fromRGB(240,240,240),sb=Color3.fromRGB(180,180,190),dc="🌈",rb=true},
 Halloween={bg=Color3.fromRGB(18,10,6),pn=Color3.fromRGB(36,20,10),ac=Color3.fromRGB(255,140,20),tx=Color3.fromRGB(255,235,210),sb=Color3.fromRGB(210,170,130),dc="🎃"},
 Frost={bg=Color3.fromRGB(10,16,24),pn=Color3.fromRGB(22,32,44),ac=Color3.fromRGB(170,230,255),tx=Color3.fromRGB(235,245,255),sb=Color3.fromRGB(170,200,220),dc="❄️"},
}
local CT="Green"
local function C() return TH[CT] end
local function Tw(o,p,t,s,d) local i=TweenInfo.new(t or .3,s or Enum.EasingStyle.Quart,d or Enum.EasingDirection.Out) local w=T:Create(o,i,p) w:Play() return w end
local function GP() local ok,h=pcall(function() return gethui and gethui() end) if ok and h then return h end return game:GetService("CoreGui") end
local G=GP()
for _,v in pairs(G:GetChildren()) do if v:IsA("ScreenGui") and v.Name:find("FFUI") then v:Destroy() end end

local SG=Instance.new("ScreenGui")
SG.Name="FFUI";SG.ResetOnSpawn=false;SG.IgnoreGuiInset=true;SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;SG.Parent=G

local TB=Instance.new("TextButton")
TB.Size=UDim2.new(0,42,0,42);TB.Position=UDim2.new(0,10,0,90)
TB.BackgroundColor3=C().pn;TB.BackgroundTransparency=.15;TB.Text="💨";TB.TextColor3=C().ac;TB.TextSize=20
TB.Font=Enum.Font.GothamBold;TB.BorderSizePixel=0;TB.AutoButtonColor=false;TB.Parent=SG
Instance.new("UICorner",TB).CornerRadius=UDim.new(0,12)
local TBS=Instance.new("UIStroke",TB);TBS.Color=C().ac;TBS.Thickness=1.5

local MF=Instance.new("Frame")
MF.Size=UDim2.new(0,270,0,370);MF.Position=UDim2.new(.5,-135,.5,-185)
MF.BackgroundColor3=C().bg;MF.BackgroundTransparency=.15;MF.BorderSizePixel=0;MF.Active=true;MF.Visible=false;MF.Parent=SG
Instance.new("UICorner",MF).CornerRadius=UDim.new(0,10)
local MFS=Instance.new("UIStroke",MF);MFS.Color=C().ac;MFS.Thickness=1.2;MFS.Transparency=.4
local SC=Instance.new("UIScale",MF);SC.Scale=1

local TBar=Instance.new("Frame")
TBar.Size=UDim2.new(1,0,0,32);TBar.BackgroundColor3=C().pn;TBar.BackgroundTransparency=.2;TBar.BorderSizePixel=0;TBar.Active=true;TBar.Parent=MF
Instance.new("UICorner",TBar).CornerRadius=UDim.new(0,10)
local Ttl=Instance.new("TextLabel")
Ttl.Size=UDim2.new(1,-60,1,0);Ttl.Position=UDim2.new(0,10,0,0);Ttl.BackgroundTransparency=1
Ttl.Text="💨 FLING / MM2 / MUSIC";Ttl.TextColor3=C().ac;Ttl.Font=Enum.Font.GothamBold
Ttl.TextSize=11;Ttl.TextXAlignment=Enum.TextXAlignment.Left;Ttl.Parent=TBar
local CB=Instance.new("TextButton")
CB.Size=UDim2.new(0,20,0,20);CB.Position=UDim2.new(1,-26,0,6)
CB.BackgroundColor3=Color3.fromRGB(255,70,70);CB.Text="✕";CB.TextColor3=Color3.new(1,1,1)
CB.Font=Enum.Font.GothamBold;CB.TextSize=10;CB.BorderSizePixel=0;CB.AutoButtonColor=false;CB.Parent=TBar
Instance.new("UICorner",CB).CornerRadius=UDim.new(0,6)

local TabB=Instance.new("Frame")
TabB.Size=UDim2.new(1,-12,0,24);TabB.Position=UDim2.new(0,6,0,38);TabB.BackgroundTransparency=1;TabB.Parent=MF
local TabL=Instance.new("UIListLayout",TabB)
TabL.FillDirection=Enum.FillDirection.Horizontal;TabL.Padding=UDim.new(0,3);TabL.SortOrder=Enum.SortOrder.LayoutOrder

local Cnt=Instance.new("Frame")
Cnt.Size=UDim2.new(1,-12,1,-72);Cnt.Position=UDim2.new(0,6,0,68);Cnt.BackgroundTransparency=1;Cnt.Parent=MF

local isOpen=false
local function OpenW() isOpen=true;MF.Visible=true;SC.Scale=.7;Tw(SC,{Scale=1},.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out) end
local function CloseW() isOpen=false;local t=Tw(SC,{Scale=.7},.2,Enum.EasingStyle.Quart,Enum.EasingDirection.In);t.Completed:Connect(function() MF.Visible=false end) end
TB.MouseButton1Click:Connect(function() if isOpen then CloseW() else OpenW() end end)
CB.MouseButton1Click:Connect(CloseW)

local dg,ds,sp
TBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=true;ds=i.Position;sp=MF.Position end end)
TBar.InputChanged:Connect(function(i) if dg and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local d=i.Position-ds;MF.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end end)
U.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=false end end)

local function LA(uid,il,n) n=n or 3;local u=("rbxthumb://type=AvatarHeadShot&id=%d&w=100&h=100"):format(uid) for k=1,n do local ok=pcall(function() il.Image=u;CP:PreloadAsync({il}) end) if ok and il.Image~="" then return true end task.wait(.4*k) end il.Image="rbxassetid://0" return false end
local function MkAv(uid,pr,sz) local f=Instance.new("Frame") f.Size=sz or UDim2.new(0,26,0,26);f.BackgroundColor3=Color3.fromRGB(30,30,40);f.BorderSizePixel=0;f.Parent=pr Instance.new("UICorner",f).CornerRadius=UDim.new(1,0) local im=Instance.new("ImageLabel") im.Size=UDim2.new(1,-4,1,-4);im.Position=UDim2.new(0,2,0,2);im.BackgroundTransparency=1;im.ScaleType=Enum.ScaleType.Crop;im.Parent=f Instance.new("UICorner",im).CornerRadius=UDim.new(1,0) task.spawn(function() LA(uid,im,3) end) return f,im end

local St={FT=nil,MM2=false,ESP=false}
local CurGame=game.PlaceId
local IsMM2=(CurGame==142823291)
local IsDoors=(CurGame==6516141723)
local Is99=(CurGame==79546208627805)

-- ========== FLING ==========
local FF=Instance.new("Frame")
FF.Size=UDim2.new(1,0,1,0);FF.BackgroundTransparency=1;FF.Parent=Cnt
local PL=Instance.new("ScrollingFrame")
PL.Size=UDim2.new(1,0,0,140);PL.BackgroundColor3=C().bg;PL.BackgroundTransparency=.25;PL.BorderSizePixel=0
PL.CanvasSize=UDim2.new(0,0,0,0);PL.AutomaticCanvasSize=Enum.AutomaticSize.Y
PL.ScrollBarThickness=2;PL.ScrollBarImageColor3=C().ac;PL.Parent=FF
Instance.new("UICorner",PL).CornerRadius=UDim.new(0,6)
local PLL=Instance.new("UIListLayout",PL);PLL.Padding=UDim.new(0,2);PLL.SortOrder=Enum.SortOrder.LayoutOrder

local function RFL()
  for _,c in ipairs(PL:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
  for _,p in ipairs(P:GetPlayers()) do if p~=LP then
    local r=Instance.new("Frame") r.Size=UDim2.new(1,-4,0,30);r.BackgroundColor3=C().pn;r.BackgroundTransparency=.2;r.BorderSizePixel=0;r.Parent=PL Instance.new("UICorner",r).CornerRadius=UDim.new(0,6)
    local av=MkAv(p.UserId,r,UDim2.new(0,24,0,24)) av.Position=UDim2.new(0,3,.5,-12)
    local nl=Instance.new("TextLabel") nl.Size=UDim2.new(1,-36,1,0);nl.Position=UDim2.new(0,32,0,0);nl.BackgroundTransparency=1;nl.Text=p.Name;nl.TextColor3=C().tx;nl.Font=Enum.Font.Gotham;nl.TextSize=10;nl.TextXAlignment=Enum.TextXAlignment.Left;nl.Parent=r
    local h=Instance.new("TextButton") h.Size=UDim2.new(1,0,1,0);h.BackgroundTransparency=1;h.Text="";h.Parent=r
    h.MouseButton1Click:Connect(function() St.FT=p for _,o in ipairs(PL:GetChildren()) do if o:IsA("Frame") then Tw(o,{BackgroundColor3=C().pn},.2) end end Tw(r,{BackgroundColor3=C().ac},.25) end)
  end end
end
P.PlayerAdded:Connect(function() task.wait(1) RFL() end)
P.PlayerRemoving:Connect(function() task.wait(1) RFL() end)
RFL()

local SB=Instance.new("TextButton")
SB.Size=UDim2.new(1,0,0,32);SB.Position=UDim2.new(0,0,0,146)
SB.BackgroundColor3=C().ac;SB.BackgroundTransparency=.1;SB.Text="START FLING";SB.TextColor3=Color3.new(1,1,1)
SB.Font=Enum.Font.GothamBold;SB.TextSize=11;SB.BorderSizePixel=0;SB.AutoButtonColor=false;SB.Parent=FF
Instance.new("UICorner",SB).CornerRadius=UDim.new(0,6)

-- ========== MM2 ==========
local MFr=Instance.new("Frame")
MFr.Size=UDim2.new(1,0,1,0);MFr.BackgroundTransparency=1;MFr.Visible=false;MFr.Parent=Cnt
local ML=Instance.new("ScrollingFrame")
ML.Size=UDim2.new(1,0,1,-58);ML.BackgroundColor3=C().bg;ML.BackgroundTransparency=.25;ML.BorderSizePixel=0
ML.CanvasSize=UDim2.new(0,0,0,0);ML.AutomaticCanvasSize=Enum.AutomaticSize.Y
ML.ScrollBarThickness=2;ML.ScrollBarImageColor3=C().ac;ML.Parent=MFr
Instance.new("UICorner",ML).CornerRadius=UDim.new(0,6)
local MML=Instance.new("UIListLayout",ML);MML.Padding=UDim.new(0,2);MML.SortOrder=Enum.SortOrder.LayoutOrder
local RMB=Instance.new("TextButton") RMB.Size=UDim2.new(1,0,0,26);RMB.Position=UDim2.new(0,0,1,-52);RMB.BackgroundColor3=Color3.fromRGB(30,60,100);RMB.Text="ОБНОВИТЬ";RMB.TextColor3=Color3.new(1,1,1);RMB.Font=Enum.Font.GothamBold;RMB.TextSize=10;RMB.BorderSizePixel=0;RMB.AutoButtonColor=false;RMB.Parent=MFr Instance.new("UICorner",RMB).CornerRadius=UDim.new(0,6)
local EB=Instance.new("TextButton") EB.Size=UDim2.new(1,0,0,26);EB.Position=UDim2.new(0,0,1,-26);EB.BackgroundColor3=Color3.fromRGB(90,40,40);EB.Text="ESP: ВЫКЛ";EB.TextColor3=Color3.new(1,1,1);EB.Font=Enum.Font.GothamBold;EB.TextSize=10;EB.BorderSizePixel=0;EB.AutoButtonColor=false;EB.Parent=MFr Instance.new("UICorner",EB).CornerRadius=UDim.new(0,6)

local RC={M=Color3.fromRGB(255,60,60),S=Color3.fromRGB(60,140,255),I=Color3.fromRGB(60,220,100),U=Color3.fromRGB(150,150,160)}
local RN={M="МАРДЕР",S="ШЕРИФ",I="ИННОСЕНТ",U="НЕ РАСКРЫТ"}
local KR={}

local function CheckRole(plr)
  local ch=plr.Character
  if ch then
    for _,obj in ipairs(ch:GetChildren()) do
      local n=obj.Name:lower()
      if n=="knife" or n=="knife tool" then return "M" end
      if n=="revolver" or n=="gun" or n=="pistol" then return "S" end
    end
    local ht=ch:FindFirstChildOfClass("Tool")
    if ht then local n=ht.Name:lower() if n:find("knife") then return "M" end if n:find("revolver") or n:find("gun") then return "S" end end
  end
  local bp=plr:FindFirstChildOfClass("Backpack")
  if bp then for _,t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then local n=t.Name:lower() if n:find("knife") then return "M" end if n:find("revolver") or n:find("gun") then return "S" end end end end
  local pg=plr:FindFirstChildOfClass("PlayerGui")
  if pg then
    if pg:FindFirstChild("KnifeGui") or pg:FindFirstChild("Knife") then return "M" end
    if pg:FindFirstChild("RevolverGui") or pg:FindFirstChild("Revolver") then return "S" end
  end
  return nil
end

local function GR(p)
  local r=CheckRole(p)
  if r then KR[p.UserId]=r;return r end
  return KR[p.UserId] or "U"
end

local EH={}
local function UESP()
  if not St.ESP then for _,h in pairs(EH) do h:Destroy() end;EH={};return end
  for _,p in ipairs(P:GetPlayers()) do if p~=LP then
    local ro=GR(p);local co=RC[ro];local ch=p.Character
    local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
    if ro~="U" and ch and hrp then
      local h=EH[p.UserId]
      if not h or not h.Parent then
        h=Instance.new("Highlight");h.Name="MM2_ESP";h.Adornee=ch
        h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop;h.Parent=ch;EH[p.UserId]=h
      else h.Adornee=ch end
      h.FillColor=co;h.OutlineColor=co;h.FillTransparency=.55;h.OutlineTransparency=.1
    else
      if EH[p.UserId] then EH[p.UserId]:Destroy();EH[p.UserId]=nil end
    end
  end end
end
EB.MouseButton1Click:Connect(function() St.ESP=not St.ESP EB.Text=St.ESP and "ESP: ВКЛ" or "ESP: ВЫКЛ" EB.BackgroundColor3=St.ESP and Color3.fromRGB(40,120,60) or Color3.fromRGB(90,40,40) UESP() end)
local MR={}
local function UMR(p)
  local e=MR[p.UserId];if not e then return end
  local ro=GR(p);local co=RC[ro] or RC.U
  if e.rl.Text~=RN[ro] then e.rl.Text=RN[ro];e.rl.TextColor3=co;e.ring.Color=co;e.dot.BackgroundColor3=co Tw(e.ring,{Thickness=4},.15) task.delay(.2,function() Tw(e.ring,{Thickness=2},.25) end) end
end
local function BMR(p)
  local r=Instance.new("Frame") r.Size=UDim2.new(1,-4,0,38);r.BackgroundColor3=C().pn;r.BackgroundTransparency=.2;r.BorderSizePixel=0;r.Parent=ML Instance.new("UICorner",r).CornerRadius=UDim.new(0,6)
  local af=MkAv(p.UserId,r,UDim2.new(0,28,0,28)) af.Position=UDim2.new(0,4,.5,-14)
  local ring=Instance.new("UIStroke",af) ring.Color=RC.U;ring.Thickness=2
  local nl=Instance.new("TextLabel") nl.Size=UDim2.new(1,-80,0,14);nl.Position=UDim2.new(0,36,0,4);nl.BackgroundTransparency=1;nl.Text=p.Name;nl.TextColor3=C().tx;nl.Font=Enum.Font.GothamBold;nl.TextSize=10;nl.TextXAlignment=Enum.TextXAlignment.Left;nl.Parent=r
  local rl=Instance.new("TextLabel") rl.Size=UDim2.new(1,-80,0,12);rl.Position=UDim2.new(0,36,0,18);rl.BackgroundTransparency=1;rl.Text=RN.U;rl.TextColor3=RC.U;rl.Font=Enum.Font.GothamBold;rl.TextSize=9;rl.TextXAlignment=Enum.TextXAlignment.Left;rl.Parent=r
  local dt=Instance.new("Frame") dt.Size=UDim2.new(0,7,0,7);dt.Position=UDim2.new(1,-14,.5,-3.5);dt.BackgroundColor3=RC.U;dt.BorderSizePixel=0;dt.Parent=r Instance.new("UICorner",dt).CornerRadius=UDim.new(1,0)
  MR[p.UserId]={row=r,ring=ring,rl=rl,dot=dt}
end
local function RMR() for _,e in pairs(MR) do e.row:Destroy() end;MR={} for _,p in ipairs(P:GetPlayers()) do BMR(p) end end
RMB.MouseButton1Click:Connect(RMR)
P.PlayerAdded:Connect(function(p) task.wait(.5) if St.MM2 then BMR(p) end end)
P.PlayerRemoving:Connect(function(p) if MR[p.UserId] then MR[p.UserId].row:Destroy();MR[p.UserId]=nil end if EH[p.UserId] then EH[p.UserId]:Destroy();EH[p.UserId]=nil end end)

R.Heartbeat:Connect(function()
  if St.ESP then UESP() end
  if St.MM2 and MF.Visible then for _,p in ipairs(P:GetPlayers()) do if MR[p.UserId] then UMR(p) end end end
end)

-- ========== MM2 SCRIPT LOADER (только в MM2) ==========
local MM2ScriptPanel=nil
if IsMM2 then
  MM2ScriptPanel=Instance.new("Frame")
  MM2ScriptPanel.Size=UDim2.new(1,0,0,60);MM2ScriptPanel.Position=UDim2.new(0,0,0,0)
  MM2ScriptPanel.BackgroundColor3=C().pn;MM2ScriptPanel.BackgroundTransparency=.25;MM2ScriptPanel.BorderSizePixel=0
  MM2ScriptPanel.Parent=MFr
  Instance.new("UICorner",MM2ScriptPanel).CornerRadius=UDim.new(0,6)
  local lbl=Instance.new("TextLabel") lbl.Size=UDim2.new(1,-8,0,14);lbl.Position=UDim2.new(0,4,0,2);lbl.BackgroundTransparency=1;lbl.Text="Загрузить скрипт MM2:";lbl.TextColor3=C().ac;lbl.Font=Enum.Font.GothamBold;lbl.TextSize=10;lbl.TextXAlignment=Enum.TextXAlignment.Left;lbl.Parent=MM2ScriptPanel
  local function mkBtn(txt,y)
    local b=Instance.new("TextButton") b.Size=UDim2.new(.48,-2,0,20);b.Position=UDim2.new(y>0 and .52 or 0, y>0 and 2 or 4, 0, y>0 and 20 or 20);b.BackgroundColor3=C().ac;b.Text=txt;b.TextColor3=Color3.new(1,1,1);b.Font=Enum.Font.GothamBold;b.TextSize=9;b.BorderSizePixel=0;b.AutoButtonColor=false;b.Parent=MM2ScriptPanel Instance.new("UICorner",b).CornerRadius=UDim.new(0,5) return b end
  local b1=mkBtn("PulseZax",0) b1.Position=UDim2.new(0,4,0,20)
  local b2=mkBtn("Luarmor",0) b2.Position=UDim2.new(.5,2,0,20)
  local status=Instance.new("TextLabel") status.Size=UDim2.new(1,-8,0,12);status.Position=UDim2.new(0,4,0,44);status.BackgroundTransparency=1;status.Text="";status.TextColor3=C().sb;status.Font=Enum.Font.Gotham;status.TextSize=9;status.TextXAlignment=Enum.TextXAlignment.Left;status.Parent=MM2ScriptPanel
  local function run(code,label)
    status.Text="Загрузка "..label.."..."
    task.spawn(function()
      local ok,err=pcall(function() local f=loadstring(code) if not f then error("loadstring nil") end f() end)
      status.Text=ok and (label.." — готово") or ("Ошибка: "..tostring(err))
    end)
  end
  b1.MouseButton1Click:Connect(function() run('loadstring(game:HttpGet("https://raw.githubusercontent.com/PulseZax/Loader/refs/heads/main/.lua"))()',"PulseZax") end)
  b2.MouseButton1Click:Connect(function() run('loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/5857a6cfae3b902eb3c2dff7cdbf173b.lua"))()',"Luarmor") end)
  -- сдвигаем список вниз
  ML.Size=UDim2.new(1,0,1,-118);ML.Position=UDim2.new(0,0,0,64)
end

-- ========== DOORS ==========
local DoorsFrame=nil
if IsDoors then
  DoorsFrame=Instance.new("Frame")
  DoorsFrame.Size=UDim2.new(1,0,1,0);DoorsFrame.BackgroundTransparency=1;DoorsFrame.Visible=false;DoorsFrame.Parent=Cnt
  local b=Instance.new("TextButton")
  b.Size=UDim2.new(1,0,0,36);b.Position=UDim2.new(0,0,0,0)
  b.BackgroundColor3=C().ac;b.Text="Загрузить Abysall (Doors)"
  b.TextColor3=Color3.new(1,1,1);b.Font=Enum.Font.GothamBold
  b.TextSize=11;b.BorderSizePixel=0;b.AutoButtonColor=false;b.Parent=DoorsFrame
  Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
  local st=Instance.new("TextLabel")
  st.Size=UDim2.new(1,0,0,14);st.Position=UDim2.new(0,0,0,40)
  st.BackgroundTransparency=1;st.Text="";st.TextColor3=C().sb;st.Font=Enum.Font.Gotham
  st.TextSize=9;st.TextXAlignment=Enum.TextXAlignment.Left;st.Parent=DoorsFrame
  b.MouseButton1Click:Connect(function()
    st.Text="Загрузка..."
    task.spawn(function()
      local ok,err=pcall(function() local f=loadstring('loadstring(game:HttpGet("https://raw.githubusercontent.com/therealcookiemonsterof1966/AbysallContinued/main/Games/Doors/Main.luau"))()') if not f then error("loadstring nil") end f() end)
      st.Text=ok and "Abysall — готово" or ("Ошибка: "..tostring(err))
    end)
  end)
end

-- ========== 99 NIGHTS ==========
local N99Frame=nil
if Is99 then
  N99Frame=Instance.new("Frame")
  N99Frame.Size=UDim2.new(1,0,1,0);N99Frame.BackgroundTransparency=1;N99Frame.Visible=false;N99Frame.Parent=Cnt
  local function mkB(txt,y,code,label)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(1,0,0,30);b.Position=UDim2.new(0,0,0,y)
    b.BackgroundColor3=C().ac;b.Text=txt;b.TextColor3=Color3.new(1,1,1)
    b.Font=Enum.Font.GothamBold;b.TextSize=10;b.BorderSizePixel=0;b.AutoButtonColor=false;b.Parent=N99Frame
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    b.MouseButton1Click:Connect(function()
      local st=N99Frame:FindFirstChild("Status")
      if st then st.Text="Загрузка "..label.."..." end
      task.spawn(function()
        local ok,err=pcall(function() local f=loadstring(code) if not f then error("loadstring nil") end f() end)
        if st then st.Text=ok and (label.." — готово") or ("Ошибка: "..tostring(err)) end
      end)
    end)
  end
  mkB("Загрузить VapeVoidware",0,'loadstring(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/VW-Add/main/nightsintheforest.lua", true))()',"VapeVoidware")
  mkB("Загрузить Kixdev",36,'loadstring(game:HttpGet("https://raw.githubusercontent.com/Kixdev/99NITF/main/script", true))()',"Kixdev")
  local st=Instance.new("TextLabel")
  st.Name="Status";st.Size=UDim2.new(1,0,0,14);st.Position=UDim2.new(0,0,0,70)
  st.BackgroundTransparency=1;st.Text="";st.TextColor3=C().sb;st.Font=Enum.Font.Gotham
  st.TextSize=9;st.TextXAlignment=Enum.TextXAlignment.Left;st.Parent=N99Frame
end

-- ========== MUSIC ==========
local MuF=Instance.new("Frame")
MuF.Size=UDim2.new(1,0,1,0);MuF.BackgroundTransparency=1;MuF.Visible=false;MuF.Parent=Cnt
local NP=Instance.new("Frame") NP.Size=UDim2.new(1,0,0,52);NP.BackgroundColor3=C().pn;NP.BackgroundTransparency=.2;NP.BorderSizePixel=0;NP.Parent=MuF Instance.new("UICorner",NP).CornerRadius=UDim.new(0,6)
local NC=Instance.new("ImageLabel") NC.Size=UDim2.new(0,42,0,42);NC.Position=UDim2.new(0,5,0,5);NC.BackgroundColor3=C().bg;NC.BorderSizePixel=0;NC.Image="";NC.ScaleType=Enum.ScaleType.Crop;NC.Parent=NP Instance.new("UICorner",NC).CornerRadius=UDim.new(0,5)
local NT=Instance.new("TextLabel") NT.Size=UDim2.new(1,-120,0,16);NT.Position=UDim2.new(0,52,0,6);NT.BackgroundTransparency=1;NT.Text="Ничего не играет";NT.TextColor3=C().tx;NT.Font=Enum.Font.GothamBold;NT.TextSize=10;NT.TextXAlignment=Enum.TextXAlignment.Left;NT.Parent=NP
local NTM=Instance.new("TextLabel") NTM.Size=UDim2.new(1,-120,0,12);NTM.Position=UDim2.new(0,52,0,22);NTM.BackgroundTransparency=1;NTM.Text="0:00 / 0:00";NTM.TextColor3=C().sb;NTM.Font=Enum.Font.Gotham;NTM.TextSize=9;NTM.TextXAlignment=Enum.TextXAlignment.Left;NTM.Parent=NP
local PB=Instance.new("Frame") PB.Size=UDim2.new(1,-120,0,3);PB.Position=UDim2.new(0,52,0,38);PB.BackgroundColor3=C().bg;PB.BorderSizePixel=0;PB.Parent=NP Instance.new("UICorner",PB).CornerRadius=UDim.new(1,0)
local PF=Instance.new("Frame") PF.Size=UDim2.new(0,0,1,0);PF.BackgroundColor3=C().ac;PF.BorderSizePixel=0;PF.Parent=PB Instance.new("UICorner",PF).CornerRadius=UDim.new(1,0)
local PPB=Instance.new("TextButton") PPB.Size=UDim2.new(0,22,0,22);PPB.Position=UDim2.new(1,-58,.5,-11);PPB.BackgroundColor3=C().ac;PPB.Text="▶";PPB.TextColor3=Color3.new(1,1,1);PPB.Font=Enum.Font.GothamBold;PPB.TextSize=10;PPB.BorderSizePixel=0;PPB.AutoButtonColor=false;PPB.Parent=NP Instance.new("UICorner",PPB).CornerRadius=UDim.new(1,0)
local StB=Instance.new("TextButton") StB.Size=UDim2.new(0,22,0,22);StB.Position=UDim2.new(1,-32,.5,-11);StB.BackgroundColor3=Color3.fromRGB(120,40,40);StB.Text="■";StB.TextColor3=Color3.new(1,1,1);StB.Font=Enum.Font.GothamBold;StB.TextSize=10;StB.BorderSizePixel=0;StB.AutoButtonColor=false;StB.Parent=NP Instance.new("UICorner",StB).CornerRadius=UDim.new(1,0)
local MuL=Instance.new("ScrollingFrame") MuL.Size=UDim2.new(1,0,1,-112);MuL.Position=UDim2.new(0,0,0,56);MuL.BackgroundColor3=C().bg;MuL.BackgroundTransparency=.25;MuL.BorderSizePixel=0;MuL.CanvasSize=UDim2.new(0,0,0,0);MuL.AutomaticCanvasSize=Enum.AutomaticSize.Y;MuL.ScrollBarThickness=2;MuL.ScrollBarImageColor3=C().ac;MuL.Parent=MuF Instance.new("UICorner",MuL).CornerRadius=UDim.new(0,6)
local MuLay=Instance.new("UIListLayout",MuL) MuLay.Padding=UDim.new(0,2);MuLay.SortOrder=Enum.SortOrder.LayoutOrder
local AP=Instance.new("Frame") AP.Size=UDim2.new(1,0,0,50);AP.Position=UDim2.new(0,0,1,-50);AP.BackgroundColor3=C().pn;AP.BackgroundTransparency=.2;AP.BorderSizePixel=0;AP.Parent=MuF Instance.new("UICorner",AP).CornerRadius=UDim.new(0,6)
local II=Instance.new("TextBox") II.Size=UDim2.new(.35,-4,0,18);II.Position=UDim2.new(0,4,0,3);II.BackgroundColor3=C().bg;II.PlaceholderText="ID";II.Text="";II.TextColor3=C().tx;II.PlaceholderColor3=C().sb;II.Font=Enum.Font.Gotham;II.TextSize=9;II.BorderSizePixel=0;II.Parent=AP Instance.new("UICorner",II).CornerRadius=UDim.new(0,5)
local NI=Instance.new("TextBox") NI.Size=UDim2.new(.45,-4,0,18);NI.Position=UDim2.new(.35,2,0,3);NI.BackgroundColor3=C().bg;NI.PlaceholderText="Название";NI.Text="";NI.TextColor3=C().tx;NI.PlaceholderColor3=C().sb;NI.Font=Enum.Font.Gotham;NI.TextSize=9;NI.BorderSizePixel=0;NI.Parent=AP Instance.new("UICorner",NI).CornerRadius=UDim.new(0,5)
local AB=Instance.new("TextButton") AB.Size=UDim2.new(.2,-6,0,18);AB.Position=UDim2.new(.8,2,0,3);AB.BackgroundColor3=C().ac;AB.Text="+";AB.TextColor3=Color3.new(1,1,1);AB.Font=Enum.Font.GothamBold;AB.TextSize=12;AB.BorderSizePixel=0;AB.AutoButtonColor=false;AB.Parent=AP Instance.new("UICorner",AB).CornerRadius=UDim.new(0,5)
local TLb=Instance.new("TextLabel") TLb.Size=UDim2.new(1,-8,0,12);TLb.Position=UDim2.new(0,4,0,24);TLb.BackgroundTransparency=1;TLb.Text="Темы:";TLb.TextColor3=C().sb;TLb.Font=Enum.Font.GothamBold;TLb.TextSize=9;TLb.TextXAlignment=Enum.TextXAlignment.Left;TLb.Parent=AP
local ApplyTheme,Sp,DecoLs
local TBtns={}
local TNames={"Green","Red","Blue","Astral","Crystal","Rainbow","Halloween","Frost"}
for i,tn in ipairs(TNames) do
  local b=Instance.new("TextButton")
  b.Size=UDim2.new(0,22,0,10);b.Position=UDim2.new(0,4+(i-1)*24,0,36)
  b.BackgroundColor3=TH[tn].ac;b.Text="";b.BorderSizePixel=0;b.AutoButtonColor=false;b.Name=tn;b.Parent=AP
  Instance.new("UICorner",b).CornerRadius=UDim.new(1,0)
  table.insert(TBtns,b)
  b.MouseButton1Click:Connect(function() CT=tn if ApplyTheme then ApplyTheme() end end)
end
local TR={{id=111743516263186},{id=123272377121190},{id=96448997190133},{id=121336955981923},{id=86030568049889},{id=103401575600819},{id=134763052215450},{id=116873078212017},{id=71393805905055}}
if not getgenv().CustomTracks then getgenv().CustomTracks={} end
local CM=nil
local function StopM() if CM then CM:Destroy();CM=nil end NT.Text="Ничего не играет";NTM.Text="0:00 / 0:00";PF.Size=UDim2.new(0,0,1,0);PPB.Text="▶" end
local function FTm(s) s=math.floor(s or 0);return string.format("%d:%02d",math.floor(s/60),s%60) end
local function PlayM(id,title)
  StopM()
  local s=Instance.new("Sound",SS) s.SoundId="rbxassetid://"..tostring(id);s.Volume=.5;s:Play();CM=s
  NT.Text=title or ("ID "..tostring(id))
  NC.Image=("rbxthumb://type=Asset&id=%d&w=100&h=100"):format(id)
  PPB.Text="❚❚"
  s.Ended:Connect(StopM)
  task.spawn(function() while CM==s do local ln=s.TimeLength or 0 local ps=s.TimePosition or 0 NTM.Text=FTm(ps).." / "..FTm(ln) if ln>0 then PF.Size=UDim2.new(math.clamp(ps/ln,0,1),0,1,0) end task.wait(.25) end end)
end
PPB.MouseButton1Click:Connect(function() if CM then if CM.IsPlaying then CM:Pause();PPB.Text="▶" else CM:Resume();PPB.Text="❚❚" end end end)
StB.MouseButton1Click:Connect(StopM)
local function BML()
  for _,c in ipairs(MuL:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
  local all={} for _,t in ipairs(TR) do table.insert(all,t) end for _,t in ipairs(getgenv().CustomTracks) do table.insert(all,t) end
  for i,tr in ipairs(all) do
    local r=Instance.new("Frame") r.Size=UDim2.new(1,-4,0,34);r.BackgroundColor3=C().pn;r.BackgroundTransparency=.2;r.BorderSizePixel=0;r.Parent=MuL Instance.new("UICorner",r).CornerRadius=UDim.new(0,6)
    local cv=Instance.new("ImageLabel") cv.Size=UDim2.new(0,28,0,28);cv.Position=UDim2.new(0,3,.5,-14);cv.BackgroundColor3=C().bg;cv.BorderSizePixel=0;cv.Image=("rbxthumb://type=Asset&id=%d&w=100&h=100"):format(tr.id);cv.ScaleType=Enum.ScaleType.Crop;cv.Parent=r Instance.new("UICorner",cv).CornerRadius=UDim.new(0,5)
    local lb=Instance.new("TextLabel") lb.Size=UDim2.new(1,-40,1,0);lb.Position=UDim2.new(0,36,0,0);lb.BackgroundTransparency=1;lb.Text=tr.name or ("Трек "..i);lb.TextColor3=C().tx;lb.Font=Enum.Font.Gotham;lb.TextSize=10;lb.TextXAlignment=Enum.TextXAlignment.Left;lb.Parent=r
    local h=Instance.new("TextButton") h.Size=UDim2.new(1,0,1,0);h.BackgroundTransparency=1;h.Text="";h.Parent=r
    h.MouseButton1Click:Connect(function() PlayM(tr.id,tr.name or ("Трек "..i)) end)
  end
end
BML()
AB.MouseButton1Click:Connect(function() local id=tonumber(II.Text) if not id then return end local nm=NI.Text~="" and NI.Text or ("Мой "..(#getgenv().CustomTracks+1)) table.insert(getgenv().CustomTracks,{id=id,name=nm}) II.Text="";NI.Text="";BML() end)
task.spawn(function()
  for i,tr in ipairs(TR) do
    local ok,info=pcall(function() return MS:GetProductInfo(tr.id,Enum.InfoType.Asset) end)
    if ok and info and info.Name and info.Name~="" and info.Name~="Audio" then tr.name=info.Name else tr.name=tr.name or ("Трек "..i) end
  end
  BML()
end)

-- ========== TABS ==========
local Tabs={}
local ActiveTab=nil
local function MkTab(txt,ord) local b=Instance.new("TextButton") b.Size=UDim2.new(0,0,1,0);b.AutomaticSize=Enum.AutomaticSize.X;b.BackgroundColor3=C().pn;b.Text=txt;b.TextColor3=C().sb;b.Font=Enum.Font.GothamBold;b.TextSize=9;b.BorderSizePixel=0;b.AutoButtonColor=false;b.LayoutOrder=ord;b.Parent=TabB Instance.new("UICorner",b).CornerRadius=UDim.new(0,6) local p=Instance.new("UIPadding",b) p.PaddingLeft=UDim.new(0,6);p.PaddingRight=UDim.new(0,6) table.insert(Tabs,b) return b end
local FTb=MkTab("FLING",1)
local MTb=MkTab("MM2",2)
local MuTb=MkTab("MUSIC",3)
local DoorsTab=nil
if IsDoors then DoorsTab=MkTab("DOORS",4) end
local N99Tab=nil
if Is99 then N99Tab=MkTab("99 NIGHTS",5) end

local function SelTab(w)
  for _,b in ipairs(Tabs) do Tw(b,{BackgroundColor3=C().pn,TextColor3=C().sb},.2) end
  FF.Visible=false;MFr.Visible=false;MuF.Visible=false;St.MM2=false
  if DoorsFrame then DoorsFrame.Visible=false end
  if N99Frame then N99Frame.Visible=false end
  if w=="FLING" then ActiveTab=FTb;FF.Visible=true
  elseif w=="MM2" then ActiveTab=MTb;MFr.Visible=true;St.MM2=true;RMR()
  elseif w=="MUSIC" then ActiveTab=MuTb;MuF.Visible=true
  elseif w=="DOORS" and DoorsFrame then ActiveTab=DoorsTab;DoorsFrame.Visible=true
  elseif w=="99" and N99Frame then ActiveTab=N99Tab;N99Frame.Visible=true end
  Tw(ActiveTab,{BackgroundColor3=C().ac,TextColor3=Color3.new(1,1,1)},.25)
end
FTb.MouseButton1Click:Connect(function() SelTab("FLING") end)
MTb.MouseButton1Click:Connect(function() SelTab("MM2") end)
MuTb.MouseButton1Click:Connect(function() SelTab("MUSIC") end)
if DoorsTab then DoorsTab.MouseButton1Click:Connect(function() SelTab("DOORS") end) end
if N99Tab then N99Tab.MouseButton1Click:Connect(function() SelTab("99") end) end

DecoLs={}
Sp=function()
  for _,d in ipairs(DecoLs) do d:Destroy() end;DecoLs={}
  local th=C() if th.dc=="" then return end
  for i=1,5 do local d=Instance.new("TextLabel") d.Size=UDim2.new(0,30,0,30);d.Position=UDim2.new(math.random(),-15,math.random(),-15);d.BackgroundTransparency=1;d.Text=th.dc;d.TextSize=20;d.TextTransparency=.75;d.ZIndex=0;d.Parent=MF table.insert(DecoLs,d) end
end
ApplyTheme=function()
  local t=C()
  Tw(MF,{BackgroundColor3=t.bg},.4);Tw(TBar,{BackgroundColor3=t.pn},.4);Tw(Ttl,{TextColor3=t.ac},.4)
  Tw(MFS,{Color=t.ac},.4);Tw(TBS,{Color=t.ac},.4);Tw(TB,{BackgroundColor3=t.pn,TextColor3=t.ac},.4)
  for _,b in ipairs(Tabs) do if b~=ActiveTab then Tw(b,{BackgroundColor3=t.pn,TextColor3=t.sb},.3) end end
  if ActiveTab then Tw(ActiveTab,{BackgroundColor3=t.ac},.3) end
  for _,l in ipairs({PL,ML,MuL}) do Tw(l,{BackgroundColor3=t.bg,ScrollBarImageColor3=t.ac},.3) end
  for _,b in ipairs(TBtns) do if b.Name==CT then Tw(b,{BackgroundColor3=t.ac},.25) else Tw(b,{BackgroundColor3=t.pn},.25) end end
  Sp()
end

local function SkidFling(tp)
  local ch=LP.Character;local hu=ch and ch:FindFirstChildOfClass("Humanoid");local rp=hu and hu.RootPart
  local tc=tp.Character;if not tc then return end
  local thu,trp,thd,acc,hnd
  if tc:FindFirstChildOfClass("Humanoid") then thu=tc:FindFirstChildOfClass("Humanoid") end
  if thu and thu.RootPart then trp=thu.RootPart end
  if tc:FindFirstChild("Head") then thd=tc.Head end
  if tc:FindFirstChildOfClass("Accessory") then acc=tc:FindFirstChildOfClass("Accessory") end
  if acc and acc:FindFirstChild("Handle") then hnd=acc.Handle end
  if not (ch and hu and rp) then return end
  if rp.Velocity.Magnitude<50 then getgenv().OldPos=rp.CFrame end
  if thu and thu.Sit then return end
  if thd then W.CurrentCamera.CameraSubject=thd end
  local function FP(bp,po,an) rp.CFrame=CFrame.new(bp.Position)*po*an;ch:SetPrimaryPartCFrame(CFrame.new(bp.Position)*po*an);rp.Velocity=Vector3.new(9e7,9e7*10,9e7);rp.RotVelocity=Vector3.new(9e8,9e8,9e8) end
  local function SF(bp) local tw=2;local t=tick();local a=0 repeat if rp and thu then if bp.Velocity.Magnitude<50 then a=a+100 FP(bp,CFrame.new(0,1.5,0)+thu.MoveDirection*bp.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(a),0,0));task.wait() FP(bp,CFrame.new(0,-1.5,0)+thu.MoveDirection*bp.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(a),0,0));task.wait() FP(bp,CFrame.new(0,1.5,0)+thu.MoveDirection*bp.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(a),0,0));task.wait() FP(bp,CFrame.new(0,-1.5,0)+thu.MoveDirection*bp.Velocity.Magnitude/1.25,CFrame.Angles(math.rad(a),0,0));task.wait() else FP(bp,CFrame.new(0,1.5,thu.WalkSpeed),CFrame.Angles(math.rad(90),0,0));task.wait() FP(bp,CFrame.new(0,-1.5,-thu.WalkSpeed),CFrame.Angles(0,0,0));task.wait() end end until t+tw<tick() end
  W.FallenPartsDestroyHeight=0/0
  local bv=Instance.new("BodyVelocity") bv.Parent=rp;bv.Velocity=Vector3.new(0,0,0);bv.MaxForce=Vector3.new(9e9,9e9,9e9)
  hu:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
  if trp then SF(trp) elseif thd then SF(thd) elseif hnd then SF(hnd) end
  bv:Destroy();hu:SetStateEnabled(Enum.HumanoidStateType.Seated,true);W.CurrentCamera.CameraSubject=hu
  if getgenv().OldPos then repeat rp.CFrame=getgenv().OldPos*CFrame.new(0,.5,0);ch:SetPrimaryPartCFrame(getgenv().OldPos*CFrame.new(0,.5,0));hu:ChangeState("GettingUp") for _,p in pairs(ch:GetChildren()) do if p:IsA("BasePart") then p.Velocity,p.RotVelocity=Vector3.new(),Vector3.new() end end task.wait() until (rp.Position-getgenv().OldPos.p).Magnitude<25 W.FallenPartsDestroyHeight=getgenv().FPDH end
end
SB.MouseButton1Click:Connect(function() if St.FT and St.FT.Character then SkidFling(St.FT) else warn("Выбери игрока!") end end)

R.Heartbeat:Connect(function()
  if CT=="Rainbow" then
    local h=(tick()*.15)%1;local c=Color3.fromHSV(h,.8,1)
    MFS.Color=c;TBS.Color=c;Ttl.TextColor3=c
    if ActiveTab then ActiveTab.BackgroundColor3=c end
    for _,d in ipairs(DecoLs) do d.TextColor3=c end
  end
end)

SelTab("FLING")
ApplyTheme()
print("[FF] Loaded. PlaceId="..CurGame.." by:@Promtikdeepseek")
