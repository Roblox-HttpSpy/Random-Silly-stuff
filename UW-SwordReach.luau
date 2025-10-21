local work = game:GetService("Workspace")
local plr = game:GetService("Players").LocalPlayer
local gui = gethui():FindFirstChild("ToolReachGUI")

if gui then
	local f = gui:FindFirstChild("Frame")
	local b = f and f:FindFirstChildOfClass("TextBox")
	if f and b then
		f.Position = UDim2.new(0.5,-75,0.5,-25)
		b.Text = "5"
	end
	return
end

gui = Instance.new("ScreenGui", gethui())
gui.Name = "ToolReachGUI"

local f = Instance.new("Frame", gui)
f.Name = "Frame"
f.Size = UDim2.new(0,150,0,50)
f.Position = UDim2.new(0.5,-75,0.5,-25)
f.BackgroundColor3 = Color3.new(0,0,0)
f.BackgroundTransparency = 0.4
f.AnchorPoint = Vector2.new(0.5,0.5)
Instance.new("UICorner", f).CornerRadius = UDim.new(0,8)
Instance.new("UIDragDetector", f)

local b = Instance.new("TextBox", f)
b.Size = UDim2.new(0.8,0,0.6,0)
b.Position = UDim2.new(0.1,0,0.2,0)
b.BackgroundTransparency = 0.9
b.TextColor3 = Color3.new(1,1,1)
b.Text = "5"
b.TextWrapped = true
b.ClearTextOnFocus = false
b.Font = "BuilderSansBold"
b.TextSize = 14
Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)

local vis = Instance.new("Part", work)
vis.Size = Vector3.new(5,5,5)
vis.Color = Color3.fromHSV(0,1,1)
vis.Transparency = 0.6
vis.Anchored = true
vis.CanCollide = false
vis.Shape = Enum.PartType.Ball
vis.Material = Enum.Material.ForceField
vis.BottomSurface = Enum.SurfaceType.Smooth
vis.TopSurface = Enum.SurfaceType.Smooth
vis.CastShadow = false

b:GetPropertyChangedSignal("Text"):Connect(function()
	local r = tonumber(b.Text)
	if r then
		if r > 50 then
			b.Text = "50"
			r = 50
		end
		vis.Size = Vector3.new(r,r,r)
	end
end)

local function hit(p,h)
	local c = p.Parent
	local hum = c and c:FindFirstChildOfClass("Humanoid")
	if hum and c.Name ~= plr.Name then
		for _,part in pairs(c:GetChildren()) do
			if part:IsA("BasePart") then
				firetouchinterest(part,h,0)
				firetouchinterest(part,h,1)
			end
		end
	end
end

local hue = 0
game:GetService("RunService").RenderStepped:Connect(function()
	hue = (hue + 0.002) % 1
	vis.Color = Color3.fromHSV(hue, 1, 1)
	local tool = plr.Character and plr.Character:FindFirstChild("Sword")
	if not tool then vis.Parent = nil return end
	local h = tool:FindFirstChild("Handle")
	if h then
		vis.Parent = work
		local r = tonumber(b.Text) or 5
		if r > 50 then r = 50 b.Text = "50" end
		vis.Size = Vector3.new(r,r,r)
		vis.CFrame = h.CFrame
		for _,v in pairs(game.Players:GetPlayers()) do
			if v ~= plr then
				if v.Team and plr.Team and v.Team ~= plr.Team then
					local hrp = v.Character and v.Character:FindFirstChild("HumanoidRootPart")
					if hrp and (hrp.Position - h.Position).Magnitude <= r then
						pcall(function() hit(hrp,h) end)
					end
				end
			end
		end
	end
end)
