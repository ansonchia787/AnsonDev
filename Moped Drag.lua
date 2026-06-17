--[[
    AnsonDev - Moped Drag
    Version : 1.0.0
    Author  : AnsonDev
    UI      : WindUI
]]

local WindUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
))()

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService  = game:GetService("TeleportService")
local VirtualUser      = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ═══════════════════════════════════════════════════
--  State
-- ═══════════════════════════════════════════════════
local State = {
    farmPoints    = {},
    farmIndex     = 1,
    farmRunning   = false,
    farmConn      = nil,
    farmSpeed     = 150,
    arrivalDist   = 12,
    boostEnabled  = false,
    boostConn     = nil,
    boostMulti    = 2,
    flyEnabled    = false,
    flyConn       = nil,
    flyTpConn     = nil,
    flyNowe       = false,
    flySpeed      = 50,
    noclipEnabled = false,
    noclipConn    = nil,
    walkEnabled   = false,
    walkVal       = 16,
    jumpEnabled   = false,
    jumpVal       = 50,
    infJumpConn   = nil,
    godOn         = false,
    godConn       = nil,
    fpsBoostOn    = false,
    mopedMaxSpd   = 300,
    mopedTorque   = 50000,
}

-- ═══════════════════════════════════════════════════
--  Helpers
-- ═══════════════════════════════════════════════════
local function getChar()  return player.Character end
local function getHRP()   local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()   local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid") end
local function getSeat()
    local h = getHum()
    if h and h.SeatPart and h.SeatPart:IsA("VehicleSeat") then return h.SeatPart end
end
local function getVehicleModel() local s = getSeat(); return s and s.Parent end
local function getVehicleRoot()
    local s = getSeat(); if not s then return nil end
    local m = s.Parent
    return (m and (m.PrimaryPart or m:FindFirstChildOfClass("BasePart"))) or s
end
local function isR6()    local c = getChar(); return c and c:FindFirstChild("Torso") ~= nil end
local function getTorso()
    local c = getChar(); if not c then return nil end
    return isR6() and c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
end
local function ensureBV(part, name, force)
    local bv = part:FindFirstChild(name)
    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.Name = name; bv.MaxForce = Vector3.new(force,force,force)
        bv.Velocity = Vector3.zero; bv.Parent = part
    end
    return bv
end
local function ensureBG(part, name)
    local bg = part:FindFirstChild(name)
    if not bg then
        bg = Instance.new("BodyGyro")
        bg.Name = name; bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
        bg.P = 9e4; bg.D = 500; bg.CFrame = part.CFrame; bg.Parent = part
    end
    return bg
end
local function cleanInst(part, name)
    if not part then return end
    local i = part:FindFirstChild(name); if i then i:Destroy() end
end
local function notify(title, content)
    WindUI:Notify({ Title = title, Content = content or "", Duration = 3 })
end

-- ═══════════════════════════════════════════════════
--  FPS Overlay
-- ═══════════════════════════════════════════════════
local fpsGui = Instance.new("ScreenGui")
fpsGui.Name = "AnsonDevFPS"; fpsGui.ResetOnSpawn = false
fpsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
fpsGui.Parent = player:WaitForChild("PlayerGui")

local fpsBg = Instance.new("Frame")
fpsBg.Size = UDim2.new(0,80,0,24)
fpsBg.Position = UDim2.new(1,-90,0,8)
fpsBg.BackgroundColor3 = Color3.fromRGB(8,8,12)
fpsBg.BackgroundTransparency = 0.1
fpsBg.BorderSizePixel = 0; fpsBg.Parent = fpsGui
Instance.new("UICorner", fpsBg).CornerRadius = UDim.new(0,6)
local fpsStroke = Instance.new("UIStroke", fpsBg)
fpsStroke.Color = Color3.fromRGB(60,60,80); fpsStroke.Thickness = 1

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(1,0,1,0)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS  --"
fpsLabel.TextColor3 = Color3.fromRGB(120,220,120)
fpsLabel.TextSize = 12; fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.Parent = fpsBg

