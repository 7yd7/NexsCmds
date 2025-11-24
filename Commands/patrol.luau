return {
	Name = "patrol",
	Args = "<void>"	,
	Description = "Add current position to Patrol Points",
	Aliases = "setpatrol", "addpatrol",
	Callback = function(args)
		if not getgenv().Nexs_PatrolPoints then
			getgenv().Nexs_PatrolPoints = {}
		end
		
		local Players = game:GetService("Players")
		local LocalPlayer = Players.LocalPlayer
		
		if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
			table.insert(getgenv().Nexs_PatrolPoints, LocalPlayer.Character.PrimaryPart.CFrame)
		end
	end
}
