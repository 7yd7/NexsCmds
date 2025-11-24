local module = {}

function module.Run(Notifications)
	if getgenv().NEXS_CLEANUP then
		getgenv().NEXS_CLEANUP()
		getgenv().NEXS_CLEANUP = nil
	end
	
	local oldMenu = game.CoreGui:FindFirstChild("CommandConsoleUI")
	if oldMenu then oldMenu:Destroy() end
	
	if Notifications then
		Notifications.Notify("Restart Script", "The script is now restarting.", 3)
	end

	local oldNotif = game.CoreGui:FindFirstChild("NotificationUI")
	if oldNotif then oldNotif:Destroy() end
	
	local oldCommandList = game.CoreGui:FindFirstChild("CommandListUI")
	if oldCommandList then oldCommandList:Destroy() end
	
	local oldOpenUI = game.CoreGui:FindFirstChild("OpenUIMobile")
	if oldOpenUI then oldOpenUI:Destroy() end
	
	local oldCreditUI = game.CoreGui:FindFirstChild("CreditUI")
	if oldCreditUI then oldCreditUI:Destroy() end

	local oldEventLoggerUI = game.CoreGui:FindFirstChild("EventLoggerUI")
	if oldEventLoggerUI then oldEventLoggerUI:Destroy() end
	
	getgenv().NexsCredit = nil
end

function module.Set(callback)
	getgenv().NEXS_CLEANUP = callback
end

return module