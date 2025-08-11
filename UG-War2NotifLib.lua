local Notifications = {}
local hui = gethui()
local TweenService = game:GetService("TweenService")
local erm = game:GetService("Players").LocalPlayer.PlayerGui.Notifications:Clone()
erm.Parent = hui

local bindable = Instance.new("BindableEvent",hui)
bindable.Name = "Notify"

local template = hui.Notifications:WaitForChild("Notification")
local uiScale = hui.Notifications:WaitForChild("UIScale")

Notifications.COLORS = {
	Green = Color3.fromRGB(80, 255, 80),
	Red = Color3.fromRGB(255, 126, 126),
	White = Color3.new(1, 1, 1),
	Yellow = Color3.new(1, 0.835294, 0)
}

local tweenIn = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local tweenOut = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
local isShowing = false
local queue = {}
local lastNotification = {Message = "", Time = 0}

local function showNotification(message, color, duration)
	local notif = template:Clone()
	notif.Parent = template.Parent
	local shadow = notif:WaitForChild("Shadow")
	local textLabel = notif:WaitForChild("TextLabel")
	local stroke = textLabel:WaitForChild("UIStroke")
	textLabel.Text = message
	textLabel.TextColor3 = color
	stroke.Color = color:Lerp(Color3.new(), 0.9)
	local width = textLabel.TextBounds.X / uiScale.Scale
	shadow.Size = UDim2.new(0, width + width * 0.2, 1, 20)
	shadow.ImageTransparency = 1
	textLabel.TextTransparency = 1
	stroke.Transparency = 1
	notif.Position = UDim2.new(0.5, 0, 1, 0)
	notif.Visible = true

	TweenService:Create(notif, tweenIn, {Position = template.Position}):Play()
	TweenService:Create(textLabel, tweenIn, {TextTransparency = 0}):Play()
	TweenService:Create(stroke, tweenIn, {Transparency = 0}):Play()
	TweenService:Create(shadow, tweenIn, {ImageTransparency = 0.4}):Play()
	task.wait(0.5)

	local elapsed = 0
	local displayTime = duration or 4.5
	repeat
		elapsed += 0.1
		task.wait(0.1)
	until elapsed >= displayTime or #queue > 1

	TweenService:Create(notif, tweenOut, {Position = UDim2.new(0.5, 0, 1, 0)}):Play()
	TweenService:Create(textLabel, tweenOut, {TextTransparency = 1}):Play()
	TweenService:Create(stroke, tweenOut, {Transparency = 1}):Play()
	TweenService:Create(shadow, tweenOut, {ImageTransparency = 1}):Play()
	task.wait(0.5)
	notif:Destroy()
end

local function processQueue()
	if next(queue) then
		isShowing = true
		showNotification(queue[1].Message, queue[1].Color, queue[1].Duration)
		table.remove(queue, 1)
		processQueue()
	else
		isShowing = false
	end
end

local function queueNotification(message, color, duration)
	if lastNotification.Message ~= message or lastNotification.Time + 1 <= tick() then
		lastNotification.Message = message
		lastNotification.Time = tick()
		if #queue < 5 then
			color = color or Notifications.COLORS.White
			table.insert(queue, {Message = message, Color = color, Duration = duration})
			if not isShowing then processQueue() end
		end
	end
end

function Notifications.SendNotification(_, message, color, duration)
	bindable:Fire(message, color, duration)
end

bindable.Event:Connect(function(message, color, duration)
	queueNotification(message, color, duration)
end)

return Notifications
