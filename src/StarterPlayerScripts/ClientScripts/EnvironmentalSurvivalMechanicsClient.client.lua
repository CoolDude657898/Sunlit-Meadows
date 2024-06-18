-- Services
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")

-- Variables
local remotes = replicatedStorage.Remotes
local player = players.LocalPlayer
local playerValues = player:WaitForChild("PlayerValues")
local isUnderwater = false
local sprinting = false
local crouching = false

-- Waits for character to add
if not player.Character then
    player.CharacterAdded:Wait()
end

-- Get player health
local function getPlayerHealth(playerToGetHealthOf)
    local playerHealth = playerToGetHealthOf.Character.Humanoid.Health
    return playerHealth
end

-- Create color sequence for oxygen and health bar
local oxygenColorSequence = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(160,0,0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(245, 235, 159)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(171, 245, 233)),
}

-- Create color sequence for oxygen and health bar
local healthColorSequence = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(160,0,0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(218, 167, 59)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(50,170,17)),
}


-- Get point in color sequence
local function getColorSequencePoint(x, colorSequence)
    if x == 0 then return colorSequence.Keypoints[1].Value end
    if x == 1 then return colorSequence.Keypoints[#colorSequence.Keypoints].Value end

    for i = 1, #colorSequence.Keypoints - 1 do
        local current = colorSequence.Keypoints[i]
        local next = colorSequence.Keypoints[1 + i]

        if x >= current.Time and x < next.Time then
            local alpha = (x - current.Time) / (next.Time - current.Time)

            return current.Value:Lerp(next.Value, alpha)
        end
    end
end

-- Get player position
local function getPlayerHeadPosition(playerToGetPositionOf)
    local playerHeadPosition = playerToGetPositionOf.Character.Head.Position

    return playerHeadPosition
end

-- Constantly check whether player is underwater
runService.Heartbeat:Connect(function()
    local playerHeadPositon = game.Workspace.Terrain:WorldToCell(getPlayerHeadPosition(player))
    local isInWater = game.Workspace.Terrain:GetWaterCell(playerHeadPositon.X, playerHeadPositon.Y + 0.5, playerHeadPositon.Z)
    
    if isInWater and isUnderwater == false then
        isUnderwater = true
        player.PlayerGui.MenuClient.OxygenFrame.Visible = true
        remotes.UnderwaterChanged:FireServer(true)
    elseif not isInWater and isUnderwater == true then
        isUnderwater = false
        remotes.UnderwaterChanged:FireServer(false)
        while playerValues.Oxygen.Value < 1000 do
            task.wait()
        end
        player.PlayerGui.MenuClient.OxygenFrame.Visible = false 
    end
end)

-- Update oxygen color and text label
local function updateOxygenGui(value)
    if value >= 10 then
        player.PlayerGui.MenuClient.OxygenFrame.OxygenPercent.Text = "["..value.."%]"
    elseif value < 10 then
        player.PlayerGui.MenuClient.OxygenFrame.OxygenPercent.Text = "[0"..value.."%]"
    end

    local percent = math.clamp(value/100, 0, 1)
    local color = getColorSequencePoint(percent, oxygenColorSequence)
    player.PlayerGui.MenuClient.OxygenFrame.OxygenPercent.TextColor3 = color
    player.PlayerGui.MenuClient.OxygenFrame.OxygenSymbol.TextColor3 = color
    player.PlayerGui.MenuClient.OxygenFrame.NumberSymbol.TextColor3 = color
end

-- Update oxygen gui when oxygen value changed
playerValues.Oxygen:GetPropertyChangedSignal("Value"):Connect(function()
    updateOxygenGui(playerValues.Oxygen.Value/10)
end)

-- Update health bar color and text label
local function updateHealthGui(value)
    local playerHealth = getPlayerHealth(player)
    player.PlayerGui.MenuClient.HealthBackgroundBar.HealthBar.Size = UDim2.new(playerHealth/100,0,1,0)
    player.PlayerGui.MenuClient.HealthBackgroundBar.HealthPercent.Text = math.round(playerHealth).."/100"

    local percent = math.clamp(value/100, 0, 1)
    local color = getColorSequencePoint(percent, healthColorSequence)
    player.PlayerGui.MenuClient.HealthBackgroundBar.HealthBar.BackgroundColor3 = color
end

player.Character:WaitForChild("Humanoid"):GetPropertyChangedSignal("Health"):Connect(function()
    updateHealthGui(player.Character.Humanoid.Health)
end)

player.CharacterAdded:Connect(function()
    player.Character:WaitForChild("Humanoid"):GetPropertyChangedSignal("Health"):Connect(function()
        updateHealthGui(player.Character.Humanoid.Health)
    end)
end)

-- Being player sprinting
local function startSprinting()
    remotes.MovementTypeChanged:FireServer("Sprinting", true)
    sprinting = true
end

-- End player sprinting
local function stopSprinting()
    remotes.MovementTypeChanged:FireServer("Sprinting", false)
    sprinting = false
end

-- Begin player crouching
local function startCrouching()
    remotes.MovementTypeChanged:FireServer("Crouching", true)
    crouching = true
end

-- End player crouching
local function stopCrouching()
    remotes.MovementTypeChanged:FireServer("Crouching", false)
    crouching = false
end

-- Connect movement inputs to functions
local function handleInputs(key, beganOrEnded)
    if beganOrEnded == "Began" then
        if key.KeyCode == Enum.KeyCode.LeftShift then
            startSprinting()
        end
    
        if key.KeyCode == Enum.KeyCode.C and sprinting == false then
            startCrouching()
        end
    end

    if beganOrEnded == "Ended" then
        if key.KeyCode == Enum.KeyCode.LeftShift then
            stopSprinting()
        end
    
        if key.KeyCode == Enum.KeyCode.C and sprinting == false then
            stopCrouching()
        end
    end
end

-- Connect to userinputservice
userInputService.InputBegan:Connect(function(key)
    handleInputs(key, "Began")
end)

userInputService.InputEnded:Connect(function(key)
    handleInputs(key, "Ended")
end)

-- Detect when stamina changes
playerValues.Stamina:GetPropertyChangedSignal("Value"):Connect(function()
    if playerValues.Stamina.Value <= 0 then
        stopSprinting()
    end

    player.PlayerGui.MenuClient.StaminaBackgroundBar.StaminaBar.Size = UDim2.new(playerValues.Stamina.Value/1000, 0, 1, 0)
end)