return {
	Name = "loopclick",
	Aliases = "autoclick", "autoclicker",
	Args = "<int>",
	ArgsColor = Color3.fromRGB(237, 248, 74),
	Description = "Enable Click Loop Some games work",
	Callback = function(args)
		local delayTime = tonumber(args[1]) or 0.1
		
		if getgenv().Nexs_ClickLoop then
			local Notifications = getgenv().NexsNotifications
			if Notifications then
				Notifications.Notify("Loop Click", "Already running!", 3)
			end
			return
		end
		
		getgenv().Nexs_ClickLoop = true
		
		local Notifications = getgenv().NexsNotifications
		if Notifications then
			Notifications.Notify("Loop Click", "Enabled!", 3)
		end
		
		local VirtualUser = game:GetService("VirtualUser")
		local CoreGui = game:GetService("CoreGui")
		
		task.spawn(function()
			while getgenv().Nexs_ClickLoop do
				-- Check if Menu is open
				local menu = CoreGui:FindFirstChild("CommandConsoleUI")
				local menuOpen = menu and menu.Enabled
				
				if not menuOpen then
					VirtualUser:CaptureController()
					VirtualUser:ClickButton1(Vector2.new(0,0))
				end
				
				task.wait(delayTime)
			end
		end)
	end
}
