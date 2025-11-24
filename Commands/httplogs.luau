return {
	Name = "httplogs",
	Args = "<void>",
	Description = "Logs HTTP requests (HttpGet, HttpPost, request)",
	Aliases = "httplog, spy",
	Callback = function(args)
		local HttpLogsGUI = getgenv().NexsHttpLogs
		
		if HttpLogsGUI and typeof(HttpLogsGUI) == "table" and not HttpLogsGUI.Toggle then
			warn("Invalid HttpLogsGUI detected, reloading...")
			HttpLogsGUI = nil
			getgenv().NexsHttpLogs = nil
		end
		
		if not HttpLogsGUI then
			local baseUrl = getgenv().NEXS_BASE_URL
			
			if baseUrl:sub(-1) == "/" then
				baseUrl = baseUrl:sub(1, -2)
			end
			
			local url = baseUrl .. "/GUI/httplogs.luau"
			
			local success, result = pcall(function()
				return game:HttpGet(url)
			end)
			
			if success then
				local chunk, loadErr = loadstring(result)
				if not chunk then
					warn("Failed to load HttpLogs GUI syntax: " .. tostring(loadErr))
					if getgenv().NexsNotifications then
						getgenv().NexsNotifications.Notify("Error", "Failed to load HttpLogs GUI syntax", 3)
					end
					return
				end
				
				local loadSuccess, loadResult = pcall(chunk)
				
				if loadSuccess then
					if typeof(loadResult) ~= "table" then
						warn("HttpLogs GUI loaded but returned invalid result: " .. typeof(loadResult))
						if getgenv().NexsNotifications then
							getgenv().NexsNotifications.Notify("Error", "Invalid GUI Module", 3)
						end
						return
					end
					
					HttpLogsGUI = loadResult
					
					if HttpLogsGUI.GUI then
						HttpLogsGUI.GUI()
					end
					
					getgenv().NexsHttpLogs = HttpLogsGUI
				else
					warn("Failed to execute HttpLogs GUI: " .. tostring(loadResult))
					if getgenv().NexsNotifications then
						getgenv().NexsNotifications.Notify("Error", "Failed to execute HttpLogs GUI", 3)
					end
					return
				end
			else
				warn("Failed to fetch HttpLogs GUI: " .. tostring(result))
				if getgenv().NexsNotifications then
					getgenv().NexsNotifications.Notify("Error", "Failed to fetch HttpLogs GUI", 3)
				end
				return
			end
		end
		
		if HttpLogsGUI and HttpLogsGUI.Toggle then
			HttpLogsGUI.Toggle()
		else
			warn("HttpLogsGUI is nil or missing Toggle")
		end
	end
}
