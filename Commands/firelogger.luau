local module = {}
module.Name = "firelogs"
module.Args = "<void>"
module.Description = "Toggle Event Fire Logger clickdetector, proximityprompt, touchinterest"
module.Aliases = "flogs"

local guiModule = nil

function module.Callback(args)
	if not guiModule then
		local baseUrl = getgenv().NEXS_BASE_URL
		local url = baseUrl .. "/GUI/EventLogger.luau"
		guiModule = loadstring(game:HttpGet(url))()
		
		guiModule.GUI()
	end
	
	guiModule.Toggle()
end

return module
