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
end

-- Connect to player added function
players.PlayerAdded:Connect(function(player)
    createPlayerValues(player)
end)