local module = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Notifications = getgenv().NexsNotifications
local Info = {
	Name = "Nexs Command",
	Version = "Loading...",
	Description = "A simple command console for Roblox games",
	Author = "Loading...",
	Repository = "https://github.com/7yd7/NexsCommand"
}
local DataLoaded = false

task.spawn(function()
	local baseUrl = getgenv().NEXS_BASE_URL
	if baseUrl:sub(-1) == "/" then
		baseUrl = baseUrl:sub(1, -2)
	end
	
	local url = baseUrl .. "/Data/info.json"
	local success, result = pcall(function()
		return game:HttpGet(url)
	end)
	
	if success then
		local decodeSuccess, decodedInfo = pcall(function()
			return HttpService:JSONDecode(result)
		end)
		
		if decodeSuccess and decodedInfo then
			Info = decodedInfo
		end
	end
	DataLoaded = true
end)

local TweenInfoOpen = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TweenInfoClose = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local instance = nil
local toggleFunc = nil

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

function module.Create()
	if instance then return instance end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CreditUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = game.CoreGui
	screenGui.Enabled = false
	
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 250, 0, 320)
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
		if not workspace.CurrentCamera then return end
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
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, -40, 1, 0)
	titleLabel.Position = UDim2.new(0, 10, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "Credits"
	titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 16
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextTransparency = 1
	titleLabel.Parent = header
	
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

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Size = UDim2.new(1, 0, 1, -36)
	content.Position = UDim2.new(0, 0, 0, 36)
	content.BackgroundTransparency = 1
	content.Parent = mainFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 10)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	listLayout.Parent = content

	local authorImage = Instance.new("ImageLabel")
	authorImage.Name = "AuthorImage"
	authorImage.Size = UDim2.new(0, 80, 0, 80)
	authorImage.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	authorImage.BackgroundTransparency = 1
	authorImage.ImageTransparency = 1
	authorImage.Parent = content
	
	local imageCorner = Instance.new("UICorner")
	imageCorner.CornerRadius = UDim.new(1, 0)
	imageCorner.Parent = authorImage
	
	task.spawn(function()
		authorImage.Image = "rbxassetid://86348174321218" 
	end)

	local function createLabel(text, font, size, color)
		local label = Instance.new("TextLabel")
		label.Text = text
		label.Font = font
		label.TextSize = size
		label.TextColor3 = color
		label.BackgroundTransparency = 1
		label.Size = UDim2.new(1, -20, 0, size + 5)
		label.TextTransparency = 1
		label.Parent = content
		return label
	end

	local nameLabel = createLabel(Info.Name, Enum.Font.GothamBold, 18, Color3.fromRGB(255, 255, 255))
	local versionLabel = createLabel("Version: " .. Info.Version, Enum.Font.Gotham, 14, Color3.fromRGB(180, 180, 180))
	local authorLabel = createLabel("Created by: " .. Info.Author, Enum.Font.Gotham, 14, Color3.fromRGB(180, 180, 180))

	local githubButton = Instance.new("TextButton")
	githubButton.Name = "GitHubButton"
	githubButton.Size = UDim2.new(0, 120, 0, 35)
	githubButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	githubButton.BackgroundTransparency = 1 
	githubButton.Text = "GitHub"
	githubButton.Font = Enum.Font.GothamBold
	githubButton.TextSize = 14
	githubButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	githubButton.TextTransparency = 1
	githubButton.Parent = content
	
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = githubButton
	
	githubButton.MouseButton1Click:Connect(function()
		setclipboard(Info.Repository)
		Notifications.Notify("Copied to clipboard", Info.Repository, 3)
	end)

	makeDraggable(mainFrame)
	
	local function toggle(state)
		if state then
			if not DataLoaded then
				local startTime = tick()
				repeat 
					task.wait(0.1)
				until DataLoaded or (tick() - startTime > 5)
			end

			nameLabel.Text = Info.Name
			versionLabel.Text = "Version: " .. Info.Version
			authorLabel.Text = "Created by: " .. Info.Author
			
			screenGui.Enabled = true
			
			TweenService:Create(mainFrame, TweenInfoOpen, {BackgroundTransparency = 0.1}):Play()
			TweenService:Create(uiStroke, TweenInfoOpen, {Transparency = 0}):Play()
			TweenService:Create(separator, TweenInfoOpen, {BackgroundTransparency = 0}):Play()
			TweenService:Create(titleLabel, TweenInfoOpen, {TextTransparency = 0}):Play()
			TweenService:Create(closeButton, TweenInfoOpen, {TextTransparency = 0}):Play()
			
			TweenService:Create(authorImage, TweenInfoOpen, {ImageTransparency = 0}):Play()
			TweenService:Create(nameLabel, TweenInfoOpen, {TextTransparency = 0}):Play()
			TweenService:Create(versionLabel, TweenInfoOpen, {TextTransparency = 0}):Play()
			TweenService:Create(authorLabel, TweenInfoOpen, {TextTransparency = 0}):Play()
			
			TweenService:Create(githubButton, TweenInfoOpen, {BackgroundTransparency = 0, TextTransparency = 0}):Play()
		else
			local tween = TweenService:Create(mainFrame, TweenInfoClose, {BackgroundTransparency = 1})
			tween:Play()
			TweenService:Create(uiStroke, TweenInfoClose, {Transparency = 1}):Play()
			TweenService:Create(separator, TweenInfoClose, {BackgroundTransparency = 1}):Play()
			TweenService:Create(titleLabel, TweenInfoClose, {TextTransparency = 1}):Play()
			TweenService:Create(closeButton, TweenInfoClose, {TextTransparency = 1}):Play()
			
			TweenService:Create(authorImage, TweenInfoClose, {ImageTransparency = 1}):Play()
			TweenService:Create(nameLabel, TweenInfoClose, {TextTransparency = 1}):Play()
			TweenService:Create(versionLabel, TweenInfoClose, {TextTransparency = 1}):Play()
			TweenService:Create(authorLabel, TweenInfoClose, {TextTransparency = 1}):Play()
			
			TweenService:Create(githubButton, TweenInfoClose, {BackgroundTransparency = 1, TextTransparency = 1}):Play()
			
			tween.Completed:Connect(function()
				if mainFrame.BackgroundTransparency == 1 then
					screenGui.Enabled = false
				end
			end)
		end
	end
	
	closeButton.MouseButton1Click:Connect(function()
		toggle(false)
	end)
	
	toggleFunc = function()
		if screenGui.Enabled and mainFrame.BackgroundTransparency < 0.5 then
			toggle(false)
		else
			toggle(true)
		end
	end
	
	instance = screenGui
	return screenGui
end

function module.Toggle()
	if not instance then
		module.Create()
	end
	if toggleFunc then
		toggleFunc()
	end
end

return module
