local Notifications = getgenv().NexsNotifications
local Workspace = game:GetService("Workspace")

return {
	Name = "fov",
	Args = "<int>",
    ArgsColor = Color3.fromRGB(237, 248, 74),
	Description = "Change Field of View",
	Aliases = "fieldofview",
	Callback = function(args)
		local fov = tonumber(args[1]) or 70
		Workspace.CurrentCamera.FieldOfView = fov
		Notifications.Notify("FOV Changed", "Set to " .. fov, 3)
	end
}
