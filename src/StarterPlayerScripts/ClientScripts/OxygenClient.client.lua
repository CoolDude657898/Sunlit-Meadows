-- Services
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")

-- Modules
local colorSequenceModule = require(replicatedStorage.Modules.ColorSequenceModule)

-- Variables
local remotes = replicatedStorage.Remotes
local player = players.LocalPlayer
local playerValues = player:WaitForChild("PlayerValues")

-- Waits for character to add
if not player.Character then
    player.CharacterAdded:Wait()
end

-- Create color sequence for oxygen and health bar
local oxygenColorSequence = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(160,0,0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(245, 235, 159)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(171, 245, 233)),
}

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
    local color = colorSequenceModule.getColorSequencePoint(percent, oxygenColorSequence)
    player.PlayerGui.MenuClient.OxygenFrame.OxygenPercent.TextColor3 = color
    player.PlayerGui.MenuClient.OxygenFrame.OxygenSymbol.TextColor3 = color
    player.PlayerGui.MenuClient.OxygenFrame.NumberSymbol.TextColor3 = color
end

-- Update oxygen gui when oxygen value changed
playerValues.Oxygen:GetPropertyChangedSignal("Value"):Connect(function()
    updateOxygenGui(playerValues.Oxygen.Value/10)
end)
