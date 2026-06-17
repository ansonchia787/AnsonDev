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

if not URL then
    warn("No script for this game")
    return
end

local success, err = pcall(function()
    loadstring(HttpGet(URL))()
end)

if not success then
    warn("Load Error:", err)
end
