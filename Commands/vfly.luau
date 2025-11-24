local Notifications = getgenv().NexsNotifications
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

return {
	Name = "vehiclefly",
	Args = "<int>",
	Description = "Enable vehicle fly mode",
	ArgsColor = Color3.fromRGB(237, 248, 74),
	Aliases = "vfly",
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
		bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bv.Velocity = Vector3.new(0, 0, 0)
		bv.Parent = hrp
		
		local bg = Instance.new("BodyGyro")
		bg.Name = "NexsFlyGyro"
		bg.Parent = hrp
		
		getgenv().Nexs_FlyConnection = RunService.RenderStepped:Connect(function()
			if not character or not character.Parent or not hrp.Parent then
				if getgenv().Nexs_FlyConnection then getgenv().Nexs_FlyConnection:Disconnect() end
				return
			end
			
			local camera = workspace.CurrentCamera
			local moveDir = Vector3.new(0, 0, 0)
			local activeInput = false
			
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then
				moveDir = moveDir + camera.CFrame.LookVector
				activeInput = true
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then
				moveDir = moveDir - camera.CFrame.LookVector
				activeInput = true
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then
				moveDir = moveDir - camera.CFrame.RightVector
				activeInput = true
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then
				moveDir = moveDir + camera.CFrame.RightVector
				activeInput = true
			end
			
			if not activeInput and humanoid.MoveDirection.Magnitude > 0 then
				local moveVec = humanoid.MoveDirection
				local camRelative = camera.CFrame:VectorToObjectSpace(moveVec)
				
				local forward = -camRelative.Z
				local right = camRelative.X
				
				moveDir = camera.CFrame.LookVector * forward + camera.CFrame.RightVector * right
				
				if moveDir.Magnitude > 1 then
					moveDir = moveDir.Unit
				end
			end
			
			bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
			bg.D = 5000
			bg.P = 100000
			bg.CFrame = camera.CFrame
			
			bv.Velocity = moveDir * speed
		end)
		
		Notifications.Notify("VFly Enabled", "Speed: " .. speed, 3)
	end
}
