-- Services
local replicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local remotes = replicatedStorage.Remotes
local isUnderwater = false
local sprinting = false
local crouching = false

-- Lose Oxygen Loop
local function loseOxygen(player, oxygenValue)
    while isUnderwater and oxygenValue.Value > 0 do
        task.wait(0.1)
        oxygenValue.Value -= 10
    end

    while isUnderwater and oxygenValue.Value == 0 and player.Character.Humanoid.Health > 0 do
        task.wait(0.5)
        player.Character.Humanoid.Health -= 30
    end
end

-- Gain Oxygen Loop
local function gainOxygen(oxygenValue)
    while not isUnderwater and oxygenValue.Value < 1000 do
        task.wait(0.1)
        oxygenValue.Value += 10
    end
end

-- Detects when player leaves or enters water and subsequently subtracts or adds oxygen
remotes.UnderwaterChanged.OnServerEvent:Connect(function(player, isPlayerUnderwater)
    local oxygenValue = player.PlayerValues.Oxygen

    if isPlayerUnderwater == true then
        isUnderwater = true
        loseOxygen(player, oxygenValue)
    elseif isPlayerUnderwater == false then
        isUnderwater = false
        gainOxygen(oxygenValue)
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
    crouching = true
    player.Character.Humanoid.WalkSpeed = 4
end

-- End player crouching
local function stopCrouching(player)
    crouching = false
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
