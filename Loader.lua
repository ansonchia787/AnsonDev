--!strict

local function HttpGet(url: string): string
    return game:HttpGet(url)
end

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local GameId = game.PlaceId
local Games = loadstring(
    HttpGet("https://raw.githubusercontent.com/ansonchia787/AnsonDev/main/GameList.lua")
)()

print("Current PlaceId:", GameId)

local URL = Games[GameId]

-- 高级通知
local function AdvancedNotify(title: string, text: string)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AdvancedNotify"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 320, 0, 90)
    Frame.Position = UDim2.new(1, 350, 1, -120) -- 从右边外面滑入
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner", Frame)
    UICorner.CornerRadius = UDim.new(0, 14)

    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.Color = Color3.fromRGB(170, 100, 255)
    Stroke.Thickness = 1.5

    -- 渐变背景
    local Gradient = Instance.new("UIGradient", Frame)
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 20, 70)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
    }
    Gradient.Rotation = 45

    -- 发光效果
    local Glow = Instance.new("ImageLabel")
    Glow.Size = UDim2.new(1, 30, 1, 30)
    Glow.Position = UDim2.new(0, -15, 0, -15)
    Glow.BackgroundTransparency = 1
    Glow.Image = "rbxassetid://5028857084"
    Glow.ImageColor3 = Color3.fromRGB(170, 100, 255)
    Glow.ImageTransparency = 0.7
    Glow.ZIndex = 0
    Glow.Parent = Frame

    -- 标题
    local Title = Instance.new("TextLabel")
    Title.Text = title
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextColor3 = Color3.fromRGB(255,255,255)
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 15, 0, 10)
    Title.Size = UDim2.new(1, -20, 0, 20)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Frame

    -- 内容
    local Desc = Instance.new("TextLabel")
    Desc.Text = text
    Desc.Font = Enum.Font.Gotham
    Desc.TextSize = 14
    Desc.TextColor3 = Color3.fromRGB(200,200,200)
    Desc.BackgroundTransparency = 1
    Desc.Position = UDim2.new(0, 15, 0, 35)
    Desc.Size = UDim2.new(1, -20, 0, 40)
    Desc.TextWrapped = true
    Desc.TextXAlignment = Enum.TextXAlignment.Left
    Desc.Parent = Frame

    -- 进度条
    local BarBG = Instance.new("Frame")
    BarBG.Size = UDim2.new(1, 0, 0, 3)
    BarBG.Position = UDim2.new(0, 0, 1, -3)
    BarBG.BackgroundColor3 = Color3.fromRGB(60,60,80)
    BarBG.BorderSizePixel = 0
    BarBG.Parent = Frame

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, 0, 1, 0)
    Bar.BackgroundColor3 = Color3.fromRGB(170,100,255)
    Bar.BorderSizePixel = 0
    Bar.Parent = BarBG

    -- 滑入
    TweenService:Create(Frame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
        Position = UDim2.new(1, -340, 1, -120)
    }):Play()

    -- 进度条减少
    TweenService:Create(Bar, TweenInfo.new(3, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 1, 0)
    }):Play()

    task.wait(3)

    -- 淡出 + 滑出
    TweenService:Create(Frame, TweenInfo.new(0.5), {
        Position = UDim2.new(1, 350, 1, -120),
        BackgroundTransparency = 1
    }):Play()

    TweenService:Create(Title, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
    TweenService:Create(Desc, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
    TweenService:Create(Stroke, TweenInfo.new(0.4), {Transparency = 1}):Play()

    task.wait(0.6)
    ScreenGui:Destroy()
end

-- 没有脚本 → 弹高级通知
if not URL then
    AdvancedNotify(
        "Unsupported Game",
        "This game is not supported\nPlaceId: " .. tostring(GameId)
    )
    return
end

-- 有脚本 → 正常加载
local success, err = pcall(function()
    loadstring(HttpGet(URL))()
end)

if not success then
    warn("Load Error:", err)
end
