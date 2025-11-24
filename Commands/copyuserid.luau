local Notifications = getgenv().NexsNotifications
local Players = game:GetService("Players")

return {
	Name = "copyuserid",
	Args = "<player>",
	Description = "Copy player UserID",
	ArgsColor = Color3.fromRGB(248, 74, 210),
	Aliases = "",
	Callback = function(args)
		local targetName = args[1]
		local targetPlayer = nil
		
		for _, player in ipairs(Players:GetPlayers()) do
			if string.find(string.lower(player.Name), string.lower(targetName)) or 
			   string.find(string.lower(player.DisplayName), string.lower(targetName)) then
				targetPlayer = player
				break
			end
		end
		
		if targetPlayer then
			setclipboard(tostring(targetPlayer.UserId))
			Notifications.Notify("Copied UserID", "Copied " .. tostring(targetPlayer.UserId), 3)
		else
			Notifications.Notify("Player not found", targetName, 3)
		end
	end
}
