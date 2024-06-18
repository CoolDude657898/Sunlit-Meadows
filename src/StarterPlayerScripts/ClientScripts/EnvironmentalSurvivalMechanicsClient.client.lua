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
end

-- Update oxygen gui when oxygen value changed
playerValues.Oxygen:GetPropertyChangedSignal("Value"):Connect(function()
    updateOxygenGui(playerValues.Oxygen.Value/10)
end)