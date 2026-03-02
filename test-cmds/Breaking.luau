local module = {}

module.Name = "Breaking"
module.Args = "<Names>"
module.Description = "Breaks specified items or all items in Spawned."
module.Aliases = "break", "farm"
module.ArgsColor = Color3.fromRGB(255, 0, 0)

module.Suggestions = {
	[1] = function(currentArg)
		local suggestions = {"all"}
		local spawnedFolder = workspace.Gameplay.CurrentIsland.Island.Gameplay.Spawned
		local seenNames = {}
		
		for _, item in ipairs(spawnedFolder:GetChildren()) do
			if not seenNames[item.Name] then
				table.insert(suggestions, item.Name)
				seenNames[item.Name] = true
			end
		end
		return suggestions
	end
}

module.ArgsCustomColors = {
	[1] = Color3.fromRGB(255, 85, 85),
}

getgenv().BreakingLoop = false

module.Callback = function(args)
	local targetName = args[1]
	
	if not targetName then
		if getgenv().NexsNotifications then
			getgenv().NexsNotifications.Notify("Breaking", "Please specify a target name or 'all'.", 5)
		end
		return
	end

	getgenv().BreakingLoop = true
	
	task.spawn(function()
		while getgenv().BreakingLoop do
			local player = game:GetService("Players").LocalPlayer
			local character = player.Character
			if not character then 
				task.wait(1)
				continue 
			end

			-- Tool Validation
			local tool = character:FindFirstChildWhichIsA("Tool")
			local validTool = false
			local toolsFolder = game:GetService("ReplicatedStorage").Assets.Items["Tools / Weapons"]
			
			if tool then
				if toolsFolder:FindFirstChild(tool.Name) then
					validTool = true
				end
			end

			if not validTool then
				if getgenv().NexsNotifications then
					getgenv().NexsNotifications.Notify("Breaking", "You need to hold a valid tool!", 3)
				end
				getgenv().BreakingLoop = false
				break
			end

			-- Target Finding
			local spawnedFolder = workspace.Gameplay.CurrentIsland.Island.Gameplay.Spawned
			local targets = {}
			-- Removed seenNames restriction for targeting to allow breaking ALL items
			
			for _, item in ipairs(spawnedFolder:GetChildren()) do
				if targetName:lower() == "all" or item.Name:lower() == targetName:lower() then
					table.insert(targets, item)
				end
			end

			-- Firing Event (Batched)
			if #targets > 0 then
				local ohString1 = "UseMeleeWeapon"
				local ohInstance2 = tool
				local ohTable3 = targets -- Pass the entire list of targets

				game:GetService("ReplicatedStorage").Modules.EventManagerClient.ServerEvent:FireServer(ohString1, ohInstance2, ohTable3)
				
				if getgenv().NexsNotifications then
					getgenv().NexsNotifications.Notify("Breaking", "Hit " .. #targets .. " items.", 2)
				end
			end
			
			task.wait(0.5) -- Wait before next scan
		end
	end)
	
	if getgenv().NexsNotifications then
		getgenv().NexsNotifications.Notify("Breaking", "Started breaking " .. targetName, 5)
	end
end

return module
