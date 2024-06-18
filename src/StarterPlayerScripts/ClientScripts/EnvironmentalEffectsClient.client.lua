-- Services
local players = game:GetService("Players")
local lighting = game:GetService("Lighting")
local soundService = game:GetService("SoundService")
local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")

-- Variables
local player = players.LocalPlayer
local windEnabled = false
local underwaterEnabled = false
local camera = game.Workspace.CurrentCamera

-- Waits for character to add
if not player.Character then
    player.CharacterAdded:Wait()
end

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

-- Function to get player's position
local function getPlayerPosition(playerToGetPositionOf)
    local playerPosition = playerToGetPositionOf.Character.HumanoidRootPart.Position

    return playerPosition
end

-- Function to start underwater effect
local function startUnderwaterEffect()
    underwaterEnabled = true
    lighting.UnderwaterBlur.Size = 13
    soundService.SoundEffects.UnderwaterAmbience.Playing = true
end

-- Function to stop underwater effect
local function stopUnderwaterEffect()
    underwaterEnabled = false
    lighting.UnderwaterBlur.Size = 0
    soundService.SoundEffects.UnderwaterAmbience:Pause()
end

-- Function to get camera's position
local function checkIfCameraUnderwater()
    local cameraPosition = game.Workspace.Terrain:WorldToCell(camera.CFrame.Position)
    local isInWater = game.Workspace.Terrain:GetWaterCell(cameraPosition.X, cameraPosition.Y, cameraPosition.Z)
    
    if isInWater then
        return true
    else
        return false
    end
end

-- Constantly check whether to play environmental effects based on player and camera positions
runService.Heartbeat:Connect(function()
    local playerPosition = getPlayerPosition(player)
    local isCameraInWater = checkIfCameraUnderwater()

    if isCameraInWater == true and underwaterEnabled == false then
        startUnderwaterEffect()
    elseif isCameraInWater == false and underwaterEnabled == true then
        stopUnderwaterEffect()
    end

    if playerPosition.Y > 500 and windEnabled == false then
        startWindEffect()
    elseif playerPosition.Y < 500 and windEnabled == true then
        stopWindEffect()
    end
end)