local fpsSamples = {}
RunService.Heartbeat:Connect(function(dt)
    table.insert(fpsSamples, 1/dt)
    if #fpsSamples > 30 then table.remove(fpsSamples,1) end
    local sum = 0; for _,v in ipairs(fpsSamples) do sum = sum + v end
    local avg = math.floor(sum / #fpsSamples)
    fpsLabel.Text = "FPS  " .. avg
    fpsLabel.TextColor3 = avg >= 55 and Color3.fromRGB(80,220,100)
        or avg >= 30 and Color3.fromRGB(240,180,60)
        or Color3.fromRGB(220,70,70)
end)

-- ═══════════════════════════════════════════════════
--  FPS Boost
-- ═══════════════════════════════════════════════════
local function applyFpsBoost()
    pcall(function() workspace.GlobalShadows = false end)
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
    for _,v in ipairs(workspace:GetDescendants()) do pcall(function()
        if v:IsA("ParticleEmitter") or v:IsA("Beam") or v:IsA("Trail")
            or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
            v.Enabled = false end end) end
end
local function removeFpsBoost()
    pcall(function() workspace.GlobalShadows = true end)
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)
    for _,v in ipairs(workspace:GetDescendants()) do pcall(function()
        if v:IsA("ParticleEmitter") or v:IsA("Beam") or v:IsA("Trail")
            or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
            v.Enabled = true end end) end
end

-- ═══════════════════════════════════════════════════
--  Moped Physics
-- ═══════════════════════════════════════════════════
local function overrideMopedPhysics(maxSpd, maxTorque)
    local model = getVehicleModel(); if not model then return false end
    for _,v in ipairs(model:GetDescendants()) do pcall(function()
        if v:IsA("VehicleSeat")      then v.MaxSpeed = maxSpd end
        if v:IsA("TorqueConstraint") then v.MaxTorque = maxTorque end
        if v:IsA("HingeConstraint") and v.ActuatorType == Enum.ActuatorType.Motor then
            v.MaxTorque = maxTorque; v.AngularVelocity = maxSpd / 8 end
        if v:IsA("BodyVelocity") then v.MaxForce = Vector3.new(1e6,1e6,1e6) end
    end) end
    return true
end

-- ═══════════════════════════════════════════════════
--  Auto Farm
-- ═══════════════════════════════════════════════════
local function stopFarm()
    State.farmRunning = false
    if State.farmConn then State.farmConn:Disconnect(); State.farmConn = nil end
    local vr = getVehicleRoot()
    if vr then cleanInst(vr,"FarmBV"); cleanInst(vr,"FarmBG") end
    local s = getSeat(); if s then s.ThrottleFloat=0; s.SteerFloat=0 end
