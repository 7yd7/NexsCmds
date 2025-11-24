local Notifications = getgenv().NexsNotifications

return {
	Name = "Unfollow",
	Args = "<void>",
	Description = "Stop following",
	Aliases = "Unfollow, Stopfollow",
	Callback = function(args)
		if getgenv().Nexs_FollowConnection then
			getgenv().Nexs_FollowConnection:Disconnect()
			getgenv().Nexs_FollowConnection = nil
			Notifications.Notify("Follow Stopped", "", 3)
		else
			Notifications.Notify("Not following anyone", "", 3)
		end
	end
}
