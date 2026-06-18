--[[
    AnsonDev - Merge a Nuke
    Version : 1.0.0
    Author  : AnsonDev
    UI      : WindUI
]]

local WindUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
))()

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerId    = tonumber(LocalPlayer.UserId)

-- ═══════════════════════════════════════════════════
--  State
-- ═══════════════════════════════════════════════════
local S = {
    AutoMerge        = false,
    AutoPickUp       = false,
    AutoLock         = false,
    AutoUpgrade      = false,
    SelectedUpgrades = {},

    WalkEnabled  = false,
    WalkVal      = 16,
    JumpEnabled  = false,
    JumpVal      = 50,
    InfJump      = false,

    FlyEnabled   = false,
    FlySpeed     = 50,
    FlyConn      = nil,

    NoclipEnabled = false,
    NoclipConn    = nil,

    EspEnabled   = false,
    EspConns     = {},
    EspFolder    = Workspace:FindFirstChild("AnsonDevESP") or Instance.new("Folder", Workspace),
}
S.EspFolder.Name = "AnsonDevESP"

-- ═══════════════════════════════════════════════════
--  Helpers
-- ═══════════════════════════════════════════════════
local function getChar()  return LocalPlayer.Character end
local function getHRP()   local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()   local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid") end

local function getPlayerBase()
    local bases = Workspace:FindFirstChild("Bases"); if not bases then return nil end
    for _, f in ipairs(bases:GetChildren()) do
        local a = f:GetAttribute("OwnerUserId")
        if a and tonumber(a) == PlayerId then return f end
    end
end

local function teleportTo(obj)
    if not obj or not getChar() then return end
    local root = getHRP(); local pos
    if obj:IsA("Model")    then pos = obj:GetPivot().Position
    elseif obj:IsA("BasePart") then pos = obj.Position end
    if root and pos then root.CFrame = CFrame.new(pos + Vector3.new(0,2,0)) end
end

local function notify(title, content)
    WindUI:Notify({ Title = title, Content = content or "", Duration = 3 })
end

-- ═══════════════════════════════════════════════════
--  RenderStepped enforcement
-- ═══════════════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    local hum = getHum(); if not hum then return end
    if S.WalkEnabled and hum.WalkSpeed ~= S.WalkVal then hum.WalkSpeed = S.WalkVal end
    if S.JumpEnabled then
        if not hum.UseJumpPower then hum.UseJumpPower = true end
        if hum.JumpPower ~= S.JumpVal then hum.JumpPower = S.JumpVal end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if S.InfJump then
        local hum = getHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ═══════════════════════════════════════════════════
--  Fly
-- ═══════════════════════════════════════════════════
local function stopFly()
    S.FlyEnabled = false
    if S.FlyConn then S.FlyConn:Disconnect(); S.FlyConn = nil end
    local root = getHRP(); local hum = getHum()
    if root then
        local bv = root:FindFirstChild("AnsonFlyForce"); if bv then bv:Destroy() end
        local bg = root:FindFirstChild("AnsonFlyGyro");  if bg then bg:Destroy() end
    end
    if hum then hum.PlatformStand = false end
end

local function startFly()
    S.FlyEnabled = true
    local cam = Workspace.CurrentCamera
    local root = getHRP(); local hum = getHum()
    if not root or not hum then return end
    local bv = root:FindFirstChild("AnsonFlyForce") or Instance.new("BodyVelocity")
    bv.Name = "AnsonFlyForce"; bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge); bv.Parent = root
    local bg = root:FindFirstChild("AnsonFlyGyro") or Instance.new("BodyGyro")
    bg.Name = "AnsonFlyGyro"; bg.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
    bg.CFrame = root.CFrame; bg.Parent = root
    hum.PlatformStand = true
    S.FlyConn = RunService.RenderStepped:Connect(function()
        if not S.FlyEnabled or not root.Parent then stopFly(); return end
        local dir = Vector3.zero; local cf = cam.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W)         then dir = dir + cf.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.S)         then dir = dir - cf.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.A)         then dir = dir - cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D)         then dir = dir + cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)     then dir = dir + Vector3.yAxis  end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.yAxis  end
        local hm = getHum()
        if hm and hm.MoveDirection.Magnitude > 0.1 then dir = dir + hm.MoveDirection end
        bv.Velocity = dir.Magnitude > 0 and dir.Unit * S.FlySpeed or Vector3.zero
        bg.CFrame   = cf
    end)
end

