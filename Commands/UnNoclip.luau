local Notifications = getgenv().NexsNotifications

return {
	Name = "UnNoclip",
	Args = "<void>",
	Description = "Disable Noclip mode",
	Aliases = "Unnc",
	Callback = function(args)
		if getgenv().Nexs_NoclipConnection then
			getgenv().Nexs_NoclipConnection:Disconnect()
			getgenv().Nexs_NoclipConnection = nil
		end
		
		Notifications.Notify("Noclip Disabled", "", 3)
	end
}
