local RunService = game:GetService("RunService")
local Notifications = getgenv().NexsNotifications

return {
	Name = "Noclip",
	Args = "<void>",
	Description = "Enable noclip mode",
	Aliases = "nc",
	Callback = function(args)
		if getgenv().Nexs_NoclipConnection then
			getgenv().Nexs_NoclipConnection:Disconnect()
		end

		getgenv().Nexs_NoclipConnection = RunService.Stepped:Connect(function()
			local character = game.Players.LocalPlayer.Character
			if character then
				for _, v in pairs(character:GetDescendants()) do
					if v:IsA("BasePart") and v.CanCollide then
						v.CanCollide = false
					end
				end
			end
		end)
		
		Notifications.Notify("Noclip Enabled", "", 3)
	end
}
