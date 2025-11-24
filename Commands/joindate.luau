local Notifications = getgenv().NexsNotifications
local Players = game:GetService("Players")

return {
	Name = "joindate",
	Args = "<player>",
	ArgsColor = Color3.fromRGB(248, 74, 210),
	Description = "Show player join date",
	Aliases = "jd",
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
			local joinDate = os.date("%Y-%m-%d", os.time() - (targetPlayer.AccountAge * 86400))
			Notifications.Notify(targetPlayer.Name, "Join Date: " .. joinDate, 9999)
		else
			Notifications.Notify("Player not found", targetName, 3)
		end
	end
}
