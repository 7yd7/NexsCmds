local Notifications = getgenv().NexsNotifications

return {
	Name = "Uninfjump",
	Args = "<void>",
	Description = "Disable infinite jump",
	Aliases = "Uninfinitejump",
	Callback = function(args)
		if getgenv().Nexs_InfJumpConnection then
			getgenv().Nexs_InfJumpConnection:Disconnect()
			getgenv().Nexs_InfJumpConnection = nil
			Notifications.Notify("Infinite Jump", "Disabled", 3)
		else
			Notifications.Notify("Infinite Jump", "Not enabled", 3)
		end
	end
}
