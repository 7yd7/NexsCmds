local Notifications = getgenv().NexsNotifications
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

return {
	Name = "Height",
	Args = "<int>",
	ArgsColor = Color3.fromRGB(237, 248, 74),
	Description = "Set hip height",
	Aliases = "hipheight",
	Callback = function(args)
		local height = tonumber(args[1])
		local character = LocalPlayer.Character
		
		if character and character:FindFirstChild("Humanoid") then
			if height then
				character.Humanoid.HipHeight = height
			else
				character.Humanoid.HipHeight = 2
				Notifications.Notify("Height Reset", "HipHeight: 2", 3)
			end
		end
	end
}
