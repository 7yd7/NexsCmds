return {
	Name = "looptopatrol",
	Args = "<int>",
	ArgsColor = Color3.fromRGB(237, 248, 74),
	Description = "Enable Patrol Loop",
	Aliases = "patrolloop",
	Callback = function(args)
		local delayTime = tonumber(args[1]) or 2
		
		getgenv().Nexs_PatrolLoop = true
		
		local Notifications = getgenv().NexsNotifications
		if Notifications then
			Notifications.Notify("Loop Patrol", "Enabled!", 3)
		end
		
		task.spawn(function()
			while getgenv().Nexs_PatrolLoop do
				local points = getgenv().Nexs_PatrolPoints
				if points and #points > 0 then
					if not getgenv().Nexs_PatrolIndex then
						getgenv().Nexs_PatrolIndex = 1
					end
					
					local idx = getgenv().Nexs_PatrolIndex
					if idx > #points then
						idx = 1
					end
					
					local Players = game:GetService("Players")
					local LocalPlayer = Players.LocalPlayer
					
					if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
						LocalPlayer.Character:SetPrimaryPartCFrame(points[idx])
					end
					
					getgenv().Nexs_PatrolIndex = idx + 1
				end
				task.wait(delayTime)
			end
		end)
	end
}
