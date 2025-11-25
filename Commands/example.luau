local module = {}

module.Name = "example"
module.Args = "<Player> <Action> <Value>"
module.Description = "An example command to demonstrate custom argument suggestions."
module.Aliases = "ex"
module.ArgsColor = Color3.fromRGB(255, 170, 0)

-- Define suggestions for each argument index
-- Index 1: "Player" (Special keyword to show player list)
-- Index 2: Table of strings (Custom list)
-- Index 3: nil (No suggestions)
module.Suggestions = {
	[1] = "Player",
	[2] = {"Kick", "Ban", "Kill", "Freeze"},
	[3] = {"10", "20", "30", "Custom"}
}

-- Define custom colors for each argument index
module.ArgsCustomColors = {
	[1] = Color3.fromRGB(255, 85, 85),   -- Red for Player
	[2] = Color3.fromRGB(85, 255, 85),   -- Green for Action
	[3] = Color3.fromRGB(85, 255, 255)   -- Cyan for Value
}

module.Callback = function(args)
	local playerArg = args[1]
	local actionArg = args[2]
	local valueArg = args[3]
	
	print("Example Command Executed!")
	print("Player: " .. tostring(playerArg))
	print("Action: " .. tostring(actionArg))
	print("Value: " .. tostring(valueArg))
	
	if getgenv().NexsNotifications then
		getgenv().NexsNotifications.Notify("Example", "Executed: " .. tostring(actionArg) .. " on " .. tostring(playerArg), 5)
	end
end

return module
