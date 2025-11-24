return {
	Name = "Unlooptopatrol",
	Args = "<void>",
	Description = "Disable Patrol Loop",
	Aliases = "Unpatrolloop", "stoppatrol",
	Callback = function(args)
		getgenv().Nexs_PatrolLoop = false
		getgenv().Nexs_PatrolPoints = {}
		
		local Notifications = getgenv().NexsNotifications
		if Notifications then
			Notifications.Notify("Loop Patrol", "Disabled!", 3)
		end
	end
}
