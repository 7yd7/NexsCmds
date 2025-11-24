local module = {}
module.Commands = {}
module.CommandOrder = {}
module.Connections = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local TweenInfoOpen = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TweenInfoClose = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)


function module.RegisterCommand(name, args, desc, aliases, callback)
	module.Commands[name] = {
		Args = args,
		Desc = desc,
		Aliases = aliases,
		Callback = callback
	}
	table.insert(module.CommandOrder, name)
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
	screenGui.Name = "CommandListUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = game.CoreGui
	screenGui.Enabled = false
	
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 220, 0, 300)
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
				
				if viewportSize.X < 500 then
					mainFrame.Size = UDim2.new(0.85, 0, 0.7, 0) 
					uiScale.Scale = math.max(0.65, viewportSize.X / 600) 
				else
					mainFrame.Size = UDim2.new(0, 220, 0, 300) 
				end
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
	searchInput.Size = UDim2.new(1, -30, 1, 0)
	searchInput.Position = UDim2.new(0, 10, 0, 0)
	searchInput.BackgroundTransparency = 1
	searchInput.Text = ""
	searchInput.PlaceholderText = "Search..."
	searchInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
	searchInput.TextColor3 = Color3.fromRGB(220, 220, 220)
	searchInput.Font = Enum.Font.Gotham
	searchInput.TextSize = 14
	searchInput.TextXAlignment = Enum.TextXAlignment.Left
	searchInput.TextTransparency = 1 
	searchInput.Parent = header
	
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
	
	local function createItem(name, aliases)
		local label = Instance.new("TextLabel")
		label.Name = name
		label.Size = UDim2.new(1, -20, 0, 20)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.Gotham
		label.TextSize = 13
		label.TextColor3 = Color3.fromRGB(200, 200, 200)
		label.TextTransparency = 1 
		
		if aliases and aliases ~= "" then
			label.Text = string.format("%s <font color='#888888'>(%s)</font>", name, aliases)
			label.RichText = true
		else
			label.Text = name
		end
		
		label.Parent = scrollingFrame
	end
	
	local function updateList(query)
		for _, child in ipairs(scrollingFrame:GetChildren()) do
			if child:IsA("TextLabel") then child:Destroy() end
		end
		
		local count = 0
		for _, name in ipairs(module.CommandOrder) do
			local cmd = module.Commands[name]
			local match = false
			if query == "" then
				match = true
			elseif string.find(string.lower(name), string.lower(query)) then
				match = true
			elseif cmd.Aliases and string.find(string.lower(cmd.Aliases), string.lower(query)) then
				match = true
			end
			
			if match then
				createItem(name, cmd.Aliases)
				count = count + 1
			end
		end
		
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, count * 22 + 10)
		
		if screenGui.Enabled and mainFrame.BackgroundTransparency < 1 then
			for _, child in ipairs(scrollingFrame:GetChildren()) do
				if child:IsA("TextLabel") then child.TextTransparency = 0 end
			end
		end
	end
	
	updateList("")
	
	local function toggle(state)
		if state then
			updateList(searchInput.Text)
			screenGui.Enabled = true
			
			TweenService:Create(mainFrame, TweenInfoOpen, {BackgroundTransparency = 0.1}):Play()
			TweenService:Create(uiStroke, TweenInfoOpen, {Transparency = 0}):Play()
			TweenService:Create(separator, TweenInfoOpen, {BackgroundTransparency = 0}):Play()
			TweenService:Create(searchInput, TweenInfoOpen, {TextTransparency = 0}):Play()
			TweenService:Create(closeButton, TweenInfoOpen, {TextTransparency = 0}):Play()
			TweenService:Create(scrollingFrame, TweenInfoOpen, {ScrollBarImageTransparency = 0}):Play()
			
			for _, child in ipairs(scrollingFrame:GetChildren()) do
				if child:IsA("TextLabel") then
					TweenService:Create(child, TweenInfoOpen, {TextTransparency = 0}):Play()
				end
			end
		else
			local tween = TweenService:Create(mainFrame, TweenInfoClose, {BackgroundTransparency = 1})
			tween:Play()
			TweenService:Create(uiStroke, TweenInfoClose, {Transparency = 1}):Play()
			TweenService:Create(separator, TweenInfoClose, {BackgroundTransparency = 1}):Play()
			TweenService:Create(searchInput, TweenInfoClose, {TextTransparency = 1}):Play()
			TweenService:Create(closeButton, TweenInfoClose, {TextTransparency = 1}):Play()
			TweenService:Create(scrollingFrame, TweenInfoClose, {ScrollBarImageTransparency = 1}):Play()
			
			for _, child in ipairs(scrollingFrame:GetChildren()) do
				if child:IsA("TextLabel") then
					TweenService:Create(child, TweenInfoClose, {TextTransparency = 1}):Play()
				end
			end
			
			tween.Completed:Connect(function()
				if mainFrame.BackgroundTransparency == 1 then
					screenGui.Enabled = false
				end
			end)
		end
	end
	

    makeDraggable(mainFrame)

	searchInput:GetPropertyChangedSignal("Text"):Connect(function()
		updateList(searchInput.Text)
	end)
	
	closeButton.MouseButton1Click:Connect(function()
		toggle(false)
	end)
	
	function module.Toggle()
		if screenGui.Enabled and mainFrame.BackgroundTransparency < 0.5 then
			toggle(false)
		else
			toggle(true)
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
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	header.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
	
	return screenGui
end

function module.Cleanup()
	for _, connection in ipairs(module.Connections) do
		connection:Disconnect()
	end
	module.Connections = {}
	
	local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local gui = PlayerGui:FindFirstChild("CommandListUI")
	if gui then
		gui:Destroy()
	end
	
	module.Commands = {}
end

return module
