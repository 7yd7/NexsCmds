local module = {}
module.Connections = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local TweenInfoOpen = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TweenInfoClose = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local ROOT_FOLDER = "NexsCommands"
local GLOBAL_FOLDER = ROOT_FOLDER .. "/Global"
local GAMES_FOLDER = ROOT_FOLDER .. "/Games"

local function ensureFolders()
	if not isfolder(ROOT_FOLDER) then makefolder(ROOT_FOLDER) end
	if not isfolder(GLOBAL_FOLDER) then makefolder(GLOBAL_FOLDER) end
	if not isfolder(GAMES_FOLDER) then makefolder(GAMES_FOLDER) end
end

local function getGameFolder()
	local gameId = tostring(game.PlaceId)
	local folder = GAMES_FOLDER .. "/" .. gameId
	if not isfolder(folder) then makefolder(folder) end
	return folder
end

local function saveCommand(name, content, isGameSpecific)
	ensureFolders()
	local folder = isGameSpecific and getGameFolder() or GLOBAL_FOLDER
	writefile(folder .. "/" .. name .. ".luau", content)
end

local function deleteCommand(name, isGameSpecific)
	ensureFolders()
	local folder = isGameSpecific and getGameFolder() or GLOBAL_FOLDER
	local path = folder .. "/" .. name .. ".luau"
	if isfile(path) then delfile(path) end
end