end
local function startFarm(points)
    local pts = points or State.farmPoints
    if #pts < 2 then return false,"Need at least 2 points." end
    if not getVehicleRoot() then return false,"Sit on the moped first." end
    State.farmRunning = true; State.farmIndex = 1
    State.farmConn = RunService.Heartbeat:Connect(function()
        if not State.farmRunning then return end
        local vr = getVehicleRoot(); if not vr then stopFarm(); return end
        local t = pts[State.farmIndex]; if not t then State.farmIndex=1; return end
        local c = vr.Position
        local dx,dy,dz = t.X-c.X, t.Y-c.Y, t.Z-c.Z
        if math.sqrt(dx*dx+dy*dy+dz*dz) < State.arrivalDist then
            State.farmIndex = (State.farmIndex % #pts) + 1
            t = pts[State.farmIndex]; dx,dy,dz = t.X-c.X, t.Y-c.Y, t.Z-c.Z
        end
        local fd = Vector3.new(dx,0,dz)
        if fd.Magnitude < 0.01 then fd = Vector3.new(1,0,0) end
        fd = fd.Unit
        local bv = ensureBV(vr,"FarmBV",1e6)
        bv.Velocity = fd*State.farmSpeed + Vector3.new(0, math.clamp(dy,-1,1)*State.farmSpeed*0.5, 0)
        ensureBG(vr,"FarmBG").CFrame = CFrame.lookAt(c, c+fd)
        local s = getSeat(); if s then s.ThrottleFloat=1 end
    end)
    return true
end

-- ═══════════════════════════════════════════════════
--  Speed Boost
-- ═══════════════════════════════════════════════════
local function stopBoost()
    State.boostEnabled = false
    if State.boostConn then State.boostConn:Disconnect(); State.boostConn = nil end
    local vr = getVehicleRoot(); if vr then cleanInst(vr,"BoostBV") end
end
local function startBoost()
    State.boostEnabled = true
    State.boostConn = RunService.Heartbeat:Connect(function()
        if not State.boostEnabled then return end
        local vr,seat = getVehicleRoot(), getSeat()
        if not vr or not seat then return end
        local moving = UserInputService:IsKeyDown(Enum.KeyCode.W)
        local hum = getHum()
        if not moving and hum and hum.MoveDirection.Magnitude > 0.1 then moving = true end
        if moving then
            local fv = Vector3.new(vr.Velocity.X,0,vr.Velocity.Z)
            local dir = fv.Magnitude < 1 and Vector3.new(seat.CFrame.LookVector.X,0,seat.CFrame.LookVector.Z).Unit or fv.Unit
            ensureBV(vr,"BoostBV",1e6).Velocity = dir * math.max(fv.Magnitude,20) * State.boostMulti
            seat.ThrottleFloat = 1
        else cleanInst(vr,"BoostBV"); seat.ThrottleFloat = 0 end
    end)
end

-- ═══════════════════════════════════════════════════
--  Fly (V3, R6 + R15)
-- ═══════════════════════════════════════════════════
local flyStates = {
    Enum.HumanoidStateType.Climbing, Enum.HumanoidStateType.FallingDown,
    Enum.HumanoidStateType.Flying, Enum.HumanoidStateType.Freefall,
    Enum.HumanoidStateType.GettingUp, Enum.HumanoidStateType.Jumping,
    Enum.HumanoidStateType.Landed, Enum.HumanoidStateType.Physics,
    Enum.HumanoidStateType.PlatformStanding, Enum.HumanoidStateType.Ragdoll,
    Enum.HumanoidStateType.Running, Enum.HumanoidStateType.RunningNoPhysics,
    Enum.HumanoidStateType.Seated, Enum.HumanoidStateType.StrafingNoPhysics,
    Enum.HumanoidStateType.Swimming,
}
local function stopFly()
    State.flyEnabled = false; State.flyNowe = false
    if State.flyConn   then State.flyConn:Disconnect();   State.flyConn   = nil end
    if State.flyTpConn then State.flyTpConn:Disconnect(); State.flyTpConn = nil end
    local torso = getTorso()
    if torso then cleanInst(torso,"FlyBV"); cleanInst(torso,"FlyBG") end
    local hum = getHum(); local c = getChar()
    if hum then
        for _,st in ipairs(flyStates) do hum:SetStateEnabled(st,true) end
        hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
        hum.PlatformStand = false
    end
    if c then
        local anim = c:FindFirstChild("Animate"); if anim then anim.Disabled = false end
        local h2 = c:FindFirstChildOfClass("Humanoid")
        if h2 then for _,t in ipairs(h2:GetPlayingAnimationTracks()) do t:AdjustSpeed(1) end end
    end
end
local function startFly()
    State.flyEnabled = true; State.flyNowe = true
    local hum = getHum(); local c = getChar()
    if not hum or not c then return end
    for _,st in ipairs(flyStates) do hum:SetStateEnabled(st,false) end
    hum:ChangeState(Enum.HumanoidStateType.Swimming); hum.PlatformStand = true
    State.flyTpConn = RunService.Heartbeat:Connect(function()
        if not State.flyNowe then return end
        local chr = getChar(); local h = getHum()
        if chr and h and h.MoveDirection.Magnitude > 0 then
            chr:TranslateBy(h.MoveDirection * (State.flySpeed * 0.05)) end
    end)
    local torso = getTorso(); if not torso then return end
    ensureBG(torso,"FlyBG").CFrame = torso.CFrame
    ensureBV(torso,"FlyBV",9e9).Velocity = Vector3.new(0,0.1,0)
    local speed,ctrl,last = 0,{f=0,b=0,l=0,r=0},{f=0,b=0,l=0,r=0}
    State.flyConn = RunService.RenderStepped:Connect(function()
        if not State.flyNowe then return end
        local h2 = getHum(); if h2 then h2.PlatformStand = true end
        local ms = State.flySpeed
        ctrl.f = UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0
        ctrl.b = UserInputService:IsKeyDown(Enum.KeyCode.S) and -1 or 0
        ctrl.l = UserInputService:IsKeyDown(Enum.KeyCode.A) and -1 or 0
        ctrl.r = UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0
        local hm = getHum()
        if hm then local md = hm.MoveDirection
            if md.Magnitude > 0.1 then
                if ctrl.f==0 and ctrl.b==0 then ctrl.f = md.Z<0 and 1 or (md.Z>0 and -1 or 0) end
                if ctrl.l==0 and ctrl.r==0 then ctrl.r = md.X>0 and 1 or (md.X<0 and -1 or 0) end
            end end
        local mov = (ctrl.l+ctrl.r)~=0 or (ctrl.f+ctrl.b)~=0
        if mov then speed = math.min(speed+0.5+(speed/ms),ms)
        elseif speed>0 then speed = math.max(speed-1,0) end
        local cf = camera.CoordinateFrame
        local bv = torso:FindFirstChild("FlyBV"); local bg = torso:FindFirstChild("FlyBG")
        if not bv or not bg then return end
        if mov then
            bv.Velocity = ((cf.LookVector*(ctrl.f+ctrl.b)) +
                ((cf*CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*0.2,0).Position)-cf.Position))*speed
            last = {f=ctrl.f,b=ctrl.b,l=ctrl.l,r=ctrl.r}
        elseif speed>0 then
            bv.Velocity = ((cf.LookVector*(last.f+last.b)) +
                ((cf*CFrame.new(last.l+last.r,(last.f+last.b)*0.2,0).Position)-cf.Position))*speed
        else bv.Velocity = Vector3.zero end
        bg.CFrame = cf * CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*speed/ms),0,0)
    end)
