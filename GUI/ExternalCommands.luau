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
	if not name:match("%.luau$") then
		name = name .. ".luau"
	end
	writefile(folder .. "/" .. name, content)
end

local function deleteCommand(name, isGameSpecific)
	ensureFolders()
	local folder = isGameSpecific and getGameFolder() or GLOBAL_FOLDER
	local path = folder .. "/" .. name
	if not path:match("%.luau$") then path = path .. ".luau" end
	if isfile(path) then delfile(path) end
end

local function listCommands(targetFolder)
	ensureFolders()
	local cmds = {}
	
	if isfolder(targetFolder) then
		for _, file in ipairs(listfiles(targetFolder)) do
			if file:sub(-5) == ".luau" then
				local fileName = file:match("([^/\\]+)%.luau$")
				local content = readfile(file)
				-- Try to extract module.Name from content
				local internalName = content:match('module%.Name%s*=%s*"([^"]+)"') or 
									 content:match("module%.Name%s*=%s*'([^']+)'") or 
									 fileName
				
				table.insert(cmds, {Name = internalName, FileName = fileName, Path = file})
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
	
	-- Main Window
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 700, 0, 500)
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	mainFrame.BackgroundTransparency = 0.1
	mainFrame.BorderSizePixel = 0
	mainFrame.ClipsDescendants = true
	mainFrame.Parent = screenGui
	
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 10)
	uiCorner.Parent = mainFrame
	
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(60, 60, 60)
	uiStroke.Thickness = 1
	uiStroke.Transparency = 0.5
	uiStroke.Parent = mainFrame
	
	makeDraggable(mainFrame)
	
	-- Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 50)
	header.BackgroundTransparency = 1
	header.Parent = mainFrame
	
	local title = Instance.new("TextLabel")
	title.Text = "File Explorer"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 18
	title.TextColor3 = Color3.fromRGB(220, 220, 220)
	title.Size = UDim2.new(0, 200, 1, 0)
	title.Position = UDim2.new(0, 20, 0, 0)
	title.BackgroundTransparency = 1
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = header
	
	local closeButton = Instance.new("TextButton")
	closeButton.Text = "×"
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextSize = 24
	closeButton.TextColor3 = Color3.fromRGB(150, 150, 150)
	closeButton.Size = UDim2.new(0, 40, 0, 50)
	closeButton.Position = UDim2.new(1, -40, 0, 0)
	closeButton.BackgroundTransparency = 1
	closeButton.Parent = header
	
	local separator = Instance.new("Frame")
	separator.Size = UDim2.new(1, 0, 0, 1)
	separator.Position = UDim2.new(0, 0, 0, 50)
	separator.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	separator.BorderSizePixel = 0
	separator.Parent = mainFrame
	
	-- Toolbar
	local toolbar = Instance.new("Frame")
	toolbar.Name = "Toolbar"
	toolbar.Size = UDim2.new(1, 0, 0, 40)
	toolbar.Position = UDim2.new(0, 0, 0, 51)
	toolbar.BackgroundTransparency = 1
	toolbar.Parent = mainFrame
	
	local function createToolButton(text, icon, layoutOrder)
		local btn = Instance.new("TextButton")
		btn.Text = text
		btn.Font = Enum.Font.GothamMedium
		btn.TextSize = 14
		btn.TextColor3 = Color3.fromRGB(200, 200, 200)
		btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		btn.BackgroundTransparency = 0.5
		btn.Size = UDim2.new(0, 100, 0, 30)
		btn.LayoutOrder = layoutOrder
		
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 6)
		c.Parent = btn
		
		return btn
	end
	
	local toolbarLayout = Instance.new("UIListLayout")
	toolbarLayout.FillDirection = Enum.FillDirection.Horizontal
	toolbarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	toolbarLayout.Padding = UDim.new(0, 10)
	toolbarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	toolbarLayout.Parent = toolbar
	
	local toolbarPadding = Instance.new("UIPadding")
	toolbarPadding.PaddingLeft = UDim.new(0, 20)
	toolbarPadding.PaddingTop = UDim.new(0, 5)
	toolbarPadding.Parent = toolbar
	
	local switchViewBtn = createToolButton("Global", nil, 1)
	switchViewBtn.Size = UDim2.new(0, 120, 0, 30)
	switchViewBtn.Parent = toolbar
	
	local addBtn = createToolButton("New File", nil, 2)
	addBtn.Parent = toolbar
	
	local refreshBtn = createToolButton("Refresh", nil, 3)
	refreshBtn.Parent = toolbar
	
	-- Content Area
	local contentArea = Instance.new("ScrollingFrame")
	contentArea.Name = "ContentArea"
	contentArea.Size = UDim2.new(1, 0, 1, -100)
	contentArea.Position = UDim2.new(0, 0, 0, 95)
	contentArea.BackgroundTransparency = 1
	contentArea.BorderSizePixel = 0
	contentArea.ScrollBarThickness = 4
	contentArea.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
	contentArea.Parent = mainFrame
	
	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 90, 0, 100)
	gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.Parent = contentArea
	
	local contentPadding = Instance.new("UIPadding")
	contentPadding.PaddingLeft = UDim.new(0, 20)
	contentPadding.PaddingTop = UDim.new(0, 20)
	contentPadding.PaddingRight = UDim.new(0, 20)
	contentPadding.Parent = contentArea
	
	-- Editor
	local editorFrame = Instance.new("Frame")
	editorFrame.Name = "Editor"
	editorFrame.Size = UDim2.new(1, 0, 1, 0)
	editorFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	editorFrame.Visible = false
	editorFrame.Parent = mainFrame
	
	local editorHeader = Instance.new("Frame")
	editorHeader.Size = UDim2.new(1, 0, 0, 40)
	editorHeader.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	editorHeader.BorderSizePixel = 0
	editorHeader.Parent = editorFrame
	
	local editorTitle = Instance.new("TextLabel")
	editorTitle.Text = "Editing: script.luau"
	editorTitle.Font = Enum.Font.GothamBold
	editorTitle.TextSize = 14
	editorTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
	editorTitle.Size = UDim2.new(1, -220, 1, 0)
	editorTitle.Position = UDim2.new(0, 15, 0, 0)
	editorTitle.BackgroundTransparency = 1
	editorTitle.TextXAlignment = Enum.TextXAlignment.Left
	editorTitle.Parent = editorHeader
	
	local saveBtn = Instance.new("TextButton")
	saveBtn.Text = "Save"
	saveBtn.Size = UDim2.new(0, 60, 0, 24)
	saveBtn.Position = UDim2.new(1, -210, 0, 8)
	saveBtn.BackgroundColor3 = Color3.fromRGB(40, 150, 40)
	saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	saveBtn.Font = Enum.Font.GothamBold
	saveBtn.TextSize = 12
	saveBtn.Parent = editorHeader
	Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 4)
	
	local deleteBtn = Instance.new("TextButton")
	deleteBtn.Text = "Delete"
	deleteBtn.Size = UDim2.new(0, 60, 0, 24)
	deleteBtn.Position = UDim2.new(1, -140, 0, 8)
	deleteBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
	deleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	deleteBtn.Font = Enum.Font.GothamBold
	deleteBtn.TextSize = 12
	deleteBtn.Parent = editorHeader
	Instance.new("UICorner", deleteBtn).CornerRadius = UDim.new(0, 4)

	local closeEditorBtn = Instance.new("TextButton")
	closeEditorBtn.Text = "Close"
	closeEditorBtn.Size = UDim2.new(0, 60, 0, 24)
	closeEditorBtn.Position = UDim2.new(1, -70, 0, 8)
	closeEditorBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	closeEditorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeEditorBtn.Font = Enum.Font.GothamBold
	closeEditorBtn.TextSize = 12
	closeEditorBtn.Parent = editorHeader
	Instance.new("UICorner", closeEditorBtn).CornerRadius = UDim.new(0, 4)
	
	local editorInput = Instance.new("TextBox")
	editorInput.Size = UDim2.new(1, -20, 1, -60)
	editorInput.Position = UDim2.new(0, 10, 0, 50)
	editorInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	editorInput.TextColor3 = Color3.fromRGB(220, 220, 220)
	editorInput.Font = Enum.Font.Code
	editorInput.TextSize = 14
	editorInput.TextXAlignment = Enum.TextXAlignment.Left
	editorInput.TextYAlignment = Enum.TextYAlignment.Top
	editorInput.ClearTextOnFocus = false
	editorInput.MultiLine = true
	editorInput.Parent = editorFrame
	
	Instance.new("UICorner", editorInput).CornerRadius = UDim.new(0, 6)
	local ep = Instance.new("UIPadding")
	ep.PaddingLeft = UDim.new(0, 10)
	ep.PaddingTop = UDim.new(0, 10)
	ep.Parent = editorInput
	
	-- Logic Variables
	local isGameSpecificView = false
	local currentEditingFile = nil
	local currentEditingName = nil
	
	-- Functions
	local function populateList()
		for _, child in ipairs(contentArea:GetChildren()) do
			if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
		end
		
		local targetFolder = isGameSpecificView and getGameFolder() or GLOBAL_FOLDER
		local cmds = listCommands(targetFolder)
		
		for _, cmd in ipairs(cmds) do
			local fileBtn = Instance.new("TextButton")
			fileBtn.Name = cmd.FileName
			fileBtn.Text = ""
			fileBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			fileBtn.BackgroundTransparency = 1
			fileBtn.Parent = contentArea
			
			local iconFrame = Instance.new("Frame")
			iconFrame.Size = UDim2.new(0, 50, 0, 60)
			iconFrame.Position = UDim2.new(0.5, -25, 0, 10)
			iconFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			iconFrame.BorderSizePixel = 0
			iconFrame.Parent = fileBtn
			
			local iconCorner = Instance.new("UICorner")
			iconCorner.CornerRadius = UDim.new(0, 4)
			iconCorner.Parent = iconFrame
			
			local iconFold = Instance.new("Frame")
			iconFold.Size = UDim2.new(0, 15, 0, 15)
			iconFold.Position = UDim2.new(1, -15, 0, 0)
			iconFold.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			iconFold.BorderSizePixel = 0
			iconFold.Parent = iconFrame
			
			local foldGradient = Instance.new("UIGradient")
			foldGradient.Rotation = 45
			foldGradient.Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.5, 0),
				NumberSequenceKeypoint.new(0.51, 1),
				NumberSequenceKeypoint.new(1, 1)
			}
			foldGradient.Parent = iconFold
			
			local iconLabel = Instance.new("TextLabel")
			iconLabel.Text = "LUA"
			iconLabel.Size = UDim2.new(1, 0, 1, 0)
			iconLabel.BackgroundTransparency = 1
			iconLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
			iconLabel.Font = Enum.Font.GothamBold
			iconLabel.TextSize = 12
			iconLabel.Parent = iconFrame
			
			local nameLabel = Instance.new("TextLabel")
			nameLabel.Text = cmd.Name -- Use internal name if available
			nameLabel.Size = UDim2.new(1, 0, 0, 20)
			nameLabel.Position = UDim2.new(0, 0, 1, -20)
			nameLabel.BackgroundTransparency = 1
			nameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
			nameLabel.Font = Enum.Font.Gotham
			nameLabel.TextSize = 12
			nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
			nameLabel.Parent = fileBtn
			
			-- Interaction: Single Click to Edit
			fileBtn.MouseButton1Click:Connect(function()
				currentEditingFile = cmd.FileName
				currentEditingName = cmd.Name
				editorTitle.Text = "Editing: " .. cmd.Name
				editorInput.Text = readfile(cmd.Path)
				editorFrame.Visible = true
			end)
		end
		
		local rows = math.ceil(#cmds / 5)
		contentArea.CanvasSize = UDim2.new(0, 0, 0, rows * 110 + 20)
	end
	
	-- Event Connections
	
	switchViewBtn.MouseButton1Click:Connect(function()
		isGameSpecificView = not isGameSpecificView
		if isGameSpecificView then
			local MarketplaceService = game:GetService("MarketplaceService")
			local success, info = pcall(function()
				return MarketplaceService:GetProductInfo(game.PlaceId)
			end)
			local gameName = success and info.Name or "Unknown Game"
			switchViewBtn.Text = "Game: " .. gameName
			switchViewBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
			title.Text = "File Explorer (" .. gameName .. ")"
		else
			switchViewBtn.Text = "Global"
			switchViewBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
			title.Text = "File Explorer (Global)"
		end
		populateList()
	end)
	
	addBtn.MouseButton1Click:Connect(function()
		local defaultName = "NewCommand"
		local counter = 1
		local targetFolder = isGameSpecificView and getGameFolder() or GLOBAL_FOLDER
		
		while isfile(targetFolder .. "/" .. defaultName .. ".luau") do
			defaultName = "NewCommand" .. counter
			counter = counter + 1
		end
		
		local template = [[local module = {}

module.Name = "]] .. defaultName .. [["
module.Args = "<args>"
module.Description = "A new command"
module.Aliases = ""

module.Callback = function(args)
    print("Hello from " .. module.Name)
end

return module]]
		
		saveCommand(defaultName, template, isGameSpecificView)
		populateList()
		
		currentEditingFile = defaultName .. ".luau"
		editorTitle.Text = "Editing: " .. defaultName
		editorInput.Text = template
		editorFrame.Visible = true
	end)
	
	refreshBtn.MouseButton1Click:Connect(populateList)
	
	saveBtn.MouseButton1Click:Connect(function()
		if currentEditingFile then
			saveCommand(currentEditingFile, editorInput.Text, isGameSpecificView)
			editorFrame.Visible = false
			populateList()
		end
	end)
	
	deleteBtn.MouseButton1Click:Connect(function()
		if currentEditingFile then
			deleteCommand(currentEditingFile, isGameSpecificView)
			editorFrame.Visible = false
			populateList()
		end
	end)
	
	closeEditorBtn.MouseButton1Click:Connect(function()
		editorFrame.Visible = false
	end)
	
	closeButton.MouseButton1Click:Connect(function()
		module.Toggle()
	end)
	
	-- Toggle Logic
	local function toggle(state)
		if state then
			populateList()
			screenGui.Enabled = true
			TweenService:Create(mainFrame, TweenInfoOpen, {BackgroundTransparency = 0.1}):Play()
			TweenService:Create(uiStroke, TweenInfoOpen, {Transparency = 0.5}):Play()
		else
			local t = TweenService:Create(mainFrame, TweenInfoClose, {BackgroundTransparency = 1})
			t:Play()
			TweenService:Create(uiStroke, TweenInfoClose, {Transparency = 1}):Play()
			t.Completed:Connect(function()
				if mainFrame.BackgroundTransparency == 1 then
					screenGui.Enabled = false
				end
			end)
		end
	end
	
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