local function listCommands(targetFolder)
	ensureFolders()
	local cmds = {}
	
	if isfolder(targetFolder) then
		for _, file in ipairs(listfiles(targetFolder)) do
			if file:sub(-5) == ".luau" then
				local name = file:match("([^/\\]+)%.luau$")
				table.insert(cmds, {Name = name, Path = file})
			end
		end
	end
	
	return cmds
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
	screenGui.Name = "NexsExternalCmdsUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = game.CoreGui
	screenGui.Enabled = false
	
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 600, 0, 450)
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
	
	makeDraggable(mainFrame)
	
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 40)
	header.BackgroundTransparency = 1
	header.Parent = mainFrame
	
	local title = Instance.new("TextLabel")
	title.Text = "External Commands Manager"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 16
	title.TextColor3 = Color3.fromRGB(220, 220, 220)
	title.Size = UDim2.new(1, -40, 1, 0)
	title.Position = UDim2.new(0, 15, 0, 0)
	title.BackgroundTransparency = 1
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextTransparency = 1
	title.Parent = header
	
	local closeButton = Instance.new("TextButton")
	closeButton.Text = "×"
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextSize = 20
	closeButton.TextColor3 = Color3.fromRGB(150, 150, 150)
	closeButton.Size = UDim2.new(0, 30, 0, 40)
	closeButton.Position = UDim2.new(1, -30, 0, 0)
	closeButton.BackgroundTransparency = 1
	closeButton.TextTransparency = 1
	closeButton.Parent = header
	
	local separator = Instance.new("Frame")
	separator.Size = UDim2.new(1, 0, 0, 1)
	separator.Position = UDim2.new(0, 0, 0, 40)
	separator.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	separator.BorderSizePixel = 0
	separator.BackgroundTransparency = 1
	separator.Parent = mainFrame
	
	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Size = UDim2.new(1, 0, 1, -80)
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
	
	local bottomBar = Instance.new("Frame")
	bottomBar.Size = UDim2.new(1, 0, 0, 40)
	bottomBar.Position = UDim2.new(0, 0, 1, -40)
	bottomBar.BackgroundTransparency = 1
	bottomBar.Parent = mainFrame
	
	local bottomSeparator = Instance.new("Frame")
	bottomSeparator.Size = UDim2.new(1, 0, 0, 1)
	bottomSeparator.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	bottomSeparator.BorderSizePixel = 0
	bottomSeparator.BackgroundTransparency = 1
	bottomSeparator.Parent = bottomBar
	
	local function createButton(text, pos, width, color)
		local btn = Instance.new("TextButton")
		btn.Text = text
		btn.Size = UDim2.new(0, width, 0, 24)
		btn.Position = pos
		btn.BackgroundColor3 = color or Color3.fromRGB(30, 30, 30)
		btn.BackgroundTransparency = 1
		btn.Font = Enum.Font.GothamMedium
		btn.TextSize = 12
		btn.TextColor3 = Color3.fromRGB(200, 200, 200)
		btn.TextTransparency = 1
		btn.Parent = bottomBar
		
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 6)
		c.Parent = btn
		
		local s = Instance.new("UIStroke")
		s.Color = Color3.fromRGB(60, 60, 60)
		s.Thickness = 1
		s.Transparency = 1
		s.Parent = btn
		
		return btn, s
	end
	
	local addButton, addStroke = createButton("Add Command", UDim2.new(0, 15, 0, 8), 100, Color3.fromRGB(40, 40, 40))
	local refreshButton, refreshStroke = createButton("Refresh", UDim2.new(1, -85, 0, 8), 70)
	
	local gameFolderBtn, gameFolderStroke = createButton("Game Folder", UDim2.new(0, 125, 0, 8), 100, Color3.fromRGB(40, 40, 60))
	
	local editorFrame = Instance.new("Frame")
	editorFrame.Name = "Editor"
	editorFrame.Size = UDim2.new(1, 0, 1, 0)
	editorFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	editorFrame.BackgroundTransparency = 0
	editorFrame.Visible = false
	editorFrame.Parent = mainFrame
	
	local editorTitle = Instance.new("TextLabel")
	editorTitle.Text = "Edit Command"
	editorTitle.Font = Enum.Font.GothamBold
	editorTitle.TextSize = 16
	editorTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
	editorTitle.Size = UDim2.new(1, -40, 0, 40)
	editorTitle.Position = UDim2.new(0, 15, 0, 0)
	editorTitle.BackgroundTransparency = 1
	editorTitle.TextXAlignment = Enum.TextXAlignment.Left
	editorTitle.Parent = editorFrame
	
	local configLabel = Instance.new("TextLabel")
	configLabel.Text = "Configuration (module.Name = ...)"
	configLabel.Font = Enum.Font.GothamBold
	configLabel.TextSize = 12
	configLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	configLabel.Size = UDim2.new(1, -30, 0, 20)
	configLabel.Position = UDim2.new(0, 15, 0, 40)
	configLabel.BackgroundTransparency = 1
	configLabel.TextXAlignment = Enum.TextXAlignment.Left
	configLabel.Parent = editorFrame

	local configInput = Instance.new("TextBox")
	configInput.PlaceholderText = "-- Paste your configuration here\nmodule.Name = \"example\"\nmodule.Args = \"...\""
	configInput.Size = UDim2.new(1, -30, 0, 140)
	configInput.Position = UDim2.new(0, 15, 0, 60)
	configInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	configInput.TextColor3 = Color3.fromRGB(220, 220, 220)
	configInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
	configInput.Font = Enum.Font.Code
	configInput.TextSize = 13
	configInput.TextXAlignment = Enum.TextXAlignment.Left
	configInput.TextYAlignment = Enum.TextYAlignment.Top
	configInput.ClearTextOnFocus = false
	configInput.MultiLine = true
	configInput.Parent = editorFrame
	
	Instance.new("UICorner", configInput).CornerRadius = UDim.new(0, 6)
	local cp = Instance.new("UIPadding")
	cp.PaddingLeft = UDim.new(0, 10)
	cp.PaddingTop = UDim.new(0, 10)
	cp.Parent = configInput

	local callbackLabel = Instance.new("TextLabel")
	callbackLabel.Text = "Callback (function(args) ... end)"
	callbackLabel.Font = Enum.Font.GothamBold
	callbackLabel.TextSize = 12
	callbackLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	callbackLabel.Size = UDim2.new(1, -30, 0, 20)
	callbackLabel.Position = UDim2.new(0, 15, 0, 210)
	callbackLabel.BackgroundTransparency = 1
	callbackLabel.TextXAlignment = Enum.TextXAlignment.Left
	callbackLabel.Parent = editorFrame

	local callbackInput = Instance.new("TextBox")
	callbackInput.PlaceholderText = "-- Write your callback code here\nprint(args[1])"
	callbackInput.Size = UDim2.new(1, -30, 0, 140)
	callbackInput.Position = UDim2.new(0, 15, 0, 230)
	callbackInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	callbackInput.TextColor3 = Color3.fromRGB(220, 220, 220)
	callbackInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
	callbackInput.Font = Enum.Font.Code
	callbackInput.TextSize = 13
	callbackInput.TextXAlignment = Enum.TextXAlignment.Left
	callbackInput.TextYAlignment = Enum.TextYAlignment.Top
	callbackInput.ClearTextOnFocus = false
	callbackInput.MultiLine = true
	callbackInput.Parent = editorFrame
	
	Instance.new("UICorner", callbackInput).CornerRadius = UDim.new(0, 6)
	local cbp = Instance.new("UIPadding")
	cbp.PaddingLeft = UDim.new(0, 10)
	cbp.PaddingTop = UDim.new(0, 10)
	cbp.Parent = callbackInput
	
	local saveButton = Instance.new("TextButton")
	saveButton.Text = "Save"
	saveButton.Size = UDim2.new(0, 80, 0, 25)
	saveButton.Position = UDim2.new(1, -95, 1, -35)
	saveButton.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
	saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	saveButton.Font = Enum.Font.GothamBold
	saveButton.TextSize = 12
	saveButton.Parent = editorFrame
	Instance.new("UICorner", saveButton).CornerRadius = UDim.new(0, 6)
	
	local cancelEditButton = Instance.new("TextButton")
	cancelEditButton.Text = "Cancel"
	cancelEditButton.Size = UDim2.new(0, 80, 0, 25)
	cancelEditButton.Position = UDim2.new(1, -185, 1, -35)
	cancelEditButton.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
	cancelEditButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	cancelEditButton.Font = Enum.Font.GothamBold
	cancelEditButton.TextSize = 12
	cancelEditButton.Parent = editorFrame
	Instance.new("UICorner", cancelEditButton).CornerRadius = UDim.new(0, 6)
	
	local isGameSpecificView = false
	
	local function populateList()
		for _, child in ipairs(scrollingFrame:GetChildren()) do
			if child:IsA("Frame") then child:Destroy() end
		end
		
		local targetFolder = isGameSpecificView and getGameFolder() or GLOBAL_FOLDER
		local cmds = listCommands(targetFolder)
		
		for _, cmd in ipairs(cmds) do
			local item = Instance.new("Frame")
			item.Size = UDim2.new(1, -20, 0, 40)
			item.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			item.BackgroundTransparency = 0
			item.Parent = scrollingFrame
			Instance.new("UICorner", item).CornerRadius = UDim.new(0, 6)
			
			local nameLabel = Instance.new("TextLabel")
			nameLabel.Text = cmd.Name
			nameLabel.Font = Enum.Font.GothamBold
			nameLabel.TextSize = 14
			nameLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
			nameLabel.Size = UDim2.new(0, 150, 1, 0)
			nameLabel.Position = UDim2.new(0, 10, 0, 0)
			nameLabel.BackgroundTransparency = 1
			nameLabel.TextXAlignment = Enum.TextXAlignment.Left
			nameLabel.Parent = item
			
			local delBtn = Instance.new("TextButton")
			delBtn.Text = "Delete"
			delBtn.Size = UDim2.new(0, 50, 0, 24)
			delBtn.Position = UDim2.new(1, -60, 0, 8)
			delBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
			delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			delBtn.Font = Enum.Font.Gotham
			delBtn.TextSize = 11
			delBtn.Parent = item
			Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 4)
			
			delBtn.MouseButton1Click:Connect(function()
				deleteCommand(cmd.Name, isGameSpecificView)
				populateList()
			end)
			
			local editBtn = Instance.new("TextButton")
			editBtn.Text = "Edit"
			editBtn.Size = UDim2.new(0, 50, 0, 24)
			editBtn.Position = UDim2.new(1, -120, 0, 8)
			editBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 150)
			editBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			editBtn.Font = Enum.Font.Gotham
			editBtn.TextSize = 11
			editBtn.Parent = item
			Instance.new("UICorner", editBtn).CornerRadius = UDim.new(0, 4)
			
			editBtn.MouseButton1Click:Connect(function()
				local content = readfile(cmd.Path)
				
				local configPart = ""
				local callbackPart = ""
				
				local callbackStart = content:find("module.Callback%s*=%s*function")
				if callbackStart then
					configPart = content:sub(1, callbackStart - 1)
					configPart = configPart:gsub("local module = {}", ""):gsub("^%s+", "")
					
					local callbackEnd = content:find("end%s*}$") or content:find("end%s*$")
					if callbackEnd then
						local bodyStart = content:find("%)", callbackStart)
						if bodyStart then
							callbackPart = content:sub(bodyStart + 1, callbackEnd - 1)
							callbackPart = callbackPart:gsub("^%s+", ""):gsub("%s+$", "")
						end
					end
				else
					configPart = content
				end
				
				configInput.Text = configPart
				callbackInput.Text = callbackPart
				
				editorFrame.Visible = true
			end)
		end
		
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #cmds * 44 + 10)
	end
	
	gameFolderBtn.MouseButton1Click:Connect(function()
		isGameSpecificView = not isGameSpecificView
		
		if isGameSpecificView then
			local MarketplaceService = game:GetService("MarketplaceService")
			local success, info = pcall(function()
				return MarketplaceService:GetProductInfo(game.PlaceId)
			end)
			local gameName = success and info.Name or "Unknown Game"
			
			gameFolderBtn.Text = "View: " .. gameName
			gameFolderBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
			title.Text = "External Commands (" .. gameName .. ")"
		else
			gameFolderBtn.Text = "Game Folder"
			gameFolderBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
			title.Text = "External Commands (Global)"
		end
		
		populateList()
	end)
	
	addButton.MouseButton1Click:Connect(function()
		configInput.Text = "module.Name = \"example\"\nmodule.Args = \"<arg1>\"\nmodule.Description = \"Description\""
		callbackInput.Text = "print(\"Hello World\")"
		editorFrame.Visible = true
	end)
	
	refreshButton.MouseButton1Click:Connect(populateList)
	
	cancelEditButton.MouseButton1Click:Connect(function()
		editorFrame.Visible = false
	end)
	
	saveButton.MouseButton1Click:Connect(function()
		local config = configInput.Text
		local callback = callbackInput.Text
		
		local name = config:match('module.Name%s*=%s*"([^"]+)"')
		if not name then
			name = config:match("module.Name%s*=%s*'([^']+)'")
		end
		
		if not name then
			warn("Could not find module.Name in config")
			return 
		end
		
		local fileContent = string.format([[local module = {}

%s

module.Callback = function(args)
%s
end

return module]], config, callback)

		saveCommand(name, fileContent, isGameSpecificView)
		editorFrame.Visible = false
		populateList()
	end)
	
	local function toggle(state)
		if state then
			populateList()
			screenGui.Enabled = true
			TweenService:Create(mainFrame, TweenInfoOpen, {BackgroundTransparency = 0.1}):Play()
			TweenService:Create(uiStroke, TweenInfoOpen, {Transparency = 0}):Play()
			TweenService:Create(title, TweenInfoOpen, {TextTransparency = 0}):Play()
			TweenService:Create(closeButton, TweenInfoOpen, {TextTransparency = 0}):Play()
			TweenService:Create(separator, TweenInfoOpen, {BackgroundTransparency = 0}):Play()
			TweenService:Create(bottomSeparator, TweenInfoOpen, {BackgroundTransparency = 0}):Play()
			
			TweenService:Create(addButton, TweenInfoOpen, {BackgroundTransparency = 0, TextTransparency = 0}):Play()
			TweenService:Create(addStroke, TweenInfoOpen, {Transparency = 0}):Play()
			TweenService:Create(gameFolderBtn, TweenInfoOpen, {BackgroundTransparency = 0, TextTransparency = 0}):Play()
			TweenService:Create(gameFolderStroke, TweenInfoOpen, {Transparency = 0}):Play()
			TweenService:Create(refreshButton, TweenInfoOpen, {BackgroundTransparency = 0, TextTransparency = 0}):Play()
			TweenService:Create(refreshStroke, TweenInfoOpen, {Transparency = 0}):Play()
			
			TweenService:Create(scrollingFrame, TweenInfoOpen, {ScrollBarImageTransparency = 0}):Play()
		else
			local t = TweenService:Create(mainFrame, TweenInfoClose, {BackgroundTransparency = 1})
			t:Play()
			TweenService:Create(uiStroke, TweenInfoClose, {Transparency = 1}):Play()
			TweenService:Create(title, TweenInfoClose, {TextTransparency = 1}):Play()
			TweenService:Create(closeButton, TweenInfoClose, {TextTransparency = 1}):Play()
			TweenService:Create(separator, TweenInfoClose, {BackgroundTransparency = 1}):Play()
			TweenService:Create(bottomSeparator, TweenInfoClose, {BackgroundTransparency = 1}):Play()
			
			TweenService:Create(addButton, TweenInfoClose, {BackgroundTransparency = 1, TextTransparency = 1}):Play()
			TweenService:Create(addStroke, TweenInfoClose, {Transparency = 1}):Play()
			TweenService:Create(gameFolderBtn, TweenInfoClose, {BackgroundTransparency = 1, TextTransparency = 1}):Play()
			TweenService:Create(gameFolderStroke, TweenInfoClose, {Transparency = 1}):Play()
			TweenService:Create(refreshButton, TweenInfoClose, {BackgroundTransparency = 1, TextTransparency = 1}):Play()
			TweenService:Create(refreshStroke, TweenInfoClose, {Transparency = 1}):Play()
			
			TweenService:Create(scrollingFrame, TweenInfoClose, {ScrollBarImageTransparency = 1}):Play()
			
			t.Completed:Connect(function()
				if mainFrame.BackgroundTransparency == 1 then
					screenGui.Enabled = false
				end
			end)
		end
	end
	
	closeButton.MouseButton1Click:Connect(function() toggle(false) end)
	
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
	local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local gui = PlayerGui:FindFirstChild("NexsExternalCmdsUI")
	if gui then gui:Destroy() end
end

return module
