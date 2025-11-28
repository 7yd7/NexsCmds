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

local ICONS = {
	Add = "rbxassetid://17544384647",
	Game = "rbxassetid://94953827000248",
	Refresh = "rbxassetid://82068432966618",
	Back = "rbxassetid://93111945058621",
	Clear = "rbxassetid://102910221413931",
	Delete = "rbxassetid://131197451603952",
	Save = "rbxassetid://77826812844460",
	Export = "rbxassetid://115295068143548",
	Import = "rbxassetid://120380873978812",
	Copy = "rbxassetid://130973468889534"
}

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
	
	makeDraggable(mainFrame)
	
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 35)
	header.BackgroundTransparency = 1
	header.Parent = mainFrame
	
	local backButton = Instance.new("ImageButton")
	backButton.Name = "BackButton"
	backButton.Size = UDim2.new(0, 25, 0, 25)
	backButton.Position = UDim2.new(0, 5, 0, 5)
	backButton.BackgroundTransparency = 1
	backButton.Image = ICONS.Back
	backButton.ImageColor3 = Color3.fromRGB(200, 200, 200)
	backButton.Visible = false
	backButton.Parent = header
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, -70, 1, 0)
	titleLabel.Position = UDim2.new(0, 10, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "External Cmds"
	titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 14
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
	
	local contentContainer = Instance.new("Frame")
	contentContainer.Name = "Content"
	contentContainer.Size = UDim2.new(1, 0, 1, -36)
	contentContainer.Position = UDim2.new(0, 0, 0, 36)
	contentContainer.BackgroundTransparency = 1
	contentContainer.Parent = mainFrame
	
	local listView = Instance.new("Frame")
	listView.Name = "ListView"
	listView.Size = UDim2.new(1, 0, 1, 0)
	listView.BackgroundTransparency = 1
	listView.Visible = true
	listView.Parent = contentContainer
	
	local fileList = Instance.new("ScrollingFrame")
	fileList.Name = "FileList"
	fileList.Size = UDim2.new(1, 0, 1, -40) 
	fileList.BackgroundTransparency = 1
	fileList.BorderSizePixel = 0
	fileList.ScrollBarThickness = 2
	fileList.Parent = listView
	
	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 5)
	listLayout.Parent = fileList
	
	local listPadding = Instance.new("UIPadding")
	listPadding.PaddingLeft = UDim.new(0, 10)
	listPadding.PaddingTop = UDim.new(0, 10)
	listPadding.PaddingRight = UDim.new(0, 10)
	listPadding.Parent = fileList
	
	local listBottomBar = Instance.new("Frame")
	listBottomBar.Size = UDim2.new(1, 0, 0, 40)
	listBottomBar.Position = UDim2.new(0, 0, 1, -40)
	listBottomBar.BackgroundTransparency = 1
	listBottomBar.Parent = listView
	
	local listBarLayout = Instance.new("UIListLayout")
	listBarLayout.FillDirection = Enum.FillDirection.Horizontal
	listBarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listBarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	listBarLayout.Padding = UDim.new(0, 15)
	listBarLayout.Parent = listBottomBar
	
	local function createIconBtn(parent, iconId, name)
		local btn = Instance.new("ImageButton")
		btn.Name = name
		btn.Size = UDim2.new(0, 25, 0, 25)
		btn.BackgroundTransparency = 1
		btn.Image = iconId
		btn.ImageColor3 = Color3.fromRGB(200, 200, 200)
		btn.Parent = parent
		return btn
	end
	
	local addBtn = createIconBtn(listBottomBar, ICONS.Add, "AddBtn")
	local gameBtn = createIconBtn(listBottomBar, ICONS.Game, "GameBtn")
	local refreshBtn = createIconBtn(listBottomBar, ICONS.Refresh, "RefreshBtn")
	local exportBtn = createIconBtn(listBottomBar, ICONS.Export, "ExportBtn")
	local importBtn = createIconBtn(listBottomBar, ICONS.Import, "ImportBtn")
	
	local editorView = Instance.new("Frame")
	editorView.Name = "EditorView"
	editorView.Size = UDim2.new(1, 0, 1, 0)
	editorView.BackgroundTransparency = 1
	editorView.Visible = false
	editorView.Parent = contentContainer
	
	local editorInput = Instance.new("TextBox")
	editorInput.Size = UDim2.new(1, -20, 1, -50)
	editorInput.Position = UDim2.new(0, 10, 0, 10)
	editorInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	editorInput.BackgroundTransparency = 0.5
	editorInput.TextColor3 = Color3.fromRGB(220, 220, 220)
	editorInput.Font = Enum.Font.Code
	editorInput.TextSize = 12
	editorInput.TextXAlignment = Enum.TextXAlignment.Left
	editorInput.TextYAlignment = Enum.TextYAlignment.Top
	editorInput.ClearTextOnFocus = false
	editorInput.MultiLine = true
	editorInput.Parent = editorView
	
	local editorCorner = Instance.new("UICorner")
	editorCorner.CornerRadius = UDim.new(0, 6)
	editorCorner.Parent = editorInput
	
	local editorPadding = Instance.new("UIPadding")
	editorPadding.PaddingLeft = UDim.new(0, 5)
	editorPadding.PaddingTop = UDim.new(0, 5)
	editorPadding.Parent = editorInput
	
	local editorBottomBar = Instance.new("Frame")
	editorBottomBar.Size = UDim2.new(1, 0, 0, 40)
	editorBottomBar.Position = UDim2.new(0, 0, 1, -40)
	editorBottomBar.BackgroundTransparency = 1
	editorBottomBar.Parent = editorView
	
	local editorBarLayout = Instance.new("UIListLayout")
	editorBarLayout.FillDirection = Enum.FillDirection.Horizontal
	editorBarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	editorBarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	editorBarLayout.Padding = UDim.new(0, 20)
	editorBarLayout.Parent = editorBottomBar
	
	local clearBtn = createIconBtn(editorBottomBar, ICONS.Clear, "ClearBtn")
	local deleteBtn = createIconBtn(editorBottomBar, ICONS.Delete, "DeleteBtn")
	local saveBtn = createIconBtn(editorBottomBar, ICONS.Save, "SaveBtn")
	
	local exportView = Instance.new("Frame")
	exportView.Name = "ExportView"
	exportView.Size = UDim2.new(1, 0, 1, 0)
	exportView.BackgroundTransparency = 1
	exportView.Visible = false
	exportView.Parent = contentContainer
	
	local exportInput = Instance.new("TextBox")
	exportInput.Size = UDim2.new(1, -20, 1, -50)
	exportInput.Position = UDim2.new(0, 10, 0, 10)
	exportInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	exportInput.BackgroundTransparency = 0.5
	exportInput.TextColor3 = Color3.fromRGB(220, 220, 220)
	exportInput.Font = Enum.Font.Code
	exportInput.TextSize = 10
	exportInput.TextXAlignment = Enum.TextXAlignment.Left
	exportInput.TextYAlignment = Enum.TextYAlignment.Top
	exportInput.ClearTextOnFocus = false
	exportInput.MultiLine = true
	exportInput.TextEditable = false 
	exportInput.Parent = exportView
	
	local exportCorner = Instance.new("UICorner")
	exportCorner.CornerRadius = UDim.new(0, 6)
	exportCorner.Parent = exportInput
	
	local exportBottomBar = Instance.new("Frame")
	exportBottomBar.Size = UDim2.new(1, 0, 0, 40)
	exportBottomBar.Position = UDim2.new(0, 0, 1, -40)
	exportBottomBar.BackgroundTransparency = 1
	exportBottomBar.Parent = exportView
	
	local exportBarLayout = Instance.new("UIListLayout")
	exportBarLayout.FillDirection = Enum.FillDirection.Horizontal
	exportBarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	exportBarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	exportBarLayout.Parent = exportBottomBar
	
	local copyExportBtn = createIconBtn(exportBottomBar, ICONS.Copy, "CopyBtn")
	
	local importView = Instance.new("Frame")
	importView.Name = "ImportView"
	importView.Size = UDim2.new(1, 0, 1, 0)
	importView.BackgroundTransparency = 1
	importView.Visible = false
	importView.Parent = contentContainer
	
	local importInput = Instance.new("TextBox")
	importInput.Size = UDim2.new(1, -20, 1, -50)
	importInput.Position = UDim2.new(0, 10, 0, 10)
	importInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	importInput.BackgroundTransparency = 0.5
	importInput.TextColor3 = Color3.fromRGB(220, 220, 220)
	importInput.Font = Enum.Font.Code
	importInput.TextSize = 10
	importInput.TextXAlignment = Enum.TextXAlignment.Left
	importInput.TextYAlignment = Enum.TextYAlignment.Top
	importInput.ClearTextOnFocus = false
	importInput.MultiLine = true
	importInput.PlaceholderText = "Paste JSON here..."
	importInput.Parent = importView
	
	local importCorner = Instance.new("UICorner")
	importCorner.CornerRadius = UDim.new(0, 6)
	importCorner.Parent = importInput
	
	local importBottomBar = Instance.new("Frame")
	importBottomBar.Size = UDim2.new(1, 0, 0, 40)
	importBottomBar.Position = UDim2.new(0, 0, 1, -40)
	importBottomBar.BackgroundTransparency = 1
	importBottomBar.Parent = importView
	
	local importBarLayout = Instance.new("UIListLayout")
	importBarLayout.FillDirection = Enum.FillDirection.Horizontal
	importBarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	importBarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	importBarLayout.Parent = importBottomBar
	
	local saveImportBtn = createIconBtn(importBottomBar, ICONS.Save, "SaveImportBtn")
	
	
	local isGameSpecificView = false
	local currentEditingFile = nil
	local currentEditingName = nil
	
	local function populateList()
		for _, child in ipairs(fileList:GetChildren()) do
			if child:IsA("TextButton") then child:Destroy() end
		end
		
		local targetFolder = isGameSpecificView and getGameFolder() or GLOBAL_FOLDER
		local cmds = listCommands(targetFolder)
		
		for _, cmd in ipairs(cmds) do
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 0, 30)
			btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			btn.BackgroundTransparency = 0.5
			btn.Text = "  " .. cmd.Name
			btn.TextColor3 = Color3.fromRGB(220, 220, 220)
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 12
			btn.TextXAlignment = Enum.TextXAlignment.Left
			btn.Parent = fileList
			
			local btnCorner = Instance.new("UICorner")
			btnCorner.CornerRadius = UDim.new(0, 4)
			btnCorner.Parent = btn
			
			btn.MouseButton1Click:Connect(function()
				currentEditingFile = cmd.FileName
				currentEditingName = cmd.Name
				
				titleLabel.Text = cmd.Name
				titleLabel.Position = UDim2.new(0, 35, 0, 0)
				backButton.Visible = true
				
				editorInput.Text = readfile(cmd.Path)
				
				listView.Visible = false
				editorView.Visible = true
			end)
		end
		
		fileList.CanvasSize = UDim2.new(0, 0, 0, #cmds * 35 + 10)
	end
	
	local function switchView(viewName)
		listView.Visible = false
		editorView.Visible = false
		exportView.Visible = false
		importView.Visible = false
		backButton.Visible = true
		titleLabel.Position = UDim2.new(0, 35, 0, 0)
		
		if viewName == "List" then
			listView.Visible = true
			backButton.Visible = false
			titleLabel.Position = UDim2.new(0, 10, 0, 0)
			titleLabel.Text = "External Cmds"
		elseif viewName == "Editor" then
			editorView.Visible = true
		elseif viewName == "Export" then
			exportView.Visible = true
			titleLabel.Text = "Export"
		elseif viewName == "Import" then
			importView.Visible = true
			titleLabel.Text = "Import"
		end
	end
	
	gameBtn.MouseButton1Click:Connect(function()
		isGameSpecificView = not isGameSpecificView
		if isGameSpecificView then
			gameBtn.ImageColor3 = Color3.fromRGB(100, 255, 100)
		else
			gameBtn.ImageColor3 = Color3.fromRGB(200, 200, 200)
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
	end)
	
	refreshBtn.MouseButton1Click:Connect(populateList)
	
	exportBtn.MouseButton1Click:Connect(function()
		local targetFolder = isGameSpecificView and getGameFolder() or GLOBAL_FOLDER
		local cmds = listCommands(targetFolder)
		local exportData = {}
		
		for _, cmd in ipairs(cmds) do
			table.insert(exportData, {
				FileName = cmd.FileName,
				Content = readfile(cmd.Path)
			})
		end
		
		local success, json = pcall(function()
			return HttpService:JSONEncode(exportData)
		end)
		
		if success then
			exportInput.Text = json
			switchView("Export")
		else
			exportInput.Text = "Error encoding data."
			switchView("Export")
		end
	end)
	
	copyExportBtn.MouseButton1Click:Connect(function()
		setclipboard(exportInput.Text)
	end)
	
	importBtn.MouseButton1Click:Connect(function()
		importInput.Text = ""
		switchView("Import")
	end)
	
	saveImportBtn.MouseButton1Click:Connect(function()
		local json = importInput.Text
		local success, data = pcall(function()
			return HttpService:JSONDecode(json)
		end)
		
		if success and type(data) == "table" then
			local targetFolder = isGameSpecificView and getGameFolder() or GLOBAL_FOLDER
			local count = 0
			for _, item in ipairs(data) do
				if item.FileName and item.Content then
					local path = targetFolder .. "/" .. item.FileName
					if not path:match("%.luau$") then path = path .. ".luau" end
					
					if not isfile(path) then
						saveCommand(item.FileName, item.Content, isGameSpecificView)
						count = count + 1
					end
				end
			end
			populateList()
			switchView("List")
		else
			importInput.Text = "Invalid JSON data."
		end
	end)
	
	backButton.MouseButton1Click:Connect(function()
		switchView("List")
		currentEditingFile = nil
	end)
	
	clearBtn.MouseButton1Click:Connect(function()
		editorInput.Text = ""
	end)
	
	deleteBtn.MouseButton1Click:Connect(function()
		if currentEditingFile then
			deleteCommand(currentEditingFile, isGameSpecificView)
			switchView("List")
			currentEditingFile = nil
			populateList()
		end
	end)
	
	saveBtn.MouseButton1Click:Connect(function()
		if currentEditingFile then
			saveCommand(currentEditingFile, editorInput.Text, isGameSpecificView)
		end
	end)
	
	local function toggle(state)
		if state then
			populateList()
			screenGui.Enabled = true
			
			TweenService:Create(mainFrame, TweenInfoOpen, {BackgroundTransparency = 0.1}):Play()
			TweenService:Create(uiStroke, TweenInfoOpen, {Transparency = 0}):Play()
			TweenService:Create(separator, TweenInfoOpen, {BackgroundTransparency = 0}):Play()
			TweenService:Create(titleLabel, TweenInfoOpen, {TextTransparency = 0}):Play()
			TweenService:Create(closeButton, TweenInfoOpen, {TextTransparency = 0}):Play()
		else
			local t = TweenService:Create(mainFrame, TweenInfoClose, {BackgroundTransparency = 1})
			t:Play()
			TweenService:Create(uiStroke, TweenInfoClose, {Transparency = 1}):Play()
			TweenService:Create(separator, TweenInfoClose, {BackgroundTransparency = 1}):Play()
			TweenService:Create(titleLabel, TweenInfoClose, {TextTransparency = 1}):Play()
			TweenService:Create(closeButton, TweenInfoClose, {TextTransparency = 1}):Play()
			
			t.Completed:Connect(function()
				if mainFrame.BackgroundTransparency == 1 then
					screenGui.Enabled = false
				end
			end)
		end
	end
	
	closeButton.MouseButton1Click:Connect(function()
		module.Toggle()
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
	local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local gui = PlayerGui:FindFirstChild("NexsExternalCmdsUI")
	if gui then gui:Destroy() end
end

return module
