-- sadly doesn't work anymore
local CoreGui, hui = game:GetService("CoreGui"), gethui()
local StarterGui = game:GetService("StarterGui")
local CorePackages = game:GetService("CorePackages")
local Packages = CorePackages:WaitForChild("Packages")

local React = require(Packages.React)
local RbxReact = require(Packages.ReactRoblox)
local ExecutedEvent = Instance.new("BindableEvent", hui)
ExecutedEvent.Name = "KrnlExecuteEngine"

local e = React.createElement
local useState = React.useState
local useRef = React.useRef
local useEffect = React.useEffect

local hud = CoreGui.RobloxGui.ScreenshotHudFrame.ScreenshotHudContent

local function getkeys(tb)
    local keys = {}
    for key, value in tb do
        table.insert(keys, key)
    end
    return keys
end

local function merge(t1, t2)
    for k, v in t2 do
        t1[k] = v
    end
    return t1
end

local genv = merge({}, getgenv())
local env = merge(genv, getrenv())

local lua_keywords = {
    "and", "break", "do", "else", "elseif", "end", "false", "for", "function",
    "goto", "if", "in", "local", "nil", "not", "or", "repeat", "return", "then",
    "true", "until", "while", "const", "@", "@native", "@deprecated"
}

local global_env = getkeys(env)

local function execute(code)
	local func, err = loadstring(code)
	if err then
		warn("[KRNL] :: FAILED TO COMPILE SCRIPT. REASON :: "..tostring(err))
		return
	end
	xpcall(func, function(bad)
		warn("[KRNL] :: FAILED TO RUN SCRIPT. REASON :: "..tostring(bad))
	end)
end

local function load(raw, ishttp)
	if ishttp then
		local bool, data = pcall(game.HttpGet, game, raw)
		if not bool then
			warn("[KRNL] :: FAILED TO FETCH [".. tostring(raw) .."] REASON :: "..tostring(data))
			return
		end
		execute(data)
	end
	execute(raw)
end

local function StartThread(...)
	ExecutedEvent:Fire(...)
end

