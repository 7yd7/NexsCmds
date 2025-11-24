local Notifications = getgenv().NexsNotifications
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

return {
	Name = "firetouchinterest",
	Args = "<void>",
	Description = "Fire all TouchInterests",
	Aliases = "firetouch",
	Callback = function(args)
		local char = LocalPlayer.Character
		if not char or not char:FindFirstChild("HumanoidRootPart") then return end
		local hrp = char.HumanoidRootPart
		
		local count = 0
		for _, v in ipairs(Workspace:GetDescendants()) do
			if v:IsA("BasePart") and v:FindFirstChild("TouchInterest") then
				firetouchinterest(hrp, v, 0) -- Touch
				firetouchinterest(hrp, v, 1) -- Untouch
				count = count + 1
			end
		end
		Notifications.Notify("Touches Fired", "Fired " .. count .. " touch interests", 3)
	end
}
