return {
	Name = "Unloopfling",
	Args = "<void>",
	Description = "Disable Fling Loop",
	Aliases = "Unautofling", "stopfling",
	Callback = function(args)
		getgenv().Nexs_LoopFling = false
		getgenv().Nexs_LoopFlingTarget = nil
		
		local Notifications = getgenv().NexsNotifications
		if Notifications then
			Notifications.Notify("Loop Fling", "Disabled!", 3)
		end
		
		local Players = game:GetService("Players")
		local LocalPlayer = Players.LocalPlayer
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local s = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("SpinFling")
			if s then s:Destroy() end
			LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
		end
	end
}
