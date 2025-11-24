local Notifications = getgenv().NexsNotifications
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

return {
	Name = "Follow",
	Args = "<player>",
	ArgsColor = Color3.fromRGB(248, 74, 210),
	Description = "Follow a player",
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
		
		if not targetPlayer then
			Notifications.Notify("Player not found", targetName, 3)
			return
		end
		
		if getgenv().Nexs_FollowConnection then
			getgenv().Nexs_FollowConnection:Disconnect()
		end
		
		Notifications.Notify("Following " .. targetPlayer.Name, "", 3)
		
		getgenv().Nexs_FollowConnection = RunService.Stepped:Connect(function()
			local character = LocalPlayer.Character
			local targetChar = targetPlayer.Character
			
			if character and targetChar and character:FindFirstChild("Humanoid") and targetChar:FindFirstChild("HumanoidRootPart") then
				character.Humanoid:MoveTo(targetChar.HumanoidRootPart.Position)
			elseif not targetChar or not targetChar.Parent then
				if getgenv().Nexs_FollowConnection then
					getgenv().Nexs_FollowConnection:Disconnect()
					getgenv().Nexs_FollowConnection = nil
					Notifications.Notify("Follow Stopped", "Target lost", 3)
				end
			end
		end)
	end
}
