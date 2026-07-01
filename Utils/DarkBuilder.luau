--[[
	made by: Roblox-HttpSpy
	
==== DOCUMENTATION ====

DarkBuilder:CreateSwitch(
	text: string,
	defaultState: boolean,
	callback: (boolean)->(any?)
)
creates a UI Switch
text is the text that would be applied
defaultState is if the switch should be on by default or not.
callback is the function that is called when the switch is triggered. and the function is called with a boolean (true if on - false if off)

Builder:CreateButton(
	text: string,
	callback: ()->(any?)
)
text is the text that would be applied to the button
callback the function that is called when buttin is pressed

DarkBuilder:GetGui(): ScreenGui
returns the ScreenGui of the UI (allow you to add extra customizations)

DarkBuilder:SetTitle(text: string)
sets the title of the UI

DarkBuilder.Version: string
a property of the current version of DarkBuilder

==== TEMPLATE'S ====

DarkBuilder:SetTitle("OP CHEATS")
DarkBuilder:CreateSwitch("Infinite Jump", false, function(state)
	print("Infinite Jump toggled:", state)
end)

DarkBuilder:CreateSwitch("Show Hitboxes", false, function(state)
	print("Hitboxes toggled:", state)
end)

DarkBuilder:CreateButton("TELEPORT TO SPAWN", function()
	print("Teleport button clicked")
end)

==== HOW TO LOAD UILIB ====
local DarkBuilder = loadstring(game:HttpGet("https://raw.githubusercontent.com/Roblox-HttpSpy/Random-Silly-stuff/refs/heads/main/Utils/DarkBuilder.luau"))()
DarkBuilder:CreateSwitch("example", false, function(state)
	print(state)
end)
]]--
local is_exploit_env = true
if debug.setsafeenv then --// if showhow your executor supports this should set the script to a safeenv allowing the luau complier todo advanced optimizations
	debug.setsafeenv(coroutine.running(), true)
end
if not identifyexecutor then --// like in studio (why?)
	is_exploit_env = false
end

local TweenService = game:GetService("TweenService")
local CoreGui
if (is_exploit_env and gethui) then
	CoreGui = gethui()
elseif is_exploit_env then
	CoreGui = game:GetService("CoreGui")
else
	CoreGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui", 300)
end

local THEME = table.freeze({
	Background = Color3.fromRGB(20, 20, 20),
	SecondaryBackground = Color3.fromRGB(30, 30, 30),
	ElementBackground = Color3.fromRGB(45, 45, 45),
	AccentBlue = Color3.fromRGB(0, 130, 255),
	Text = Color3.fromRGB(255, 255, 255),
	TextDark = Color3.fromRGB(200, 200, 200)
})
local FONT = Enum.Font.BuilderSansExtraBold

if CoreGui:FindFirstChild("DarkCheats") then
	CoreGui.DarkCheats:Destroy()
end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = ""
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local BoundingFrame = Instance.new("Frame", ScreenGui)
BoundingFrame.Name = "BoundingFrame"
BoundingFrame.Size = UDim2.fromScale(1, 1)
BoundingFrame.BackgroundTransparency = 1

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainWindow"
MainFrame.BackgroundColor3 = THEME.Background
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.fromScale(0.5, 0.5)
MainFrame.Size = UDim2.fromScale(0.35, 0.45)
MainFrame.BorderSizePixel = 0

local Bubble = Instance.new("TextLabel", ScreenGui)
Bubble.Name = "Bubble"
Bubble.Size = UDim2.new(0, 70, 0, 70)
Bubble.Position = MainFrame.Position
Bubble.BackgroundColor3 = THEME.Background
Bubble.TextColor3 = THEME.Text
Bubble.RichText = true
Bubble.Text = "<font size='28' weight='700' family='rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json'>lightning-bolt</font>"
Bubble.Font = FONT
Bubble.Visible = false
Instance.new("UICorner", Bubble)

local Dragging = false
local function SetDrag(UIDragger, DragEnd)
	UIDragger.BoundingUI = BoundingFrame
	UIDragger.DragStart:Connect(function()
		Dragging = true
	end)
	UIDragger.DragEnd:Connect(DragEnd)
	UIDragger.DragContinue:Connect(function()
		Dragging = false
	end)
end

local MainFrameDrag = Instance.new("UIDragDetector", MainFrame)
local BubbleDrag = Instance.new("UIDragDetector", Bubble)

SetDrag(MainFrameDrag, function()
	if Dragging then
		MainFrame.Visible = false
		Bubble.Visible = true
	end
end)

SetDrag(BubbleDrag, function()
	if Dragging then
		Bubble.Visible = false
		MainFrame.Visible = true
	end
end)

local SizeConstraint = Instance.new("UISizeConstraint", MainFrame)
SizeConstraint.MinSize = Vector2.new(100, 100)
SizeConstraint.MaxSize = Vector2.new(600, 700)

local AspectRatio = Instance.new("UIAspectRatioConstraint", MainFrame)
AspectRatio.AspectRatio = 0.857 
AspectRatio.AspectType = Enum.AspectType.ScaleWithParentSize
AspectRatio.DominantAxis = Enum.DominantAxis.Width

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 12)

local Shadow = Instance.new("UIShadow", MainFrame)
Shadow.BlurRadius = UDim.new(0, 15)
Shadow.Color = THEME.Background

