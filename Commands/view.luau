local Notifications = getgenv().NexsNotifications
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

return {
	Name = "View",
	Args = "<player>",
	ArgsColor = Color3.fromRGB(248, 74, 210),
	Description = "Spectate a player",
	Aliases = "spectate, watch",
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
			local targetChar = targetPlayer.Character
			if targetChar and targetChar:FindFirstChild("Humanoid") then
				workspace.CurrentCamera.CameraSubject = targetChar.Humanoid
				Notifications.Notify("Viewing " .. targetPlayer.Name, "", 3)
			end
		else
			Notifications.Notify("Player not found", targetName, 3)
		end
	end
}
