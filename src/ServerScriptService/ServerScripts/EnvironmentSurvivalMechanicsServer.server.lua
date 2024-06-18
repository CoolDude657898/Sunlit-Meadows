-- Services
local replicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local remotes = replicatedStorage.Remotes
local isUnderwater = false

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



