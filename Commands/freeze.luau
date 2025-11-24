local Notifications = getgenv().NexsNotifications
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

return {
	Name = "Freeze",
	Args = "<void>",
	Description = "Freeze your character",
	Aliases = "",
	Callback = function(args)
		local character = LocalPlayer.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			character.HumanoidRootPart.Anchored = true
			Notifications.Notify("Freeze", "Character Anchored", 3)
		end
	end
}
