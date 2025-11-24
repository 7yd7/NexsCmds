local Notifications = getgenv().NexsNotifications
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

return {
	Name = "sit",
	Args = "<void>",
	Description = "Make your character sit",
	Aliases = "",
	Callback = function(args)
		local char = LocalPlayer.Character
		if char then
			local hum = char:FindFirstChild("Humanoid")
			if hum then
				hum.Sit = true
			end
		end
	end
}
