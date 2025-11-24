local Notifications = getgenv().NexsNotifications

return {
	Name = "copygameid",
	Args = "<void>",
	Description = "Copy Game ID",
	Aliases = "",
	Callback = function(args)
		setclipboard(tostring(game.GameId))
		Notifications.Notify("Copied GameID", "Copied " .. tostring(game.GameId), 3)
	end
}
