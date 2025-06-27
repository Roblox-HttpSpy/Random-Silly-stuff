--[[ 
AIMBOT For First person Shooter games...

btw this script isnt really "mine mine" as i got this script is from
a LocalScript in a game that had Aim Assist, so i decompiled it
modified it (snaps camera) and tada! heres the script,

this is the game i was talking about btw = https://www.roblox.com/games/12137249458/FPS-Gun-Grounds-FFA

AimBotV2 : made it bypass Anticheats like one ins unnamed shooter
but... your executor gonna neeed to support a good cloneref() so if this script breaks
scroll down and copy v1 AimBot NOTE YOU WONT HAVE THE ANTICHEAT BYPASSING
]]--

local function ClonedService(name)
    local Service = (game.GetService)
    local Reference = (cloneref) or function(ref) return ref end
    return Reference(Service(game, name))
end

local TARGET_DISTANCE_LIMIT = 150 -- Range of Aimbot Trigger

local Players = ClonedService("Players")
local RunService = ClonedService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = ClonedService("UserInputService")
local Workspace = ClonedService("Workspace")

local function ArePlayersOnSameTeam(player1, player2)
    return player1.Team ~= nil and player2.Team ~= nil and player1.Team == player2.Team
end

local function GetClosestTarget()
    local closestDistance = math.huge
    local closestTarget = nil

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")

            if humanoid and rootPart and humanoid.Health > 0 then
                if not ArePlayersOnSameTeam(LocalPlayer, player) then
                    local targetPosition = rootPart.Position
                    local cameraPosition = Camera.CFrame.Position
                    local distanceToTarget = (targetPosition - cameraPosition).Magnitude

                    if distanceToTarget <= TARGET_DISTANCE_LIMIT and distanceToTarget < closestDistance then
                        local raycastParams = RaycastParams.new()
                        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}

                        local rayResult = Workspace:Raycast(cameraPosition, (targetPosition - cameraPosition).Unit * distanceToTarget, raycastParams)

                        if rayResult and rayResult.Instance:IsDescendantOf(player.Character) then
                            closestTarget = targetPosition
                            closestDistance = distanceToTarget
                        end
                    end
                end
            end
        end
    end

    return closestTarget
end

local function SnapAimAssist()
    local connectedGamepads = UserInputService:GetConnectedGamepads()
    local lastInputType = UserInputService:GetLastInputType()
    local isUsingGamepadOrTouch = (#connectedGamepads > 0 and lastInputType == Enum.UserInputType.Gamepad1) or lastInputType == Enum.UserInputType.Touch

    local targetPosition = isUsingGamepadOrTouch and GetClosestTarget()
    if targetPosition then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
    end
end

RunService.RenderStepped:Connect(SnapAimAssist)

--[[ 

-- V1 : Copy script below and execute but dont copy the ]--


local TARGET_DISTANCE_LIMIT = 150  -- Range of Aimbot Trigger

local Players = game:GetService("Players")  
local RunService = game:GetService("RunService")  
local LocalPlayer = Players.LocalPlayer  
local Camera = workspace.CurrentCamera  
local UserInputService = game:GetService("UserInputService")  
local Workspace = game:GetService("Workspace")  

local function ArePlayersOnSameTeam(player1, player2)  
    return player1.Team ~= nil and player2.Team ~= nil and player1.Team == player2.Team  
end  

local function GetClosestTarget()  
    local closestDistance = math.huge  
    local closestTarget = nil  

    for _, player in pairs(Players:GetPlayers()) do  
        if player ~= LocalPlayer and player.Character then  
            local humanoid = player.Character:FindFirstChild("Humanoid")  
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")  

            if humanoid and rootPart and humanoid.Health > 0 then  
                if not ArePlayersOnSameTeam(LocalPlayer, player) then  
                    local targetPosition = rootPart.Position  
                    local cameraPosition = Camera.CFrame.Position  
                    local distanceToTarget = (targetPosition - cameraPosition).Magnitude  

                    if distanceToTarget <= TARGET_DISTANCE_LIMIT and distanceToTarget < closestDistance then  
                        local raycastParams = RaycastParams.new()  
                        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist  
                        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}  

                        local rayResult = Workspace:Raycast(cameraPosition, (targetPosition - cameraPosition).Unit * distanceToTarget, raycastParams)  

                        if rayResult and rayResult.Instance:IsDescendantOf(player.Character) then  
                            closestTarget = targetPosition  
                            closestDistance = distanceToTarget  
                        end  
                    end  
                end  
            end  
        end  
    end  

    return closestTarget  
end  

local function SnapAimAssist()  
    local connectedGamepads = UserInputService:GetConnectedGamepads()  
    local lastInputType = UserInputService:GetLastInputType()  
    local isUsingGamepadOrTouch = (#connectedGamepads > 0 and lastInputType == Enum.UserInputType.Gamepad1) or lastInputType == Enum.UserInputType.Touch  

    local targetPosition = isUsingGamepadOrTouch and GetClosestTarget()  
    if targetPosition then  
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPosition)  
    end  
end  

RunService.RenderStepped:Connect(SnapAimAssist)


]]-- dont copy this line
