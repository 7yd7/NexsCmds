local Notifications = getgenv().NexsNotifications

return {
	Name = "copyplaceid",
	Args = "<void>",
	Description = "Copy Place ID",
	Aliases = "",
	Callback = function(args)
		setclipboard(tostring(game.PlaceId))
		Notifications.Notify("Copied PlaceID", "Copied " .. tostring(game.PlaceId), 3)
	end
}
