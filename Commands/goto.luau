return {
	Name = "goto",
	Args = "<player>",
	ArgsColor = Color3.fromRGB(248, 74, 210),
	Description = "Teleport to a player",
	Aliases = "tp, teleport, to",
	Callback = function(args)
		local targetName = args[1]
		for _, player in ipairs(game.Players:GetPlayers()) do
			if string.sub(string.lower(player.Name), 1, #targetName) == string.lower(targetName) then
				if game.Players.LocalPlayer.Character and player.Character then
					game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
				end
				break
			end
		end
	end
}
