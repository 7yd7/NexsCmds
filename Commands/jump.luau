return {
	Name = "jump",
	Args = "<int>",
	ArgsColor = Color3.fromRGB(237, 248, 74),
	Description = "Set your JumpPower",
	Aliases = "jp, jumpPower",
	Callback = function(args)
		local speed = tonumber(args[1])
		if speed and game.Players.LocalPlayer.Character then
			game.Players.LocalPlayer.Character.Humanoid.JumpPower = speed
		end
	end
}
