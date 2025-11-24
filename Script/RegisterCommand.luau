local module = {}

function module.Start(GUI, BASE_URL)
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
				GUI.RegisterCommand(
					commandModule.Name,
					commandModule.Args,
					commandModule.Description,
					commandModule.Aliases,
					commandModule.Callback,
					commandModule.ArgsColor
				)
			end
		end)
	end
end

return module