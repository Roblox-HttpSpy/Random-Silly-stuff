--[[ 
AIMBOT For First person Shooter games...

btw this script isnt really "mine mine" as i got this script is from
a LocalScript in a game that had Aim Assist, so i decompiled it
modified it (snaps camera + some extra stuff) and tada! heres the script,

this is the game i was talking about btw = https://www.roblox.com/games/12137249458/FPS-Gun-Grounds-FFA
]]--

local TARGET_DISTANCE_LIMIT = 150 -- aimbot distance

local reference = cloneref or function(obj)
	return obj
end

local function service(s)
	return reference(game:GetService(s))
end

local players = service("Players")
local run_service = service("RunService")
local workspace = service("Workspace")
local huge, cframe, raycast = math.huge, CFrame.new, RaycastParams.new

local local_player = players.LocalPlayer
local camera = reference(workspace.CurrentCamera)

local function are_on_same_team(player1, player2)
	return player1.Team ~= nil
		and player2.Team ~= nil
		and player1.Team == player2.Team
end

local function target_fully_visible(target_position, target_character)
	local camera_position = camera.CFrame.Position
	local direction = target_position - camera_position
	local distance = direction.Magnitude
	
	if distance <= 0 or distance > TARGET_DISTANCE_LIMIT then
		return false
	end
	
	local viewport_point, on_screen = camera:WorldToViewportPoint(target_position)
	if not on_screen or viewport_point.Z <= 0 then
		return false
	end
	
	local raycast_params = raycast()
	raycast_params.FilterType = Enum.RaycastFilterType.Exclude
	raycast_params.FilterDescendantsInstances = { local_player.Character }
	
	local ray_result = workspace:Raycast(
		camera_position,
		direction.Unit * distance,
		raycast_params
	)
	
	return ray_result ~= nil
		and ray_result.Instance:IsDescendantOf(target_character)
end

local function get_closest_target()
	local closest_distance = huge
	local closest_target = nil
	local camera_position = camera.CFrame.Position
	
	for _, player in players:GetPlayers() do
		if player == local_player then
			continue
		end
		
		local character = player.Character
		if not character then
			continue
		end
		
		local humanoid = character:FindFirstChild("Humanoid")
		local root_part = character:FindFirstChild("HumanoidRootPart")
		
		if not humanoid or not root_part or humanoid.Health <= 0 then
			continue
		end
		
		if are_on_same_team(local_player, player) then
			continue
		end
		
		local target_position = root_part.Position
		local distance = (target_position - camera_position).Magnitude
		
		if distance > TARGET_DISTANCE_LIMIT or distance >= closest_distance then
			continue
		end
		
		if target_fully_visible(target_position, character) then
			closest_target = target_position
			closest_distance = distance
		end
	end
	
	return closest_target
end

local function snap_aim_assist()
	local target_position = get_closest_target()
	if target_position then
		camera.CFrame = cframe(camera.CFrame.Position, target_position)
	end
end

run_service.RenderStepped:Connect(snap_aim_assist)
