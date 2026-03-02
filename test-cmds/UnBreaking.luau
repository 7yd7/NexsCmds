local module = {}

module.Name = "UnBreaking"
module.Args = ""
module.Description = "Stops the Breaking command."
module.Aliases = "unbreak", "unfarm"
module.ArgsColor = Color3.fromRGB(0, 255, 0)

module.Callback = function(args)
	getgenv().BreakingLoop = false
	if getgenv().NexsNotifications then
		getgenv().NexsNotifications.Notify("UnBreaking", "Stopped breaking.", 5)
	end
end

return module
