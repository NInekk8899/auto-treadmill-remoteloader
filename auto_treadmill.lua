-- Auto-Walk to Treadmill + Anti-AFK — Steal an Egg
-- This file is intended to be hosted raw on GitHub and loaded by loader.lua.
return function()
  repeat task.wait() until game:IsLoaded()
  task.wait(3)

  local Log = {}
  local PREFIX = "[AutoWalk] "
  local function _out(lvl, msg) print(PREFIX.."["..lvl.."] "..tostring(msg)) end
  function Log.info(m)  _out("INFO",  m) end
  function Log.warn(m)  _out("WARN",  m) end
  function Log.error(m) _out("ERROR", m) end

  local cref        = (cloneref or function(x) return x end)
  local Players     = cref(game:GetService("Players"))
  local VirtualUser = cref(game:GetService("VirtualUser"))
  local LocalPlayer = Players.LocalPlayer

  -- FIND MY PLOT
  local function findMyPlot()
      local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
      local hrp  = char:WaitForChild("HumanoidRootPart")
      local plots = workspace:FindFirstChild("Plots")
      if not plots then Log.error("Plots folder not found!") return nil end

      local closestPlot, closestDist = nil, math.huge
      for _, plot in ipairs(plots:GetChildren()) do
          local sp = plot:FindFirstChild("SpawnPoint")
          if sp then
              local dist = (hrp.Position - sp.Position).Magnitude
              if dist < closestDist then
                  closestDist = dist
                  closestPlot = plot
              end
          end
      end
      if closestPlot then
          Log.info("Plot detected: " .. closestPlot.Name .. " (dist: " .. math.floor(closestDist) .. ")")
      end
      return closestPlot
  end

  -- WALK TO TREADMILL
  local function walkToTreadmill()
      local char     = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
      local hrp      = char:WaitForChild("HumanoidRootPart")
      local humanoid = char:WaitForChild("Humanoid")
      local myPlot   = findMyPlot()
      if not myPlot then return false end

      local treadmill = myPlot:FindFirstChild("TreadmillBottom")
      if not treadmill then
          Log.error("TreadmillBottom not found in plot " .. myPlot.Name)
          return false
      end

      local target = treadmill.Position + Vector3.new(0, 3, 0)
      Log.info("Walking to treadmill at plot " .. myPlot.Name .. "...")
      humanoid:MoveTo(target)

      local startTime = tick()
      repeat
          task.wait(0.5)
          if (hrp.Position - target).Magnitude < 5 then
              Log.info("Arrived at treadmill!")
              return true
          end
      until tick() - startTime > 15

      Log.warn("Timeout — could not reach treadmill exactly")
      return false
  end

  -- ANTI-AFK
  local function startAntiAFK()
      task.spawn(function()
          while true do
              task.wait(60) -- every 60 seconds
              pcall(function()
                  VirtualUser:CaptureController()
                  VirtualUser:ClickButton2(Vector2.new(0, 0))
              end)
              pcall(function()
                  local char = LocalPlayer.Character
                  local hum  = char and char:FindFirstChildOfClass("Humanoid")
                  if hum then hum.Jump = true end
              end)
              Log.info("Anti-AFK ping")
          end
      end)
  end

  -- INIT
  Log.info("Starting auto-walk to treadmill...")
  pcall(walkToTreadmill)
  startAntiAFK()
  Log.info("Anti-AFK started (ping every 60s)")
end
