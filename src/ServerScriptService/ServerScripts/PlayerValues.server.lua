-- Services
local players = game:GetService("Players")

-- Create player values folder
local function createPlayerValues(playerToCreateValuesFor)
    local playerValues = Instance.new("Folder")
    playerValues.Name = "PlayerValues"
    playerValues.Parent = playerToCreateValuesFor

    local oxygen = Instance.new("IntValue")
    oxygen.Name = "Oxygen"
    oxygen.Parent = playerValues
    oxygen.Value = 1000

    local stamina = Instance.new("IntValue")
    stamina.Name = "Stamina"
    stamina.Parent = playerValues
    stamina.Value = 1000

    -- Make sure values cant exceed set values
    local oxygenMinimum = 0
    local oxygenMaximum = 1000

    oxygen:GetPropertyChangedSignal("Value"):Connect(function()
        if oxygen.Value < oxygenMinimum then
            oxygen.Value = oxygenMinimum
        elseif oxygen.Value > oxygenMaximum then
            oxygen.Value = oxygenMaximum
        end
    end)

    local isUnderwater = Instance.new("BoolValue")
    isUnderwater.Parent = playerValues
    isUnderwater.Name = "IsUnderwater"
    isUnderwater.Value = false
end

-- Connect to player added function
players.PlayerAdded:Connect(function(player)
    createPlayerValues(player)
end)