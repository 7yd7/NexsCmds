local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")

local module = {}

local NOTIFICATION_SIZE = UDim2.new(0, 300, 0, 60)
local PADDING = 10
local START_POSITION = UDim2.new(0.5, 0, 1, 50) 
local ANCHOR_POINT = Vector2.new(0.5, 1) 
local BASE_POSITION_Y = 1 

local THEME = {
	BackgroundColor = Color3.fromRGB(35, 35, 35),
	BackgroundTransparency = 0.1,
	TextColor = Color3.fromRGB(255, 255, 255),
	SubTextColor = Color3.fromRGB(200, 200, 200),
	Font = Enum.Font.GothamMedium,
	SubFont = Enum.Font.Gotham,
	CornerRadius = UDim.new(0, 10)
}

local activeNotifications = {} 
local gui = nil

local function createGui()
	if gui and gui.Parent then return gui end
	gui = Instance.new("ScreenGui")
	gui.Name = "NotificationUI"
	gui.ResetOnSpawn = false
	gui.Parent = game.CoreGui
	return gui
end

local function updatePositions()
	local viewportSize = workspace.CurrentCamera.ViewportSize
	local isSmallScreen = viewportSize.X < 450
	local startY = isSmallScreen and -80 or -20
	
	local currentYOffset = startY 
	
	for i = #activeNotifications, 1, -1 do
		local frame = activeNotifications[i]
		if frame and frame.Parent then
			local targetPos = UDim2.new(0.5, 0, 1, currentYOffset)
			
			TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Position = targetPos
			}):Play()
			
			currentYOffset = currentYOffset - frame.AbsoluteSize.Y - PADDING
		end
	end
end

function module.Notify(title, text, duration)
	local screenGui = createGui()
	duration = duration or 5

	local textWidth = TextService:GetTextSize(text, 14, THEME.SubFont, Vector2.new(math.huge, 20)).X
	
	local minWidth = 300
	local padding = 80 
	local requiredWidth = textWidth + padding
	
	local viewportSize = workspace.CurrentCamera.ViewportSize
	local isSmallScreen = viewportSize.X < 450
	
	if isSmallScreen then
		minWidth = viewportSize.X * 0.9
		requiredWidth = math.min(requiredWidth, viewportSize.X * 0.95)
	end
	
	local finalWidth = math.max(minWidth, requiredWidth)
	if isSmallScreen then finalWidth = viewportSize.X * 0.9 end 
	
	local finalSize = UDim2.new(0, finalWidth, 0, 60) 

	local frame = Instance.new("TextButton")
	frame.Name = "Notification"
	frame.Size = finalSize
	frame.Position = START_POSITION
	frame.AnchorPoint = ANCHOR_POINT
	frame.BackgroundColor3 = THEME.BackgroundColor
	frame.BackgroundTransparency = THEME.BackgroundTransparency
	frame.BorderSizePixel = 0
	frame.Text = ""
	frame.AutoButtonColor = false
	frame.ClipsDescendants = true
	frame.Parent = screenGui

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = THEME.CornerRadius
	uiCorner.Parent = frame
	
	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.Size = UDim2.new(0, 30, 0, 30)
	icon.Position = UDim2.new(0, 15, 0.5, -15) 
	icon.BackgroundTransparency = 1
	icon.Image = "rbxassetid://11401835376" 
	icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
	icon.Parent = frame

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, -60, 0, 20)
	titleLabel.Position = UDim2.new(0, 55, 0, 10)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = THEME.Font
	titleLabel.TextSize = 16
	titleLabel.TextColor3 = THEME.TextColor
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = title
	titleLabel.Parent = frame

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Text"
	textLabel.Size = UDim2.new(1, -60, 0, 20)
	textLabel.Position = UDim2.new(0, 55, 0, 30)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = THEME.SubFont
	textLabel.TextSize = 14
	textLabel.TextColor3 = THEME.SubTextColor
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextWrapped = false 
	textLabel.Text = text
	textLabel.Parent = frame
	
	table.insert(activeNotifications, frame)
	
	updatePositions()

	local isClosing = false
	local function close()
		if isClosing or not frame or not frame.Parent then return end
		isClosing = true
		
		local fadeInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(titleLabel, fadeInfo, {TextTransparency = 1}):Play()
		TweenService:Create(textLabel, fadeInfo, {TextTransparency = 1}):Play()
		TweenService:Create(icon, fadeInfo, {ImageTransparency = 1}):Play()
		
		task.wait(0.1)
		
		local shrinkInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		local shrinkTween = TweenService:Create(frame, shrinkInfo, {
			Size = UDim2.new(0, 250, 0, 0), 
			BackgroundTransparency = 1
		})
		shrinkTween:Play()
		
		local index = table.find(activeNotifications, frame)
		if index then
			table.remove(activeNotifications, index)
		end
		
		updatePositions()
		
		shrinkTween.Completed:Wait()
		frame:Destroy()
	end

	frame.MouseButton1Click:Connect(close)

	task.delay(duration, close)
end

return module
