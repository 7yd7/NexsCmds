local Players = game:GetService("Players")

return {
	Name = "reset",
	Args = "<void>",
	Aliases = "re",
	Description = "Resets your character and returns to the same position",
	Callback = function(args)
		local LocalPlayer = Players.LocalPlayer
		if not LocalPlayer or not LocalPlayer.Character then return end
		
		local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
		
		if rootPart and humanoid then
			local savedCFrame = rootPart.CFrame
			
			local connection
			connection = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
				connection:Disconnect()
				local newRoot = newCharacter:WaitForChild("HumanoidRootPart", 10)
				if newRoot then
					task.wait()
					newRoot.CFrame = savedCFrame
				end
			end)
			humanoid.Health = 0
		end
	end
}
