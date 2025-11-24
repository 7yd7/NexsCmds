return {
	Name = "looppickup",
	Args = "<int>",
	ArgsColor = Color3.fromRGB(237, 248, 74),
	Description = "Enable Pickup Loop (ProximityPrompt)",
	Aliases = "autopickup",
	Callback = function(args)
		getgenv().Nexs_PickupLoop = true
		
		local Notifications = getgenv().NexsNotifications
		if Notifications then
			Notifications.Notify("Loop Pickup", "Enabled!", 3)
		end
		
		local ProximityPromptService = game:GetService("ProximityPromptService")
		local Players = game:GetService("Players")
		local LocalPlayer = Players.LocalPlayer
		
		task.spawn(function()
			while getgenv().Nexs_PickupLoop do
				if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
					local charPos = LocalPlayer.Character.PrimaryPart.Position
					
					for _, prompt in ipairs(workspace:GetDescendants()) do
						if prompt:IsA("ProximityPrompt") and prompt.Enabled then
							local promptParent = prompt.Parent
							if promptParent and promptParent:IsA("BasePart") then
								local dist = (charPos - promptParent.Position).Magnitude
								if dist <= prompt.MaxActivationDistance then
									fireproximityprompt(prompt)
								end
							elseif promptParent and promptParent:IsA("Model") and promptParent.PrimaryPart then
								local dist = (charPos - promptParent.PrimaryPart.Position).Magnitude
								if dist <= prompt.MaxActivationDistance then
									fireproximityprompt(prompt)
								end
							end
						end
					end
					
					for _, part in ipairs(workspace:GetDescendants()) do
						if part:IsA("BasePart") and part:FindFirstChild("TouchInterest") then
							local dist = (charPos - part.Position).Magnitude
							if dist <= 10 then
								firetouchinterest(LocalPlayer.Character.PrimaryPart, part, 0)
								task.wait()
								firetouchinterest(LocalPlayer.Character.PrimaryPart, part, 1)
							end
						end
					end
				end
				task.wait(0.1)
			end
		end)
	end
}
