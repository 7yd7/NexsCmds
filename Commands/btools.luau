return {
	Name = "btools",
	Args = "<void>",
	Description = "Get tool btools script",
	Aliases = "",
	Callback = function(args)
loadstring(game:HttpGet("https://obj.wearedevs.net/2/scripts/BTools.lua"))()
	end
}
