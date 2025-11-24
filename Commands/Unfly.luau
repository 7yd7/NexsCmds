local Notifications = getgenv().NexsNotifications
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

return {
	Name = "Unfly",
	Args = "<void>",
	Description = "Disable Fly mode",
	Aliases = "Stopfly",
	Callback = function(args)
		if getgenv().Nexs_FlyConnection then
			getgenv().Nexs_FlyConnection:Disconnect()
			getgenv().Nexs_FlyConnection = nil
		end
		
		local character = LocalPlayer.Character
		if character then
			local hrp = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChild("Humanoid")
			
			if hrp then
				local bv = hrp:FindFirstChild("NexsFlyVelocity")
				if bv then bv:Destroy() end
				
				local bg = hrp:FindFirstChild("NexsFlyGyro")
				if bg then bg:Destroy() end
				
				hrp.Velocity = Vector3.new(0, 0, 0)
				hrp.RotVelocity = Vector3.new(0, 0, 0)
				
				if getgenv().Nexs_CFrameFlyEnabled then
					hrp.Anchored = false
					getgenv().Nexs_CFrameFlyEnabled = false
				end
			end
			
			if humanoid then
				humanoid.PlatformStand = false
			end
		end
		
		Notifications.Notify("Fly Disabled", "", 3)
	end
}
