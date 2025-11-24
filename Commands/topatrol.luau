return {
	Name = "topatrol",
	Args = "<void>",
	Description = "Move to next Patrol Point",
	Aliases = "",
	Callback = function(args)
		local points = getgenv().Nexs_PatrolPoints
		if not points or #points == 0 then return end
		
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
}
