-- Services
local userInputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")

-- Variables
local player = players.LocalPlayer
local playerGui = player.PlayerGui
local sprinting = false
local crouching = false
local maxStamina = 1000
local currentStamina = maxStamina
local staminaDepletionRate = 1
local staminaReplenishRate = 2
local jumpDebounce = false

-- Wait for player character to add
if not player.Character then
    player.CharacterAdded:Wait()
end

-- Input began connections for sprinting and crouching
userInputService.InputBegan:Connect(function(key)
    if key.KeyCode == Enum.KeyCode.LeftShift and not crouching and currentStamina > 200 then
        sprinting = true
        local startSprintingWalkSpeedTween = tweenService:Create(player.Character.Humanoid, TweenInfo.new(0.4, Enum.EasingStyle.Linear), {WalkSpeed = 16.8})
        startSprintingWalkSpeedTween:Play()
    end

    if key.KeyCode == Enum.KeyCode.C or key.KeyCode == Enum.KeyCode.LeftControl and not sprinting then
        crouching = true
        local startCrouchingWalkSpeedTween = tweenService:Create(player.Character.Humanoid, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {WalkSpeed = 4})
        startCrouchingWalkSpeedTween:Play()
    end
end)

-- Input ended connections for sprinting and crouching
userInputService.InputEnded:Connect(function(key)
    if key.KeyCode == Enum.KeyCode.LeftShift and not crouching then
        sprinting = false
        local endSprintingWalkSpeedTween = tweenService:Create(player.Character.Humanoid, TweenInfo.new(0.4, Enum.EasingStyle.Linear), {WalkSpeed = 9})
        endSprintingWalkSpeedTween:Play()
    end

    if key.KeyCode == Enum.KeyCode.C or key.KeyCode == Enum.KeyCode.LeftControl and not sprinting then
        crouching = false
        local endCrouchingWalkSpeedTween = tweenService:Create(player.Character.Humanoid, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {WalkSpeed = 9})
        endCrouchingWalkSpeedTween:Play()
    end
end)

-- Jumping and stamina + jump cooldown
userInputService.JumpRequest:Connect(function()
    player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
    if jumpDebounce == false then
        jumpDebounce = true
        if currentStamina > 200 then
            local staminaAfterJump = currentStamina - 200
            while currentStamina > staminaAfterJump do
                task.wait()
                currentStamina -= 5
            end
        elseif currentStamina < 200 then
            player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
        end
        task.wait(0.5)
        jumpDebounce = false
    elseif jumpDebounce == true then
        player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
    end
end)

-- Loop to increase and decrease stamina
runService.RenderStepped:Connect(function(deltaTime)
    if player.Character.Humanoid:GetState() == Enum.HumanoidStateType.Swimming then
        currentStamina = currentStamina
        if player.Character.Humanoid.WalkSpeed ~= 16 then
            player.Character.Humanoid.WalkSpeed = 16
        end
    else
        if not sprinting then
            player.Character.Humanoid.WalkSpeed = 9
        end

        if sprinting and currentStamina > 0 and player.Character.Humanoid.MoveDirection.Magnitude > 0 then
            currentStamina = math.max(0, currentStamina - staminaDepletionRate * deltaTime * 100)
        elseif not sprinting and currentStamina < maxStamina then
            if player.Character.Humanoid.MoveDirection.Magnitude > 0 then
                currentStamina = math.min(maxStamina, currentStamina + (staminaReplenishRate*0.8) * deltaTime * 100)
            else
                currentStamina = math.min(maxStamina, currentStamina + staminaReplenishRate * deltaTime * 100)
            end
        end
    
        playerGui:WaitForChild("MenuClient").StaminaBackgroundBar.StaminaBar.Size = UDim2.new(currentStamina/1000, 0, 1, 0)
    
        if currentStamina <= 0 then
            sprinting = false
            local endSprintingWalkSpeedTween = tweenService:Create(player.Character.Humanoid, TweenInfo.new(0.4, Enum.EasingStyle.Linear), {WalkSpeed = 9})
            endSprintingWalkSpeedTween:Play()
        end
    
        if currentStamina < 200 then
            playerGui:WaitForChild("MenuClient").StaminaBackgroundBar.StaminaBar.BackgroundColor3 = Color3.fromRGB(122, 69, 70)
        end
    
        if currentStamina > 200 then
            playerGui:WaitForChild("MenuClient").StaminaBackgroundBar.StaminaBar.BackgroundColor3 = Color3.fromRGB(158, 142, 142)
        end
    end

    task.wait()
end)

-- Reset player speed on death
player.CharacterAdded:Connect(function()
    player.Character.Humanoid.WalkSpeed = 9
end)