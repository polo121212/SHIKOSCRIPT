-- SHIKO SCRIPT | Main
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local heartbeatConn

-- Settings
local MAIN_SPEED = 50
local RESET_INTERVAL = 3
local RESET_DURATION = 0.5
local RESET_SPEED = 34
local CORRECTION_DISTANCE = 13
local TOGGLE_KEY = Enum.KeyCode.C

local enabled = true

local function disconnectHeartbeat()
    if heartbeatConn then
        heartbeatConn:Disconnect()
        heartbeatConn = nil
    end
end

local function onCharacter(char)
    disconnectHeartbeat()

    local humanoidRootPart = char:WaitForChild("HumanoidRootPart", 5)
    local humanoid = char:WaitForChild("Humanoid", 5)
    if not humanoidRootPart or not humanoid then return end

    local lastPosition = humanoidRootPart.Position

    heartbeatConn = RunService.Heartbeat:Connect(function()
        if enabled and humanoid then
            pcall(function()
                humanoid.WalkSpeed = MAIN_SPEED
            end)
        end

        local distance = (humanoidRootPart.Position - lastPosition).Magnitude
        if distance > CORRECTION_DISTANCE then
            warn("[SHIKO] Server correction detected:", distance)
        end

        lastPosition = humanoidRootPart.Position
    end)

    task.spawn(function()
        while char and humanoid and humanoid.Parent do
            task.wait(RESET_INTERVAL)

            if enabled then
                local currentSpeed
                pcall(function()
                    currentSpeed = humanoid.WalkSpeed
                end)

                pcall(function()
                    humanoid.WalkSpeed = RESET_SPEED
                end)

                task.wait(RESET_DURATION)

                if enabled and currentSpeed then
                    pcall(function()
                        humanoid.WalkSpeed = currentSpeed
                    end)
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

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == TOGGLE_KEY then
        enabled = not enabled
        print("[SHIKO] Speed:", enabled and "ON" or "OFF")
    end
end)