-- ═══════════════════════════════════════════════════
--  Noclip
-- ═══════════════════════════════════════════════════
local function stopNoclip()
    S.NoclipEnabled = false
    if S.NoclipConn then S.NoclipConn:Disconnect(); S.NoclipConn = nil end
    local c = getChar()
    if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end end
end
local function startNoclip()
    S.NoclipEnabled = true
    S.NoclipConn = RunService.Stepped:Connect(function()
        if not S.NoclipEnabled then stopNoclip(); return end
        local c = getChar(); if not c then return end
        for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
    end)
end

-- ═══════════════════════════════════════════════════
--  ESP
-- ═══════════════════════════════════════════════════
local function cleanESP(plr)
    if S.EspConns[plr] then
        for _,c in ipairs(S.EspConns[plr]) do c:Disconnect() end
        S.EspConns[plr] = nil
    end
    local cont = S.EspFolder:FindFirstChild(plr.Name)
    if cont then cont:Destroy() end
end
local function buildESP(plr)
    if plr == LocalPlayer then return end
    cleanESP(plr); S.EspConns[plr] = {}
    local cont = Instance.new("Folder"); cont.Name = plr.Name; cont.Parent = S.EspFolder
    local function makeTag(char)
        if not char then return end
        local root = char:WaitForChild("HumanoidRootPart",5); if not root then return end
        local bb = Instance.new("BillboardGui")
        bb.AlwaysOnTop = true; bb.Size = UDim2.new(0,200,0,50)
        bb.StudsOffset = Vector3.new(0,3,0); bb.Adornee = root; bb.Parent = cont
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1
        lbl.Text = plr.Name; lbl.TextColor3 = Color3.fromRGB(255,60,60)
        lbl.TextSize = 14; lbl.Font = Enum.Font.GothamBold
        lbl.TextStrokeTransparency = 0; lbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
        lbl.Parent = bb
    end
    if plr.Character then makeTag(plr.Character) end
    local conn = plr.CharacterAdded:Connect(function(c) task.wait(0.5); makeTag(c) end)
    table.insert(S.EspConns[plr], conn)
end

-- ═══════════════════════════════════════════════════
--  Window
-- ═══════════════════════════════════════════════════
local Window = WindUI:CreateWindow({
    Title   = "AnsonDev  |  Merge a Nuke",
    Folder  = "AnsonDev",
    Icon    = "zap",
    NewElements = true,
    Topbar  = { Height = 48, ButtonsType = "Mac" },
    OpenButton = {
        Title           = "AnsonDev",
        CornerRadius    = UDim.new(1,0),
        StrokeThickness = 2,
        Enabled         = true,
        Draggable       = true,
        OnlyMobile      = false,
        Scale           = 0.55,
        Color = ColorSequence.new(
            Color3.fromHex("#F7514F"),
            Color3.fromHex("#F59B1E")
        ),
    },
})

Window:Tag({ Title = "v1.0.0",       Icon = "sparkles", Color = Color3.fromHex("#18181b"), Border = true })
Window:Tag({ Title = "Merge a Nuke", Icon = "zap",      Color = Color3.fromHex("#1e1e2e"), Border = true })

-- ★ 一个 Section 包含全部 Tab，Home 第一个 ★
local AllSection = Window:Section({ Title = "AnsonDev" })

