-- Services
local userInputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local runService = game:GetService("RunService")

-- Variables
local player = players.LocalPlayer
local staminaGui = player.PlayerGui:WaitForChild("MenuClient"):WaitForChild("StaminaBackgroundBar")
local sprinting = false
local crouching = false
local maxStamina = 1000
local currentStamina = maxStamina
local staminaDepletionRate = 1
local staminaReplenishRate = 2
local jumpDebounce = false

-- Input began connections for sprinting and crouching
userInputService.InputBegan:Connect(function(key)
    if key.KeyCode == Enum.KeyCode.LeftShift and not crouching and currentStamina > 200 then
        sprinting = true
        player.Character.Humanoid.WalkSpeed = 18
    end

    if key.KeyCode == Enum.KeyCode.C or key.KeyCode == Enum.KeyCode.LeftControl and not sprinting then
        crouching = true
        player.Character.Humanoid.WalkSpeed = 4
    end
end)

-- Input ended connections for sprinting and crouching
userInputService.InputEnded:Connect(function(key)
    if key.KeyCode == Enum.KeyCode.LeftShift and not crouching then
        sprinting = false
        player.Character.Humanoid.WalkSpeed = 9
    end

    if key.KeyCode == Enum.KeyCode.C or key.KeyCode == Enum.KeyCode.LeftControl and not sprinting then
        crouching = false
        player.Character.Humanoid.WalkSpeed = 9
    end
end)

-- Jumping and stamina + jump cooldown
userInputService.JumpRequest:Connect(function()
    player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
    if jumpDebounce == false then
        jumpDebounce = true
        if currentStamina > 200 then
            print("skibidi")
            currentStamina -= 200
        elseif currentStamina < 200 then
            player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
        end
        task.wait(2)
        jumpDebounce = false
    elseif jumpDebounce == true then
        player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
    end
end)

-- Loop to increase and decrease stamina
runService.RenderStepped:Connect(function(deltaTime)
    if sprinting and currentStamina > 0 then
        currentStamina = math.max(0, currentStamina - staminaDepletionRate * deltaTime * 100)
    elseif not sprinting and currentStamina < maxStamina then
        if player.Character.Humanoid.MoveDirection.Magnitude > 0 then
            currentStamina = math.min(maxStamina, currentStamina + (staminaReplenishRate*0.8) * deltaTime * 100)
        else
            currentStamina = math.min(maxStamina, currentStamina + staminaReplenishRate * deltaTime * 100)
        end
    end

    staminaGui.StaminaBar.Size = UDim2.new(currentStamina/1000, 0, 1, 0)

    if currentStamina <= 0 then
        sprinting = false
        player.Character.Humanoid.WalkSpeed = 9
    end

    if currentStamina < 200 then
        staminaGui.StaminaBar.BackgroundColor3 = Color3.fromRGB(255,70,70)
    end

    if currentStamina > 200 then
        staminaGui.StaminaBar.BackgroundColor3 = Color3.fromRGB(255, 217, 0)
    end

    task.wait()
end)