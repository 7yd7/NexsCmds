local module = {}
module.Name = "commands"
module.Args = "<void>"
module.Description = "Show command list"
module.Aliases = "cmds, list"

local guiModule = nil

function module.Callback(args)
	if not guiModule then
		local baseUrl = getgenv().NEXS_BASE_URL
		local url = baseUrl .. "/GUI/Commands.luau"
		guiModule = loadstring(game:HttpGet(url))()
		
		guiModule.GUI()
		
		local HttpService = game:GetService("HttpService")
		local commandsUrl = baseUrl .. "/Data/Commands.json"
		local commandFiles = HttpService:JSONDecode(game:HttpGet(commandsUrl))
		
		local function import(name)
			local cmdUrl = baseUrl .. "/Commands/" .. name .. ".luau"
			return loadstring(game:HttpGet(cmdUrl))()
		end
		
		local pending = #commandFiles
		local loaded = 0
		
		for _, moduleName in ipairs(commandFiles) do
			task.spawn(function()
				local success, commandModule = pcall(function()
					return import(moduleName)
				end)
				
				if success and commandModule and type(commandModule) == "table" then
					guiModule.RegisterCommand(commandModule.Name, commandModule.Args, commandModule.Description, commandModule.Aliases, commandModule.Callback)
				end
				
				loaded = loaded + 1
				if loaded >= pending then
					guiModule.Toggle()
				end
			end)
		end
	else
		guiModule.Toggle()
	end
end

return module
