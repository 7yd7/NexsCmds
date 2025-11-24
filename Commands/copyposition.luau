local Notifications = getgenv().NexsNotifications
local Players = game:GetService("Players")

return {
	Name = "copyposition",
	Args = "<player>",
	Description = "Copy player position",
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
			local character = targetPlayer.Character
			if character and character:FindFirstChild("HumanoidRootPart") then
				local pos = character.HumanoidRootPart.Position
				local posString = string.format("%d, %d, %d", pos.X, pos.Y, pos.Z)
				setclipboard(posString)
				Notifications.Notify("Copied Position", "Copied " .. posString, 3)
			else
				Notifications.Notify("Error", "Player has no character/HRP", 3)
			end
		else
			Notifications.Notify("Player not found", targetName, 3)
		end
	end
}
