local Notifications = getgenv().NexsNotifications
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

return {
	Name = "Unview",
	Args = "<void>",
	Description = "Stop spectating",
	Aliases = "Unspectate, stopwatch",
	Callback = function(args)
		local character = LocalPlayer.Character
		if character and character:FindFirstChild("Humanoid") then
			workspace.CurrentCamera.CameraSubject = character.Humanoid
			Notifications.Notify("View Reset", "", 3)
		end
	end
}