-- ═══════════════════════════════════════════════════
--  TAB 1 : Home  ← 第一个加入，排最顶
-- ═══════════════════════════════════════════════════
do
    local HomeTab = AllSection:Tab({ Title = "Home", Icon = "house" })

    local Hero = HomeTab:Section({ Title = "AnsonDev  |  Merge a Nuke" })
    Hero:Section({
        Title = "Welcome back, " .. LocalPlayer.Name,
        TextSize = 24, FontWeight = Enum.FontWeight.Bold,
    })
    Hero:Space()
    Hero:Section({
        Title = "Automate merging, upgrading and managing your nukes.\nAuto Merge  •  Auto Pick Up  •  Auto Upgrade  •  Player Tools",
        TextSize = 15, TextTransparency = 0.35, FontWeight = Enum.FontWeight.Medium,
    })

    HomeTab:Space({ Columns = 3 })

    local StatsGroup = HomeTab:Group({})
    StatsGroup:Section({ Title = "Version",      TextSize = 12, TextTransparency = 0.5 })
    StatsGroup:Section({ Title = "1.0.0",        TextSize = 18, FontWeight = Enum.FontWeight.Bold })
    StatsGroup:Space()
    StatsGroup:Section({ Title = "Author",       TextSize = 12, TextTransparency = 0.5 })
    StatsGroup:Section({ Title = "AnsonDev",     TextSize = 18, FontWeight = Enum.FontWeight.Bold })
    StatsGroup:Space()
    StatsGroup:Section({ Title = "Game",         TextSize = 12, TextTransparency = 0.5 })
    StatsGroup:Section({ Title = "Merge a Nuke", TextSize = 18, FontWeight = Enum.FontWeight.Bold })

    HomeTab:Space({ Columns = 3 })

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

    local FeatGroup1 = HomeTab:Group({})
    local f1 = FeatGroup1:Section({ Title = "Auto Merge", Box = true, BoxBorder = true, Opened = true })
    f1:Section({ Title = "Automatically detects and merges matching nukes in your base.", TextSize = 13, TextTransparency = 0.35 })
    FeatGroup1:Space()
    local f2 = FeatGroup1:Section({ Title = "Auto Upgrade", Box = true, BoxBorder = true, Opened = true })
    f2:Section({ Title = "Continuously fires selected upgrade types (MAX / TIER / LOCKBASE).", TextSize = 13, TextTransparency = 0.35 })

    HomeTab:Space({ Columns = 2 })

    local FeatGroup2 = HomeTab:Group({})
    local f3 = FeatGroup2:Section({ Title = "Auto Pick Up", Box = true, BoxBorder = true, Opened = true })
    f3:Section({ Title = "Teleports to each nuke, picks it up, drops singles back.", TextSize = 13, TextTransparency = 0.35 })
    FeatGroup2:Space()
    local f4 = FeatGroup2:Section({ Title = "Player Tools", Box = true, BoxBorder = true, Opened = true })
    f4:Section({ Title = "Fly, Noclip, Walk Speed, Jump Power, ESP and more.", TextSize = 13, TextTransparency = 0.35 })
end

