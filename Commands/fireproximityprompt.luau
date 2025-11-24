local Notifications = getgenv().NexsNotifications
local Workspace = game:GetService("Workspace")

return {
	Name = "fireproximityprompt",
	Args = "<void>",
	Description = "Fire all ProximityPrompts",
	Aliases = "fireprompts",
	Callback = function(args)
		local count = 0
		for _, v in ipairs(Workspace:GetDescendants()) do
			if v:IsA("ProximityPrompt") then
				fireproximityprompt(v)
				count = count + 1
			end
		end
		Notifications.Notify("Prompts Fired", "Fired " .. count .. " prompts", 3)
	end
}
