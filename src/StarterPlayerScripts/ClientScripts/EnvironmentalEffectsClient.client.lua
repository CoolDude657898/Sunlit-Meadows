-- Services
local players = game:GetService("Players")
local soundService = game:GetService("SoundService")
local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")

-- Variables
local player = players.LocalPlayer
local windEnabled = false

-- Waits for character to add
player.CharacterAdded:Wait()

-- Wind Effects Function
local function startWindEffect()
    windEnabled = true
    soundService.SoundEffects.Wind.Playing = true
    local volumeTween = tweenService:Create(soundService.SoundEffects.Wind, TweenInfo.new(5, Enum.EasingStyle.Linear), {Volume = 1})
    volumeTween:Play()
end

local function stopWindEffect()
    windEnabled = false
    local volumeTween = tweenService:Create(soundService.SoundEffects.Wind, TweenInfo.new(5, Enum.EasingStyle.Linear), {Volume = 0})
    volumeTween:Play()
end

-- Function to detect player's position
local function getPlayerPosition(playerToGetPositionOf)
    local playerPosition = playerToGetPositionOf.Character.HumanoidRootPart.Position

    return playerPosition
end

-- Constantly check whether to play wind based on player's y position value
runService.Heartbeat:Connect(function()
    local playerPosition = getPlayerPosition(player)

    if playerPosition.Y > 1450 and windEnabled == false then
        startWindEffect()
    elseif playerPosition.Y < 1450 and windEnabled == true then
        stopWindEffect()
    end
end)