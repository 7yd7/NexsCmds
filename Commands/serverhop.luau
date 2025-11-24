local module = {}
module.Name = "serverhop"
module.Args = "<void>"
module.Description = "Teleports to a different server"
module.Aliases = "shop, hop"

function module.Callback(args)
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local Players = game:GetService("Players")
    
    local PlaceId = game.PlaceId
    local JobId = game.JobId
    
    local Notifications = getgenv().NexsNotifications
    if Notifications then
        Notifications.Notify("Server Hop", "Finding a server...", 3)
    end
    
    task.spawn(function()
        local servers = {}
        local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
        
        local success, result = pcall(function()
            return game:HttpGet(url)
        end)
        
        if success then
            local data = HttpService:JSONDecode(result)
            if data and data.data then
                for _, server in ipairs(data.data) do
                    if server.playing < server.maxPlayers and server.id ~= JobId then
                        table.insert(servers, server.id)
                    end
                end
            end
        else
             warn("Failed to fetch servers: " .. tostring(result))
             if Notifications then
                Notifications.Notify("Error", "Failed to fetch servers", 3)
             end
             return
        end
        
        if #servers > 0 then
            local randomServer = servers[math.random(1, #servers)]
            if Notifications then
                Notifications.Notify("Server Hop", "Teleporting...", 3)
            end
            TeleportService:TeleportToPlaceInstance(PlaceId, randomServer, Players.LocalPlayer)
        else
            if Notifications then
                Notifications.Notify("Server Hop", "No suitable servers found.", 3)
            end
            warn("No suitable servers found.")
        end
    end)
end

return module
