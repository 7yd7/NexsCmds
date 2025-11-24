local module = {}
module.Logs = {}
module.Enabled = true
module.BlockRequests = false
module.Connections = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

local TweenInfoOpen = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TweenInfoClose = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local function logRequest(method, url, body)
	if not module.Enabled then return end
	
	local formattedBody = body
	if body and type(body) == "string" and (body:sub(1,1) == "{" or body:sub(1,1) == "[") then
		pcall(function()
			formattedBody = HttpService:JSONEncode(HttpService:JSONDecode(body))
		end)
	end

	module.AddLog(method, url, formattedBody)
end

if getgenv().Nexs_Original_HttpGet then
	pcall(function() hookfunction(game.HttpGet, getgenv().Nexs_Original_HttpGet) end)
end
if getgenv().Nexs_Original_HttpPost then
	pcall(function() hookfunction(game.HttpPost, getgenv().Nexs_Original_HttpPost) end)
end

pcall(function()
	getgenv().Nexs_Original_HttpGet = hookfunction(game.HttpGet, function(self, url, ...)
		if module.BlockRequests then
			task.spawn(logRequest, "HttpGet [BLOCKED]", url)
			return ""
		end
		task.spawn(logRequest, "HttpGet", url)
		return getgenv().Nexs_Original_HttpGet(self, url, ...)
	end)
end)

pcall(function()
	getgenv().Nexs_Original_HttpPost = hookfunction(game.HttpPost, function(self, url, body, ...)
		if module.BlockRequests then
			task.spawn(logRequest, "HttpPost [BLOCKED]", url, body)
			return ""
		end
		task.spawn(logRequest, "HttpPost", url, body)
		return getgenv().Nexs_Original_HttpPost(self, url, body, ...)
	end)
end)

local mt = getrawmetatable(game)
if mt then
	setreadonly(mt, false)
	local oldNamecall = mt.__namecall
	
	mt.__namecall = newcclosure(function(self, ...)
		local method = getnamecallmethod()
		local args = {...}
		
		if method == "HttpGet" or method == "HttpGetAsync" then
			if module.BlockRequests then
				task.spawn(logRequest, "HttpGet [BLOCKED]", args[1])
				return ""
			end
			task.spawn(logRequest, "HttpGet", args[1])
		elseif method == "HttpPost" or method == "HttpPostAsync" then
			if module.BlockRequests then
				task.spawn(logRequest, "HttpPost [BLOCKED]", args[1], args[2])
				return ""
			end
			task.spawn(logRequest, "HttpPost", args[1], args[2])
		end
		
		return oldNamecall(self, ...)
	end)
	
	setreadonly(mt, true)
end

if type(request) == "function" then
	local oldRequest = request
	pcall(function()
		hookfunction(request, function(options)
			if type(options) == "table" then
				if module.BlockRequests then
					task.spawn(logRequest, (options.Method or "GET") .. " [BLOCKED]", options.Url, options.Body)
					return {Body = "", StatusCode = 403, StatusMessage = "Blocked by HttpSpy"}
				end
				task.spawn(logRequest, options.Method or "GET", options.Url, options.Body)
			end
			return oldRequest(options)
		end)
	end)
elseif type(http_request) == "function" then
	local oldRequest = http_request
	pcall(function()
		hookfunction(http_request, function(options)
			if type(options) == "table" then
				if module.BlockRequests then
					task.spawn(logRequest, (options.Method or "GET") .. " [BLOCKED]", options.Url, options.Body)
					return {Body = "", StatusCode = 403, StatusMessage = "Blocked by HttpSpy"}
				end
				task.spawn(logRequest, options.Method or "GET", options.Url, options.Body)
			end
			return oldRequest(options)
		end)
	end)
elseif type(syn) == "table" and type(syn.request) == "function" then
	local oldRequest = syn.request
	pcall(function()
		hookfunction(syn.request, function(options)
			if type(options) == "table" then
				if module.BlockRequests then
					task.spawn(logRequest, (options.Method or "GET") .. " [BLOCKED]", options.Url, options.Body)
					return {Body = "", StatusCode = 403, StatusMessage = "Blocked by HttpSpy"}
				end
				task.spawn(logRequest, options.Method or "GET", options.Url, options.Body)
			end
			return oldRequest(options)
		end)
	end)
