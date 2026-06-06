--// by https - github: github.com/roblox-httpspy/
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui") --// game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui", 60) -- if you wanna test in studio

local VM = UIS:CreateVirtualInput()
local protect, make, CodeEnum = pcall, Instance.new, Enum.KeyCode
local udim, udim2, vector2, color = UDim.new, UDim2.new, Vector2.new, Color3.fromRGB
local sfind, tinsert = string.find, table.insert

if not VM then
	return error("[keyboard script] VirtualInput could not be initiated (for some reason)", 3)
end

--// configs //--
local MaxUISize, MinUISize = vector2(500, 400), vector2(400, 220) -- big version: vector2(1000, 420), vector2(520, 220)

--// script //--
local function create(class, parent, properties)
	local instance = make(class)
	if properties then
		for prop, val in properties do
			instance[prop] = val
		end
	end
	if parent then
		instance.Parent = parent
	end
	return instance
end

local MainGui = create("ScreenGui", CoreGui, {
	Name = "MobileVirtualKeyboard",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

local dragWrap = create("Frame", MainGui, {
	Name = "KeyboardDragWrap",
	Size = udim2(0.85, 0, 0.42, 0),
	Position = udim2(0.5, 0, 0.75, 0),
	AnchorPoint = vector2(0.5, 0.5),
	BackgroundColor3 = color(225, 225, 225),
	BackgroundTransparency = 0.55
})

make("UICorner", dragWrap).CornerRadius = udim(0, 14)

create("UIPadding", dragWrap, {
	PaddingTop = udim(0, 14),
	PaddingBottom = udim(0, 14),
	PaddingLeft = udim(0, 14),
	PaddingRight = udim(0, 14)
})

create("UISizeConstraint", dragWrap, {
	MinSize = MinUISize,
	MaxSize = MaxUISize
})

make("UIDragDetector", dragWrap)

local keyboardFrame = create("Frame", dragWrap, {
	Name = "KeyboardMain",
	Size = udim2(1, 0, 1, 0),
	BackgroundColor3 = color(40, 40, 40),
	Active = true
})

make("UICorner", keyboardFrame).CornerRadius = udim(0, 8)

create("UIPadding", keyboardFrame, {
	PaddingTop = udim(0, 6),
	PaddingBottom = udim(0, 6),
	PaddingLeft = udim(0, 6),
	PaddingRight = udim(0, 6)
})

local function handleKeyPress(button, code)
	local isDown = false
	local function press()
		if isDown then return end
		isDown = true
		button.BackgroundColor3 = color(70, 70, 70)
		protect(VM.SendKey, VM, true, code, false)
	end
	
	local function release()
		if not isDown then return end
		isDown = false
		button.BackgroundColor3 = color(20, 20, 20)
		protect(VM.SendKey, VM, false, code, false)
	end
	
	button.MouseButton1Down:Connect(press)
	button.MouseButton1Up:Connect(release)
	button.MouseLeave:Connect(release)
end

--// keys
local layout = {
	{
		{Name = "Esc", Code = CodeEnum.Escape, Weight = 1.4},
		{Name = "F1", Code = CodeEnum.F1}, {Name = "F2", Code = CodeEnum.F2},
		{Name = "F3", Code = CodeEnum.F3}, {Name = "F4", Code = CodeEnum.F4},
		{Name = "F5", Code = CodeEnum.F5}, {Name = "F6", Code = CodeEnum.F6},
		{Name = "F7", Code = CodeEnum.F7}, {Name = "F8", Code = CodeEnum.F8},
		{Name = "F9", Code = CodeEnum.F9}, {Name = "F10", Code = CodeEnum.F10},
		{Name = "F11", Code = CodeEnum.F11}, {Name = "F12", Code = CodeEnum.F12},
	},
	{
		{Name = "`", Code = CodeEnum.Backquote}, {Name = "1", Code = CodeEnum.One},
		{Name = "2", Code = CodeEnum.Two}, {Name = "3", Code = CodeEnum.Three},
		{Name = "4", Code = CodeEnum.Four}, {Name = "5", Code = CodeEnum.Five},
		{Name = "6", Code = CodeEnum.Six}, {Name = "7", Code = CodeEnum.Seven},
		{Name = "8", Code = CodeEnum.Eight}, {Name = "9", Code = CodeEnum.Nine},
		{Name = "0", Code = CodeEnum.Zero}, {Name = "-", Code = CodeEnum.Minus},
		{Name = "=", Code = CodeEnum.Equals}, {Name = "Bksp", Code = CodeEnum.Backspace, Weight = 2},
	},
	{
		{Name = "Tab", Code = CodeEnum.Tab, Weight = 1.5}, {Name = "Q", Code = CodeEnum.Q},
		{Name = "W", Code = CodeEnum.W}, {Name = "E", Code = CodeEnum.E},
		{Name = "R", Code = CodeEnum.R}, {Name = "T", Code = CodeEnum.T},
		{Name = "Y", Code = CodeEnum.Y}, {Name = "U", Code = CodeEnum.U},
		{Name = "I", Code = CodeEnum.I}, {Name = "O", Code = CodeEnum.O},
		{Name = "P", Code = CodeEnum.P}, {Name = "[", Code = CodeEnum.LeftBracket},
		{Name = "]", Code = CodeEnum.RightBracket}, {Name = "\\", Code = CodeEnum.BackSlash, Weight = 1.5},
	},
	{
		{Name = "Caps", Code = CodeEnum.CapsLock, Weight = 1.8}, {Name = "A", Code = CodeEnum.A},
		{Name = "S", Code = CodeEnum.S}, {Name = "D", Code = CodeEnum.D},
		{Name = "F", Code = CodeEnum.F}, {Name = "G", Code = CodeEnum.G},
		{Name = "H", Code = CodeEnum.H}, {Name = "J", Code = CodeEnum.J},
		{Name = "K", Code = CodeEnum.K}, {Name = "L", Code = CodeEnum.L},
		{Name = ";", Code = CodeEnum.Semicolon}, {Name = "'", Code = CodeEnum.Quote},
		{Name = "Enter", Code = CodeEnum.Return, Weight = 2.2},
	},
	{
		{Name = "LShift", Code = CodeEnum.LeftShift, Weight = 2.4}, {Name = "Z", Code = CodeEnum.Z},
		{Name = "X", Code = CodeEnum.X}, {Name = "C", Code = CodeEnum.C},
		{Name = "V", Code = CodeEnum.V}, {Name = "B", Code = CodeEnum.B},
		{Name = "N", Code = CodeEnum.N}, {Name = "M", Code = CodeEnum.M},
		{Name = ",", Code = CodeEnum.Comma}, {Name = ".", Code = CodeEnum.Period},
		{Name = "/", Code = CodeEnum.Slash}, {Name = "RShift", Code = CodeEnum.RightShift, Weight = 2.4},
	},
	{
		{Name = "Ctrl", Code = CodeEnum.LeftControl, Weight = 1.5}, {Name = "Alt", Code = CodeEnum.LeftAlt, Weight = 1.5},
		{Name = "Space", Code = CodeEnum.Space, Weight = 5.5}, {Name = "Alt", Code = CodeEnum.RightAlt, Weight = 1.5},
		{Name = "Ctrl", Code = CodeEnum.RightControl, Weight = 1.5}, 
		{Name = "←", Code = CodeEnum.Left}, {Name = "↑", Code = CodeEnum.Up},
		{Name = "↓", Code = CodeEnum.Down}, {Name = "→", Code = CodeEnum.Right},
	}
}

local usedCodes = {}
for _, row in layout do
	for _, key in row do
		usedCodes[key.Code] = true
	end
end

local extraRow = {}
for _, enumItem in CodeEnum:GetEnumItems() do
	local name = enumItem.Name
	if not usedCodes[enumItem] then
		if not sfind(name, "Gamepad") and 
			not sfind(name, "Button") and 
			not sfind(name, "Thumbstick") and 
			not sfind(name, "DPad") and 
			not sfind(name, "Mouse") and 
			not sfind(name, "World") and 
			name ~= "Unknown" then
			tinsert(extraRow, {Name = name, Code = enumItem, Weight = 1})
		end
	end
end

table.sort(extraRow, function(a, b) return a.Name < b.Name end)

local totalRows = #layout + (if #extraRow > 0 then 1 else 0)
local rowPadding = 0.005
local availableHeightScale = 1 - (rowPadding * (totalRows - 1))
local rowHeight = (1 / totalRows) * availableHeightScale

create("UIListLayout", keyboardFrame, {
	FillDirection = Enum.FillDirection.Vertical,
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = udim(rowPadding, 0)
})

if #extraRow > 0 then
	local extraRowFrame = create("ScrollingFrame", keyboardFrame, {
		Name = "ExtraKeysRow",
		Size = udim2(1, 0, rowHeight, 0),
		BackgroundTransparency = 1,
		CanvasSize = udim2(0, #extraRow * 75, 0, 0),
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = color(255, 255, 255),
		ScrollingDirection = Enum.ScrollingDirection.X,
		LayoutOrder = 0
	})
	
	create("UIListLayout", extraRowFrame, {
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = udim(0, 4)
	})
	
	for i, key in extraRow do
		local button = create("TextButton", extraRowFrame, {
			Name = key.Name,
			Size = udim2(0, 70, 1, -6),
			BackgroundColor3 = color(20, 20, 20),
			Text = key.Name,
			TextColor3 = color(255, 255, 255),
			Font = Enum.Font.SourceSansBold,
			TextScaled = true,
			LayoutOrder = i
		})
		
		make("UICorner", button).CornerRadius = udim(0, 5)
		
		create("UIPadding", button, {
			PaddingTop = udim(0.15, 0),
			PaddingBottom = udim(0.15, 0)
		})
		
		handleKeyPress(button, key.Code)
	end
end

for rowIndex, rowData in layout do
	local rowFrame = create("Frame", keyboardFrame, {
		Name = "Row_" .. rowIndex,
		Size = udim2(1, 0, rowHeight, 0),
		BackgroundTransparency = 1,
		LayoutOrder = rowIndex
	})
	
	create("UIListLayout", rowFrame, {
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = udim(rowPadding, 0)
	})
	
	local totalWeight = 0
	for _, key in rowData do
		totalWeight += (key.Weight or 1)
	end
	
	local numKeys = #rowData
	local availableWidthScale = 1 - (rowPadding * (numKeys - 1))
	
	for keyIndex, key in rowData do
		local weight = key.Weight or 1
		local keyWidth = (weight / totalWeight) * availableWidthScale
		
		local button = create("TextButton", rowFrame, {
			Name = key.Name,
			Size = udim2(keyWidth, 0, 1, 0),
			BackgroundColor3 = color(20, 20, 20),
			Text = key.Name,
			TextColor3 = color(255, 255, 255),
			Font = Enum.Font.SourceSansBold,
			TextScaled = true,
			LayoutOrder = keyIndex
		})
		
		make("UICorner", button).CornerRadius = udim(0, 5)
		
		create("UIPadding", button, {
			PaddingTop = udim(0.12, 0),
			PaddingBottom = udim(0.12, 0),
			PaddingLeft = udim(0.02, 0),
			PaddingRight = udim(0.02, 0)
		})
		
		handleKeyPress(button, key.Code)
	end
  end
