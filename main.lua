-- SHIKO SCRIPT | Main + Menu

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local heartbeatConn

-- ===== SHIKO SETTINGS =====
local MAIN_SPEED = 50
local RESET_INTERVAL = 3
local RESET_DURATION = 0.5
local RESET_SPEED = 34
local CORRECTION_DISTANCE = 13

local TOGGLE_KEY = Enum.KeyCode.C        -- Toggle speed
local MENU_KEY = Enum.KeyCode.RightShift -- Open menu

local enabled = true

-- ===== SPEED LOGIC =====
local function disconnectHeartbeat()
    if heartbeatConn then
        heartbeatConn:Disconnect()
        heartbeatConn = nil
    end
end

local function onCharacter(char)
    disconnectHeartbeat()

    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    local humanoid = char:WaitForChild("Humanoid", 5)
    if not hrp or not humanoid then return end

    local lastPosition = hrp.Position

    heartbeatConn = RunService.Heartbeat:Connect(function()
        if enabled and humanoid then
            pcall(function()
                humanoid.WalkSpeed = MAIN_SPEED
            end)
        end

        local distance = (hrp.Position - lastPosition).Magnitude
        if distance > CORRECTION_DISTANCE then
            warn("[SHIKO] Server correction detected:", distance)
        end

        lastPosition = hrp.Position
    end)

    task.spawn(function()
        while char and humanoid and humanoid.Parent do
            task.wait(RESET_INTERVAL)
            if enabled then
                local currentSpeed = humanoid.WalkSpeed
                humanoid.WalkSpeed = RESET_SPEED
                task.wait(RESET_DURATION)
                if enabled then
                    humanoid.WalkSpeed = currentSpeed
                end
            end
        end
    end)
end

if player.Character then
    onCharacter(player.Character)
end

player.CharacterAdded:Connect(onCharacter)
player.CharacterRemoving:Connect(disconnectHeartbeat)

-- Keyboard toggle
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == TOGGLE_KEY then
        enabled = not enabled
        print("[SHIKO] Speed:", enabled and "ON" or "OFF")
    end
end)

-- ===== SHIKO MENU =====
local shikoGui = Instance.new("ScreenGui")
shikoGui.Name = "SHIKO_MENU"
shikoGui.ResetOnSpawn = false
shikoGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", shikoGui)
frame.Size = UDim2.fromScale(0.3, 0.35)
frame.Position = UDim2.fromScale(0.35, 0.32)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Visible = false
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "SHIKO SCRIPT"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(0.8, 0, 0, 40)
toggleBtn.Position = UDim2.new(0.1, 0, 0.3, 0)
toggleBtn.Text = "Toggle Speed"
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)

toggleBtn.MouseButton1Click:Connect(function()
    enabled = not enabled
    print("[SHIKO] Speed:", enabled and "ON" or "OFF")
end)

local resetBtn = Instance.new("TextButton", frame)
resetBtn.Size = UDim2.new(0.8, 0, 0, 40)
resetBtn.Position = UDim2.new(0.1, 0, 0.5, 0)
resetBtn.Text = "Reset Speed"
resetBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
resetBtn.TextColor3 = Color3.new(1, 1, 1)

resetBtn.MouseButton1Click:Connect(function()
    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
    if hum then
        hum.WalkSpeed = MAIN_SPEED
        print("[SHIKO] Speed reset")
    end
end)

-- Open / Close menu
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == MENU_KEY then
        frame.Visible = not frame.Visible
    end
end)

