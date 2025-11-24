local Notifications = getgenv().NexsNotifications

return {
	Name = "UnSpin",
	Args = "<void>",
	Description = "Stop spinning",
	Aliases = "unrotate, stopspin",
	Callback = function(args)
		local character = game.Players.LocalPlayer.Character
		
		if character and character:FindFirstChild("HumanoidRootPart") then
			local hrp = character.HumanoidRootPart
			local existingSpin = hrp:FindFirstChild("NexsSpinVelocity")
			
			if existingSpin then 
				existingSpin:Destroy() 
				Notifications.Notify("Spin Disabled", "", 3)
			else
				Notifications.Notify("Not spinning", "", 3)
			end
		end
	end
}
