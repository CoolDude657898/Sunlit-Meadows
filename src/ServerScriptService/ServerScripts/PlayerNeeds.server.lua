-- Services
local players = game:GetService("Players")

-- Lose hunger function
local function loseHunger(hungerValue, player)
    local loseHungerCoroutine = coroutine.create(function()
        while task.wait(2) do
            if hungerValue.Value > 0 then
                task.wait(8)
                hungerValue.Value -= 1
            elseif hungerValue.Value == 0 then
                player.Character.Humanoid.Health -= 30
            end
        end
    end)

    coroutine.resume(loseHungerCoroutine)
end

-- Lose thirst function
local function loseThirst(thirstValue, player)
    local loseThirstCoroutine = coroutine.create(function()
        while task.wait(2) do
            if thirstValue.Value >0 then
                task.wait(3)
                thirstValue.Value -= 1
            elseif thirstValue.Value == 0 then
                player.Character.Humanoid.Health -= 30
            end
        end
    end)

    coroutine.resume(loseThirstCoroutine)
end

-- Player added connection
players.PlayerAdded:Connect(function(player)
    local playerValues = player:WaitForChild("PlayerValues")
    local hungerValue = playerValues:WaitForChild("Hunger")
    local thirstValue = playerValues:WaitForChild("Thirst")

    loseHunger(hungerValue, player)
    loseThirst(thirstValue, player)
end)