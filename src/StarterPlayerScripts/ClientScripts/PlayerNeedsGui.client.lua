-- Services
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local colorSequenceModule = require(replicatedStorage.Modules.ColorSequenceModule)

-- Variables
local player = players.LocalPlayer
local playerValues = player:WaitForChild("PlayerValues")
local hungerValue = playerValues:WaitForChild("Hunger")
local thirstValue = playerValues:WaitForChild("Thirst")
local playerGui = player:WaitForChild("PlayerGui")
local hungerGui = playerGui:WaitForChild("MenuClient"):WaitForChild("HungerBackgroundBar")
local thirstGui = playerGui:WaitForChild("MenuClient"):WaitForChild("ThirstBackgroundBar")

-- Waits for character to add
if not player.Character then
    player.CharacterAdded:Wait()
end

-- Color sequence
local hungerColorSequence = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 127, 127)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(199, 172, 96)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 138, 40)),
}

-- Color sequence
local thirstColorSequence = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 127, 127)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(62, 102, 117)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(77, 163, 163)),
}

-- Detects when hunger and thirst values change and updates gui
hungerValue:GetPropertyChangedSignal("Value"):Connect(function()
    local percent = math.clamp(hungerValue.Value/100, 0, 1)
    hungerGui.HungerBar.Size = UDim2.new(percent, 0, 1, 0)
    hungerGui.HungerBar.BackgroundColor3 = colorSequenceModule.getColorSequencePoint(percent, hungerColorSequence)
    hungerGui.HungerPercent.Text = math.round(hungerValue.Value).."/100"
end)

thirstValue:GetPropertyChangedSignal("Value"):Connect(function()
    local percent = math.clamp(thirstValue.Value/100, 0, 1)
    thirstGui.ThirstBar.Size = UDim2.new(percent, 0, 1, 0)
    thirstGui.ThirstBar.BackgroundColor3 = colorSequenceModule.getColorSequencePoint(percent, thirstColorSequence)
    thirstGui.ThirstPercent.Text = math.round(thirstValue.Value).."/100"
end)