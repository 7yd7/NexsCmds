local Notifications = getgenv().NexsNotifications
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

return {
	Name = "visualname",
	Args = "<void>",
	Description = "Show other players' names",
	Aliases = "shownames, visualnames",
	Callback = function(args)
		local count = 0
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				local hum = player.Character:FindFirstChild("Humanoid")
				if hum then
					hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
					count = count + 1
				end
			end
		end
		Notifications.Notify("Names Visible", "Showed " .. count .. " names", 3)
	end
}
