local HttpGet = game.HttpGet
local GameId = game.GameId

local Games = loadstring(
    HttpGet(game, "https://raw.githubusercontent.com/ansonchia787/AnsonDevScript/main/gamelist.lua")
)()

local URL = Games[GameId]

if not URL then
    warn("Game not supported:", GameId)
    return
end

loadstring(HttpGet(game, URL))()