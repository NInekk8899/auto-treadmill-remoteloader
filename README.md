# auto-treadmill-remoteloader

This repository contains:
- auto_treadmill.lua — game logic; returns a function that runs the auto-walk + anti-AFK code.
- loader.lua — a LocalScript that fetches the raw auto_treadmill.lua and executes it.

Usage:
1. Place `loader.lua` (or an adapted one-liner) inside `StarterPlayerScripts` as a LocalScript, or run it through your executor.
2. If using a one-liner in an executor, use the raw URL:

   loadstring(game:HttpGet("https://raw.githubusercontent.com/NInekk8899/auto-treadmill-remoteloader/main/auto_treadmill.lua"))()()

Notes:
- The remote file returns a function, so the extra `()` after the chunk call is required.
- Standard Roblox Studio blocks `loadstring` and direct `HttpGet` in normal LocalScripts — these one-liners only work in environments/executors that expose `loadstring` and `game:HttpGet` or allow `HttpService:GetAsync`.
- Only load remote code you trust.