-- ═══════════════════════════════════════════════════
--  TAB 2 : Main
-- ═══════════════════════════════════════════════════
do
    local MainTab = AllSection:Tab({ Title = "Main", Icon = "zap" })

    local AutoSection = MainTab:Section({ Title = "Nuke Automation", Box = true, BoxBorder = true, Opened = true })

    AutoSection:Toggle({
        Title = "Auto Merge",
        Desc  = "Automatically merges matching nukes in your base",
        Callback = function(v)
            S.AutoMerge = v
            if not v then return end
            task.spawn(function()
                while S.AutoMerge do
                    local base = getPlayerBase()
                    if base and base:FindFirstChild("Nukes") then
                        local counts = {}
                        for _, nuke in ipairs(base.Nukes:GetChildren()) do
                            if nuke.Name == "Nuke"
                                and nuke:FindFirstChild("OverheadNuke")
                                and nuke.OverheadNuke:FindFirstChild("TextLabel") then
                                local t = nuke.OverheadNuke.TextLabel.Text
                                if t and t ~= "" then
                                    counts[t] = counts[t] or {}
                                    table.insert(counts[t], nuke)
                                end
                            end
                        end
                        for _, matches in pairs(counts) do
                            if #matches >= 2 then
                                ReplicatedStorage.NukeRemotes.PickUp:FireServer(matches[1])
                                task.wait()
                                ReplicatedStorage.NukeRemotes.MergeRequest:FireServer(matches[2])
                                break
                            end
                        end
                    end
                    task.wait()
                end
            end)
        end,
    })

    AutoSection:Space()

    AutoSection:Toggle({
        Title = "Auto Pick Up All",
        Desc  = "Teleports to each nuke, picks up, drops singles back",
        Callback = function(v)
            S.AutoPickUp = v
            if not v then return end
            task.spawn(function()
                while S.AutoPickUp do
                    local base = getPlayerBase()
                    if base and base:FindFirstChild("Nukes") then
                        local counts = {}
                        for _, nuke in ipairs(base.Nukes:GetChildren()) do
                            if nuke.Name == "Nuke"
                                and nuke:FindFirstChild("OverheadNuke")
                                and nuke.OverheadNuke:FindFirstChild("TextLabel") then
                                local t = nuke.OverheadNuke.TextLabel.Text
                                if t and t ~= "" then
                                    counts[t] = counts[t] or {}
                                    table.insert(counts[t], nuke)
                                end
                            end
                        end
                        for _, nuke in ipairs(base.Nukes:GetChildren()) do
                            if not S.AutoPickUp then break end
                            if nuke.Name == "Nuke"
                                and nuke:FindFirstChild("OverheadNuke")
                                and nuke.OverheadNuke:FindFirstChild("TextLabel") then
                                local t  = nuke.OverheadNuke.TextLabel.Text
                                local mc = counts[t] and #counts[t] or 0
                                local root   = getHRP()
                                local origCF = root and root.CFrame
                                teleportTo(nuke)
                                task.wait()
                                ReplicatedStorage.NukeRemotes.PickUp:FireServer(nuke)
                                task.wait()
                                if mc < 2 then
                                    local drop = ReplicatedStorage.NukeRemotes.Drop
                                    if root then drop:FireServer(root.CFrame)
                                    else drop:FireServer(CFrame.new(290.03,17.20,249.74)) end
                                    task.wait()
                                end
                                if root and origCF then root.CFrame = origCF end
                            end
                        end
                    end
                    task.wait()
                end
            end)
        end,
    })

    AutoSection:Space()

    AutoSection:Toggle({
        Title = "Auto Lock Base",
        Desc  = "Continuously fires the lock base event",
        Callback = function(v)
            S.AutoLock = v
            if not v then return end
            task.spawn(function()
                while S.AutoLock do
                    task.wait()
                    ReplicatedStorage.NukeRemotes.RequestLockBase:FireServer()
                end
            end)
        end,
    })

    MainTab:Space()

    local UpgradeSection = MainTab:Section({ Title = "Upgrade", Box = true, BoxBorder = true, Opened = true })

    UpgradeSection:Dropdown({
        Title    = "Select Upgrade Types",
        Desc     = "Choose which upgrades to fire (multi-select)",
        Values   = { "MAX", "TIER", "LOCKBASE" },
        Multi    = true,
        Value    = nil,
        AllowNone = true,
        Callback = function(v)
            S.SelectedUpgrades = {}
            if type(v) == "table" then
                for _,val in ipairs(v) do table.insert(S.SelectedUpgrades, val) end
            elseif v then
                table.insert(S.SelectedUpgrades, v)
            end
        end,
    })

    UpgradeSection:Space()

    UpgradeSection:Toggle({
        Title = "Auto Upgrade",
        Desc  = "Fires selected upgrade events continuously",
        Callback = function(v)
            S.AutoUpgrade = v
            if not v then return end
            task.spawn(function()
                while S.AutoUpgrade do
                    for _, utype in ipairs(S.SelectedUpgrades) do
                        if not S.AutoUpgrade then break end
                        ReplicatedStorage.NukeRemotes.PurchaseUpgrade:FireServer(utype)
                    end
                    task.wait()
                end
            end)
        end,
    })

    MainTab:Space()

    local TpSection = MainTab:Section({ Title = "Teleport", Box = true, BoxBorder = true, Opened = true })

    local TpGroup = TpSection:Group({})
    TpGroup:Button({
        Title = "To Spawn", Icon = "home", Justify = "Center",
        Callback = function()
            local root = getHRP(); if not root then return end
            local spawn = Workspace:FindFirstChildOfClass("SpawnLocation")
            if spawn then root.CFrame = CFrame.new(spawn.Position + Vector3.new(0,5,0)) end
        end,
    })
    TpGroup:Space()
    TpGroup:Button({
        Title = "To My Base", Icon = "map-pin", Justify = "Center",
        Callback = function()
            local base = getPlayerBase()
            if base then teleportTo(base)
            else notify("Teleport","Could not find your base.") end
        end,
    })
end

