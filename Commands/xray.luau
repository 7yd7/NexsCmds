local Notifications = getgenv().NexsNotifications
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

return {
	Name = "xray",
	Args = "<void>",
	Description = "Make walls transparent",
	Aliases = "",
	Callback = function(args)
		getgenv().Nexs_XRayCache = {}
		
		for _, part in ipairs(Workspace:GetDescendants()) do
			if part:IsA("BasePart") and not part:IsA("Terrain") then
				if not (LocalPlayer.Character and part:IsDescendantOf(LocalPlayer.Character)) then
					getgenv().Nexs_XRayCache[part] = part.Transparency
					part.Transparency = 0.5
				end
			end
		end
		Notifications.Notify("XRay Enabled", "Walls are now transparent", 3)
	end
}