-- Remoteloader: fetches auto_treadmill.lua from this repo's raw URL and executes it.
-- Put this in a LocalScript in StarterPlayerScripts (or run in your executor).
local HttpService = game:GetService("HttpService")

-- Raw URL to the remote script in this repo
local scriptUrl = "https://raw.githubusercontent.com/NInekk8899/auto-treadmill-remoteloader/main/auto_treadmill.lua"

local function fetchRaw(url)
    local ok, res = pcall(function()
        if typeof(game.HttpGet) == "function" then
            return game:HttpGet(url, true)
        end
        -- fallback for environments that permit HttpService:GetAsync
        return HttpService:GetAsync(url, true)
    end)
    if not ok then
        return nil, res
    end
    return res
end

local function runRemote(code)
    local loader = loadstring or load
    if not loader then return false, "no loadstring/load available in this environment" end
    local fn, err = loader(code)
    if not fn then return false, "compile error: "..tostring(err) end

    -- Expect the remote file to return a function (safer pattern)
    local ok, returned = pcall(fn)
    if not ok then return false, "runtime error during remote init: "..tostring(returned) end

    if type(returned) == "function" then
        local ok2, err2 = pcall(returned)
        if not ok2 then return false, "error executing remote function: "..tostring(err2) end
    end
    return true
end

-- Main
if not HttpService.HttpEnabled then
    warn("[loader] HttpService.HttpEnabled is false — loader may fail unless enabled.")
end

local code, ferr = fetchRaw(scriptUrl)
if not code then
    warn("[loader] failed to fetch remote script:", ferr)
    return
end

local ok, msg = runRemote(code)
if not ok then
    warn("[loader] remote load error:", msg)
else
    print("[loader] remote script loaded and executed.")
end
