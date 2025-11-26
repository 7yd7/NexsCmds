local BASE_URL = "https://raw.githubusercontent.com/7yd7/NexsCmds/Menu/"
-- local BASE_URL = "https://raw.githubusercontent.com/7yd7/NexsCmds/Menu/"
getgenv().NEXS_BASE_URL = BASE_URL

if BASE_URL:sub(-1) == "/" then
	BASE_URL = BASE_URL:sub(1, -2)
end

if queue_on_teleport and not getgenv().Nexs_Queued then
	getgenv().Nexs_Queued = true
	queue_on_teleport('loadstring(game:HttpGet("' .. BASE_URL .. '/client.luau"))()')
end

local function import(name)
	local url = BASE_URL .. "/" .. name
	
	local success, result = pcall(function()
		return game:HttpGet(url)
	end)

	if not success then
		warn("[Nexs Command] Failed to fetch: " .. url .. " | Error: " .. tostring(result))
		if getgenv().NexsNotifications then
			getgenv().NexsNotifications.Notify("Load Error", "Failed to fetch: " .. name, 5)
		end
		return nil
	end

	local loadSuccess, loadResult = pcall(function()
		return loadstring(result)()
	end)

	if not loadSuccess then
		warn("[Nexs Command] Syntax Error in: " .. name .. " | Error: " .. tostring(loadResult))
		if getgenv().NexsNotifications then
			getgenv().NexsNotifications.Notify("Syntax Error", "Error in: " .. name, 5)
		end
		return nil
	end

	return loadResult
end

local GUIMenu = import("GUI/Menu.luau")
local GUICommands = import("GUI/Commands.luau")
getgenv().Nexs_GUICommands = GUICommands
local Notifications = import("GUI/notifications.luau")
getgenv().NexsNotifications = Notifications

local OpenUI = import("GUI/OpenUI.luau")
local RegisterCommand = import("Script/RegisterCommand.luau")
local Cleanup = import("Script/Cleanup.luau")
local ExternalCommands = import("GUI/ExternalCommands.luau")
getgenv().Nexs_ExternalGUI = ExternalCommands

local UserInputService = game:GetService("UserInputService")

if Cleanup and Notifications then
	Cleanup.Run(Notifications)
end

if RegisterCommand and GUIMenu and GUICommands then
	RegisterCommand.Start(GUIMenu, GUICommands, BASE_URL)
end

if GUIMenu then
	GUIMenu.GUI()
end

if GUICommands then
	GUICommands.GUI()
end

if ExternalCommands then
	ExternalCommands.GUI()
end

task.spawn(function()
	if Notifications then
		Notifications.Notify("System Ready", "Nexs Command has been loaded successfully.", 3)
		task.wait(.5)
		if UserInputService.KeyboardEnabled then
			Notifications.Notify("Open Command", 'Open menu press button ";"', 5)
		end
	end
	
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		if OpenUI and GUIMenu then
			OpenUI.Run(GUIMenu)
		end
	end
end)