--[[
Modified by https
original Made By Scripty#2063
RespectFilteringEnabled must be false to use it

of you gonna showcase this version of the script make sure to credit me (https) and most importantly credit the original owner Scripty#2063
--]]

local players = game:GetService("Players")
local soundservice = game:GetService("SoundService")
local startergui = game:GetService("StarterGui")
local work = workspace

local defaultwaittime = 0.5
local notificationsoundid = "rbxassetid://9086208751"

local function getallsounds()
	return work:QueryDescendants(">>Sound")
end

local function HideGui()
	local success, result = pcall(function()
		return gethui()
	end)
	if success and result then
		return result
	else
		return game:GetService("CoreGui"):FindFirstChild("RobloxGui")
	end
end

local HiddenUI = HideGui()

local screengui = Instance.new("ScreenGui")
local rootframe = Instance.new("Frame")
local topbar = Instance.new("Frame")
local dragdetector = Instance.new("UIDragDetector")
local topbarshadow = Instance.new("Frame")
local imagelabel = Instance.new("ImageLabel")
local titlelabel = Instance.new("TextLabel")
local exitbutton = Instance.new("TextButton")
local minimizebutton = Instance.new("TextButton")
local backgroundframe = Instance.new("Frame")
local uicornerbackground = Instance.new("UICorner")
local rfestatuslabel = Instance.new("TextLabel")
local mutegamebutton = Instance.new("TextButton")
local uicornermute = Instance.new("UICorner")
local annoyingsoundbutton = Instance.new("TextButton")
local uicornerannoying = Instance.new("UICorner")
local loopplaysoundsbutton = Instance.new("TextButton")
local uicornerloopplay = Instance.new("UICorner")
local devnotelabel = Instance.new("TextLabel")
local stopbutton = Instance.new("TextButton")
local uicornerstop = Instance.new("UICorner")
local unmutegamebutton = Instance.new("TextButton")
local uicornerunmute = Instance.new("UICorner")
local waitspeedlabel = Instance.new("TextLabel")
local waittimetextbox = Instance.new("TextBox")
local uicornertextbox = Instance.new("UICorner")

screengui.Parent = HiddenUI
screengui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screengui.ResetOnSpawn = false

rootframe.Parent = screengui
rootframe.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
rootframe.BorderSizePixel = 0
rootframe.Position = UDim2.new(0.35, 0, 0.30, 0)
rootframe.Size = UDim2.new(0, 438, 0, 277)

topbar.Parent = rootframe
topbar.BackgroundColor3 = Color3.fromRGB(41, 60, 157)
topbar.BorderColor3 = Color3.fromRGB(27, 42, 53)
topbar.BorderSizePixel = 0
topbar.Position = UDim2.new(0, 0, 0, 0)
topbar.Size = UDim2.new(1, 0, 0, 30)

dragdetector.Parent = rootframe

backgroundframe.Parent = rootframe
backgroundframe.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
backgroundframe.BorderColor3 = Color3.fromRGB(27, 42, 53)
backgroundframe.BorderSizePixel = 0
backgroundframe.Position = UDim2.new(0, 0, 0, 30)
backgroundframe.Size = UDim2.new(1, 0, 1, -30)
backgroundframe.Active = true

uicornerbackground.CornerRadius = UDim.new(0, 5)
uicornerbackground.Parent = backgroundframe

topbarshadow.Parent = topbar
topbarshadow.BackgroundColor3 = Color3.fromRGB(30, 45, 118)
topbarshadow.BorderColor3 = Color3.fromRGB(27, 42, 53)
topbarshadow.BorderSizePixel = 0
topbarshadow.Position = UDim2.new(0, 0, 1, 0)
topbarshadow.Size = UDim2.new(1, 0, 0, 5)

imagelabel.Parent = topbar
imagelabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
imagelabel.BackgroundTransparency = 1.000
imagelabel.Position = UDim2.new(0, 0, 0.05, 0)
imagelabel.Size = UDim2.new(0, 29, 0, 27)
imagelabel.Image = "http://www.roblox.com/asset/?id=8798286232"

titlelabel.Parent = imagelabel
titlelabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
titlelabel.BackgroundTransparency = 1.000
titlelabel.Position = UDim2.new(1, 0, 0, 0)
titlelabel.Size = UDim2.new(0, 397, 1, 0)
titlelabel.Font = Enum.Font.GothamSemibold
titlelabel.Text = "FEAG"
titlelabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titlelabel.TextScaled = true
titlelabel.TextSize = 14.000
titlelabel.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
titlelabel.TextWrapped = true

exitbutton.Parent = topbar
exitbutton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
exitbutton.BackgroundTransparency = 1.000
exitbutton.Position = UDim2.new(0.92, 0, 0, 0)
exitbutton.Size = UDim2.new(0, 32, 1, 0)
exitbutton.Font = Enum.Font.GothamSemibold
exitbutton.Text = "x"
exitbutton.TextColor3 = Color3.fromRGB(255, 255, 255)
exitbutton.TextScaled = true
exitbutton.TextSize = 14.000
exitbutton.TextWrapped = true

