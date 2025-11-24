local Notifications = getgenv().NexsNotifications
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

return {
	Name = "invisible",
	Args = "<void>",
	Description = "Become invisible",
	Aliases = "ghost, invis",
	Callback = function(args)
		local realChar = LocalPlayer.Character
		if not realChar or not realChar:FindFirstChild("HumanoidRootPart") then return end
		
		if getgenv().Nexs_RealChar then 
			Notifications.Notify("Already Invisible", "Use uninvisible first", 3)
			return 
		end

		realChar.Archivable = true
		local clone = realChar:Clone()
		clone.Name = realChar.Name .. "_Ghost"
		clone.Parent = Workspace
		
		local hum = clone:FindFirstChild("Humanoid")
		if hum then
			hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		end

		for _, part in ipairs(clone:GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				part.Transparency = 0.5
				part.CanCollide = false
			elseif part:IsA("Decal") then
				part.Transparency = 0.5
			end
		end
		
		local originalCFrame = realChar.HumanoidRootPart.CFrame
		local originalCamCFrame = Workspace.CurrentCamera.CFrame
		
		local bv = Instance.new("BodyVelocity")
		bv.Name = "InvisibleHold"
		bv.Velocity = Vector3.new(0, 0, 0)
		bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bv.Parent = realChar.HumanoidRootPart
		
		realChar.HumanoidRootPart.CFrame = CFrame.new(0, 100000, 0)
		
		task.wait(0.2)
		
		clone.HumanoidRootPart.CFrame = originalCFrame
		LocalPlayer.Character = clone
		
		local animate = clone:FindFirstChild("Animate")
		if animate then
			animate.Disabled = true
			animate.Disabled = false
		end
		
		local cam = Workspace.CurrentCamera
		cam.CameraSubject = hum
		cam.CameraType = Enum.CameraType.Custom
		cam.CFrame = originalCamCFrame
		
		getgenv().Nexs_RealChar = realChar
		
		local connection
		connection = hum.Died:Connect(function()
            task.wait(0.2)
			connection:Disconnect()
			
			if realChar and realChar.Parent and realChar:FindFirstChild("HumanoidRootPart") then
				if clone and clone:FindFirstChild("HumanoidRootPart") then
					realChar.HumanoidRootPart.CFrame = clone.HumanoidRootPart.CFrame
				end
				
				realChar.HumanoidRootPart.Anchored = false
				
				local bv = realChar.HumanoidRootPart:FindFirstChild("InvisibleHold")
				if bv then bv:Destroy() end
				
				LocalPlayer.Character = realChar
				
				local cam = Workspace.CurrentCamera
				cam.CameraSubject = realChar:FindFirstChild("Humanoid")
				
				Notifications.Notify("Invisible Disabled", "Restored upon death", 3)
			else
				getgenv().Nexs_RealChar = nil
			end
			
			if clone then clone:Destroy() end
			getgenv().Nexs_RealChar = nil
		end)
		
		Notifications.Notify("Invisible Enabled", "You are now a ghost", 3)
	end
}
