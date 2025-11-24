local Notifications = getgenv().NexsNotifications
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

return {
	Name = "infjump",
	Args = "<void>",
	Description = "Enable infinite jump",
	Aliases = "infinitejump",
	Callback = function(args)
		if getgenv().Nexs_InfJumpConnection then
			getgenv().Nexs_InfJumpConnection:Disconnect()
		end
		
		getgenv().Nexs_InfJumpConnection = UserInputService.JumpRequest:Connect(function()
			local character = LocalPlayer.Character
			if character then
				local humanoid = character:FindFirstChild("Humanoid")
				if humanoid then
					humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end
		end)
		
		Notifications.Notify("Infinite Jump", "Enabled", 3)
	end
}
