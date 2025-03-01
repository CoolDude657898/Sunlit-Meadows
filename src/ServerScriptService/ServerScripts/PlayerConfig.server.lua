-- Services
local players = game:GetService("Players")

-- Create player values folder
local function createPlayerValues(player)
    local playerValues = Instance.new("Folder")
    playerValues.Name = "PlayerValues"
    playerValues.Parent = player

    local oxygen = Instance.new("IntValue")
    oxygen.Name = "Oxygen"
    oxygen.Parent = playerValues
    oxygen.Value = 1000

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
    
    -- Makes sure player walkspeed is set correctly
    if not player.Character then
        player.CharacterAdded:Wait()
    end

    player.Character.Humanoid.WalkSpeed = 9

    -- Creates hunger and thirst values
    local hunger = Instance.new("IntValue")
    hunger.Name = "Hunger"
    hunger.Parent = playerValues
    hunger.Value = 100

    local thirst = Instance.new("IntValue")
    thirst.Name = "Thirst"
    thirst.Parent = playerValues
    thirst.Value = 100
end

-- Connect to player added function
players.PlayerAdded:Connect(function(player)
    createPlayerValues(player)
end)