local function buildHighlightMasks(text, lua_keywords_list, global_env_list)
	local chars = table.create(#text, 0)
	local len = #text
	
	local function mark(p1, p2, id)
		for j = p1, p2 - 1 do
			if chars[j] == 0 then chars[j] = id end
		end
	end
	
	local inString = false
	local strChar = ""
	local escape = false
	local inMultiString = false
	local inSingleComment = false
	local inMultiComment = false
	
	local i = 1
	while i <= len do
		local c = text:sub(i, i)
		local c2 = text:sub(i, i+1)
		local c4 = text:sub(i, i+3)
		
		if inString then
			chars[i] = 3
			if escape then escape = false
			elseif c == '\\' then escape = true
			elseif c == strChar then inString = false end
			i += 1
		elseif inMultiString then
			chars[i] = 3
			if c2 == "]]" then
				chars[i+1] = 3
				inMultiString = false
				i += 2
			else
				i += 1
			end
		elseif inMultiComment then
			chars[i] = 9
			if c2 == "]]" then
				chars[i+1] = 9
				inMultiComment = false
				i += 2
			else
				i += 1
			end
		elseif inSingleComment then
			chars[i] = 9
			if c == '\n' then
				inSingleComment = false
			end
			i += 1
		else
			if c4 == "--[[" then
				inMultiComment = true
				mark(i, i + 4, 9)
				i += 4
			elseif c2 == "--" then
				inSingleComment = true
				mark(i, i + 2, 9)
				i += 2
			elseif c2 == "[[" then
				inMultiString = true
				mark(i, i + 2, 3)
				i += 2
			elseif c == '"' or c == "'" then
				inString = true
				strChar = c
				chars[i] = 3
				i += 1
			else
				i += 1
			end
		end
	end
	
	local custom_funcs = {}
	local custom_types = {}
	for funcName in text:gmatch("function%s+([%a_][%w_]*)") do custom_funcs[funcName] = true end
	for t1, t2 in text:gmatch("type%s+([%a_][%w_]*)%s+([%a_][%w_]*)") do
		if t1 == "function" then custom_types[t2] = true end
	end
	for t1 in text:gmatch("type%s+([%a_][%w_]*)") do
		if t1 ~= "function" then custom_types[t1] = true end
	end
	
	i = 1
	local parenStack = {}
	local lastType = 0
	local typeFuncDepth = 0
	
	local TokenDict = { ["="]=true, ["."]=true, [","]=true, ["["]=true, ["]"]=true, ["{"]=true, ["}"]=true, ["*"]=true, ["/"]=true, ["+"]=true, ["-"]=true, ["%"]=true, [";"]=true, ["~"]=true }
	
	while i <= len do
		if chars[i] ~= 0 then 
			i += 1 
			continue 
		end
		
		local c = text:sub(i, i)
		
		if c == "@" then
			local s, e, word = text:find("^@([%a_][%w_]*)", i)
			if word then
				mark(i, e + 1, 1)
				i = e + 1
			else
				mark(i, i + 1, 1)
				i += 1
			end
			continue
		end
		
		if c:match("[%a_]") then
			local s, e, word = text:find("^([%a_][%w_]*)", i)
			local matched = false
			
			if word == "export" and text:find("^%s+type%s+function", e + 1) then
				local s_end, e_end = text:find("^%s+type%s+function%s+[%a_][%w_]*", e + 1)
				if s_end then
					mark(s, e_end + 1, 7)
					i = e_end + 1
					typeFuncDepth = 1
					matched = true
					lastType = 0
				end
			elseif word == "export" then
				local s2, e2, w2 = text:find("^%s+(type)", e + 1)
				if w2 then
					mark(s, e + 1, 7)
					mark(s2, e2 + 1, 7)
					i = e2 + 1
					local s4, e4, w4 = text:find("^%s+([%a_][%w_]*)", i)
					if w4 then
						mark(s4, e4 + 1, 8)
						i = e4 + 1
					end
					matched = true
					lastType = 0
				end
			elseif word == "type" and text:find("^%s+function", e + 1) then
				local s_end, e_end = text:find("^%s+function%s+[%a_][%w_]*", e + 1)
				if s_end then
					mark(s, e_end + 1, 7)
					i = e_end + 1
					typeFuncDepth = 1
					matched = true
					lastType = 0
				end
			elseif word == "type" then
				mark(s, e + 1, 7)
				i = e + 1
				local s4, e4, w4 = text:find("^%s+([%a_][%w_]*)", i)
				if w4 then
					mark(s4, e4 + 1, 8)
					i = e4 + 1
				end
				matched = true
				lastType = 0
			end
			
			if not matched then
				if typeFuncDepth > 0 then
					if word == "function" or word == "do" or word == "if" then
						typeFuncDepth += 1
					elseif word == "end" then
						typeFuncDepth -= 1
						if typeFuncDepth == 0 then
							mark(s, e + 1, 7)
							i = e + 1
							matched = true
							lastType = 0
						end
					end
				end
			end
			
			if not matched then
				if word == "function" then
					mark(s, e + 1, typeFuncDepth > 0 and 7 or 1)
					i = e + 1
					local s2, e2, w2 = text:find("^%s+([%a_][%w_]*)", i)
					if w2 then
						mark(s2, e2 + 1, 6)
						i = e2 + 1
						lastType = 6
					else
						lastType = 0
					end
					matched = true
				end
			end
			
			if not matched then
				if custom_funcs[word] then
					mark(s, e + 1, typeFuncDepth > 0 and 7 or 6)
					lastType = 6
				elseif word == "any" or word == "unknown" or custom_types[word] then
					mark(s, e + 1, 7)
					lastType = 0
				elseif table.find(lua_keywords_list, word) then
					mark(s, e + 1, typeFuncDepth > 0 and 7 or 1)
					lastType = 0
				elseif table.find(global_env_list, word) then
					if typeFuncDepth > 0 then
						mark(s, e + 1, 8)
					else
						mark(s, e + 1, 2)
					end
					lastType = 0
				else
					if typeFuncDepth > 0 then
						mark(s, e + 1, 7)
					else
						lastType = 0
					end
				end
				i = e + 1
			end
		elseif c == ":" then
			mark(i, i + 1, typeFuncDepth > 0 and 7 or 10)
			i += 1
			local s, e, word = text:find("^%s*([%a_][%w_]*)", i)
			if word then
				if word == "string" or word == "number" or word == "boolean" or word == "any" or word == "unknown" or custom_types[word] then
					mark(s, e + 1, 7)
					lastType = 0
				else
					if typeFuncDepth > 0 then
						mark(s, e + 1, 8)
					else
						mark(s, e + 1, 5)
					end
					lastType = 5
				end
				i = e + 1
			end
		elseif c == "(" then
			local cType = 10
			if typeFuncDepth > 0 then cType = 7
			elseif lastType == 5 or lastType == 6 then cType = lastType end
			
			table.insert(parenStack, lastType == 5 and 5 or (lastType == 6 and 6 or 10))
			mark(i, i + 1, cType)
			i += 1
			lastType = 0
		elseif c == ")" then
			local cType = table.remove(parenStack) or 10
			if typeFuncDepth > 0 then cType = 7 end
			mark(i, i + 1, cType)
			i += 1
			lastType = 0
		elseif c:match("%d") then
			local s, e = text:find("^%d+%.?%d*", i)
			mark(s, e + 1, typeFuncDepth > 0 and 7 or 4)
			i = e + 1
			lastType = 0
		else
			if TokenDict[c] then
				mark(i, i + 1, typeFuncDepth > 0 and 7 or 10)
			end
			i += 1
			if c ~= " " and c ~= "\t" and c ~= "\n" and c ~= "\r" then
				lastType = 0
			end
		end
	end
	
	local res = {
		[1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {}, [6] = {}, [7] = {}, [8] = {}, [9] = {}, [10] = {}
	}
	
	for j = 1, len do
		local char = text:sub(j, j)
		if char == "\n" or char == "\t" or char == "\r" then
			for k, v in res do table.insert(v, char) end
		else
			local id = chars[j]
			for k, v in res do
				if k == id then table.insert(v, char)
				else table.insert(v, "\32") end
			end
		end
	end
	
	for k, v in res do res[k] = table.concat(v) end
	return res
end

local function TextButtonStyled(props)
	return e("TextButton", {
		BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = props.BackgroundTransparency or 1,
		Position = props.Position,
		Size = props.Size,
		Font = props.Font or Enum.Font.SourceSans,
		Text = props.Text,
		TextColor3 = props.TextColor3 or Color3.fromRGB(255, 255, 255),
		TextScaled = true,
		TextSize = props.TextSize or 15,
		TextWrapped = true,
		TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Center,
		Visible = props.Visible,
		[React.Event.Activated] = props.OnActivated
	}, {
		Constraint = e("UITextSizeConstraint", { MaxTextSize = props.TextSize or 15 })
	})
end

local function Editor(props)
	local text = props.Text
	local tbRef = useRef(nil)
	
	local maxLineLength = 0
	local linesCount = 1
	for line in text:gmatch("[^\n]+") do
		if #line > maxLineLength then maxLineLength = #line end
	end
	text:gsub("\n", function() linesCount += 1 end)
	
	local lineNumbers = ""
	for i = 1, linesCount do lineNumbers = lineNumbers .. i .. "\n" end
	
	local masks = buildHighlightMasks(text, lua_keywords, global_env)
	
	local canvasWidth = math.max(maxLineLength * 8.5 + 50, 600)
	local canvasHeight = math.max(linesCount * 16 + 50, 300)
	
	return e("ScrollingFrame", {
		Active = true,
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		BorderColor3 = Color3.fromRGB(40, 40, 40),
		Position = UDim2.new(0.012, 0, 0.079, 0),
		Size = UDim2.new(0.973, 0, 0.917, 0),
		Visible = props.Visible,
		ScrollBarThickness = 10,
		CanvasSize = UDim2.new(0, canvasWidth, 0, canvasHeight),
	}, {
		Lines = e("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 30, 1, 0),
			ZIndex = 4,
			Font = Enum.Font.SourceSans,
			Text = lineNumbers,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 15,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = false,
		}),
		Source = e("TextBox", {
			ref = tbRef,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 35, 0, 0),
			Size = UDim2.new(1, -35, 1, 0),
			ZIndex = 3,
			ClearTextOnFocus = false,
			Font = Enum.Font.Code,
			MultiLine = true,
			Text = text,
			TextColor3 = Color3.fromRGB(204, 204, 204),
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = false,
			[React.Change.Text] = function(rbx)
				props.SetText(rbx.Text)
			end,
			[React.Event.FocusLost] = function(rbx, enterPressed)
				if enterPressed then
					props.SetText(rbx.Text .. "\n")
					task.defer(function()
						if tbRef.current then
							tbRef.current:CaptureFocus()
							tbRef.current.CursorPosition = #tbRef.current.Text + 1
						end
					end)
				end
			end
		}, {
			Keywords = e("TextLabel", { TextWrapped = false, BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), ZIndex = 5, Font = Enum.Font.Code, Text = masks[1] or "", TextColor3 = Color3.fromRGB(213, 53, 117), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top }),
			Globals = e("TextLabel", { TextWrapped = false, BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), ZIndex = 5, Font = Enum.Font.Code, Text = masks[2] or "", TextColor3 = Color3.fromRGB(85, 222, 154), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top }),
			Strings = e("TextLabel", { TextWrapped = false, BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), ZIndex = 5, Font = Enum.Font.Code, Text = masks[3] or "", TextColor3 = Color3.fromRGB(229, 164, 60), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top }),
			Numbers = e("TextLabel", { TextWrapped = false, BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), ZIndex = 4, Font = Enum.Font.Code, Text = masks[4] or "", TextColor3 = Color3.fromRGB(142, 71, 213), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top }),
			Methods = e("TextLabel", { TextWrapped = false, BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), ZIndex = 5, Font = Enum.Font.Code, Text = masks[5] or "", TextColor3 = Color3.fromRGB(170, 120, 255), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top }),
			Functions = e("TextLabel", { TextWrapped = false, BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), ZIndex = 5, Font = Enum.Font.Code, Text = masks[6] or "", TextColor3 = Color3.fromRGB(255, 255, 0), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top }),
			TypesLight = e("TextLabel", { TextWrapped = false, BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), ZIndex = 5, Font = Enum.Font.Code, Text = masks[7] or "", TextColor3 = Color3.fromRGB(85, 170, 255), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top }),
			TypesDark = e("TextLabel", { TextWrapped = false, BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), ZIndex = 5, Font = Enum.Font.Code, Text = masks[8] or "", TextColor3 = Color3.fromRGB(0, 85, 255), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top }),
			Comments = e("TextLabel", { TextWrapped = false, BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), ZIndex = 5, Font = Enum.Font.Code, Text = masks[9] or "", TextColor3 = Color3.fromRGB(150, 150, 150), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top }),
			Tokens = e("TextLabel", { TextWrapped = false, BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), ZIndex = 5, Font = Enum.Font.Code, Text = masks[10] or "", TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top })
		})
	})