end

-- ═══════════════════════════════════════════════════
--  Noclip
-- ═══════════════════════════════════════════════════
local function stopNoclip()
    State.noclipEnabled = false
    if State.noclipConn then State.noclipConn:Disconnect(); State.noclipConn = nil end
    local c = getChar()
    if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end
end
local function startNoclip()
    State.noclipEnabled = true
    State.noclipConn = RunService.Stepped:Connect(function()
        if not State.noclipEnabled then return end
        local c = getChar(); if not c then return end
        for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
    end)
end

-- ═══════════════════════════════════════════════════
--  WindUI Window
-- ═══════════════════════════════════════════════════
local Window = WindUI:CreateWindow({
    Title   = "AnsonDev  |  Moped Drag",
    Folder  = "AnsonDev",
    Icon    = "bike",
    NewElements = true,
    Topbar = {
        Height      = 48,
        ButtonsType = "Mac",
    },
    OpenButton = {
        Title           = "AnsonDev",
        CornerRadius    = UDim.new(1, 0),
        StrokeThickness = 2,
        Enabled         = true,
        Draggable       = true,
        OnlyMobile      = false,
        Scale           = 0.55,
        Color = ColorSequence.new(
            Color3.fromHex("#4F8EF7"),
            Color3.fromHex("#9B59F5")
        ),
    },
})

Window:Tag({
    Title  = "v1.0.0",
    Icon   = "sparkles",
    Color  = Color3.fromHex("#18181b"),
    Border = true,
})

Window:Tag({
    Title  = "Moped Drag",
    Icon   = "bike",
    Color  = Color3.fromHex("#1e1e2e"),
    Border = true,
})

