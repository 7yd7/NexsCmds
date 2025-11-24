local Notifications = getgenv().NexsNotifications
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

return {
	Name = "Unfreeze",
	Args = "<void>",
	Description = "Unfreeze your character",
	Aliases = "",
	Callback = function(args)
		local character = LocalPlayer.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			character.HumanoidRootPart.Anchored = false
			Notifications.Notify("Unfreeze", "Character UnAnchored", 3)
		end
	end
}
