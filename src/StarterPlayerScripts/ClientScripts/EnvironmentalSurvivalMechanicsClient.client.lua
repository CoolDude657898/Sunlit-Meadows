-- Services
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")

-- Variables
local remotes = replicatedStorage.Remotes
local player = players.LocalPlayer
local playerValues = player:WaitForChild("PlayerValues")
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
    local playerHeadPosition = playerToGetPositionOf.Character:WaitForChild("Head").Position

    return playerHeadPosition
end

-- Constantly check whether player is underwater
runService.Heartbeat:Connect(function()
    local playerHeadPositon = game.Workspace.Terrain:WorldToCell(getPlayerHeadPosition(player))
    local isInWater = game.Workspace.Terrain:GetWaterCell(playerHeadPositon.X, playerHeadPositon.Y + 0.5, playerHeadPositon.Z)
    
    if isInWater == true then
        player.PlayerGui.MenuClient.OxygenFrame.Visible = true
        remotes.UnderwaterChanged:FireServer(true)
    elseif isInWater == false then
        remotes.UnderwaterChanged:FireServer(false)

        while playerValues.Oxygen.Value < 1000 do
            task.wait()
        end
        
        player.PlayerGui.MenuClient.OxygenFrame.Visible = false 
    end
end)

-- Detects when isUnderwater value changes
playerValues.IsUnderwater:GetPropertyChangedSignal("Value"):Connect(function()
    -- Constantly fire remote to either lose or gain oxygen
    while playerValues.IsUnderwater.Value == true do
        task.wait(0.1)
        if playerValues.Oxygen.Value == 0 then
            task.wait(0.4)
            remotes.OxygenChanged:FireServer("Lose Health")
        else
            remotes.OxygenChanged:FireServer("Lose Oxygen")
        end
    end

    while playerValues.IsUnderwater.Value == false and playerValues.Oxygen.Value < 1000 do
        task.wait(0.1)
        remotes.OxygenChanged:FireServer("Gain Oxygen")
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

-- Detect when stamina value changes to update GUI
playerValues.Stamina:GetPropertyChangedSignal("Value"):Connect(function()
    player.PlayerGui.MenuClient.StaminaBackgroundBar.StaminaBar.Size = UDim2.new(playerValues.Stamina.Value/1000, 0, 1, 0)

    if playerValues.Stamina.Value <= 200 then
        player.PlayerGui.MenuClient.StaminaBackgroundBar.StaminaBar.BackgroundColor3 = Color3.fromRGB(155, 80, 80)
    end

    if playerValues.Stamina.Value > 200 then
        player.PlayerGui.MenuClient.StaminaBackgroundBar.StaminaBar.BackgroundColor3 = Color3.fromRGB(255, 217, 0)
    end
end)

userInputService.InputBegan:Connect(function(key, processed)
    if not processed then
        if key.KeyCode == Enum.KeyCode.LeftShift and playerValues.Stamina.Value > 200 then
            sprinting = true
            while sprinting do
                task.wait()
                remotes.MovementTypeChanged:FireServer("Sprinting")
            end
        end

        if key.KeyCode == Enum.KeyCode.C or key.KeyCode == Enum.KeyCode.LeftControl then
        crouching = true
            while crouching do
             task.wait()
                remotes.MovementTypeChanged:FireServer("Crouching")
            end
        end
    end
end)

userInputService.InputEnded:Connect(function(key, processed)
    if not processed then
        if key.KeyCode == Enum.KeyCode.LeftShift and sprinting then
            sprinting = false
            while not sprinting and not crouching do
                task.wait()
                remotes.MovementTypeChanged:FireServer("Walking")
            end
        end

        if key.KeyCode == Enum.KeyCode.LeftControl or key.KeyCode == Enum.KeyCode.C and crouching then
            crouching = false
            while not crouching and not sprinting do
                task.wait()
                remotes.MovementTypeChanged:FireServer("Walking")
            end
        end
    end
end)

while task.wait() do
    print("Sprint ", sprinting)
    print("Crouch", crouching)
end