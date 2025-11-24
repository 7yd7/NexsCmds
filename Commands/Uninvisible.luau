local Notifications = getgenv().NexsNotifications
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

return {
	Name = "Uninvisible",
	Args = "<void>",
	Description = "Return to normal mode",
	Aliases = "unghost, uninvis",
	Callback = function(args)
		local realChar = getgenv().Nexs_RealChar
		local clone = LocalPlayer.Character
		
		if not realChar or not realChar.Parent then
			Notifications.Notify("Error", "Real character not found", 3)
			getgenv().Nexs_RealChar = nil
			return
		end
		
		if not clone then
			Notifications.Notify("Error", "Current character not found", 3)
			return
		end

		if clone:FindFirstChild("HumanoidRootPart") and realChar:FindFirstChild("HumanoidRootPart") then
			realChar.HumanoidRootPart.CFrame = clone.HumanoidRootPart.CFrame
			realChar.HumanoidRootPart.Anchored = false
			
			local bv = realChar.HumanoidRootPart:FindFirstChild("InvisibleHold")
			if bv then bv:Destroy() end
		end
		
		LocalPlayer.Character = realChar
		local cam = Workspace.CurrentCamera
		cam.CameraSubject = realChar:FindFirstChild("Humanoid")
		clone:Destroy()
		getgenv().Nexs_RealChar = nil
		
		Notifications.Notify("Invisible Disabled", "You are back to normal", 3)
	end
}
