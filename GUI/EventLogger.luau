local module = {}
module.Logs = {}
module.Connections = {}
module.ObjectConnections = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local TweenInfoOpen = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TweenInfoClose = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local function getPath(obj)
	if not obj then return "nil" end
	local path = obj.Name
	local current = obj.Parent
	while current and current ~= game do
		path = current.Name .. "." .. path
		current = current.Parent
	end
	return "game." .. path
end

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
	screenGui.Name = "EventLoggerUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = game.CoreGui
	screenGui.Enabled = false
	
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 350, 0, 300)
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35) 
	mainFrame.BackgroundTransparency = 1 
	mainFrame.BorderSizePixel = 0
	mainFrame.ClipsDescendants = true
	mainFrame.Parent = screenGui
	
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 10)
	uiCorner.Parent = mainFrame
	
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(60, 60, 60)
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
	header.Size = UDim2.new(1, 0, 0, 35)
	header.BackgroundTransparency = 1
	header.Parent = mainFrame
	
	local searchInput = Instance.new("TextBox")
	searchInput.Name = "SearchInput"
	searchInput.Size = UDim2.new(1, -90, 1, 0)
	searchInput.Position = UDim2.new(0, 10, 0, 0)
	searchInput.BackgroundTransparency = 1
	searchInput.Text = ""
	searchInput.PlaceholderText = "Search logs..."
	searchInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
	searchInput.TextColor3 = Color3.fromRGB(220, 220, 220)
	searchInput.Font = Enum.Font.Gotham
	searchInput.TextSize = 14
	searchInput.TextXAlignment = Enum.TextXAlignment.Left
	searchInput.TextTransparency = 1 
	searchInput.Parent = header
	
	local clearButton = Instance.new("TextButton")
	clearButton.Name = "ClearButton"
	clearButton.Size = UDim2.new(0, 50, 0, 25)
	clearButton.Position = UDim2.new(1, -85, 0, 5)
	clearButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
	clearButton.BackgroundTransparency = 1
	clearButton.Text = "Clear"
	clearButton.Font = Enum.Font.GothamBold
	clearButton.TextSize = 12
	clearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	clearButton.TextTransparency = 1
	clearButton.Parent = header
	
	local clearCorner = Instance.new("UICorner")
	clearCorner.CornerRadius = UDim.new(0, 4)
	clearCorner.Parent = clearButton
	
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 25, 0, 35)
	closeButton.Position = UDim2.new(1, -25, 0, 0)
	closeButton.BackgroundTransparency = 1
	closeButton.Text = "×"
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextSize = 18
	closeButton.TextColor3 = Color3.fromRGB(180, 180, 180)
	closeButton.TextTransparency = 1 
	closeButton.Parent = header
	
	local separator = Instance.new("Frame")
	separator.Size = UDim2.new(1, 0, 0, 1)
	separator.Position = UDim2.new(0, 0, 0, 35)
	separator.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	separator.BorderSizePixel = 0
	separator.BackgroundTransparency = 1 
	separator.Parent = mainFrame
	
	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Name = "List"
	scrollingFrame.Size = UDim2.new(1, 0, 1, -36)
	scrollingFrame.Position = UDim2.new(0, 0, 0, 36)
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.ScrollBarThickness = 2
	scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
	scrollingFrame.ScrollBarImageTransparency = 1 
	scrollingFrame.Parent = mainFrame
	
	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 2)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.Parent = scrollingFrame
	
	local listPadding = Instance.new("UIPadding")
	listPadding.PaddingTop = UDim.new(0, 5)
	listPadding.PaddingBottom = UDim.new(0, 5)
	listPadding.Parent = scrollingFrame
	
	local function createLogItem(log)
		local itemFrame = Instance.new("Frame")
		itemFrame.Name = "LogItem"
		itemFrame.Size = UDim2.new(1, -10, 0, 40)
		itemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		itemFrame.BackgroundTransparency = 1
		itemFrame.Parent = scrollingFrame
		
		local itemCorner = Instance.new("UICorner")
		itemCorner.CornerRadius = UDim.new(0, 6)
		itemCorner.Parent = itemFrame
		
		local typeLabel = Instance.new("TextLabel")
		typeLabel.Size = UDim2.new(0, 80, 0, 20)
		typeLabel.Position = UDim2.new(0, 5, 0, 2)
		typeLabel.BackgroundTransparency = 1
		typeLabel.Font = Enum.Font.GothamBold
		typeLabel.TextSize = 11
		typeLabel.TextXAlignment = Enum.TextXAlignment.Left
		typeLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
		typeLabel.Text = log.Type
		typeLabel.TextTransparency = 1
		typeLabel.Parent = itemFrame
		
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, -90, 0, 20)
		nameLabel.Position = UDim2.new(0, 90, 0, 2)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Font = Enum.Font.Gotham
		nameLabel.TextSize = 11
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
		nameLabel.Text = log.Name
		nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
		nameLabel.TextTransparency = 1
		nameLabel.Parent = itemFrame
		
		local copyButton = Instance.new("TextButton")
		copyButton.Size = UDim2.new(0, 40, 0, 15)
		copyButton.Position = UDim2.new(1, -90, 0, 22)
		copyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		copyButton.BackgroundTransparency = 1
		copyButton.Text = "Copy"
		copyButton.Font = Enum.Font.Gotham
		copyButton.TextSize = 10
		copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		copyButton.TextTransparency = 1
		copyButton.Parent = itemFrame
		
		local copyCorner = Instance.new("UICorner")
		copyCorner.CornerRadius = UDim.new(0, 4)
		copyCorner.Parent = copyButton
		
		local fireButton = Instance.new("TextButton")
		fireButton.Size = UDim2.new(0, 40, 0, 15)
		fireButton.Position = UDim2.new(1, -45, 0, 22)
		fireButton.BackgroundColor3 = Color3.fromRGB(60, 150, 60)
		fireButton.BackgroundTransparency = 1
		fireButton.Text = "Fire"
		fireButton.Font = Enum.Font.Gotham
		fireButton.TextSize = 10
		fireButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		fireButton.TextTransparency = 1
		fireButton.Parent = itemFrame
		
		local fireCorner = Instance.new("UICorner")
		fireCorner.CornerRadius = UDim.new(0, 4)
		fireCorner.Parent = fireButton
		
		copyButton.MouseButton1Click:Connect(function()
			if log.Object then
				setclipboard(getPath(log.Object))
			end
		end)
		
		fireButton.MouseButton1Click:Connect(function()
			if log.Object then
				if log.Type == "ProximityPrompt" then
					fireproximityprompt(log.Object)
				elseif log.Type == "ClickDetector" then
					fireclickdetector(log.Object)
				elseif log.Type == "TouchInterest" then
					if log.Object.Parent then
						firetouchinterest(LocalPlayer.Character.HumanoidRootPart, log.Object.Parent, 0)
						task.wait()
						firetouchinterest(LocalPlayer.Character.HumanoidRootPart, log.Object.Parent, 1)
					end
				end
			end
		end)
		
		return itemFrame
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
			elseif string.find(string.lower(log.Name), string.lower(query)) then
				match = true
			end
			
			if match then
				local item = createLogItem(log)
				count = count + 1
			end
		end
		
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, count * 42 + 10)
		
		if screenGui.Enabled and mainFrame.BackgroundTransparency < 1 then
			for _, child in ipairs(scrollingFrame:GetChildren()) do
				if child.Name == "LogItem" then
					child.BackgroundTransparency = 0.5
					for _, desc in ipairs(child:GetDescendants()) do
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
	end
	
	local function addLog(type, object)
		if not object then return end
		
		local displayName = object.Name
		if object.Parent then
			displayName = getPath(object.Parent)
		end
		
		table.insert(module.Logs, {
			Type = type,
			Name = displayName,
			Object = object,
			Time = os.time()
		})
		if screenGui.Enabled then
			updateList(searchInput.Text)
		end
	end
	
	table.insert(module.Connections, ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
		if player == LocalPlayer then
			addLog("ProximityPrompt", prompt)
		end
	end))
	
	local function setupClickDetector(cd)
		if module.ObjectConnections[cd] then return end
		module.ObjectConnections[cd] = cd.MouseClick:Connect(function(player)
			if player == LocalPlayer then
				addLog("ClickDetector", cd)
			end
		end)
	end
	
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("ClickDetector") then
			setupClickDetector(v)
		end
	end
	
	table.insert(module.Connections, workspace.DescendantAdded:Connect(function(desc)
		if desc:IsA("ClickDetector") then
			setupClickDetector(desc)
		end
	end))
	
	makeDraggable(mainFrame)

	local function setupCharacter(char)
		if not char then return end
		local hrp = char:WaitForChild("HumanoidRootPart", 5)
		if not hrp then return end
		
		table.insert(module.Connections, hrp.Touched:Connect(function(hit)
			if hit:FindFirstChild("TouchInterest") then
				addLog("TouchInterest", hit:FindFirstChild("TouchInterest"))
			end
		end))
	end
	
	if LocalPlayer.Character then
		setupCharacter(LocalPlayer.Character)
	end
	table.insert(module.Connections, LocalPlayer.CharacterAdded:Connect(setupCharacter))
	
	
	local function toggle(state)
		if state then
			updateList(searchInput.Text)
			screenGui.Enabled = true
			
			TweenService:Create(mainFrame, TweenInfoOpen, {BackgroundTransparency = 0.1}):Play()
			TweenService:Create(uiStroke, TweenInfoOpen, {Transparency = 0}):Play()
			TweenService:Create(separator, TweenInfoOpen, {BackgroundTransparency = 0}):Play()
			TweenService:Create(searchInput, TweenInfoOpen, {TextTransparency = 0}):Play()
			TweenService:Create(closeButton, TweenInfoOpen, {TextTransparency = 0}):Play()
			TweenService:Create(clearButton, TweenInfoOpen, {BackgroundTransparency = 0, TextTransparency = 0}):Play()
			TweenService:Create(scrollingFrame, TweenInfoOpen, {ScrollBarImageTransparency = 0}):Play()
			
			for _, child in ipairs(scrollingFrame:GetChildren()) do
				if child.Name == "LogItem" then
					TweenService:Create(child, TweenInfoOpen, {BackgroundTransparency = 0.5}):Play()
					for _, desc in ipairs(child:GetDescendants()) do
						if desc:IsA("TextLabel") or desc:IsA("TextButton") then
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
			TweenService:Create(searchInput, TweenInfoClose, {TextTransparency = 1}):Play()
			TweenService:Create(closeButton, TweenInfoClose, {TextTransparency = 1}):Play()
			TweenService:Create(clearButton, TweenInfoClose, {BackgroundTransparency = 1, TextTransparency = 1}):Play()
			TweenService:Create(scrollingFrame, TweenInfoClose, {ScrollBarImageTransparency = 1}):Play()
			
			for _, child in ipairs(scrollingFrame:GetChildren()) do
				if child.Name == "LogItem" then
					TweenService:Create(child, TweenInfoClose, {BackgroundTransparency = 1}):Play()
					for _, desc in ipairs(child:GetDescendants()) do
						if desc:IsA("TextLabel") or desc:IsA("TextButton") then
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
	
	local dragging, dragInput, dragStart, startPos
	local function update(input)
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	header.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then update(input) end
	end)
	
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
	for _, connection in pairs(module.ObjectConnections) do
		connection:Disconnect()
	end
	module.Connections = {}
	module.ObjectConnections = {}
	
	local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local gui = PlayerGui:FindFirstChild("EventLoggerUI")
	if gui then
		gui:Destroy()
	end
end

return module
