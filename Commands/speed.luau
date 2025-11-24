return {
	Name = "speed",
	Args = "<int>",
	ArgsColor = Color3.fromRGB(237, 248, 74),
	Description = "Set your walkspeed",
	Aliases = "ws, walkspeed",
	Callback = function(args)
		local speed = tonumber(args[1])
		if speed and game.Players.LocalPlayer.Character then
			game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = speed
		end
	end
}
