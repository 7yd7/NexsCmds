return {
	Name = "loopfling",
	Args = "<player>",
	ArgsColor = Color3.fromRGB(248, 74, 210),
	Description = "Enable Fling Loop",
	Aliases = "autofling",
	Callback = function(args)
		local targetName = args[1]
		if not targetName then return end
		
		local Notifications = getgenv().NexsNotifications
		if Notifications then
			Notifications.Notify("Loop Fling", "Enabled! Flinging " .. targetName, 3)
		end
		
		local Players = game:GetService("Players")
		local LocalPlayer = Players.LocalPlayer
		local RunService = game:GetService("RunService")
		
		local function getPlayer(name)
			name = name:lower()
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer and (p.Name:lower():find(name) or p.DisplayName:lower():find(name)) then
					return p
				end
			end
			return nil
		end
		
		local target = getPlayer(targetName)
		if not target then return end
		
		getgenv().Nexs_LoopFlingTarget = target.Name
		getgenv().Nexs_LoopFling = true
		
		task.spawn(function()
			local angularVelocity = Instance.new("BodyAngularVelocity")
			angularVelocity.Name = "SpinFling"
			angularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
			angularVelocity.AngularVelocity = Vector3.new(0, 10000, 0)
			
			while getgenv().Nexs_LoopFling do
				local currentTarget = Players:FindFirstChild(getgenv().Nexs_LoopFlingTarget)
				if not currentTarget then break end
				
				local tChar = currentTarget.Character
				local lChar = LocalPlayer.Character
				
				if tChar and lChar and tChar:FindFirstChild("HumanoidRootPart") and lChar:FindFirstChild("HumanoidRootPart") then
					local tHrp = tChar.HumanoidRootPart
					local lHrp = lChar.HumanoidRootPart
					
					-- Ensure velocity for fling
					if not lHrp:FindFirstChild("SpinFling") then
						angularVelocity:Clone().Parent = lHrp
					end
					
					lHrp.Velocity = Vector3.new(0, 0, 0)
					lHrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, 0) -- Inside them
					
					-- Keep player alive/noclip
					for _, part in ipairs(lChar:GetDescendants()) do
						if part:IsA("BasePart") then
							part.CanCollide = false
						end
					end
				end
				RunService.Heartbeat:Wait()
			end
			
			-- Cleanup
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
				local s = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("SpinFling")
				if s then s:Destroy() end
				LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
			end
		end)
	end
}
