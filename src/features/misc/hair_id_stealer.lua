local feature = Feature:new("hair_id_stealer")

local toggled = false
local players = game:GetService("Players")

local function getSelectedPlayer()
    local playerName = aztup_options.hair_id_stealer_target.Value 
    if playerName and playerName ~= "" then
        return players:FindFirstChild(playerName)
    end
    return nil
end

local function onHairStealPlayer(player)
    if not player then return end
    
    local liveFolder = workspace:FindFirstChild("Live") and workspace.Live:FindFirstChild(player.Name)
    if not liveFolder then
        warn("Could not find folder for: " .. player.Name)
        return
    end

    local foundIds = {}
    
    for _, item in pairs(liveFolder:GetChildren()) do
        if item.Name:sub(1, 6) == "Asset:" then
            local id = item.Name:match("%d+")
            if id then
                table.insert(foundIds, id)
            end
        end
    end

    if #foundIds > 0 then
        local result = table.concat(foundIds, ", ")
        setclipboard(result)
        
        Logger:notify_sound(string.format("Successfully stole %s's hair IDs. Copied to clipboard.", player.Name))
    else
        Logger:notify_sound("Failed to find any hair IDs for " .. player.Name)
    end
end

function feature:enable()
    if toggled then return end
    toggled = true
    
    aztup_options.hair_id_stealer_target:OnChanged(function()
        if not toggled then return end
        local player = getSelectedPlayer()
        if player then
            onHairStealPlayer(player)
        end
    end)
end

function feature:disable()
    if not toggled then return end
    toggled = false
end

return feature