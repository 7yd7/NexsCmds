local Notifications = getgenv().NexsNotifications
local Workspace = game:GetService("Workspace")

return {
	Name = "fireclickdetector",
	Args = "<void>",
	Description = "Fire all ClickDetectors",
	Aliases = "fireclicks",
	Callback = function(args)
		local count = 0
		for _, v in ipairs(Workspace:GetDescendants()) do
			if v:IsA("ClickDetector") then
				fireclickdetector(v)
				count = count + 1
			end
		end
		Notifications.Notify("Clicks Fired", "Fired " .. count .. " detectors", 3)
	end
}
