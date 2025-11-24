return {
	Name = "rejoin",
	Args = "<void>",
	Description = "Rejoin the game",
	Aliases = "rj, refresh",
	Callback = function(args)
		game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
	end
}