local BubbleShadow = Instance.new("UIShadow", Bubble)
BubbleShadow.BlurRadius = UDim.new(0, 15)
BubbleShadow.Color = THEME.Background

local BubbleStroke = Instance.new("UIStroke", Bubble)
BubbleStroke.Color = THEME.Text
BubbleStroke.Transparency = 0.5
BubbleStroke.Thickness = 4
BubbleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local TitleLabel = Instance.new("TextLabel", MainFrame)
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(1, 0, 0, 50)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "DarkCheats"
TitleLabel.Font = FONT
TitleLabel.TextSize = 24
TitleLabel.TextColor3 = THEME.Text

local Divider = Instance.new("Frame", MainFrame)
Divider.Size = UDim2.new(1, 0, 0, 2)
Divider.Position = UDim2.new(0, 0, 0, 50)
Divider.BackgroundColor3 = THEME.SecondaryBackground
Divider.BorderSizePixel = 0

local Content = Instance.new("ScrollingFrame", MainFrame)
Content.Name = "Content"
Content.Size = UDim2.new(1, -20, 1, -65)
Content.Position = UDim2.new(0, 10, 0, 55)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = THEME.ElementBackground
Content.BorderSizePixel = 0
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y

local ContentLayout = Instance.new("UIListLayout", Content)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 12)

local ContentPadding = Instance.new("UIPadding", Content)
ContentPadding.PaddingTop = UDim.new(0, 10)
ContentPadding.PaddingBottom = UDim.new(0, 10)
ContentPadding.PaddingLeft = UDim.new(0, 10)
ContentPadding.PaddingRight = UDim.new(0, 10)

local Builder = {}
function Builder:CreateButton(text, callback)
	local Button = Instance.new("TextButton", Content)
	Button.Size = UDim2.new(1, 0, 0, 50)
	Button.BackgroundColor3 = THEME.SecondaryBackground
	Button.Text = text
	Button.Font = FONT
	Button.TextSize = 18
	Button.TextColor3 = THEME.Text
	Button.AutoButtonColor = false
	Button.BorderSizePixel = 0
	
	local Corner = Instance.new("UICorner", Button)
	Corner.CornerRadius = UDim.new(0, 8)
	
	Button.MouseEnter:Connect(function()
		TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = THEME.ElementBackground}):Play()
	end)
	
	Button.MouseLeave:Connect(function()
		TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = THEME.SecondaryBackground}):Play()
	end)
	
	Button.MouseButton1Click:Connect(function()
		local ClickTween = TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = THEME.AccentBlue})
		ClickTween:Play()
		ClickTween.Completed:Wait()
		TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = THEME.ElementBackground}):Play()
		
		if callback then callback() end
	end)
	
	return Button
end

function Builder:CreateSwitch(text, defaultState, callback)
	local SwitchContainer = Instance.new("Frame", Content)
	SwitchContainer.Size = UDim2.new(1, 0, 0, 50)
	SwitchContainer.BackgroundColor3 = THEME.SecondaryBackground
	SwitchContainer.BorderSizePixel = 0
	
	local ContainerCorner = Instance.new("UICorner", SwitchContainer)
	ContainerCorner.CornerRadius = UDim.new(0, 8)
	
	local Label = Instance.new("TextLabel", SwitchContainer)
	Label.Size = UDim2.new(1, -80, 1, 0)
	Label.Position = UDim2.new(0, 15, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.Font = FONT
	Label.TextSize = 18
	Label.TextColor3 = THEME.Text
	Label.TextXAlignment = Enum.TextXAlignment.Left
	
	local SwitchBase = Instance.new("TextButton", SwitchContainer)
	SwitchBase.Size = UDim2.new(0, 50, 0, 26)
	SwitchBase.AnchorPoint = Vector2.new(1, 0.5)
	SwitchBase.Position = UDim2.new(1, -15, 0.5, 0)
	SwitchBase.BackgroundColor3 = THEME.ElementBackground
	SwitchBase.Text = ""
	SwitchBase.AutoButtonColor = false
	
	local SwitchCorner = Instance.new("UICorner", SwitchBase)
	SwitchCorner.CornerRadius = UDim.new(1, 0)
	
	local Knob = Instance.new("Frame", SwitchBase)
	Knob.Size = UDim2.new(0, 20, 0, 20)
	Knob.AnchorPoint = Vector2.new(0, 0.5)
	Knob.BackgroundColor3 = THEME.Text
	
	local KnobCorner = Instance.new("UICorner", Knob)
	KnobCorner.CornerRadius = UDim.new(1, 0)
	
	local isToggled = defaultState or false
	
	local function UpdateSwitch(animated)
		local targetColor = isToggled and THEME.AccentBlue or THEME.ElementBackground
		local targetPos = isToggled and UDim2.new(1, -23, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
		
		if animated then
			TweenService:Create(SwitchBase, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {BackgroundColor3 = targetColor}):Play()
			TweenService:Create(Knob, TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {Position = targetPos}):Play()
		else
			SwitchBase.BackgroundColor3 = targetColor
			Knob.Position = targetPos
		end
	end
	
	SwitchBase.MouseButton1Click:Connect(function()
		isToggled = not isToggled
		UpdateSwitch(true)
		if callback then callback(isToggled) end
	end)
	
	UpdateSwitch(false)
	return SwitchContainer
end

function Builder:GetGui()
	return ScreenGui
end

function Builder:SetTitle(text)
	TitleLabel.Text = text
end

Builder.Version = "1.0.0"

return table.freeze(Builder)
