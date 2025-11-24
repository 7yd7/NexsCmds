local Notifications = getgenv().NexsNotifications
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

return {
	Name = "cframefly",
	Args = "<int>",
	ArgsColor = Color3.fromRGB(237, 248, 74),
	Description = "Enable CFrame fly mode (Fake Body)",
	Aliases = "cfly",
	Callback = function(args)
		local speed = tonumber(args[1]) or 50
		
		if getgenv().Nexs_FlyConnection then
			getgenv().Nexs_FlyConnection:Disconnect()
			getgenv().Nexs_FlyConnection = nil
		end
		
		local character = LocalPlayer.Character
		if not character then return end
		local hrp = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")
		if not hrp or not humanoid then return end

		local oldBv = hrp:FindFirstChild("NexsFlyVelocity")
		if oldBv then oldBv:Destroy() end
		local oldBg = hrp:FindFirstChild("NexsFlyGyro")
		if oldBg then oldBg:Destroy() end
		
		if getgenv().Nexs_CFrameFlyEnabled then
			hrp.Anchored = false
			getgenv().Nexs_CFrameFlyEnabled = false
		end
		
		humanoid.PlatformStand = false

		hrp.Anchored = true
		humanoid.PlatformStand = true
		
		getgenv().Nexs_CFrameFlyEnabled = true
		
		getgenv().Nexs_FlyConnection = RunService.RenderStepped:Connect(function()
			if not character or not character.Parent or not hrp.Parent then
				if getgenv().Nexs_FlyConnection then getgenv().Nexs_FlyConnection:Disconnect() end
				return
			end
			
			local camera = workspace.CurrentCamera
			local moveDir = Vector3.new(0, 0, 0)
			
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then
				moveDir = moveDir + camera.CFrame.LookVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then
				moveDir = moveDir - camera.CFrame.LookVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then
				moveDir = moveDir - camera.CFrame.RightVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then
				moveDir = moveDir + camera.CFrame.RightVector
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
				moveDir = moveDir + Vector3.new(0, 1, 0)
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
				moveDir = moveDir - Vector3.new(0, 1, 0)
			end
			
			local currentPos = hrp.Position
			local newPos = currentPos + (moveDir * speed * RunService.RenderStepped:Wait())
			
			hrp.CFrame = CFrame.new(newPos, newPos + camera.CFrame.LookVector)
			hrp.Velocity = Vector3.new(0,0,0)
		end)
		
		Notifications.Notify("CFrame Fly Enabled", "Speed: " .. speed, 3)
	end
}