-- ═══════════════════════════════════════════════════
--  TAB 3 : Player
-- ═══════════════════════════════════════════════════
do
    local PlayerTab = AllSection:Tab({ Title = "Player", Icon = "user" })

    local MovSection = PlayerTab:Section({ Title = "Movement", Box = true, BoxBorder = true, Opened = true })

    MovSection:Slider({
        Title = "Walk Speed", Step = 1, Value = { Min=16, Max=500, Default=16 },
        Callback = function(v)
            S.WalkVal = v
            if S.WalkEnabled then local h=getHum(); if h then h.WalkSpeed=v end end
        end,
    })
    MovSection:Space()
    MovSection:Toggle({
        Title = "Enable Walk Speed",
        Callback = function(v)
            S.WalkEnabled = v
            local h = getHum(); if h then h.WalkSpeed = v and S.WalkVal or 16 end
        end,
    })
    MovSection:Space()
    MovSection:Slider({
        Title = "Jump Power", Step = 5, Value = { Min=50, Max=1000, Default=50 },
        Callback = function(v)
            S.JumpVal = v
            if S.JumpEnabled then local h=getHum(); if h then h.UseJumpPower=true; h.JumpPower=v end end
        end,
    })
    MovSection:Space()
    MovSection:Toggle({
        Title = "Enable Jump Power",
        Callback = function(v)
            S.JumpEnabled = v
            local h = getHum()
            if h then h.UseJumpPower=true; h.JumpPower = v and S.JumpVal or 50 end
        end,
    })
    MovSection:Space()
    MovSection:Toggle({
        Title = "Infinite Jump",
        Callback = function(v) S.InfJump = v end,
    })

    PlayerTab:Space()

    local AdvSection = PlayerTab:Section({ Title = "Advanced Movement", Box = true, BoxBorder = true, Opened = true })

    AdvSection:Slider({
        Title = "Fly Speed", Step = 5, Value = { Min=10, Max=500, Default=50 },
        Callback = function(v) S.FlySpeed = v end,
    })
    AdvSection:Space()
    AdvSection:Toggle({
        Title = "Fly", Desc = "PC: WASD + Space / Shift   Mobile: joystick",
        Callback = function(v) if v then startFly() else stopFly() end end,
    })
    AdvSection:Space()
    AdvSection:Toggle({
        Title = "Noclip", Desc = "Walk through walls",
        Callback = function(v) if v then startNoclip() else stopNoclip() end end,
    })

    PlayerTab:Space()

    local VisSection = PlayerTab:Section({ Title = "Visuals", Box = true, BoxBorder = true, Opened = true })

    VisSection:Toggle({
        Title = "Player ESP", Desc = "Shows player names above their heads",
        Callback = function(v)
            S.EspEnabled = v
            if v then
                for _,p in ipairs(Players:GetPlayers()) do buildESP(p) end
                S.EspAddConn = Players.PlayerAdded:Connect(buildESP)
                S.EspRemConn = Players.PlayerRemoving:Connect(cleanESP)
            else
                if S.EspAddConn then S.EspAddConn:Disconnect() end
                if S.EspRemConn then S.EspRemConn:Disconnect() end
                for _,p in ipairs(Players:GetPlayers()) do cleanESP(p) end
            end
        end,
    })

    PlayerTab:Space()

    PlayerTab:Button({
        Title = "Reset Player Stats", Icon = "rotate-ccw",
        Desc  = "Resets WalkSpeed and JumpPower to default",
        Callback = function()
            local h = getHum()
            if h then h.WalkSpeed=16; h.UseJumpPower=true; h.JumpPower=50 end
            notify("Player","Stats reset to default.")
        end,
    })
end

-- ═══════════════════════════════════════════════════
--  TAB 4 : Misc
-- ═══════════════════════════════════════════════════
do
    local MiscTab = AllSection:Tab({ Title = "Misc", Icon = "wrench" })

    local UtilSection = MiscTab:Section({ Title = "Utilities", Box = true, BoxBorder = true, Opened = true })

    UtilSection:Toggle({
        Title = "Anti AFK", Desc = "Fires on idle event only, zero performance cost",
        Callback = function(v)
            if v then
                local VU = game:GetService("VirtualUser")
                LocalPlayer.Idled:Connect(function()
                    VU:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
                    task.wait(0.1)
                    VU:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
                end)
            end
            notify("Anti AFK", v and "ON" or "OFF")
        end,
    })
end

-- ═══════════════════════════════════════════════════
--  TAB 5 : Settings
-- ═══════════════════════════════════════════════════
do
    local SettingsTab = AllSection:Tab({ Title = "Settings", Icon = "settings" })

    local UISection = SettingsTab:Section({ Title = "Interface", Box = true, BoxBorder = true, Opened = true })

    UISection:Keybind({
        Title = "Toggle UI", Desc = "Key to show / hide the window",
        Value = "RightAlt",
        Callback = function(v)
            pcall(function() Window:SetToggleKey(Enum.KeyCode[v]) end)
        end,
    })

    SettingsTab:Space()

    local CredSection = SettingsTab:Section({ Title = "Credits", Box = true, BoxBorder = true, Opened = true })
    CredSection:Section({
        Title = "Made by AnsonDev\ndiscord.gg/FBaqTQqutg",
        TextSize = 14, TextTransparency = 0.3,
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
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local hum = char:WaitForChild("Humanoid",5); if not hum then return end
    if S.WalkEnabled  then hum.WalkSpeed = S.WalkVal end
    if S.JumpEnabled  then hum.UseJumpPower=true; hum.JumpPower=S.JumpVal end
    if S.FlyEnabled   then startFly()    end
    if S.NoclipEnabled then startNoclip() end
end)

WindUI:Notify({
    Title   = "AnsonDev",
    Content = "Merge a Nuke v1.0 loaded.",
    Icon    = "zap",
    Duration = 4,
})