minimizebutton.Parent = topbar
minimizebutton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
minimizebutton.BackgroundTransparency = 1.000
minimizebutton.Position = UDim2.new(0.85, 0, 0, 0)
minimizebutton.Size = UDim2.new(0, 32, 1, 0)
minimizebutton.Font = Enum.Font.GothamSemibold
minimizebutton.Text = "_"
minimizebutton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizebutton.TextScaled = true
minimizebutton.TextSize = 14.000
minimizebutton.TextWrapped = true

rfestatuslabel.Parent = backgroundframe
rfestatuslabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
rfestatuslabel.BackgroundTransparency = 1.000
rfestatuslabel.Position = UDim2.new(0, 0, 0.01, 0)
rfestatuslabel.Size = UDim2.new(1, 0, 0, 31)
rfestatuslabel.Font = Enum.Font.GothamSemibold
rfestatuslabel.Text = "RespectFilteringEnabled(RFE) : nil"
rfestatuslabel.TextColor3 = Color3.fromRGB(255, 255, 255)
rfestatuslabel.TextScaled = true
rfestatuslabel.TextSize = 14.000
rfestatuslabel.TextWrapped = true

mutegamebutton.Parent = backgroundframe
mutegamebutton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
mutegamebutton.BorderSizePixel = 0
mutegamebutton.Position = UDim2.new(0.02, 0, 0.67, 0)
mutegamebutton.Size = UDim2.new(0.47, 0, 0, 33)
mutegamebutton.Font = Enum.Font.SourceSans
mutegamebutton.Text = "Mute Game (Loop)"
mutegamebutton.TextColor3 = Color3.fromRGB(255, 255, 255)
mutegamebutton.TextScaled = true
mutegamebutton.TextSize = 30.000
mutegamebutton.TextWrapped = true

uicornermute.Parent = mutegamebutton

unmutegamebutton.Parent = backgroundframe
unmutegamebutton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
unmutegamebutton.BorderSizePixel = 0
unmutegamebutton.Position = UDim2.new(0.51, 0, 0.67, 0)
unmutegamebutton.Size = UDim2.new(0.47, 0, 0, 33)
unmutegamebutton.Font = Enum.Font.SourceSans
unmutegamebutton.Text = "Unmute Game"
unmutegamebutton.TextColor3 = Color3.fromRGB(255, 255, 255)
unmutegamebutton.TextScaled = true
unmutegamebutton.TextSize = 30.000
unmutegamebutton.TextWrapped = true

uicornerunmute.Parent = unmutegamebutton

annoyingsoundbutton.Parent = backgroundframe
annoyingsoundbutton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
annoyingsoundbutton.BorderSizePixel = 0
annoyingsoundbutton.Position = UDim2.new(0.02, 0, 0.14, 0)
annoyingsoundbutton.Size = UDim2.new(0.47, 0, 0, 33)
annoyingsoundbutton.Font = Enum.Font.SourceSans
annoyingsoundbutton.Text = "Play All Sounds Once"
annoyingsoundbutton.TextColor3 = Color3.fromRGB(255, 255, 255)
annoyingsoundbutton.TextScaled = true
annoyingsoundbutton.TextSize = 30.000
annoyingsoundbutton.TextWrapped = true

uicornerannoying.Parent = annoyingsoundbutton

loopplaysoundsbutton.Parent = backgroundframe
loopplaysoundsbutton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
loopplaysoundsbutton.BorderSizePixel = 0
loopplaysoundsbutton.Position = UDim2.new(0.51, 0, 0.14, 0)
loopplaysoundsbutton.Size = UDim2.new(0.47, 0, 0, 33)
loopplaysoundsbutton.Font = Enum.Font.SourceSans
loopplaysoundsbutton.Text = "Loop Play Sounds"
loopplaysoundsbutton.TextColor3 = Color3.fromRGB(255, 255, 255)
loopplaysoundsbutton.TextScaled = true
loopplaysoundsbutton.TextSize = 30.000
loopplaysoundsbutton.TextWrapped = true

uicornerloopplay.Parent = loopplaysoundsbutton

stopbutton.Parent = backgroundframe
stopbutton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
stopbutton.BorderSizePixel = 0
stopbutton.Position = UDim2.new(0.02, 0, 0.31, 0)
stopbutton.Size = UDim2.new(0.96, 0, 0, 33)
stopbutton.Font = Enum.Font.SourceSans
stopbutton.Text = "Stop All Loops"
stopbutton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopbutton.TextScaled = true
stopbutton.TextSize = 30.000
stopbutton.TextWrapped = true

uicornerstop.Parent = stopbutton

