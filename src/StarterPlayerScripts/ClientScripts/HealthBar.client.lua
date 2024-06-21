-- Services
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local colorSequenceModule = require(replicatedStorage.Modules.ColorSequenceModule)

-- Variables
local player = players.LocalPlayer

-- Waits for character to add
if not player.Character then
    player.CharacterAdded:Wait()
end

-- Color sequence
local healthColorSequence = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(109, 55, 55)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(128, 106, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(53, 94, 42)),
}

-- Get player health
local function getPlayerHealth(playerToGetHealthOf)
    local playerHealth = playerToGetHealthOf.Character.Humanoid.Health
    return playerHealth
end

-- Update health bar color and text label
local function updateHealthGui(value)
    local playerHealth = getPlayerHealth(player)
    player.PlayerGui.MenuClient.HealthBackgroundBar.HealthBar.Size = UDim2.new(playerHealth/100,0,1,0)
    player.PlayerGui.MenuClient.HealthBackgroundBar.HealthPercent.Text = math.round(playerHealth).."/100"

    local percent = math.clamp(value/100, 0, 1)
    local color = colorSequenceModule.getColorSequencePoint(percent, healthColorSequence)
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