local Notifications = getgenv().NexsNotifications
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

return {
	Name = "deletealltools",
	Args = "<void>",
	Description = "Remove all tools",
	Aliases = "cleartools, removetools",
	Callback = function(args)
		local char = LocalPlayer.Character
		local backpack = LocalPlayer:FindFirstChild("Backpack")
		local count = 0
		
		if backpack then
			for _, tool in ipairs(backpack:GetChildren()) do
				if tool:IsA("Tool") then
					tool:Destroy()
					count = count + 1
				end
			end
		end
		
		if char then
			for _, tool in ipairs(char:GetChildren()) do
				if tool:IsA("Tool") then
					tool:Destroy()
					count = count + 1
				end
			end
		end
		
		Notifications.Notify("Tools Deleted", "Removed " .. count .. " tools", 3)
	end
}
