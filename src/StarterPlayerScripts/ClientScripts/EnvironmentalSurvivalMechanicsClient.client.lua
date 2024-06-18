-- Services
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")

-- Variables
local remotes = replicatedStorage.Remotes
local player = players.LocalPlayer
local playerValues = player:WaitForChild("PlayerValues")
local isUnderwater = false

-- Waits for character to add
player.CharacterAdded:Wait()

-- Create color sequence for oxygen
local colorSequence = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(160,0,0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(245, 235, 159)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(171, 245, 233)),
}

-- Get point in color sequence
local function getColorSequencePoint(x)
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

-- Always check if player head is underwater
runService.Heartbeat:Connect(function()
    local playerHeadPositon = game.Workspace.Terrain:WorldToCell(getPlayerHeadPosition(player))
    local isInWater = game.Workspace.Terrain:GetWaterCell(playerHeadPositon.X, playerHeadPositon.Y, playerHeadPositon.Z)
    
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

-- Update oxygen text label
local function updateOxygenGui(value)
    if value >= 10 then
        player.PlayerGui.MenuClient.OxygenFrame.OxygenPercent.Text = "["..value.."%]"
    elseif value < 10 then
        player.PlayerGui.MenuClient.OxygenFrame.OxygenPercent.Text = "[0"..value.."%]"
    end

    local percent = math.clamp(value/100, 0, 1)
    local color = getColorSequencePoint(percent)
    player.PlayerGui.MenuClient.OxygenFrame.OxygenPercent.TextColor3 = color
    player.PlayerGui.MenuClient.OxygenFrame.OxygenSymbol.TextColor3 = color
    player.PlayerGui.MenuClient.OxygenFrame.NumberSymbol.TextColor3 = color
end

-- Update oxygen gui when oxygen value changed
playerValues.Oxygen:GetPropertyChangedSignal("Value"):Connect(function()
    updateOxygenGui(playerValues.Oxygen.Value/10)
end)