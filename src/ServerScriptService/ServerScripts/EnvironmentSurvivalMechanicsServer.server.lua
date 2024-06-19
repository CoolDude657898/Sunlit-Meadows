-- Services
local replicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local remotes = replicatedStorage.Remotes
local sprinting = false

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

-- Being player sprinting
local function startSprinting(player)
    sprinting = true
    player.Character.Humanoid.WalkSpeed = 18

    while sprinting == true do
        player.PlayerValues.Stamina.Value -= 0.714285714286
        task.wait(0.01)
    end

    if player.PlayerValues.Stamina.Value < 0 then
        player.PlayerValues.Stamina.Value = 0
    end
end

-- End player sprinting
local function stopSprinting(player)
    sprinting = false
    player.Character.Humanoid.WalkSpeed = 9

    while sprinting == false and player.PlayerValues.Stamina.Value < 1000 do
        player.PlayerValues.Stamina.Value += 1.666666667
        task.wait(0.01)
    end

    if player.PlayerValues.Stamina.Value > 1000 then
        player.PlayerValues.Stamina.Value = 1000
    end
end

-- Begin player crouching
local function startCrouching(player)
    player.Character.Humanoid.WalkSpeed = 4
end

-- End player crouching
local function stopCrouching(player)
    player.Character.Humanoid.WalkSpeed = 9
end

-- Detect when movement type changed
remotes.MovementTypeChanged.OnServerEvent:Connect(function(player, movementType, movementTypeInUse)
    if movementType == "Sprinting" and movementTypeInUse == true then
        startSprinting(player)
    end

    if movementType == "Sprinting" and movementTypeInUse == false then
        stopSprinting(player)
    end

    if movementType == "Crouching" and movementTypeInUse == true then
        startCrouching(player)
    end

    if movementType == "Crouching" and movementTypeInUse == false then
        stopCrouching(player)
    end
end)