-- ═══════════════════════════════════════════════════
--  HOME TAB  (first, no section so it appears at top)
-- ═══════════════════════════════════════════════════
do
    local HomeTab = Window:Tab({
        Title = "Home",
        Icon  = "house",
    })

    -- Hero banner
    local HeroSection = HomeTab:Section({ Title = "AnsonDev  |  Moped Drag" })

    HeroSection:Section({
        Title      = "Welcome back, " .. player.Name,
        TextSize   = 24,
        FontWeight = Enum.FontWeight.Bold,
    })

    HeroSection:Space()

    HeroSection:Section({
        Title            = "The ultimate Moped Drag automation tool.\nAuto Farm  •  Speed Boost  •  Player Utilities  •  Misc Tools",
        TextSize         = 15,
        TextTransparency = 0.35,
        FontWeight       = Enum.FontWeight.Medium,
    })

    HeroSection:Space({ Columns = 3 })

    -- Stats row
    local StatsGroup = HomeTab:Group({})

    StatsGroup:Section({
        Title      = "Version",
        TextSize   = 12,
        TextTransparency = 0.5,
    })
    StatsGroup:Section({
        Title      = "1.0.0",
        TextSize   = 18,
        FontWeight = Enum.FontWeight.Bold,
    })

    StatsGroup:Space()

    StatsGroup:Section({
        Title      = "Author",
        TextSize   = 12,
        TextTransparency = 0.5,
    })
    StatsGroup:Section({
        Title      = "AnsonDev",
        TextSize   = 18,
        FontWeight = Enum.FontWeight.Bold,
    })

    StatsGroup:Space()

    StatsGroup:Section({
        Title      = "Game",
        TextSize   = 12,
        TextTransparency = 0.5,
    })
    StatsGroup:Section({
        Title      = "Moped Drag",
        TextSize   = 18,
        FontWeight = Enum.FontWeight.Bold,
    })

    HomeTab:Space({ Columns = 3 })

    -- Discord card
    HomeTab:Paragraph({
        Title   = "Community  &  Support",
        Desc    = "Join the AnsonDev Discord server for updates, bug reports and support.",
        Image   = "message-circle",
        Buttons = {
            {
                Title    = "Join Discord",
                Icon     = "link",
                Callback = function()
                    if setclipboard then
                        setclipboard("https://discord.gg/FBaqTQqutg")
                        notify("Discord", "Invite link copied to clipboard.")
                    end
                end,
            },
        },
    })

    HomeTab:Space({ Columns = 3 })

    -- Quick feature cards
    local FeatGroup1 = HomeTab:Group({})

    local f1 = FeatGroup1:Section({ Title = "Auto Farm", Box = true, BoxBorder = true, Opened = true })
    f1:Section({ Title = "Loop between up to 4 custom points or use preset race track coordinates.", TextSize = 13, TextTransparency = 0.35 })

    FeatGroup1:Space()

    local f2 = FeatGroup1:Section({ Title = "Speed Boost", Box = true, BoxBorder = true, Opened = true })
    f2:Section({ Title = "Multiply moped velocity on the ground. Override MaxSpeed and RPM cap.", TextSize = 13, TextTransparency = 0.35 })

    HomeTab:Space({ Columns = 2 })

    local FeatGroup2 = HomeTab:Group({})

    local f3 = FeatGroup2:Section({ Title = "Player Tools", Box = true, BoxBorder = true, Opened = true })
    f3:Section({ Title = "Walk Speed, Jump Power, Fly, Noclip, God Mode, Infinite Jump.", TextSize = 13, TextTransparency = 0.35 })

    FeatGroup2:Space()

    local f4 = FeatGroup2:Section({ Title = "Misc", Box = true, BoxBorder = true, Opened = true })
    f4:Section({ Title = "Anti AFK, FPS Boost, Rejoin, Server Hop, Teleport to Player.", TextSize = 13, TextTransparency = 0.35 })
end

-- ═══════════════════════════════════════════════════
--  Sections for remaining tabs
-- ═══════════════════════════════════════════════════
local CoreSection  = Window:Section({ Title = "Core"  })
local ExtraSection = Window:Section({ Title = "Extra" })

