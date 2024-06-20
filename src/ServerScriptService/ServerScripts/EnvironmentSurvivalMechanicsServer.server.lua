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

-- Detect when movement type changed
remotes.MovementTypeChanged.OnServerEvent:Connect(function(player, movementType)
    if movementType == "Sprinting" and player.Character.Humanoid.MoveDirection.Magnitude > 0 then
        if player.Character.Humanoid.WalkSpeed ~= 18 then
            player.Character.Humanoid.WalkSpeed = 18
        end

        if player.PlayerValues.Stamina.Value <= 0 then
            player.PlayerValues.Stamina.Value = 0
            player.Character.Humanoid.WalkSpeed = 9
        end
        player.PlayerValues.Stamina.Value -= 1
    elseif movementType == "Walking" then
        if player.Character.Humanoid.WalkSpeed ~= 9 then
            player.Character.Humanoid.WalkSpeed = 9
        end
    elseif movementType == "Crouching" then
        if player.Character.Humanoid.WalkSpeed ~= 4 then
            player.Character.Humanoid.WalkSpeed = 4
        end
    end
    
    if movementType == "Crouching" or movementType == "Walking" then
        if player.PlayerValues.Stamina.Value < 1000 then
            player.PlayerValues.Stamina.Value += 2
        end

        if player.PlayerValues.Stamina.Value > 1000 then
            player.PlayerValues.Stamina.Value = 1000
        end
    end
end)