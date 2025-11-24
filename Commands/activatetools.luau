local Notifications = getgenv().NexsNotifications
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

return {
	Name = "activatetools",
	Args = "<void>",
	Description = "Activate all tools",
	Aliases = "usetools",
	Callback = function(args)
		local char = LocalPlayer.Character
		local backpack = LocalPlayer:FindFirstChild("Backpack")
		
		if not char or not backpack then return end
		
		local count = 0
		
		for _, tool in ipairs(backpack:GetChildren()) do
			if tool:IsA("Tool") then
				tool.Parent = char
				count = count + 1
			end
		end
		
		for _, tool in ipairs(char:GetChildren()) do
			if tool:IsA("Tool") then
				tool:Activate()
			end
		end
		
		Notifications.Notify("Tools Activated", "Used " .. count .. " tools", 3)
	end
}
