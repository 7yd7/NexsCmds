return {
	Name = "credit",
	Args = "<void>",
	Description = "Displays the credits and information about the script",
	Aliases = "info", "about",
	Callback = function(args)
		local CreditGUI = getgenv().NexsCredit
		
		if not CreditGUI then
			local baseUrl = getgenv().NEXS_BASE_URL
			if baseUrl:sub(-1) == "/" then
				baseUrl = baseUrl:sub(1, -2)
			end
			
			local url = baseUrl .. "/GUI/Credit.luau"
			local success, result = pcall(function()
				return game:HttpGet(url)
			end)
			
			if success then
				local loadSuccess, loadResult = pcall(function()
					return loadstring(result)()
				end)
				
				if loadSuccess then
					CreditGUI = loadResult
					getgenv().NexsCredit = CreditGUI
				else
					warn("Failed to load Credit GUI syntax: " .. tostring(loadResult))
					if getgenv().NexsNotifications then
						getgenv().NexsNotifications.Notify("Error", "Failed to load Credit GUI syntax", 3)
					end
					return
				end
			else
				warn("Failed to fetch Credit GUI: " .. tostring(result))
				if getgenv().NexsNotifications then
					getgenv().NexsNotifications.Notify("Error", "Failed to fetch Credit GUI", 3)
				end
				return
			end
		end
		
		if CreditGUI then
			CreditGUI.Toggle()
		end
	end
}
