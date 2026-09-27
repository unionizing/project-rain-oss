local moderator_map = require("@src/features/misc/mod_detector/group_members".."");
local enabled = false;

function send_moderator_info(player, role)
    
end

local feature do
    feature = Feature:new("mod_detector", services.Players.PlayerAdded, function(player)
        feature:check(player);
    end);

    function feature:safe_in_group(player)
        local res;
        repeat task.wait(2.5); pcall(function()
            res = player:GetRankInGroup(5212858) > 0;
        end) until res ~= nil;
        
        return res    
end;

    function feature:check(player)
        if player == local_player.instance then return end
        if aztup.silent_mode then return end

        local user_id = tostring(player.UserId)
        if moderator_map[user_id] then
            repeat task.wait() until aztup.auto_loaded and aztup.flags.mod_detector;

            Library:NotifyWithSound(string.format("%s is in the 'Deepwoken Staff' group under the role: '%s'", player.Name, moderator_map[user_id]), 9e9)

            task.spawn(pcall, send_moderator_info, player, moderator_map[user_id]);

            pcall(function()
                if aztup.automation:has_any() then
                    local slot = local_player.instance:GetAttribute("DataSlot");
                    server_utility:hop(slot, 'any', true)
                end;
            end);
        else
            task.spawn(function()
                if not self:safe_in_group(player) then return end
                
                repeat task.wait() until aztup.auto_loaded and aztup.flags.mod_detector;
                Library:NotifyWithSound(string.format("%s is in the 'Deepwoken Staff' group, failed check 2. This should never happen", player.Name), 9e9)
    
                pcall(function()
                    if aztup.automation:has_any() then
                        local slot = local_player.instance:GetAttribute("DataSlot");
                        server_utility:hop(slot, 'any', true)
                    end;
                end);
            end);
        end;
    end;

    function feature:enable()
        enabled = true;
        self.removing_conn = services.Players.PlayerRemoving:Connect(function(player)
            local user_id = tostring(player.UserId)
            if moderator_map[user_id] then
                Logger:long_notify(string.format("%s left, they are in the 'Deepwoken Staff' group under the role: '%s'", player.Name, moderator_map[user_id]))
            end
        end);
        
        task.delay(0.25, function()
            for _, player in pairs(services.Players:GetPlayers()) do
                task.spawn(self.check, self, player);
            end
        end)
    end;

    function feature:disable()
        if not self.removing_conn then return end;
        self.removing_conn:Disconnect();
        self.removing_conn = nil;
    end
end;
















return feature