end

table.insert(module.Logs, {
	Method = "System",
	Url = "Http Spy Initialized - Async Logging Active",
	Body = "Hooks active",
	Time = os.time()
})

local function makeDraggable(frame)
	local dragging = false
	local dragInput
	local dragStart
	local startPos
	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
			startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or 
			input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or 
			input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end

function module.GUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "HttpLogsUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = game.CoreGui
	screenGui.Enabled = false
	
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "HttpLogsUI"
	mainFrame.Size = UDim2.new(0, 450, 0, 320)
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35) 
	mainFrame.BackgroundTransparency = 1 
	mainFrame.BorderSizePixel = 0
	mainFrame.ClipsDescendants = true
	mainFrame.Parent = screenGui
	
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 8)
	uiCorner.Parent = mainFrame
	
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(50, 50, 50)
	uiStroke.Thickness = 1
	uiStroke.Transparency = 1 
	uiStroke.Parent = mainFrame

	local uiScale = Instance.new("UIScale")
	uiScale.Parent = mainFrame
	
	local function updateScale()
		local viewportSize = workspace.CurrentCamera.ViewportSize
		local scaleFactor = math.min(1, viewportSize.X / 750)
		uiScale.Scale = math.max(0.7, scaleFactor)
	end
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
	updateScale()
		
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 40)
	header.BackgroundTransparency = 1
	header.Parent = mainFrame
	
	local searchInput = Instance.new("TextBox")
	searchInput.Name = "SearchInput"
	searchInput.Size = UDim2.new(1, -40, 1, 0)
	searchInput.Position = UDim2.new(0, 15, 0, 0)
	searchInput.BackgroundTransparency = 1
	searchInput.Text = ""
	searchInput.PlaceholderText = "Search requests..."
	searchInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
	searchInput.TextColor3 = Color3.fromRGB(220, 220, 220)
	searchInput.Font = Enum.Font.GothamMedium
	searchInput.TextSize = 14
	searchInput.TextXAlignment = Enum.TextXAlignment.Left
	searchInput.TextTransparency = 1 
	searchInput.Parent = header
	
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 30, 0, 40)
	closeButton.Position = UDim2.new(1, -30, 0, 0)
	closeButton.BackgroundTransparency = 1
	closeButton.Text = "×"
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextSize = 20
	closeButton.TextColor3 = Color3.fromRGB(150, 150, 150)
	closeButton.TextTransparency = 1 
	closeButton.Parent = header
	
	local separator = Instance.new("Frame")
	separator.Size = UDim2.new(1, 0, 0, 1)
	separator.Position = UDim2.new(0, 0, 0, 40)
	separator.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	separator.BorderSizePixel = 0
	separator.BackgroundTransparency = 1 
	separator.Parent = mainFrame
	
	local bottomBar = Instance.new("Frame")
	bottomBar.Name = "BottomBar"
	bottomBar.Size = UDim2.new(1, 0, 0, 40)
	bottomBar.Position = UDim2.new(0, 0, 1, -40)
	bottomBar.BackgroundTransparency = 1
	bottomBar.Parent = mainFrame
	
	local bottomSeparator = Instance.new("Frame")
	bottomSeparator.Size = UDim2.new(1, 0, 0, 1)
	bottomSeparator.Position = UDim2.new(0, 0, 0, 0)
	bottomSeparator.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	bottomSeparator.BorderSizePixel = 0
	bottomSeparator.BackgroundTransparency = 1
	bottomSeparator.Parent = bottomBar

	local function createStyledButton(name, text, position, width)
		local btn = Instance.new("TextButton")
		btn.Name = name
		btn.Size = UDim2.new(0, width, 0, 24)
		btn.Position = position
		btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		btn.BackgroundTransparency = 1
		btn.Text = text
		btn.Font = Enum.Font.GothamMedium
		btn.TextSize = 12
		btn.TextColor3 = Color3.fromRGB(200, 200, 200)
		btn.TextTransparency = 1
		btn.Parent = bottomBar
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 6)
		corner.Parent = btn
		
		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(60, 60, 60)
		stroke.Thickness = 1
		stroke.Transparency = 1
		stroke.Parent = btn
		
		return btn, stroke
	end

	local clearButton, clearStroke = createStyledButton("ClearButton", "Clear Logs", UDim2.new(0, 15, 0, 8), 80)
	local enabledButton, enabledStroke = createStyledButton("EnabledButton", module.Enabled and "Status: ON" or "Status: OFF", UDim2.new(0, 105, 0, 8), 90)
	local blockButton, blockStroke = createStyledButton("BlockButton", "Block: OFF", UDim2.new(0, 205, 0, 8), 90)
	
	enabledButton.MouseButton1Click:Connect(function()
		module.Enabled = not module.Enabled
		enabledButton.Text = module.Enabled and "Status: ON" or "Status: OFF"
		enabledButton.TextColor3 = module.Enabled and Color3.fromRGB(200, 200, 200) or Color3.fromRGB(150, 150, 150)
	end)

	blockButton.MouseButton1Click:Connect(function()
		module.BlockRequests = not module.BlockRequests
		blockButton.Text = module.BlockRequests and "Block: ON" or "Block: OFF"
		blockButton.TextColor3 = module.BlockRequests and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(200, 200, 200)
	end)

	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Name = "List"
	scrollingFrame.Size = UDim2.new(1, 0, 1, -81)
	scrollingFrame.Position = UDim2.new(0, 0, 0, 41)
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.ScrollBarThickness = 2
	scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
	scrollingFrame.ScrollBarImageTransparency = 1 
	scrollingFrame.Parent = mainFrame
	
	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 4)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.Parent = scrollingFrame
	
	local listPadding = Instance.new("UIPadding")
	listPadding.PaddingTop = UDim.new(0, 8)
	listPadding.PaddingBottom = UDim.new(0, 8)
	listPadding.Parent = scrollingFrame
	
	local function createLogItem(log)
		local itemFrame = Instance.new("Frame")
		itemFrame.Name = "LogItem"
		itemFrame.Size = UDim2.new(1, -20, 0, 50)
		itemFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
		itemFrame.BackgroundTransparency = 1
		itemFrame.Parent = scrollingFrame
		
		local itemCorner = Instance.new("UICorner")
		itemCorner.CornerRadius = UDim.new(0, 6)
		itemCorner.Parent = itemFrame
		
		local itemStroke = Instance.new("UIStroke")
		itemStroke.Color = Color3.fromRGB(50, 50, 50)
		itemStroke.Thickness = 1
		itemStroke.Transparency = 1
		itemStroke.Parent = itemFrame
		
		local methodLabel = Instance.new("TextLabel")
		methodLabel.Size = UDim2.new(0, 60, 0, 20)
		methodLabel.Position = UDim2.new(0, 10, 0, 5)
		methodLabel.BackgroundTransparency = 1
		methodLabel.Font = Enum.Font.GothamBold
		methodLabel.TextSize = 12
		methodLabel.TextXAlignment = Enum.TextXAlignment.Left
		methodLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
		methodLabel.Text = log.Method
		methodLabel.TextTransparency = 1
		methodLabel.Parent = itemFrame
		
		local urlLabel = Instance.new("TextLabel")
		urlLabel.Size = UDim2.new(1, -80, 0, 20)
		urlLabel.Position = UDim2.new(0, 70, 0, 5)
		urlLabel.BackgroundTransparency = 1
		urlLabel.Font = Enum.Font.Gotham
		urlLabel.TextSize = 12
		urlLabel.TextXAlignment = Enum.TextXAlignment.Left
		urlLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
		urlLabel.Text = log.Url
		urlLabel.TextTruncate = Enum.TextTruncate.AtEnd
		urlLabel.TextTransparency = 1
		urlLabel.Parent = itemFrame
		
		local function createActionBtn(text, xOffset)
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(0, 50, 0, 18)
			btn.Position = UDim2.new(1, xOffset, 0, 26)
			btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			btn.BackgroundTransparency = 1
			btn.Text = text
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 10
			btn.TextColor3 = Color3.fromRGB(200, 200, 200)
			btn.TextTransparency = 1
			btn.Parent = itemFrame
			
			local c = Instance.new("UICorner")
			c.CornerRadius = UDim.new(0, 4)
			c.Parent = btn
			
			local s = Instance.new("UIStroke")
			s.Color = Color3.fromRGB(60, 60, 60)
			s.Thickness = 1
			s.Transparency = 1
			s.Parent = btn
			
			return btn, s
		end
		
		local copyButton, copyStroke = createActionBtn("Copy", -115)
		local runButton, runStroke = createActionBtn("Run", -60)
		
		copyButton.MouseButton1Click:Connect(function()
			setclipboard(log.Url)
		end)
		
		runButton.MouseButton1Click:Connect(function()
			if log.Method == "HttpGet" then
				game:HttpGet(log.Url)
			elseif log.Method == "HttpPost" then
				game:HttpPost(log.Url, log.Body or "")
			elseif log.Method == "GET" or log.Method == "POST" then
				if request then
					request({Url = log.Url, Method = log.Method, Body = log.Body})
				elseif http_request then
					http_request({Url = log.Url, Method = log.Method, Body = log.Body})
				end
			end
		end)
		
		return itemFrame, {itemStroke, copyStroke, runStroke}
	end
	
	local function updateList(query)
		for _, child in ipairs(scrollingFrame:GetChildren()) do
			if child.Name == "LogItem" then child:Destroy() end
		end
		
		local count = 0
		for i = #module.Logs, 1, -1 do
			local log = module.Logs[i]
			local match = false
			if query == "" then
				match = true
			elseif string.find(string.lower(log.Url), string.lower(query)) then
				match = true
			elseif string.find(string.lower(log.Method), string.lower(query)) then
				match = true
			end
			
			if match then
				local item, strokes = createLogItem(log)
				count = count + 1
				
				if screenGui.Enabled and mainFrame.BackgroundTransparency < 1 then
					item.BackgroundTransparency = 0
					for _, s in ipairs(strokes) do s.Transparency = 0 end
					for _, desc in ipairs(item:GetDescendants()) do
						if desc:IsA("TextLabel") or desc:IsA("TextButton") then
							desc.TextTransparency = 0
						end
						if desc:IsA("TextButton") then
							desc.BackgroundTransparency = 0
						end
					end
				end
			end
		end
		
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, count * 54 + 10)
	end
	
	function module.AddLog(method, url, body)
		table.insert(module.Logs, {
			Method = method,
			Url = url,
			Body = body,
			Time = os.time()
		})
		if screenGui.Enabled then
			updateList(searchInput.Text)
		end
	end
	
	makeDraggable(mainFrame)
	
	local function toggle(state)
		if state then
			updateList(searchInput.Text)
			screenGui.Enabled = true
			
			TweenService:Create(mainFrame, TweenInfoOpen, {BackgroundTransparency = 0.1}):Play()
			TweenService:Create(uiStroke, TweenInfoOpen, {Transparency = 0}):Play()
			TweenService:Create(separator, TweenInfoOpen, {BackgroundTransparency = 0}):Play()
			TweenService:Create(bottomSeparator, TweenInfoOpen, {BackgroundTransparency = 0}):Play()
			TweenService:Create(searchInput, TweenInfoOpen, {TextTransparency = 0}):Play()
			TweenService:Create(closeButton, TweenInfoOpen, {TextTransparency = 0}):Play()
			
			TweenService:Create(clearButton, TweenInfoOpen, {BackgroundTransparency = 0, TextTransparency = 0}):Play()
			TweenService:Create(clearStroke, TweenInfoOpen, {Transparency = 0}):Play()
			
			TweenService:Create(enabledButton, TweenInfoOpen, {BackgroundTransparency = 0, TextTransparency = 0}):Play()
			TweenService:Create(enabledStroke, TweenInfoOpen, {Transparency = 0}):Play()
			
			TweenService:Create(blockButton, TweenInfoOpen, {BackgroundTransparency = 0, TextTransparency = 0}):Play()
			TweenService:Create(blockStroke, TweenInfoOpen, {Transparency = 0}):Play()
			
			TweenService:Create(scrollingFrame, TweenInfoOpen, {ScrollBarImageTransparency = 0}):Play()
			
			for _, child in ipairs(scrollingFrame:GetChildren()) do
				if child.Name == "LogItem" then
					TweenService:Create(child, TweenInfoOpen, {BackgroundTransparency = 0}):Play()
					local strokes = {}
					for _, desc in ipairs(child:GetDescendants()) do
						if desc:IsA("UIStroke") then
							TweenService:Create(desc, TweenInfoOpen, {Transparency = 0}):Play()
						elseif desc:IsA("TextLabel") or desc:IsA("TextButton") then
							TweenService:Create(desc, TweenInfoOpen, {TextTransparency = 0}):Play()
						end
						if desc:IsA("TextButton") then
							TweenService:Create(desc, TweenInfoOpen, {BackgroundTransparency = 0}):Play()
						end
					end
				end
			end
		else
			local tween = TweenService:Create(mainFrame, TweenInfoClose, {BackgroundTransparency = 1})
			tween:Play()
			TweenService:Create(uiStroke, TweenInfoClose, {Transparency = 1}):Play()
			TweenService:Create(separator, TweenInfoClose, {BackgroundTransparency = 1}):Play()
			TweenService:Create(bottomSeparator, TweenInfoClose, {BackgroundTransparency = 1}):Play()
			TweenService:Create(searchInput, TweenInfoClose, {TextTransparency = 1}):Play()
			TweenService:Create(closeButton, TweenInfoClose, {TextTransparency = 1}):Play()
			
			TweenService:Create(clearButton, TweenInfoClose, {BackgroundTransparency = 1, TextTransparency = 1}):Play()
			TweenService:Create(clearStroke, TweenInfoClose, {Transparency = 1}):Play()
			
			TweenService:Create(enabledButton, TweenInfoClose, {BackgroundTransparency = 1, TextTransparency = 1}):Play()
			TweenService:Create(enabledStroke, TweenInfoClose, {Transparency = 1}):Play()
			
			TweenService:Create(blockButton, TweenInfoClose, {BackgroundTransparency = 1, TextTransparency = 1}):Play()
			TweenService:Create(blockStroke, TweenInfoClose, {Transparency = 1}):Play()
			
			TweenService:Create(scrollingFrame, TweenInfoClose, {ScrollBarImageTransparency = 1}):Play()
			
			for _, child in ipairs(scrollingFrame:GetChildren()) do
				if child.Name == "LogItem" then
					TweenService:Create(child, TweenInfoClose, {BackgroundTransparency = 1}):Play()
					for _, desc in ipairs(child:GetDescendants()) do
						if desc:IsA("UIStroke") then
							TweenService:Create(desc, TweenInfoClose, {Transparency = 1}):Play()
						elseif desc:IsA("TextLabel") or desc:IsA("TextButton") then
							TweenService:Create(desc, TweenInfoClose, {TextTransparency = 1}):Play()
						end
						if desc:IsA("TextButton") then
							TweenService:Create(desc, TweenInfoClose, {BackgroundTransparency = 1}):Play()
						end
					end
				end
			end
			
			tween.Completed:Connect(function()
				if mainFrame.BackgroundTransparency == 1 then
					screenGui.Enabled = false
				end
			end)
		end
	end
	
	searchInput:GetPropertyChangedSignal("Text"):Connect(function()
		updateList(searchInput.Text)
	end)
	
	closeButton.MouseButton1Click:Connect(function()
		toggle(false)
	end)
	
	clearButton.MouseButton1Click:Connect(function()
		module.Logs = {}
		updateList("")
	end)
	
	function module.Toggle()
		if screenGui.Enabled and mainFrame.BackgroundTransparency < 0.5 then
			toggle(false)
		else
			toggle(true)
		end
	end
	
	return screenGui
end

function module.Cleanup()
	for _, connection in ipairs(module.Connections) do
		connection:Disconnect()
	end
	module.Connections = {}
	
	local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local gui = PlayerGui:FindFirstChild("HttpLogsUI")
	if gui then
		gui:Destroy()
	end
	
	module.Enabled = false
end

return module
