local Notifications = getgenv().NexsNotifications
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

return {
	Name = "fly",
	Args = "<int>",
	ArgsColor = Color3.fromRGB(237, 248, 74),
	Description = "Enable fly mode",
	Aliases = "",
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

		local oldBv = hrp:FindFirstChild("NexsFlyVelocity")
		if oldBv then oldBv:Destroy() end
		local oldBg = hrp:FindFirstChild("NexsFlyGyro")
		if oldBg then oldBg:Destroy() end

		local bv = Instance.new("BodyVelocity")
		bv.Name = "NexsFlyVelocity"
		bv.MaxForce = Vector3.new(1, 1, 1) * 1000000
		bv.Velocity = Vector3.new(0, 0, 0)
		bv.Parent = hrp
		
		local bg = Instance.new("BodyGyro")
		bg.Name = "NexsFlyGyro"
		bg.MaxTorque = Vector3.new(1, 1, 1) * 1000000
		bg.P = 10000
		bg.D = 1000
		bg.CFrame = hrp.CFrame
		bg.Parent = hrp
		
		humanoid.PlatformStand = true
		
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
			
			bg.CFrame = camera.CFrame
			bv.Velocity = moveDir * speed
		end)
		
		Notifications.Notify("Flight Enabled", "Speed: " .. speed, 3)
	end
}
