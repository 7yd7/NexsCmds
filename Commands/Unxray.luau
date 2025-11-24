local Notifications = getgenv().NexsNotifications
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

return {
	Name = "Unxray",
	Args = "<void>",
	Description = "Disable XRay",
	Aliases = "noxray",
	Callback = function(args)
		if not getgenv().Nexs_XRayCache then
			Notifications.Notify("XRay", "Not enabled", 3)
			return
		end
		
		for part, transparency in pairs(getgenv().Nexs_XRayCache) do
			if part and part.Parent then
				part.Transparency = transparency
			end
		end
		
		getgenv().Nexs_XRayCache = nil
		Notifications.Notify("XRay Disabled", "Restored transparency", 3)
	end
}
