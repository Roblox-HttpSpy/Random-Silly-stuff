--!optimize 2

--[[
	made by: Roblox-HttpSpy
	
==== DOCUMENTATION ====

[ FUNCTION ]
DarkBuilder:CreateSwitch(
	text: string,
	defaultState: boolean,
	callback: (boolean)->(any?)
)
creates a UI Switch
text: is the text that would be applied
defaultState: is if the switch should be on by default or not.
callback: is the function that is called when the switch is triggered. and the function is called with a boolean (true if on - false if off)

[ FUNCTION ]
Builder:CreateButton(
	text: string,
	callback: ()->(any?)
)
text: is the text that would be applied to the button
callback: the function that is called when buttin is pressed

[ PROPERTY ]
Builder.MainGui :: ScreenGui
returns the ScreenGui of the UI (allow you to add extra customizations)

[ PROPERTY ]
Builder.Bubble :: TextLabel
the bubble that is used for the minimized mode of the UI
(btw to minimize tap/click anywhere on the UI outside the place that has the elements like title to minimize the UI)

[ FUNCTION ]
Builder:GetTheme(): {[string] = Color3}
the internal "THEME" table that is used when creating the UI
setting themes like GetTheme().Text = Color3.new(...) any new elements will have that color
alltho DarkBuilder:GetGui() is recommended

[ FUNCTION ]
DarkBuilder:SetTitle(text: string, color: Color3?)
text: sets the title of the UI
color: is the title color. can be left empty for the default (white)

[ PROPERTY ]
DarkBuilder.Version :: string
a property of the current version of DarkBuilder

[ PROPERTY ]
Builder.Storage :: Folder
DarkBuilder adds a empty folder inside the ScreenGui each time the UILib is loaded
feel free to use it as a cache folder like storing custom sounds for clicks and ect.

==== TEMPLATE EXAMPLE ====
> > > > > > > > > > > > > > > > > > > > 

--// uilib
local Loader, err = loadstring(game:HttpGet("https://raw.githubusercontent.com/Roblox-HttpSpy/Random-Silly-stuff/refs/heads/main/Utils/DarkBuilder.luau"), "DarkUILib_Loader")

local success, DarkBuilder = pcall(Loader)
if not Loader then
	return error("couldn't load DarkBuilder.. reason: "..tostring(err), 0)
elseif not success then
	return error("couldn't run DarkBuilder.. reason: "..tostring(DarkBuilder), 0)
end

--// script
local Player = game:GetService("Players").LocalPlayer
local huge = math.huge

local function sethumanoidprop(state, prop, old, new)
	if Player.Character then
		local humanoid = Player.Character:WaitForChild("Humanoid", 300)
		if state then
			humanoid[prop] = new
			return
		end
		humanoid[prop] = old
	end
end

-- DarkBuilder:SetTitle("Cheats")

DarkBuilder:CreateSwitch("Super Speed", false, function(state)
	sethumanoidprop(state, "WalkSpeed", 16, 200)
end)

DarkBuilder:CreateSwitch("Super Jump", false, function(state)
	sethumanoidprop(state, "JumpPower",  50, 500)
end)

DarkBuilder:CreateSwitch("INF Health", false, function(state)
	sethumanoidprop(state, "Health", 100, huge)
end)

DarkBuilder:CreateButton("Reset", function()
	sethumanoidprop(true, "Health", 0, 0)
end)

DarkBuilder:CreateButton("Sit", function()
	sethumanoidprop(true, "Sit", true, true)
end)

< < < < < < < < < < < < < < < < < < < < 
]]--

local good_exploit_env = true
local ref = cloneref
if debug.setsafeenv then --// if showhow your executor supports this (i think potassium only has this idk) it should set the script to a safeenv allowing the luau complier todo advanced optimizations
	pcall(debug.setsafeenv, coroutine.running(), true)
end
if not game:GetService("CoreGui") then --// like in studio (why?)
	good_exploit_env = false
end
local function reference(obj)
	if ref then
		return ref(obj)
	end
	return obj
end

local TweenService = reference(game:GetService("TweenService"))
local UIS = reference(game:GetService("UserInputService"))
local CoreGui
if (good_exploit_env and gethui) then
	CoreGui = gethui()
elseif good_exploit_env then
	CoreGui = game:FindService("CoreGui") --// no point of using cloneref since devs can't no longer reference this service
