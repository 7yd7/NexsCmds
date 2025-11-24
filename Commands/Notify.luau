local Notifications = getgenv().NexsNotifications

return {
	Name = "notify",
	Args = "<Text>",
	ArgsColor = Color3.fromRGB(74, 242, 248),
	Description = "Test notify",
	Aliases = "",
	Callback = function(args)
		local text = args[1]
		if text then
			Notifications.Notify("Test notify", text, 5)
		end
	end
}
