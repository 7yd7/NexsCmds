local Notifications = getgenv().NexsNotifications
local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

return {
	Name = "antiafk",
	Args = "<void>",
	Description = "Prevent idle kick",
	Aliases = "antikick, noidle",
	Callback = function(args)
		if getgenv().Nexs_AntiAfkConnection then
			Notifications.Notify("Anti-AFK", "Already enabled", 3)
			return
		end

		getgenv().Nexs_AntiAfkConnection = LocalPlayer.Idled:Connect(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new())
		end)
		
		Notifications.Notify("Anti-AFK Enabled", "You will not be kicked for idling", 3)
	end
}
