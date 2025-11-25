local module = {}

function module.Start(GUIMenu, GUICommands, BASE_URL)
	if BASE_URL:sub(-1) == "/" then
		BASE_URL = BASE_URL:sub(1, -2)
	end

	local HttpService = game:GetService("HttpService")
	local Notifications = getgenv().NexsNotifications

	local function import(name)
		local url = BASE_URL .. "/" .. name .. ".luau"
		
		local success, result = pcall(function()
			return game:HttpGet(url)
		end)

		if not success then
			warn("[Nexs Command] Failed to fetch: " .. url .. " | Error: " .. tostring(result))
			if Notifications then
				Notifications.Notify("Load Error", "Failed to fetch: " .. name .. "\nURL: " .. url, 5)
			end
			return nil
		end

		local loadSuccess, loadResult = pcall(function()
			return loadstring(result)()
		end)

		if not loadSuccess then
			warn("[Nexs Command] Syntax Error in: " .. name .. " | Error: " .. tostring(loadResult))
			if Notifications then
				Notifications.Notify("Syntax Error", "Error in: " .. name, 5)
			end
			return nil
		end

		return loadResult
	end

	local commandsUrl = BASE_URL .. "/Data/Commands.json"
	local success, commandFilesJson = pcall(function()
		return game:HttpGet(commandsUrl)
	end)

	if not success then
		warn("[Nexs Command] Failed to fetch commands list: " .. commandsUrl)
		if Notifications then
			Notifications.Notify("Critical Error", "Failed to fetch commands list", 5)
		end
		return
	end

	local commandFiles = HttpService:JSONDecode(commandFilesJson)

	for _, moduleName in ipairs(commandFiles) do
		task.spawn(function()
			local commandModule = import("Commands/" .. moduleName)
			
			if commandModule and type(commandModule) == "table" then
				if GUIMenu and GUIMenu.RegisterCommand then
					GUIMenu.RegisterCommand(
						commandModule.Name,
						commandModule.Args,
						commandModule.Description,
						commandModule.Aliases,
						commandModule.Callback,
						commandModule.ArgsColor,
						commandModule.Suggestions,
						commandModule.ArgsCustomColors
					)
				end
				
				if GUICommands and GUICommands.RegisterCommand then
					GUICommands.RegisterCommand(
						commandModule.Name,
						commandModule.Args,
						commandModule.Description,
						commandModule.Aliases,
						commandModule.Callback,
						commandModule.ArgsColor,
						"Standard"
					)
				end
			end
		end)
	end
	
	task.spawn(function()
		local ROOT_FOLDER = "NexsCommands"
		local GLOBAL_FOLDER = ROOT_FOLDER .. "/Global"
		local GAMES_FOLDER = ROOT_FOLDER .. "/Games"
		local GAME_ID = tostring(game.PlaceId)
		local GAME_SPECIFIC_FOLDER = GAMES_FOLDER .. "/" .. GAME_ID
		
		local function loadExternal(path, category)
			if not isfile(path) then 
				return 
			end
			
			local content = readfile(path)
			local success, result = pcall(function()
				return loadstring(content)()
			end)
			
			if success and type(result) == "table" then
				if GUIMenu and GUIMenu.RegisterCommand then
					GUIMenu.RegisterCommand(
						result.Name,
						result.Args,
						result.Description,
						result.Aliases,
						result.Callback,
						result.ArgsColor,
						result.Suggestions,
						result.ArgsCustomColors
					)
				end
				
				if GUICommands and GUICommands.RegisterCommand then
					GUICommands.RegisterCommand(
						result.Name,
						result.Args,
						result.Description,
						result.Aliases,
						result.Callback,
						result.ArgsColor,
						category
					)
				end
			else
				warn("[Nexs Debug] Failed to load external command: " .. path .. " | Error: " .. tostring(result))
			end
		end
		
		if isfolder(GLOBAL_FOLDER) then
			for _, file in ipairs(listfiles(GLOBAL_FOLDER)) do
				if file:sub(-5) == ".luau" then
					loadExternal(file, "Global")
				end
			end
		else
			warn("[Nexs Debug] Global Folder not found!")
		end
		
		if isfolder(GAME_SPECIFIC_FOLDER) then
			for _, file in ipairs(listfiles(GAME_SPECIFIC_FOLDER)) do
				if file:sub(-5) == ".luau" then
					loadExternal(file, "Game")
				end
			end
		else
			warn("[Nexs Debug] Game Folder not found: " .. GAME_SPECIFIC_FOLDER)
		end
	end)
end

return module