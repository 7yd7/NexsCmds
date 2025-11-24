return {
	Name = "unloopclick",
	Aliases = "unautoclick", "stopclick",
	Args = "<void>",
	Description = "Disable Click Loop",
	Callback = function(args)
		getgenv().Nexs_ClickLoop = false
		local Notifications = getgenv().NexsNotifications
		if Notifications then
			Notifications.Notify("Loop Click", "Disabled!", 3)
		end
	end
}
