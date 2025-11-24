return {
	Name = "explorer",
	Args = "<void>",
	Description = "dex script",
	Aliases = "dex",
	Callback = function(args)
loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
	end
}
