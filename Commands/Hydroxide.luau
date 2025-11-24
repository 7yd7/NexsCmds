return {
	Name = "Hydroxide",
	Args = "<void>",
	Description = "Hydroxide script",
	Aliases = "RemoteSpy",
	Callback = function(args)
local owner = "Upbolt"
local branch = "revision"

local function webImport(file)
    return loadstring(game:HttpGetAsync(("https://raw.githubusercontent.com/%s/Hydroxide/%s/%s.lua"):format(owner, branch, file)), file .. '.lua')()
end

webImport("init")
webImport("ui/main")
	end
}