waitspeedlabel.Parent = backgroundframe
waitspeedlabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
waitspeedlabel.BackgroundTransparency = 1.000
waitspeedlabel.Position = UDim2.new(0.02, 0, 0.46, 0)
waitspeedlabel.Size = UDim2.new(0.5, 0, 0, 50)
waitspeedlabel.Font = Enum.Font.GothamSemibold
waitspeedlabel.Text = "Loop Wait Speed (s):"
waitspeedlabel.TextColor3 = Color3.fromRGB(255, 255, 255)
waitspeedlabel.TextScaled = true
waitspeedlabel.TextSize = 30.000
waitspeedlabel.TextWrapped = true
waitspeedlabel.TextXAlignment = Enum.TextXAlignment.Left

waittimetextbox.Parent = backgroundframe
waittimetextbox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
waittimetextbox.BackgroundTransparency = 0
waittimetextbox.Position = UDim2.new(0.55, 0, 0.47, 0)
waittimetextbox.Size = UDim2.new(0.43, 0, 0, 33)
waittimetextbox.ZIndex = 99999
waittimetextbox.ClearTextOnFocus = false
waittimetextbox.Font = Enum.Font.GothamSemibold
waittimetextbox.Text = tostring(defaultwaittime)
waittimetextbox.TextColor3 = Color3.fromRGB(255, 255, 255)
waittimetextbox.TextScaled = true
waittimetextbox.TextSize = 30.000
waittimetextbox.TextWrapped = true

uicornertextbox.Parent = waittimetextbox

devnotelabel.Parent = backgroundframe
devnotelabel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
devnotelabel.BackgroundTransparency = 1.000
devnotelabel.Position = UDim2.new(0.01, 0, 0.81, 0)
devnotelabel.Size = UDim2.new(0.98, 0, 0, 44)
devnotelabel.Font = Enum.Font.GothamSemibold
devnotelabel.Text = "Dev Note : This Script is FE and it only FE when RespectFilteringEnabled(RFE) is disabled , elseif RespectFilteringEnabled(RFE) is true then it only be client , mostly RespectFilteringEnabled(RFE) disabled game are classic game"
devnotelabel.TextColor3 = Color3.fromRGB(255, 0, 0)
devnotelabel.TextScaled = true
devnotelabel.TextSize = 14.000
devnotelabel.TextWrapped = true

local notificationsound = Instance.new("Sound", screengui)
notificationsound.SoundId = notificationsoundid
notificationsound.Volume = 2

local ismutingloopactive = false
local isplayingloopactive = false
local fullsize = UDim2.new(0, 438, 0, 277)
local minimizedsize = UDim2.new(0, 438, 0, 30)

exitbutton.MouseButton1Click:Connect(function()
	screengui:Destroy()
end)

minimizebutton.MouseButton1Click:Connect(function()
	backgroundframe.Visible = not backgroundframe.Visible
	if backgroundframe.Visible then
		rootframe.Size = fullsize
	else
		rootframe.Size = minimizedsize
	end
end)

unmutegamebutton.MouseButton1Click:Connect(function()
	ismutingloopactive = false
end)

mutegamebutton.MouseButton1Click:Connect(function()
	if ismutingloopactive then return end
	ismutingloopactive = true
	isplayingloopactive = false

	task.spawn(function()
		while ismutingloopactive do
			task.wait()
			for _, sound in getallsounds() do
				if sound:IsA("Sound") then
					sound:Stop()
				end
			end
		end
	end)
end)

annoyingsoundbutton.MouseButton1Click:Connect(function()
	for _, sound in getallsounds() do
		if sound:IsA("Sound") then
			sound:Play()
		end
	end
end)

loopplaysoundsbutton.MouseButton1Click:Connect(function()
	if isplayingloopactive then return end
	isplayingloopactive = true
	ismutingloopactive = false

	task.spawn(function()
		while isplayingloopactive do
			local waittime
			local text = waittimetextbox.Text

			local success, parsedtime = pcall(tonumber, text)
			if success and parsedtime and parsedtime > 0.05 then
				waittime = parsedtime
			else
				waittime = defaultwaittime
			end

			task.wait(waittime)

			for _, sound in getallsounds() do
				if sound:IsA("Sound") then
					sound:Play()
				end
			end
		end
	end)
end)

stopbutton.MouseButton1Click:Connect(function()
	ismutingloopactive = false
	isplayingloopactive = false
end)

notificationsound:Play()

startergui:SetCore("SendNotification", {
	Title = "FEAG (modified)";
	Text = "Made By Scripty#2063 (gamer14_123) - Modified By https";
	Icon = "";
	Duration = 10;
	Button1 = "Yes Sir";
})

local rfesetting = soundservice.RespectFilteringEnabled

if rfesetting == true then
	rfestatuslabel.TextColor3 = Color3.fromRGB(255, 0, 0)
	rfestatuslabel.Text = "RespectFilteringEnabled(RFE) : true"
elseif rfesetting == false then
	rfestatuslabel.TextColor3 = Color3.fromRGB(0, 255, 0)
	rfestatuslabel.Text = "RespectFilteringEnabled(RFE) : false"
else
	rfestatuslabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	rfestatuslabel.Text = "RespectFilteringEnabled(RFE) : unknown? wait what-"

end