-- ═══════════════════════════════════════════════════
--  TAB: Auto Farm
-- ═══════════════════════════════════════════════════
do
    local FarmTab = CoreSection:Tab({
        Title = "Auto Farm",
        Icon  = "map-pin",
    })

    -- Points
    local PointSection = FarmTab:Section({
        Title = "Waypoints", Box = true, BoxBorder = true, Opened = true,
    })

    local PointGroup = PointSection:Group({})
    for i = 1, 4 do
        PointGroup:Button({
            Title    = "Save P" .. i,
            Icon     = "map-pin",
            Justify  = "Center",
            Callback = function()
                local vr = getVehicleRoot()
                if not vr then notify("Auto Farm","Sit on the moped first."); return end
                State.farmPoints[i] = vr.Position
                local p = State.farmPoints[i]
                notify("P"..i.." Saved", string.format("X:%.0f  Y:%.0f  Z:%.0f", p.X,p.Y,p.Z))
            end,
        })
        if i < 4 then PointGroup:Space() end
    end

    PointSection:Space()

    PointSection:Button({
        Title    = "Clear All Points",
        Icon     = "trash-2",
        Callback = function()
            State.farmPoints = {}; stopFarm()
            notify("Auto Farm","All points cleared.")
        end,
    })

    FarmTab:Space()

    -- Controls
    local CtrlSection = FarmTab:Section({
        Title = "Farm Control", Box = true, BoxBorder = true, Opened = true,
    })

    CtrlSection:Toggle({
        Title    = "Manual Farm  (P1 → P4 loop)",
        Desc     = "Cycles through all saved waypoints",
        Callback = function(v)
            if v then
                local ok,msg = startFarm(State.farmPoints)
                if not ok then notify("Auto Farm",msg) end
            else stopFarm() end
        end,
    })
    CtrlSection:Space()
    CtrlSection:Toggle({
        Title    = "Full Auto Farm  (Preset)",
        Desc     = "11185, 4, 836   ↔   15777, 4, 836",
        Callback = function(v)
            if v then
                if not getVehicleRoot() then notify("Auto Farm","Sit on the moped first."); return end
                stopFarm()
                startFarm({ Vector3.new(11185,4,836), Vector3.new(15777,4,836) })
            else stopFarm() end
        end,
    })

    FarmTab:Space()

    -- Settings
    local FarmSetSection = FarmTab:Section({
        Title = "Settings", Box = true, BoxBorder = true, Opened = true,
    })

    FarmSetSection:Slider({
        Title = "Farm Speed", Desc = "studs/s",
        Step = 10, Value = { Min=10, Max=1000, Default=150 },
        Callback = function(v) State.farmSpeed = v end,
    })
    FarmSetSection:Space()
    FarmSetSection:Slider({
        Title = "Arrival Distance", Desc = "How close before switching waypoint",
        Step = 1, Value = { Min=3, Max=40, Default=12 },
        Callback = function(v) State.arrivalDist = v end,
    })
    FarmSetSection:Space()
    FarmSetSection:Button({
        Title = "Force Stop", Icon = "square",
        Callback = function() stopFarm(); notify("Auto Farm","Stopped.") end,
    })
end

-- ═══════════════════════════════════════════════════
--  TAB: Speed Boost
-- ═══════════════════════════════════════════════════
do
    local BoostTab = CoreSection:Tab({
        Title = "Speed Boost",
        Icon  = "zap",
    })

    local BoostSection = BoostTab:Section({
        Title = "Velocity Boost", Box = true, BoxBorder = true, Opened = true,
    })

    BoostSection:Section({
        Title = "Multiplies moped velocity while keeping direction.\nPC: hold W   Mobile: use joystick",
        TextSize = 13, TextTransparency = 0.4,
    })
    BoostSection:Space()
    BoostSection:Slider({
        Title = "Speed Multiplier",
        Step = 1, Value = { Min=1, Max=20, Default=2 },
        Callback = function(v) State.boostMulti = v end,
    })
    BoostSection:Space()
    BoostSection:Toggle({
        Title = "Enable Speed Boost",
        Callback = function(v)
            if v then startBoost() else stopBoost() end
        end,
    })

    BoostTab:Space()

    local PhysSection = BoostTab:Section({
        Title = "Physics Override", Box = true, BoxBorder = true, Opened = true,
    })

    PhysSection:Section({
        Title = "Directly patches VehicleSeat MaxSpeed and HingeConstraint torque.\nSit on moped before applying.",
        TextSize = 13, TextTransparency = 0.4,
    })
    PhysSection:Space()
    PhysSection:Slider({
        Title = "Max Speed",
        Step = 10, Value = { Min=50, Max=1000, Default=300 },
        Callback = function(v) State.mopedMaxSpd = v end,
    })
    PhysSection:Space()
    PhysSection:Slider({
        Title = "Max Torque  (RPM cap override)",
        Step = 1000, Value = { Min=1000, Max=500000, Default=50000 },
        Callback = function(v) State.mopedTorque = v end,
    })
    PhysSection:Space()
    PhysSection:Button({
        Title = "Apply to Moped Now", Icon = "wrench",
        Callback = function()
            local ok = overrideMopedPhysics(State.mopedMaxSpd, State.mopedTorque)
            notify(
                ok and "Applied" or "Failed",
                ok and ("MaxSpeed: "..State.mopedMaxSpd.."   Torque: "..State.mopedTorque)
                    or "Sit on the moped first."
            )
        end,
    })
end

