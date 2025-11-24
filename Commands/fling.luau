local Notifications = getgenv().NexsNotifications
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

return {
    Name = "fling",
    Args = "<player>",
    ArgsColor = Color3.fromRGB(248, 74, 210),
    Description = "Fling a player instantly",
    Aliases = "throw",
    Callback = function(args)
        local targetName = args[1]
        local targetPlayer = nil
        
        for _, player in ipairs(Players:GetPlayers()) do
            if string.find(string.lower(player.Name), string.lower(targetName)) or 
               string.find(string.lower(player.DisplayName), string.lower(targetName)) then
                targetPlayer = player
                break
            end
        end
        
        if not targetPlayer then
            Notifications.Notify("Player not found", targetName, 3)
            return
        end
        
        local character = LocalPlayer.Character
        local targetChar = targetPlayer.Character
        
        if not character or not targetChar then return end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
        local targetHumanoid = targetChar:FindFirstChild("Humanoid")
        
        if not hrp or not targetHrp then return end
        
        local originalCFrame = hrp.CFrame
        
        Notifications.Notify("Flinging " .. targetPlayer.Name, "Instant Lock...", 3)
        
        hrp.CFrame = targetHrp.CFrame
        
        local bav = Instance.new("BodyAngularVelocity")
        bav.Name = "NexsFlingVelocity"
        bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bav.AngularVelocity = Vector3.new(0, 10000, 0)
        bav.Parent = hrp
        
        local bp = Instance.new("BodyPosition")
        bp.Name = "NexsFlingPosition"
        bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bp.P = 10000
        bp.D = 1000
        bp.Position = targetHrp.Position
        bp.Parent = hrp
        
        local camera = workspace.CurrentCamera
        local originalSubject = camera.CameraSubject
        camera.CameraSubject = targetHumanoid
        
        local noclipConnection
        noclipConnection = RunService.Stepped:Connect(function()
            if character then
                for _, v in pairs(character:GetDescendants()) do
                    if v:IsA("BasePart") and v.CanCollide then
                        v.CanCollide = false
                    end
                end
            end
        end)
        
        local startTime = tick()
        local connection
        
        connection = RunService.RenderStepped:Connect(function()
            if not character or not character.Parent or not targetChar or not targetChar.Parent then
                if connection then connection:Disconnect() end
                if noclipConnection then noclipConnection:Disconnect() end
                return
            end
            
            bp.Position = targetHrp.Position
            bav.AngularVelocity = Vector3.new(0, 10000, 0)
            
            local timeElapsed = tick() - startTime
            local isFlung = targetHrp.Position.Y > 500 or targetHrp.Velocity.Magnitude > 100
            local isDead = targetHumanoid and targetHumanoid.Health <= 0
            
            if timeElapsed > 3 or isFlung or isDead then
                connection:Disconnect()
                if noclipConnection then noclipConnection:Disconnect() end
                
                if bav then bav:Destroy() end
                if bp then bp:Destroy() end
                
                camera.CameraSubject = originalSubject
                
                hrp.Velocity = Vector3.new(0, 0, 0)
                hrp.RotVelocity = Vector3.new(0, 0, 0)
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                
                hrp.Anchored = true
                local safeHeight = originalCFrame.Position.Y + 50
                hrp.CFrame = CFrame.new(originalCFrame.Position.X, safeHeight, originalCFrame.Position.Z)
                
                task.wait(0.1)
                
                hrp.CFrame = originalCFrame
                hrp.Velocity = Vector3.new(0, 0, 0)
                
                task.wait(0.05)
                if character then
                    for _, v in pairs(character:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = true
                        end
                    end
                end
                
                task.wait(0.05)
                if hrp then 
                    hrp.Anchored = false
                    hrp.Velocity = Vector3.new(0, 0, 0)
                end
                
                if isFlung then
                    Notifications.Notify("Fling Success", targetPlayer.Name .. " was flung!", 3)
                elseif isDead then
                    Notifications.Notify("Fling Success", targetPlayer.Name .. " died!", 3)
                else
                    Notifications.Notify("Fling Timeout", "Returned to position", 3)
                end
            end
        end)
    end
}
