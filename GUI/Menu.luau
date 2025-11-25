local module = {}
module.Commands = {}
module.CommandOrder = {} 
module.Connections = {} 

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local OpenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local CloseInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

function module.RegisterCommand(name, args, desc, aliases, callback, argsColor, suggestions, argsCustomColors)
    module.Commands[name] = {
        Args = args,
        Desc = desc,
        Aliases = aliases,
        Callback = callback,
        ArgsColor = argsColor,
        Suggestions = suggestions,
        ArgsCustomColors = argsCustomColors
    }
    table.insert(module.CommandOrder, name)
end

function module.GUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CommandConsoleUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game.CoreGui 
    screenGui.Enabled = false 
    
    screenGui.DisplayOrder = 100

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 600, 0, 50)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0) 
    mainFrame.Position = UDim2.new(0.5, 0, 0.3, 0) 
    mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true 
    mainFrame.Parent = screenGui

    local uiScale = Instance.new("UIScale")
    uiScale.Parent = mainFrame

    local function updateSize()
        local viewportSize = workspace.CurrentCamera.ViewportSize
        
        if viewportSize.X < 700 then
            mainFrame.Size = UDim2.new(0.9, 0, 0, 50)
        
            local ratio = math.clamp(viewportSize.X / 800, 0.75, 1) 
            uiScale.Scale = ratio
        else
            mainFrame.Size = UDim2.new(0, 600, 0, 50)
            uiScale.Scale = 1 
        end
    end

    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateSize)
    updateSize()

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 10)
    uiCorner.Parent = mainFrame

    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 50)
    topBar.BackgroundTransparency = 1
    topBar.Parent = mainFrame

    local searchIcon = Instance.new("TextLabel")
    searchIcon.Text = ">"
    searchIcon.Font = Enum.Font.GothamBold
    searchIcon.TextSize = 18
    searchIcon.TextColor3 = Color3.fromRGB(150, 150, 150)
    searchIcon.Size = UDim2.new(0, 40, 1, 0)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Parent = topBar

    local cmdInput = Instance.new("TextBox")
    cmdInput.Name = "CmdInput"
    cmdInput.Text = ""
    cmdInput.PlaceholderText = "Type a command..."
    cmdInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    cmdInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    cmdInput.Font = Enum.Font.Gotham
    cmdInput.TextSize = 16
    cmdInput.TextXAlignment = Enum.TextXAlignment.Left
    cmdInput.Size = UDim2.new(1, -50, 1, 0)
    cmdInput.Position = UDim2.new(0, 40, 0, 0)
    cmdInput.BackgroundTransparency = 1
    cmdInput.ClearTextOnFocus = false
    cmdInput.Parent = topBar

    local separator = Instance.new("Frame")
    separator.Size = UDim2.new(1, 0, 0, 1)
    separator.Position = UDim2.new(0, 0, 0, 50)
    separator.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    separator.BorderSizePixel = 0
    separator.BackgroundTransparency = 1
    separator.Parent = mainFrame

    local listContainer = Instance.new("Frame")
    listContainer.Name = "ListContainer"
    listContainer.Size = UDim2.new(1, 0, 1, -50)
    listContainer.Position = UDim2.new(0, 0, 0, 50)
    listContainer.BackgroundTransparency = 1
    listContainer.Visible = false
    listContainer.Parent = mainFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = listContainer

    local listPadding = Instance.new("UIPadding")
    listPadding.PaddingLeft = UDim.new(0, 20)
    listPadding.PaddingTop = UDim.new(0, 10)
    listPadding.PaddingRight = UDim.new(0, 10)
    listPadding.Parent = listContainer

    local function createCommandItem(name, args, desc, aliases, argsColor, argsCustomColors)
        local itemFrame = Instance.new("TextButton")
        itemFrame.Name = name
        itemFrame.Size = UDim2.new(1, 0, 0, 50)
        itemFrame.BackgroundTransparency = 1
        itemFrame.Text = ""
        itemFrame.AutoButtonColor = false
        itemFrame.Parent = listContainer

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Name = "Title"
        titleLabel.Size = UDim2.new(1, 0, 0, 20)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Font = Enum.Font.GothamMedium
        titleLabel.TextSize = 15
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        titleLabel.RichText = true 

        local displayName = name
        if not string.find(name, "<font") then
            displayName = string.format('<font color="#E0E0E0">%s</font>', name:gsub("<", "&lt;"):gsub(">", "&gt;"))
        end

        local displayArgs = ""
        if not string.find(args, "<font") then
            local splitArgs = args:split(" ")
            for i, arg in ipairs(splitArgs) do
                local colorHex = "#8DA5C9" 
                
                if argsCustomColors and argsCustomColors[i] then
                    colorHex = "#" .. argsCustomColors[i]:ToHex()
                elseif argsColor then
                    colorHex = "#" .. argsColor:ToHex()
                end
                
                displayArgs = displayArgs .. string.format('<font color="%s">%s</font> ', colorHex, arg:gsub("<", "&lt;"):gsub(">", "&gt;"))
            end
        else
            displayArgs = args
        end
        
        titleLabel.Text = displayName .. " " .. displayArgs
        
        titleLabel.Parent = itemFrame

        local descLabel = Instance.new("TextLabel")
        descLabel.Name = "Desc"
        descLabel.Size = UDim2.new(1, 0, 0, 15)
        descLabel.Position = UDim2.new(0, 0, 0, 22)
        descLabel.BackgroundTransparency = 1
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextSize = 13
        descLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
        descLabel.TextXAlignment = Enum.TextXAlignment.Left

        local fullDesc = desc
        if aliases and aliases ~= "" then
            local safeAliases = aliases:gsub("<", "&lt;"):gsub(">", "&gt;")
            fullDesc = fullDesc .. "  <font color='#555555'>[" .. safeAliases .. "]</font>"
        end

        descLabel.RichText = true
        descLabel.Text = fullDesc
        descLabel.Parent = itemFrame

        itemFrame.MouseButton1Click:Connect(function()
            cmdInput.Text = name .. " "
            cmdInput.CursorPosition = #cmdInput.Text + 1
            cmdInput:CaptureFocus()
        end)
    end

    local function createSuggestionItem(mainText, subText, imageId, replacementText)
        local itemFrame = Instance.new("TextButton")
        itemFrame.Name = "Suggestion_" .. mainText
        itemFrame.Size = UDim2.new(1, 0, 0, 50)
        itemFrame.BackgroundTransparency = 1
        itemFrame.Text = ""
        itemFrame.AutoButtonColor = false
        itemFrame.Parent = listContainer

        if imageId and imageId ~= "" then
            local avatarImage = Instance.new("ImageLabel")
            avatarImage.Name = "Avatar"
            avatarImage.Size = UDim2.new(0, 40, 0, 40)
            avatarImage.Position = UDim2.new(1, -45, 0.5, -20) 
            avatarImage.BackgroundTransparency = 1
            avatarImage.Image = imageId
            avatarImage.Parent = itemFrame
            
            local avatarCorner = Instance.new("UICorner")
            avatarCorner.CornerRadius = UDim.new(1, 0)
            avatarCorner.Parent = avatarImage
        end

        local mainLabel = Instance.new("TextLabel")
        mainLabel.Name = "MainText"
        mainLabel.Size = UDim2.new(1, -60, 0, 20)
        mainLabel.Position = UDim2.new(0, 0, 0, 5)
        mainLabel.BackgroundTransparency = 1
        mainLabel.Font = Enum.Font.GothamMedium
        mainLabel.TextSize = 15
        mainLabel.TextColor3 = Color3.fromRGB(224, 224, 224)
        mainLabel.TextXAlignment = Enum.TextXAlignment.Left
        mainLabel.Text = mainText
        mainLabel.Parent = itemFrame

        local subLabel = Instance.new("TextLabel")
        subLabel.Name = "SubText"
        subLabel.Size = UDim2.new(1, -60, 0, 15)
        subLabel.Position = UDim2.new(0, 0, 0, 25)
        subLabel.BackgroundTransparency = 1
        subLabel.Font = Enum.Font.Gotham
        subLabel.TextSize = 13
        subLabel.TextColor3 = Color3.fromRGB(141, 165, 201) 
        subLabel.TextXAlignment = Enum.TextXAlignment.Left
        subLabel.Text = subText
        subLabel.Parent = itemFrame

        itemFrame.MouseButton1Click:Connect(function()
            local text = cmdInput.Text
            local args = text:split(" ")
            args[#args] = replacementText
            cmdInput.Text = table.concat(args, " ") .. " "
            cmdInput.CursorPosition = #cmdInput.Text + 1
            cmdInput:CaptureFocus()
        end)
    end
    local currentSuggestions = {} 
    local isOpen = false
    local lastOpenTime = 0
    local toggleMenu 

    local function updateList(query)
        for _, child in ipairs(listContainer:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
        end
        currentSuggestions = {} 

        local cleanQuery = query:gsub(" ", "")
        
        local args = query:split(" ")
        local cmdName = args[1]
        local currentArg = args[#args] 
        local count = 0
        
        local cmdData = nil
        local lowerCmdName = string.lower(cmdName)
        
        if module.Commands[cmdName] then
            cmdData = module.Commands[cmdName]
        else
            for name, data in pairs(module.Commands) do
                if string.lower(name) == lowerCmdName then
                    cmdData = data
                    break
                elseif data.Aliases then
                    local aliasList = string.split(data.Aliases, ",")
                    for _, alias in ipairs(aliasList) do
                        local trimmedAlias = alias:match("^%s*(.-)%s*$")
                        if string.lower(trimmedAlias) == lowerCmdName then
                            cmdData = data
                            break
                        end
                    end
                    if cmdData then break end
                end
            end
        end

        if #args > 1 and cmdData then
            local argIndex = #args - 1
            local suggestionType = nil
            
            if cmdData.Suggestions and cmdData.Suggestions[argIndex] then
                suggestionType = cmdData.Suggestions[argIndex]
            elseif string.find(string.lower(cmdData.Args), "player") and argIndex == 1 then
                suggestionType = "Player"
            end

            local function addPlayerSuggestions()
                for _, player in ipairs(Players:GetPlayers()) do
                    if count >= 5 then break end
                    if player == LocalPlayer then continue end
                    
                    if string.find(string.lower(player.Name), string.lower(currentArg)) or 
                       string.find(string.lower(player.DisplayName), string.lower(currentArg)) then
                        
                        local imageId = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
                        createSuggestionItem(player.DisplayName, "@" .. player.Name, imageId, player.Name)
                        table.insert(currentSuggestions, player.Name)
                        count = count + 1
                    end
                end
            end

            local function addStringSuggestion(item)
                if count >= 5 then return end
                if string.find(string.lower(item), string.lower(currentArg)) then
                    createSuggestionItem(item, "Suggestion", "", item)
                    table.insert(currentSuggestions, item)
                    count = count + 1
                end
            end

            if suggestionType == "Player" then
                addPlayerSuggestions()
            elseif type(suggestionType) == "table" then
                for _, item in ipairs(suggestionType) do
                    if item == "Player" then
                        addPlayerSuggestions()
                    else
                        addStringSuggestion(item)
                    end
                    if count >= 5 then break end
                end
            end
        else
            for _, name in ipairs(module.CommandOrder) do
                local data = module.Commands[name]
                if count >= 5 then break end

                local match = false
                local lowerQuery = string.lower(query)
                local lowerName = string.lower(name)
                
                if cleanQuery == "" then
                    match = true
                elseif lowerName:sub(1, #query) == lowerQuery then
                    match = true
                elseif data.Aliases then
                    local aliasList = string.split(data.Aliases, ",")
                    for _, alias in ipairs(aliasList) do
                        local trimmedAlias = alias:match("^%s*(.-)%s*$")
                        if string.lower(trimmedAlias):sub(1, #query) == lowerQuery then
                            match = true
                            break
                        end
                    end
                end

                if match then
                    createCommandItem(name, data.Args, data.Desc, data.Aliases, data.ArgsColor, data.ArgsCustomColors)
                    
                    if #args == 1 then
                        table.insert(currentSuggestions, name)
                    end
                    
                    count = count + 1
                end
            end
        end

        local baseHeight = 50
        local newHeight = baseHeight
        
        if count > 0 then
            newHeight = baseHeight + (count * 55) + 15
            separator.BackgroundTransparency = 0
            listContainer.Visible = true
        else
            separator.BackgroundTransparency = 1
            listContainer.Visible = false
        end

        if screenGui.Enabled then
            TweenService:Create(mainFrame, OpenInfo, {
                Size = UDim2.new(mainFrame.Size.X.Scale, mainFrame.Size.X.Offset, 0, newHeight)
            }):Play()
        end
    end

    function toggleMenu()
        if isOpen and (os.clock() - lastOpenTime < 0.2) then return end
        isOpen = not isOpen

        if isOpen then
            lastOpenTime = os.clock()
            screenGui.Enabled = true
            mainFrame.Position = UDim2.new(0.5, 0, 0.35, 0) 
            mainFrame.BackgroundTransparency = 1
            
            cmdInput.TextEditable = true
            cmdInput.Active = true

            TweenService:Create(mainFrame, OpenInfo, {
                Position = UDim2.new(0.5, 0, 0.3, 0),
                BackgroundTransparency = 0.1
            }):Play()

            cmdInput.Text = ""
            cmdInput:CaptureFocus()
            updateList(cmdInput.Text)
        else
            cmdInput.TextEditable = false
            cmdInput.Active = false
            cmdInput:ReleaseFocus()
            
            currentSuggestions = {}
            for _, child in ipairs(listContainer:GetChildren()) do
                if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
            end
            cmdInput.Text = ""
            
            listContainer.Visible = false
            separator.BackgroundTransparency = 1
            
            local closeTween = TweenService:Create(mainFrame, CloseInfo, {
                Position = UDim2.new(0.5, 0, 0.35, 0),
                Size = UDim2.new(mainFrame.Size.X.Scale, mainFrame.Size.X.Offset, 0, 50),
                BackgroundTransparency = 1
            })
            
            closeTween:Play()
            
            task.delay(0.15, function()
                if not isOpen then 
                    screenGui.Enabled = false 
                    if workspace.CurrentCamera.ViewportSize.X < 700 then
                         screenGui.Enabled = true
                         mainFrame.Visible = false 
                    end
                end
            end)
            
            if workspace.CurrentCamera.ViewportSize.X < 700 then
                mainFrame.Visible = false
            end
        end
        
        if isOpen then mainFrame.Visible = true end
    end
    module.toggleMenu = toggleMenu

    table.insert(module.Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.Semicolon then
            if not gameProcessed then
                toggleMenu()
            end
        elseif isOpen and (input.KeyCode == Enum.KeyCode.Tab or input.KeyCode == Enum.KeyCode.LeftShift) then
            
            local text = cmdInput.Text
            local args = text:split(" ")

            if #currentSuggestions > 0 then
                local suggestion = currentSuggestions[1] 
                
                args[#args] = suggestion
                
                cmdInput.Text = table.concat(args, " ") .. " "
                
                cmdInput.CursorPosition = #cmdInput.Text + 1
            end
        end
    end))

    table.insert(module.Connections, cmdInput:GetPropertyChangedSignal("Text"):Connect(function()
        if isOpen then
            updateList(cmdInput.Text)
        end
    end))

    local function closeIfSemicolon()
        if cmdInput:IsFocused() and cmdInput.Text:sub(-1) == ";" then
            cmdInput.Text = cmdInput.Text:sub(1, -2)
            toggleMenu()
        end
    end

    cmdInput:GetPropertyChangedSignal("Text"):Connect(closeIfSemicolon)


    table.insert(module.Connections, cmdInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            if cmdInput.Text:match("^%s*$") then
                task.defer(function() if isOpen then toggleMenu() end end)
                return
            end

            local text = cmdInput.Text
            local args = text:split(" ")
            local inputCmd = table.remove(args, 1) 
            
            local commandToExecute = nil
            local lowerInput = string.lower(inputCmd)

            for name, data in pairs(module.Commands) do
                if string.lower(name) == lowerInput then
                    commandToExecute = name
                    break
                elseif data.Aliases then
                      local aliasList = string.split(data.Aliases, ",")
                      for _, alias in ipairs(aliasList) do
                          local trimmedAlias = alias:match("^%s*(.-)%s*$")
                          if string.lower(trimmedAlias) == lowerInput then
                              commandToExecute = name
                              break
                          end
                      end
                      if commandToExecute then break end
                end
            end

            if not commandToExecute and #currentSuggestions > 0 then
                local firstSuggestion = currentSuggestions[1]
                if module.Commands[firstSuggestion] then
                    commandToExecute = firstSuggestion
                end
            end

            if commandToExecute and module.Commands[commandToExecute] then
                if module.Commands[commandToExecute].Callback then
                    module.Commands[commandToExecute].Callback(args)
                else
                    warn("Command " .. commandToExecute .. " has no callback!")
                end
            end
            
            task.defer(function()
                if isOpen then
                    toggleMenu()
                end
            end)
        end
    end))
end

function module.Cleanup()
    for _, connection in ipairs(module.Connections) do
        connection:Disconnect()
    end
    module.Connections = {}
    
    local gui = game.CoreGui:FindFirstChild("CommandConsoleUI")
    if gui then
        gui:Destroy()
    end
    
    module.Commands = {}
end

return module