-- ═══════════════════════════════════════════════════
--  TAB: Player
-- ═══════════════════════════════════════════════════
do
    local PlayerTab = CoreSection:Tab({
        Title = "Player",
        Icon  = "user",
    })

    local MovSection = PlayerTab:Section({
        Title = "Movement", Box = true, BoxBorder = true, Opened = true,
    })

    MovSection:Slider({
        Title = "Walk Speed", Step=1, Value={Min=8,Max=500,Default=16},
        Callback = function(v)
            State.walkVal = v
            if State.walkEnabled then local h=getHum(); if h then h.WalkSpeed=v end end
        end,
    })
    MovSection:Space()
    MovSection:Toggle({
        Title = "Enable Walk Speed",
        Callback = function(v)
            State.walkEnabled = v
            local h=getHum(); if h then h.WalkSpeed = v and State.walkVal or 16 end
        end,
    })
    MovSection:Space()
    MovSection:Slider({
        Title = "Jump Power", Step=5, Value={Min=0,Max=500,Default=50},
        Callback = function(v)
            State.jumpVal = v
            if State.jumpEnabled then
                local h=getHum(); if h then h.UseJumpPower=true; h.JumpPower=v end
            end
        end,
    })
    MovSection:Space()
    MovSection:Toggle({
        Title = "Enable Jump Power",
        Callback = function(v)
            State.jumpEnabled = v
            local h=getHum()
            if h then h.UseJumpPower=true; h.JumpPower=v and State.jumpVal or 50 end
        end,
    })
    MovSection:Space()
    MovSection:Toggle({
        Title = "Infinite Jump",
        Callback = function(v)
            if v then
                State.infJumpConn = UserInputService.JumpRequest:Connect(function()
                    local h=getHum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
                end)
            else
                if State.infJumpConn then State.infJumpConn:Disconnect(); State.infJumpConn=nil end
            end
        end,
    })

    PlayerTab:Space()

    local AbilSection = PlayerTab:Section({
        Title = "Abilities", Box = true, BoxBorder = true, Opened = true,
    })

    AbilSection:Toggle({
        Title = "God Mode", Desc = "Prevents all damage",
        Callback = function(v)
            State.godOn = v
            if v then
                local h=getHum(); if h then h.MaxHealth=math.huge; h.Health=math.huge end
                State.godConn = RunService.Heartbeat:Connect(function()
                    local h=getHum(); if h then h.Health=h.MaxHealth end
                end)
            else if State.godConn then State.godConn:Disconnect(); State.godConn=nil end end
        end,
    })
    AbilSection:Space()
    AbilSection:Slider({
        Title = "Fly Speed", Step=5, Value={Min=10,Max=500,Default=50},
        Callback = function(v) State.flySpeed = v end,
    })
    AbilSection:Space()
    AbilSection:Toggle({
        Title = "Fly", Desc = "PC: WASD + camera   Mobile: joystick",
        Callback = function(v) if v then startFly() else stopFly() end end,
    })
    AbilSection:Space()
    AbilSection:Toggle({
        Title = "Noclip", Desc = "Walk through walls",
        Callback = function(v) if v then startNoclip() else stopNoclip() end end,
    })

    PlayerTab:Space()

    PlayerTab:Button({
        Title = "Reset Player Stats", Icon = "rotate-ccw",
        Desc  = "Resets WalkSpeed, JumpPower and Health to default",
        Callback = function()
            local h=getHum()
            if h then h.WalkSpeed=16; h.JumpPower=50; h.MaxHealth=100; h.Health=100 end
            notify("Player","Stats reset to default.")
        end,
    })
end

