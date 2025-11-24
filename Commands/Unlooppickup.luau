return {
	Name = "Unlooppickup",
	Args = "<void>",
	Description = "Disable Pickup Loop",
	Aliases = "Unautopickup", "stoppickup",
	Callback = function(args)
		getgenv().Nexs_PickupLoop = false
		local Notifications = getgenv().NexsNotifications
		if Notifications then
			Notifications.Notify("Loop Pickup", "Disabled!", 3)
		end
	end
}	
