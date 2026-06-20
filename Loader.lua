--!strict

local function HttpGet(url: string): string
    return game:HttpGet(url)
end

local GameId = game.PlaceId
local Games = loadstring(
    HttpGet("https://raw.githubusercontent.com/ansonchia787/AnsonDev/main/GameList.lua")
)()

print("Current PlaceId:", GameId)

local URL = Games[GameId]

-- 没有脚本 → 显示 UI
if not URL then
    local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

    local Window = Rayfield:CreateWindow({
        Name = "Script Loader",
        LoadingTitle = "Checking Game...",
        LoadingSubtitle = "by You",
        ConfigurationSaving = {
            Enabled = false
        },
        Discord = {
            Enabled = false
        },
        KeySystem = false,
    })

    local Tab = Window:CreateTab("Status", 4483362458)

    Tab:CreateParagraph({
        Title = "Unsupported Game",
        Content = "This game is not supported yet.\nPlaceId: " .. tostring(GameId)
    })

    Tab:CreateButton({
        Name = "Copy PlaceId",
        Callback = function()
            setclipboard(tostring(GameId))
        end,
    })

    return
end

-- 有脚本 → 正常加载
local success, err = pcall(function()
    loadstring(HttpGet(URL))()
end)

if not success then
    warn("Load Error:", err)
end
