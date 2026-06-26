local function AdvancedNotify(title: string, text: string)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AdvancedNotify"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 340, 0, 110)
    Frame.Position = UDim2.new(1, 360, 1, -130)
    Frame.BackgroundColor3 = Color3.fromRGB(14, 10, 26)
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true
    Frame.Parent = ScreenGui

    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 16)

    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.Color = Color3.fromRGB(140, 60, 240)
    Stroke.Thickness = 1
    Stroke.Transparency = 0.55

    local GlowBar = Instance.new("Frame")
    GlowBar.Size = UDim2.new(1, 0, 0, 2)
    GlowBar.Position = UDim2.new(0, 0, 0, 0)
    GlowBar.BackgroundColor3 = Color3.fromRGB(160, 70, 255)
    GlowBar.BorderSizePixel = 0
    GlowBar.ZIndex = 3
    GlowBar.Parent = Frame

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 7, 0, 7)
    Dot.Position = UDim2.new(1, -18, 0, 14)
    Dot.BackgroundColor3 = Color3.fromRGB(160, 70, 255)
    Dot.BorderSizePixel = 0
    Dot.ZIndex = 4
    Dot.Parent = Frame
    Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

    local IconBG = Instance.new("Frame")
    IconBG.Size = UDim2.new(0, 38, 0, 38)
    IconBG.Position = UDim2.new(0, 16, 0, 18)
    IconBG.BackgroundColor3 = Color3.fromRGB(80, 30, 160)
    IconBG.BackgroundTransparency = 0.75
    IconBG.BorderSizePixel = 0
    IconBG.ZIndex = 2
    IconBG.Parent = Frame
    Instance.new("UICorner", IconBG).CornerRadius = UDim.new(0, 10)

    local IconStroke = Instance.new("UIStroke", IconBG)
    IconStroke.Color = Color3.fromRGB(160, 70, 255)
    IconStroke.Thickness = 1
    IconStroke.Transparency = 0.6

    local Icon = Instance.new("TextLabel")
    Icon.Text = "!"
    Icon.Font = Enum.Font.GothamBold
    Icon.TextSize = 20
    Icon.TextColor3 = Color3.fromRGB(160, 70, 255)
    Icon.BackgroundTransparency = 1
    Icon.Size = UDim2.new(1, 0, 1, 0)
    Icon.TextXAlignment = Enum.TextXAlignment.Center
    Icon.TextYAlignment = Enum.TextYAlignment.Center
    Icon.ZIndex = 3
    Icon.Parent = IconBG

    local Title = Instance.new("TextLabel")
    Title.Text = title
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextColor3 = Color3.fromRGB(232, 220, 255)
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 66, 0, 16)
    Title.Size = UDim2.new(1, -90, 0, 18)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 2
    Title.Parent = Frame

    local Desc = Instance.new("TextLabel")
    Desc.Text = text
    Desc.Font = Enum.Font.Gotham
    Desc.TextSize = 12
    Desc.TextColor3 = Color3.fromRGB(148, 136, 180)
    Desc.BackgroundTransparency = 1
    Desc.Position = UDim2.new(0, 66, 0, 36)
    Desc.Size = UDim2.new(1, -80, 0, 30)
    Desc.TextWrapped = true
    Desc.TextXAlignment = Enum.TextXAlignment.Left
    Desc.ZIndex = 2
    Desc.Parent = Frame

    local PillBG = Instance.new("Frame")
    PillBG.Size = UDim2.new(0, 0, 0, 18)
    PillBG.Position = UDim2.new(0, 66, 0, 68)
    PillBG.BackgroundColor3 = Color3.fromRGB(100, 40, 200)
    PillBG.BackgroundTransparency = 0.82
    PillBG.BorderSizePixel = 0
    PillBG.AutomaticSize = Enum.AutomaticSize.X
    PillBG.ZIndex = 2
    PillBG.Parent = Frame
    Instance.new("UICorner", PillBG).CornerRadius = UDim.new(0, 5)

    local PillStroke = Instance.new("UIStroke", PillBG)
    PillStroke.Color = Color3.fromRGB(140, 60, 240)
    PillStroke.Thickness = 1
    PillStroke.Transparency = 0.65

    local PillPad = Instance.new("UIPadding", PillBG)
    PillPad.PaddingLeft = UDim.new(0, 7)
    PillPad.PaddingRight = UDim.new(0, 7)

    local PillText = Instance.new("TextLabel")
    PillText.Text = "PlaceId: " .. tostring(GameId)
    PillText.Font = Enum.Font.Code
    PillText.TextSize = 10
    PillText.TextColor3 = Color3.fromRGB(180, 100, 255)
    PillText.BackgroundTransparency = 1
    PillText.Size = UDim2.new(0, 0, 1, 0)
    PillText.AutomaticSize = Enum.AutomaticSize.X
    PillText.TextXAlignment = Enum.TextXAlignment.Left
    PillText.ZIndex = 3
    PillText.Parent = PillBG

    local BarBG = Instance.new("Frame")
    BarBG.Size = UDim2.new(1, -36, 0, 3)
    BarBG.Position = UDim2.new(0, 18, 1, -14)
    BarBG.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BarBG.BackgroundTransparency = 0.93
    BarBG.BorderSizePixel = 0
    BarBG.ZIndex = 2
    BarBG.Parent = Frame
    Instance.new("UICorner", BarBG).CornerRadius = UDim.new(1, 0)

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, 0, 1, 0)
    Bar.BackgroundColor3 = Color3.fromRGB(160, 70, 255)
    Bar.BorderSizePixel = 0
    Bar.ZIndex = 3
    Bar.Parent = BarBG
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

    TweenService:Create(Frame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -360, 1, -130)
    }):Play()

    TweenService:Create(Bar, TweenInfo.new(3, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 1, 0)
    }):Play()

    local function pulseDot()
        while Dot.Parent do
            TweenService:Create(Dot, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = 0.8
            }):Play()
            task.wait(0.9)
            TweenService:Create(Dot, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = 0
            }):Play()
            task.wait(0.9)
        end
    end
    task.spawn(pulseDot)

    task.wait(3)

    local fadeOut = TweenInfo.new(0.45, Enum.EasingStyle.Quint)
    TweenService:Create(Frame, fadeOut, {
        Position = UDim2.new(1, 360, 1, -130),
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(Stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
    for _, lbl in ipairs({Title, Desc, PillText, Icon}) do
        TweenService:Create(lbl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    end

    task.wait(0.5)
    ScreenGui:Destroy()
end
