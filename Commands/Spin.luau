local Notifications = getgenv().NexsNotifications

return {
	Name = "Spin",
	Args = "<int>",
	ArgsColor = Color3.fromRGB(237, 248, 74),
	Description = "Spin the character",
	Aliases = "rotate",
	Callback = function(args)
		local speed = tonumber(args[1]) or 20
		local character = game.Players.LocalPlayer.Character
		
		if character and character:FindFirstChild("HumanoidRootPart") then
			local hrp = character.HumanoidRootPart
			
			local existingSpin = hrp:FindFirstChild("NexsSpinVelocity")
			if existingSpin then existingSpin:Destroy() end
			
			local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
			bodyAngularVelocity.Name = "NexsSpinVelocity"
			bodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
			bodyAngularVelocity.AngularVelocity = Vector3.new(0, speed, 0)
			bodyAngularVelocity.Parent = hrp
			
			Notifications.Notify("Spinning Enabled", "Speed: " .. speed, 3)
		end
	end
}