else
	CoreGui = reference(game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui", 300)) --// should never happen (unless your in studio or something.. why)
end

if CoreGui:FindFirstChild("DarkUILib - By: Roblox-HttpSpy") then
	CoreGui["DarkUILib - By: Roblox-HttpSpy"]:Destroy()
end

--// Builder:GetTheme() //--
local rgb = Color3.fromRGB
local THEME = {
	Background = rgb(20, 20, 20),
	SecondaryBackground = rgb(30, 30, 30),
	ElementBackground = rgb(45, 45, 45),
	AccentBlue = rgb(0, 130, 255),
	Text = rgb(255, 255, 255),
	TextDark = rgb(200, 200, 200)
}
local Enums = Enum
local FONT = Font.fromEnum(Enums.Font.BuilderSansExtraBold)

local inew, safecall = Instance.new, pcall
local UD, UD2, fromScale = UDim.new, UDim2.new, UDim2.fromScale
local V2 = Vector2.new
local tween1, tween2 = TweenInfo.new(0.1), TweenInfo.new(0.2)

local ScreenGui = inew("ScreenGui", CoreGui)
ScreenGui.Name = "DarkUILib - By: Roblox-HttpSpy"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local Storage = inew("Folder", ScreenGui)
Storage.Name = "Storage"

local BoundingFrame = inew("Frame", ScreenGui)
BoundingFrame.Name = "BoundingFrame"
BoundingFrame.Size = fromScale(1, 1)
BoundingFrame.BackgroundTransparency = 1

local MainFrame = inew("Frame", ScreenGui)
MainFrame.Name = "MainWindow"
MainFrame.BackgroundColor3 = THEME.Background
MainFrame.AnchorPoint = V2(0.5, 0.5)
MainFrame.Position = fromScale(0.5, 0.5)
MainFrame.Size = fromScale(0.35, 0.45)
MainFrame.BorderSizePixel = 0

local Bubble = inew("TextLabel", ScreenGui)
Bubble.Name = "Bubble"
Bubble.Size = UD2(0, 70, 0, 70)
Bubble.Position = MainFrame.Position
Bubble.BackgroundColor3 = THEME.Background
Bubble.TextColor3 = THEME.Text
Bubble.RichText = true
Bubble.Text = "<font size='28' weight='700' family='rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json'>lightning-bolt</font>"
Bubble.FontFace = FONT
Bubble.Visible = false
inew("UICorner", Bubble)

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

local MainFrameDrag = inew("UIDragDetector", MainFrame)
local BubbleDrag = inew("UIDragDetector", Bubble)

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

local SizeConstraint = inew("UISizeConstraint", MainFrame)
SizeConstraint.MinSize = V2(100, 100)
SizeConstraint.MaxSize = V2(600, 700)

local AspectRatio = inew("UIAspectRatioConstraint", MainFrame)
AspectRatio.AspectRatio = 0.857 
AspectRatio.AspectType = Enums.AspectType.ScaleWithParentSize
AspectRatio.DominantAxis = Enums.DominantAxis.Width

local MainCorner = inew("UICorner", MainFrame)
MainCorner.CornerRadius = UD(0, 12)

local Shadow = inew("UIShadow", MainFrame)
Shadow.BlurRadius = UD(0, 25)
Shadow.Color = THEME.Background

local BubbleShadow = inew("UIShadow", Bubble)
BubbleShadow.BlurRadius = UD(0, 25)
BubbleShadow.Color = THEME.Background

local BubbleStroke = inew("UIStroke", Bubble)
BubbleStroke.Color = THEME.Text
BubbleStroke.Transparency = 0.5
BubbleStroke.Thickness = 4
BubbleStroke.ApplyStrokeMode = Enums.ApplyStrokeMode.Border

local TitleLabel = inew("TextLabel", MainFrame)
TitleLabel.Name = "Title"
TitleLabel.Size = UD2(1, 0, 0, 50)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "DarkCheats"
TitleLabel.FontFace = FONT
TitleLabel.TextSize = 24
TitleLabel.TextColor3 = THEME.Text

local Divider = inew("Frame", MainFrame)
Divider.Size = UD2(1, 0, 0, 2)
Divider.Position = UD2(0, 0, 0, 50)
Divider.BackgroundColor3 = THEME.SecondaryBackground
Divider.BorderSizePixel = 0

local Content = inew("ScrollingFrame", MainFrame)
Content.Name = "Content"
Content.Size = UD2(1, -20, 1, -65)
Content.Position = UD2(0, 10, 0, 55)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = THEME.ElementBackground
Content.BorderSizePixel = 0
Content.CanvasSize = UD2(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enums.AutomaticSize.Y

local ContentLayout = inew("UIListLayout", Content)
ContentLayout.SortOrder = Enums.SortOrder.LayoutOrder
ContentLayout.Padding = UD(0, 12)

local ContentPadding = inew("UIPadding", Content)
ContentPadding.PaddingTop = UD(0, 10)
ContentPadding.PaddingBottom = UD(0, 10)
ContentPadding.PaddingLeft = UD(0, 10)
ContentPadding.PaddingRight = UD(0, 10)

local Builder = {}
function Builder:CreateButton(text, callback)
	local Button = inew("TextButton", Content)
	Button.Size = UD2(1, 0, 0, 50)
	Button.BackgroundColor3 = THEME.SecondaryBackground
	Button.Text = text
	Button.FontFace = FONT
	Button.TextSize = 18
	Button.TextColor3 = THEME.Text
	Button.AutoButtonColor = false
	Button.BorderSizePixel = 0
	
	inew("UICorner", Button).CornerRadius = UD(0, 8)
	
	Button.MouseEnter:Connect(function()
		TweenService:Create(Button, tween2, {BackgroundColor3 = THEME.ElementBackground}):Play()
	end)
	
	Button.MouseLeave:Connect(function()
		TweenService:Create(Button, tween2, {BackgroundColor3 = THEME.SecondaryBackground}):Play()
	end)
	
	Button.Activated:Connect(function()
		local ClickTween = TweenService:Create(Button, tween1, {BackgroundColor3 = THEME.AccentBlue})
		ClickTween:Play()
		ClickTween.Completed:Wait()
		
		local isTouch = UIS:GetLastInputType() == Enums.UserInputType.Touch
		local targetColor = isTouch and THEME.SecondaryBackground or THEME.ElementBackground
		TweenService:Create(Button, tween2, {BackgroundColor3 = targetColor}):Play()
		
		if callback then
			local bool, err = safecall(callback)
			if not bool then
				return error(err, 2)
			end
		end
	end)
	
	return Button
end

function Builder:CreateSwitch(text, defaultState, callback)
	local SwitchContainer = inew("Frame", Content)
	SwitchContainer.Size = UD2(1, 0, 0, 50)
	SwitchContainer.BackgroundColor3 = THEME.SecondaryBackground
	SwitchContainer.BorderSizePixel = 0
	
	inew("UICorner", SwitchContainer).CornerRadius = UD(0, 8)
	
	local Label = inew("TextLabel", SwitchContainer)
	Label.Size = UD2(1, -80, 1, 0)
	Label.Position = UD2(0, 15, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.FontFace = FONT
	Label.TextSize = 18
	Label.TextColor3 = THEME.Text
	Label.TextXAlignment = Enums.TextXAlignment.Left
	
	local SwitchBase = inew("TextButton", SwitchContainer)
	SwitchBase.Size = UD2(0, 50, 0, 26)
	SwitchBase.AnchorPoint = V2(1, 0.5)
	SwitchBase.Position = UD2(1, -15, 0.5, 0)
	SwitchBase.BackgroundColor3 = THEME.ElementBackground
	SwitchBase.Text = ""
	SwitchBase.AutoButtonColor = false
	
	inew("UICorner", SwitchBase).CornerRadius = UD(1, 0)
	
	local Knob = inew("Frame", SwitchBase)
	Knob.Size = UD2(0, 20, 0, 20)
	Knob.AnchorPoint = V2(0, 0.5)
	Knob.BackgroundColor3 = THEME.Text
	
	local KnobCorner = inew("UICorner", Knob)
	KnobCorner.CornerRadius = UD(1, 0)
	
	local isToggled = defaultState or false
	
	local function UpdateSwitch(animated)
		local targetColor = isToggled and THEME.AccentBlue or THEME.ElementBackground
		local targetPos = isToggled and UD2(1, -23, 0.5, 0) or UD2(0, 3, 0.5, 0)
		if animated then
			TweenService:Create(SwitchBase, tween2, {BackgroundColor3 = targetColor}):Play()
			TweenService:Create(Knob, tween2, {Position = targetPos}):Play()
		else
			SwitchBase.BackgroundColor3 = targetColor
			Knob.Position = targetPos
		end
	end
	
	SwitchBase.Activated:Connect(function()
		isToggled = not isToggled
		UpdateSwitch(true)
		if callback then
			local bool, err = safecall(callback, isToggled)
			if not bool then
				return error(err, 2)
			end
		end
	end)
	
	UpdateSwitch(false)
	return SwitchContainer
end

function Builder:GetTheme()
	return THEME
end

function Builder:SetTitle(text, color)
	TitleLabel.Text = text
	if color then
		TitleLabel.TextColor3 = color
	end
end

Builder.MainGui = ScreenGui
Builder.Bubble = Bubble

Builder.Storage = Storage
Builder.Version = "1.1.0"

return table.freeze(Builder)
