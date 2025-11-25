return {
	Name = "addcmds",
	Aliases = "addcommand, managecmds",
	Args = "<void>",
	Description = "Manage External Commands",
	Callback = function(args)
		local GUI = getgenv().Nexs_ExternalGUI
		if GUI then
			GUI.Toggle()
		else
			local Notifications = getgenv().NexsNotifications
			if Notifications then
				Notifications.Notify("Error", "External GUI not loaded.", 3)
			end
		end
	end
}
