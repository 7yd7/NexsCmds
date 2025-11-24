return {
	Name = "restart",
	Args = "<void>",
	Description = "Restart the script",
	Aliases = "rs",
	Callback = function(args)
		local BASE_URL = getgenv().NEXS_BASE_URL
		
		loadstring(game:HttpGet(BASE_URL .. "/client.luau"))()
	end
}
