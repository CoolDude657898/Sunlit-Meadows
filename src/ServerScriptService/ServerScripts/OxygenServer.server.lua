-- Services
local replicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local remotes = replicatedStorage.Remotes

-- Detects when player leaves or enters water and subsequently subtracts or adds oxygen
remotes.OxygenChanged.OnServerEvent:Connect(function(player, changeVariable)
    if changeVariable == "Lose Oxygen" then
        player.PlayerValues.Oxygen.Value -= 10
    elseif changeVariable == "Gain Oxygen" then
        player.PlayerValues.Oxygen.Value += 10
    elseif changeVariable == "Lose Health" then
        player.Character.Humanoid.Health -= 30
    end
end)

-- Detects when player leaves or enters water and changes variable in playerValues
remotes.UnderwaterChanged.OnServerEvent:Connect(function(player, trueOrFalse)
    if trueOrFalse == true then
        player.PlayerValues.IsUnderwater.Value = true
    elseif trueOrFalse == false then
        player.PlayerValues.IsUnderwater.Value = false
    end
end)