end

local function App()
	local showMain, setShowMain = useState(false)
	local showBubble, setShowBubble = useState(true)
	local activePopup, setActivePopup = useState(nil)
	
	local tabs, setTabs = useState({{ id = 1, name = "Script1.lua", text = "" }})
	local activeTabId, setActiveTabId = useState(1)
	local nextTabId, setNextTabId = useState(2)
	
	local isRenaming, setIsRenaming = useState(false)
	local renameText, setRenameText = useState("")
	
	local savedScripts, setSavedScripts = useState({})
	local selectedFile, setSelectedFile = useState(nil)
	local bubbleRef = useRef(nil)

	local function fetchScripts()
		if isfolder("KrnlUI") and isfolder("KrnlUI/SavedScripts") then
			local files = listfiles("KrnlUI/SavedScripts")
			local parsed = {}
			for _, f in files do
				local name = f:match("([^/\\]+)$") or f
				table.insert(parsed, name)
			end
			setSavedScripts(parsed)
		end
	end

	useEffect(function()
		if makefolder then
			if not isfolder("KrnlUI") then makefolder("KrnlUI") end
			if not isfolder("KrnlUI/SavedScripts") then makefolder("KrnlUI/SavedScripts") end
		end
		fetchScripts()
		
		if bubbleRef.current then
			local drag = Instance.new("UIDragDetector", bubbleRef.current)
			drag.BoundingUI = hud
			local isDragging = false
			
			local startConn = drag.DragStart:Connect(function()
				isDragging = true
			end)
			
			local endConn = drag.DragEnd:Connect(function()
				if isDragging then
					setShowMain(true)
					setShowBubble(false)
				end
			end)
			
			local contConn = drag.DragContinue:Connect(function()
				isDragging = false
			end)
			
			return function()
				startConn:Disconnect()
				endConn:Disconnect()
				contConn:Disconnect()
				drag:Destroy()
			end
		end
	end, {})
	
	local function togglePopup(name)
		setActivePopup(activePopup == name and nil or name)
	end
	
	local activeTabText = ""
	for _, t in tabs do
		if t.id == activeTabId then activeTabText = t.text break end
	end
	
	local function updateActiveTabText(newText)
		setTabs(function(prev)
			local newTabs = {}
			for _, t in prev do
				if t.id == activeTabId then
					table.insert(newTabs, { id = t.id, name = t.name, text = newText })
				else
					table.insert(newTabs, t)
				end
			end
			return newTabs
		end)
	end

	local function addNewTab()
		local newId = nextTabId
		setNextTabId(newId + 1)
		setTabs(function(prev)
			local c = table.clone(prev)
			table.insert(c, { id = newId, name = "Script" .. newId .. ".lua", text = "" })
			return c
		end)
		setActiveTabId(newId)
		setActivePopup(nil)
	end

	local function delActiveTab()
		if #tabs > 1 then
			setTabs(function(prev)
				local newTabs = {}
				local nextActive = nil
				for _, t in prev do
					if t.id ~= activeTabId then
						table.insert(newTabs, t)
						if not nextActive then nextActive = t.id end
					end
				end
				setActiveTabId(nextActive)
				return newTabs
			end)
		end
		setActivePopup(nil)
	end

	local tabElements = {
		Layout = e("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder })
	}
	for _, tab in tabs do
		tabElements["Tab_"..tab.id] = e("Frame", {
			BackgroundColor3 = activeTabId == tab.id and Color3.fromRGB(70, 70, 70) or Color3.fromRGB(50, 50, 50),
			Size = UDim2.new(0, 100, 1, 0)
		}, {
			Btn = e(TextButtonStyled, {
				BackgroundTransparency = 1, Text = tab.name, Size = UDim2.new(1, 0, 1, 0), TextSize = 14,
				OnActivated = function() setActiveTabId(tab.id) end
			})
		})
	end

	local scriptHubElements = {
		Layout = e("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5) }),
		Padding = e("UIPadding", { PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5) })
	}
	for i, sName in ipairs(savedScripts) do
		scriptHubElements["Script_"..i] = e(TextButtonStyled, {
			BackgroundTransparency = 0,
			BackgroundColor3 = selectedFile == sName and Color3.fromRGB(60, 60, 100) or Color3.fromRGB(40, 40, 40),
			Text = sName,
			Size = UDim2.new(1, 0, 0, 30),
			TextSize = 14,
			OnActivated = function()
				setSelectedFile(sName)
			end
		})
	end
	
	return e("ScreenGui", {
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		FloatingGUI = e("ImageButton", {
			ref = bubbleRef,
			Visible = showBubble,
			BackgroundColor3 = Color3.fromRGB(10, 10, 10),
			BackgroundTransparency = 0,
			Position = UDim2.new(0, 599, 0, 62),
			Size = UDim2.new(0, 60, 0, 60),
			Image = "rbxassetid://11671355800",
		}, {
			Corner = e("UICorner", { CornerRadius = UDim.new(1, 0) }),
			Stroke = e("UIStroke", { Transparency = 0.5, Thickness = 2})
		}),
		
		KrnlGUI = e("Frame", {
			Visible = showMain,
			Active = true,
			BackgroundColor3 = Color3.fromRGB(34, 34, 34),
			BorderColor3 = Color3.fromRGB(34, 34, 34),
			Position = UDim2.new(0, 137, 0, 141),
			Size = UDim2.new(0, 640, 0, 330),
		}, {
			MainDrag = e("UIDragDetector"),
			AspectRatio = e("UIAspectRatioConstraint", { AspectRatio = 1.993 }),
			
			BlueLight = e("Frame", { BackgroundColor3 = Color3.fromRGB(6, 139, 255), BorderColor3 = Color3.fromRGB(6, 139, 255), Size = UDim2.new(0.999, 0, 0.003, 0), ZIndex = 2 }),
			
			FileBtn = e(TextButtonStyled, { Text = "File", Position = UDim2.new(0.002, 0, 0.097, 0), Size = UDim2.new(0.066, 0, 0.068, 0), TextSize = 16, OnActivated = function() togglePopup("file") end }),
			CreditsBtn = e(TextButtonStyled, { Text = "Credits", Position = UDim2.new(0.07, 0, 0.097, 0), Size = UDim2.new(0.066, 0, 0.068, 0), TextSize = 16, OnActivated = function() togglePopup("credits") end }),
			ScriptsBtn = e(TextButtonStyled, { Text = "Hot-Scripts", Position = UDim2.new(0.15, 0, 0.097, 0), Size = UDim2.new(0.094, 0, 0.068, 0), OnActivated = function() togglePopup("scripts") end }),
			OthersBtn = e(TextButtonStyled, { Text = "Others", Position = UDim2.new(0.258, 0, 0.097, 0), Size = UDim2.new(0.068, 0, 0.068, 0), OnActivated = function() togglePopup("others") end }),
			
			SideGUI = e("Frame", { BackgroundColor3 = Color3.fromRGB(30, 30, 30), BorderColor3 = Color3.fromRGB(31, 31, 31), Size = UDim2.new(0.998, 0, 0.095, 0) }, {
				Icon = e("ImageLabel", { BackgroundTransparency = 1, Position = UDim2.new(0.003, 0, 0.123, 0), Size = UDim2.new(0.036, 0, 0.726, 0), Image = "rbxassetid://11671355800" }),
				Title = e("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0.465, 0, 0.136, 0), Size = UDim2.new(0.069, 0, 0.726, 0), Font = Enum.Font.SourceSans, Text = "KRNL", TextColor3 = Color3.fromRGB(255, 255, 255), TextScaled = true, TextSize = 20 }),
				MinimizeBtn = e(TextButtonStyled, { Text = "−", Position = UDim2.new(0.91, 0, 0.159, 0), Size = UDim2.new(0.04, 0, 0.69, 0), TextSize = 35, OnActivated = function()
					setShowMain(false)
					setShowBubble(true)
				end })
			}),
			
			MainGUI = e("Frame", { BackgroundColor3 = Color3.fromRGB(17, 17, 17), Position = UDim2.new(0, 0, 0.168, 0), Size = UDim2.new(1, 0, 0.831, 0) }, {
				ExecuteBar = e("Frame", { BackgroundColor3 = Color3.fromRGB(36, 36, 36), Position = UDim2.new(0.007, 0, 0.006, 0), Size = UDim2.new(0.803, 0, 0.887, 0) }, {
					Tabs = e("Frame", { BackgroundColor3 = Color3.fromRGB(50, 50, 50), Size = UDim2.new(1, 0, 0.056, 0) }, {
						TabList = e("ScrollingFrame", {
							BackgroundTransparency = 1, Size = UDim2.new(0.95, 0, 1, 0), CanvasSize = UDim2.new(0, #tabs * 100, 0, 0), ScrollBarThickness = 0, ScrollingDirection = Enum.ScrollingDirection.X
						}, tabElements),
						ConfigBtn = e(TextButtonStyled, { BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(60, 60, 60), Text = "@", Position = UDim2.new(0.95, 0, 0, 0), Size = UDim2.new(0.05, 0, 1, 0), TextSize = 16, OnActivated = function() togglePopup("tabMenu") end })
					}),
					EditorComponent = e(Editor, { Visible = true, Text = activeTabText, SetText = updateActiveTabText })
				}),
				
				ScriptHub = e("ScrollingFrame", {
					Active = true, BackgroundColor3 = Color3.fromRGB(33, 33, 33), BorderColor3 = Color3.fromRGB(33, 33, 33),
					Position = UDim2.new(0.821, 0, 0.027, 0), Size = UDim2.new(0.17, 0, 0.865, 0), ScrollBarThickness = 7
				}, scriptHubElements),
				
				ExecuteBtn = e(TextButtonStyled, { BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(44, 44, 44), Text = "EXECUTE", Position = UDim2.new(0.005, 0, 0.91, 0), Size = UDim2.new(0.143, 0, 0.074, 0), TextSize = 14, Font = Enum.Font.Arial, OnActivated = function() StartThread(activeTabText) end }),
				ClearBtn = e(TextButtonStyled, { BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(44, 44, 44), Text = "CLEAR", Position = UDim2.new(0.158, 0, 0.91, 0), Size = UDim2.new(0.143, 0, 0.074, 0), TextSize = 14, Font = Enum.Font.Arial, OnActivated = function() updateActiveTabText("") end }),
				OpenBtn = e(TextButtonStyled, { BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(44, 44, 44), Text = "OPEN FILE", Position = UDim2.new(0.31, 0, 0.91, 0), Size = UDim2.new(0.143, 0, 0.074, 0), TextSize = 14, Font = Enum.Font.Arial, OnActivated = function()
					if selectedFile then
						local content = readfile("KrnlUI/SavedScripts/" .. selectedFile)
						local newId = nextTabId
						setNextTabId(newId + 1)
						setTabs(function(prev)
							local c = table.clone(prev)
							table.insert(c, {id = newId, name = selectedFile, text = content})
							return c
						end)
						setActiveTabId(newId)
					end
				end }),
				SaveBtn = e(TextButtonStyled, { BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(44, 44, 44), Text = "SAVE FILE", Position = UDim2.new(0.461, 0, 0.91, 0), Size = UDim2.new(0.143, 0, 0.074, 0), TextSize = 14, Font = Enum.Font.Arial, OnActivated = function()
					local activeTabName = "Script.lua"
					for _, t in tabs do if t.id == activeTabId then activeTabName = t.name break end end
					writefile("KrnlUI/SavedScripts/" .. activeTabName, activeTabText)
					fetchScripts()
				end }),
				InjectBtn = e(TextButtonStyled, { BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(44, 44, 44), Text = "CONSOLE", Position = UDim2.new(0.611, 0, 0.91, 0), Size = UDim2.new(0.143, 0, 0.074, 0), TextSize = 14, Font = Enum.Font.Arial,  OnActivated = function() StarterGui:SetCore("DevConsoleVisible", true) end}),
				DeleteBtn = e(TextButtonStyled, { BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(44, 44, 44), Text = "DELETE FILE", Position = UDim2.new(0.847, 0, 0.91, 0), Size = UDim2.new(0.143, 0, 0.074, 0), TextSize = 14, Font = Enum.Font.Arial, OnActivated = function()
					if selectedFile then
						delfile("KrnlUI/SavedScripts/" .. selectedFile)
						setSelectedFile(nil)
						fetchScripts()
					end
				end })
			}),
			
			FileTab = e("Frame", {
				Visible = activePopup == "file", BackgroundColor3 = Color3.fromRGB(29, 29, 29), BorderColor3 = Color3.fromRGB(43, 43, 43),
				Position = UDim2.new(0.002, 0, 0.164, 0), Size = UDim2.new(0.202, 0, 0.13, 0), ZIndex = 5
			}, {
				KillTask = e(TextButtonStyled, { Text = "              Kill Roblox", TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.new(0, 0, 0.511, 0), Size = UDim2.new(1, 0, 0.513, 0), OnActivated = function() game:Shutdown() end }),
			}),
			
			CreditsW = e("Frame", {
				Visible = activePopup == "credits", BackgroundColor3 = Color3.fromRGB(36, 36, 36), BorderColor3 = Color3.fromRGB(36, 36, 36),
				Position = UDim2.new(1.009, 0, 0.011, 0), Size = UDim2.new(0.434, 0, 0.536, 0), ZIndex = 5
			}, {
				Top = e("Frame", { BackgroundColor3 = Color3.fromRGB(28, 28, 29), Size = UDim2.new(1, 0, 0.175, 0) }, {
					Close = e(TextButtonStyled, { Text = "X", Position = UDim2.new(0.879, 0, 0, 0), Size = UDim2.new(0.118, 0, 1, 0), TextSize = 30, OnActivated = function() setActivePopup(nil) end })
				}),
				T1 = e("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0.435, 0, 0.174, 0), Size = UDim2.new(0.535, 0, 0.145, 0), Font = Enum.Font.SourceSans, Text = "UI-Replicated", TextColor3 = Color3.fromRGB(255, 255, 255), TextScaled = true, TextXAlignment = Enum.TextXAlignment.Left }),
				T2 = e("TextLabel", { BackgroundTransparency = 1, Position = UDim2.new(0.435, 0, 0.315, 0), Size = UDim2.new(0.535, 0, 0.145, 0), Font = Enum.Font.SourceSans, Text = "AZY#0348 - rewritten by https", TextColor3 = Color3.fromRGB(126, 126, 126), TextScaled = true, TextXAlignment = Enum.TextXAlignment.Left }),
				Img = e("ImageLabel", { BackgroundTransparency = 1, Position = UDim2.new(0.046, 0, 0.225, 0), Size = UDim2.new(0.334, 0, 0.54, 0), Image = "rbxassetid://11671355800" })
			}),
			
			HScriptsHub = e("Frame", {
				Visible = activePopup == "scripts", BackgroundColor3 = Color3.fromRGB(29, 29, 29), BorderColor3 = Color3.fromRGB(43, 43, 43),
				Position = UDim2.new(0.150, 0, 0.165, 0), Size = UDim2.new(0.202, 0, 0.20, 0), ZIndex = 5
			}, {
				Layout = e("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
				Dex = e(TextButtonStyled, { Text = "              Dex++", TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0.33, 0), OnActivated = function() StartThread("https://github.com/AZYsGithub/DexPlusPlus/releases/latest/download/out.lua", true) end }),
				Spy = e(TextButtonStyled, { Text = "              Remote-Spy", TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0.33, 0), OnActivated = function() StartThread("https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/SimpleSpy.lua", true) end }),
				IY = e(TextButtonStyled, { Text = "              Infinite-Yield", TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0.33, 0), OnActivated = function() StartThread("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", true) end })
			}),
			
			TabMenu = e("Frame", {
				Visible = activePopup == "tabMenu", BackgroundColor3 = Color3.fromRGB(29, 29, 29), BorderColor3 = Color3.fromRGB(43, 43, 43),
				Position = UDim2.new(0.550, 0, 0.18, 0), Size = UDim2.new(0.25, 0, 0.25, 0), ZIndex = 6
			}, {
				Layout = e("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
				NewBtn = e(TextButtonStyled, { Text = "  [+ New Script]", TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0.33, 0), OnActivated = addNewTab }),
				DelBtn = e(TextButtonStyled, { Text = "  [- Delete Script]", TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0.33, 0), OnActivated = delActiveTab }),
				RenBtn = e(TextButtonStyled, { Text = "  [? ReName Script]", TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0.33, 0), OnActivated = function()
					local aname = ""
					for _, t in tabs do if t.id == activeTabId then aname = t.name break end end
					setRenameText(aname)
					setIsRenaming(true)
					setActivePopup(nil)
				end })
			}),

			OtherTab = e("Frame", {
				Visible = activePopup == "others", BackgroundColor3 = Color3.fromRGB(29, 29, 29), BorderColor3 = Color3.fromRGB(43, 43, 43),
				Position = UDim2.new(0.257, 0, 0.167, 0), Size = UDim2.new(0.202, 0, 0.13, 0), ZIndex = 5
			}, {
				Why = e(TextButtonStyled, { Text = "              Why you here?", TextXAlignment = Enum.TextXAlignment.Left, Position = UDim2.new(0, 0, 0.466, 0), Size = UDim2.new(1, 0, 0.513, 0)}),
				NopeBtn = e(TextButtonStyled, { Text = "              No Key >:)", TextXAlignment = Enum.TextXAlignment.Left, Size = UDim2.new(1, 0, 0.513, 0)})
			}),

			RenamePrompt = e("Frame", {
				Visible = isRenaming, BackgroundColor3 = Color3.fromRGB(30, 30, 30), Position = UDim2.new(0.3, 0, 0.3, 0), Size = UDim2.new(0.4, 0, 0.4, 0), ZIndex = 10
			}, {
				Title = e("TextLabel", { Text = "Rename Script", BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(0, 0, 0.1, 0), Size = UDim2.new(1, 0, 0.2, 0), TextSize = 18 }),
				Input = e("TextBox", { Text = renameText, BackgroundColor3 = Color3.fromRGB(50, 50, 50), TextColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(0.1, 0, 0.4, 0), Size = UDim2.new(0.8, 0, 0.2, 0), TextSize = 16,
					[React.Change.Text] = function(rbx) setRenameText(rbx.Text) end
				}),
				SaveBtn = e(TextButtonStyled, { Text = "Save", BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(60, 60, 60), Position = UDim2.new(0.1, 0, 0.7, 0), Size = UDim2.new(0.35, 0, 0.2, 0),
					OnActivated = function()
						setTabs(function(prev)
							local newTabs = {}
							for _, t in ipairs(prev) do
								if t.id == activeTabId then table.insert(newTabs, { id = t.id, name = renameText, text = t.text })
								else table.insert(newTabs, t) end
							end
							return newTabs
						end)
						setIsRenaming(false)
					end
				}),
				CancelBtn = e(TextButtonStyled, { Text = "Cancel", BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(180, 50, 50), Position = UDim2.new(0.55, 0, 0.7, 0), Size = UDim2.new(0.35, 0, 0.2, 0), OnActivated = function() setIsRenaming(false) end })
			})
		})
	})
end

ExecutedEvent.Event:Connect(load) --// react breaks if it directly handles exploit functions

local root = RbxReact.createRoot(Instance.new("Folder"))
root:render(RbxReact.createPortal(e(App), hui))