-- ═══════════════════════════════════════════════════
--  TAB: Misc
-- ═══════════════════════════════════════════════════
do
    local MiscTab = ExtraSection:Tab({
        Title = "Misc",
        Icon  = "wrench",
    })

    local UtilSection = MiscTab:Section({
        Title = "Utilities", Box = true, BoxBorder = true, Opened = true,
    })

    UtilSection:Toggle({
        Title = "Anti AFK", Desc = "Fires only on idle event, zero performance cost",
        Callback = function(v)
            if v then
                player.Idled:Connect(function()
                    VirtualUser:Button2Down(Vector2.new(0,0), camera.CFrame)
                    task.wait(0.1)
                    VirtualUser:Button2Up(Vector2.new(0,0), camera.CFrame)
                end)
            end
            notify("Anti AFK", v and "ON" or "OFF")
        end,
    })
    UtilSection:Space()
    UtilSection:Toggle({
        Title = "FPS Boost", Desc = "Disables particles, shadows, lowers render quality",
        Callback = function(v)
            if v then applyFpsBoost() else removeFpsBoost() end
            notify("FPS Boost", v and "ON" or "OFF")
        end,
    })
    UtilSection:Space()
    UtilSection:Toggle({
        Title = "Show FPS Counter", Value = true,
        Callback = function(v) fpsGui.Enabled = v end,
    })

    MiscTab:Space()

    local ServerSection = MiscTab:Section({
        Title = "Server", Box = true, BoxBorder = true, Opened = true,
    })

    local ServerGroup = ServerSection:Group({})
    ServerGroup:Button({
        Title = "Rejoin", Icon = "refresh-cw", Justify = "Center",
        Callback = function()
            notify("Server","Rejoining...")
            task.wait(1); TeleportService:Teleport(game.PlaceId, player)
        end,
    })
    ServerGroup:Space()
    ServerGroup:Button({
        Title = "New Server", Icon = "shuffle", Justify = "Center",
        Callback = function()
            notify("Server","Finding new server...")
            task.wait(1); TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
        end,
    })

    MiscTab:Space()

    local TpSection = MiscTab:Section({
        Title = "Teleport to Player", Box = true, BoxBorder = true, Opened = true,
    })

    local tpTarget = ""
    local function getPlayerNames()
        local n = {}
        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= player then table.insert(n, p.Name) end
        end
        return #n > 0 and n or {"No other players"}
    end

    local tpDrop = TpSection:Dropdown({
        Title = "Select Player", Values = getPlayerNames(),
        Value = nil, AllowNone = true,
        Callback = function(v) tpTarget = v or "" end,
    })

    TpSection:Space()

    local TpGroup = TpSection:Group({})
    TpGroup:Button({
        Title = "Refresh", Icon = "refresh-cw", Justify = "Center",
        Callback = function()
            tpDrop:Refresh(getPlayerNames())
            notify("Teleport","Player list refreshed.")
        end,
    })
    TpGroup:Space()
    TpGroup:Button({
        Title = "Teleport", Icon = "navigation", Justify = "Center",
        Callback = function()
            if tpTarget == "" or tpTarget == "No other players" then
                notify("Teleport","Select a player first."); return
            end
            local t = Players:FindFirstChild(tpTarget)
            if not t or not t.Character then notify("Teleport","Player not found."); return end
            local hrp = getHRP(); if not hrp then return end
            hrp.CFrame = t.Character:GetPrimaryPartCFrame() + Vector3.new(0,3,0)
            notify("Teleport","Teleported to "..tpTarget)
        end,
    })
end

-- ═══════════════════════════════════════════════════
--  TAB: Settings
-- ═══════════════════════════════════════════════════
do
    local SettingsTab = ExtraSection:Tab({
        Title = "Settings",
        Icon  = "settings",
    })

    local UISection = SettingsTab:Section({
        Title = "Interface", Box = true, BoxBorder = true, Opened = true,
    })

    UISection:Keybind({
        Title = "Toggle UI", Desc = "Key to show / hide the window",
        Value = "RightControl",
        Callback = function(v)
            pcall(function() Window:SetToggleKey(Enum.KeyCode[v]) end)
        end,
    })

    SettingsTab:Space()

    SettingsTab:Button({
        Title    = "Destroy UI",
        Desc     = "Completely removes the interface",
        Icon     = "trash-2",
        Color    = Color3.fromHex("#ef4444"),
        Justify  = "Center",
        Callback = function() Window:Destroy() end,
    })
end

-- ═══════════════════════════════════════════════════
--  Respawn restore
-- ═══════════════════════════════════════════════════
player.CharacterAdded:Connect(function(char)
    task.wait(1)
    local hum = char:WaitForChild("Humanoid", 5); if not hum then return end
    if State.walkEnabled   then hum.WalkSpeed = State.walkVal end
    if State.jumpEnabled   then hum.UseJumpPower=true; hum.JumpPower=State.jumpVal end
    if State.flyEnabled    then startFly()    end
    if State.noclipEnabled then startNoclip() end
    if State.boostEnabled  then startBoost()  end
    if State.godOn then
        hum.MaxHealth=math.huge; hum.Health=math.huge
        if State.godConn then State.godConn:Disconnect() end
        State.godConn = RunService.Heartbeat:Connect(function()
            local h=getHum(); if h then h.Health=h.MaxHealth end
        end)
    end
end)

WindUI:Notify({
    Title   = "AnsonDev",
    Content = "Moped Drag v1.0 loaded.",
    Icon    = "bike",
    Duration = 4,
})