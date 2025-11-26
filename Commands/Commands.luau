local module = {}
module.Name = "commands"
module.Args = "<void>"
module.Description = "Show command list"
module.Aliases = "cmds, list"

local guiModule = nil

function module.Callback(args)
	local guiModule = getgenv().Nexs_GUICommands
	
	if guiModule then
		guiModule.Toggle()
	else
		local Notifications = getgenv().NexsNotifications
		if Notifications then
			Notifications.Notify("Error", "Command GUI module not found!", 3)
		end
	end
end

return module
