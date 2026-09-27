local target_filter = require("@src/features/auto-parry/util/target-filter");

return Feature:new("auto_air_counter", scheduler:add_task(0.1), function()
    local character_handler = local_player.character and local_player.character:FindFirstChild("CharacterHandler")
    local requests = character_handler and character_handler:FindFirstChild("Requests")
    local anti_air = requests and requests:FindFirstChild("AntiAir");
    if not anti_air then return end;

    local live = workspace:FindFirstChild("Live");
    if not live then return end

    if not aztup.flags.air_counter_on_ground and not general:in_air() then
        return    
end
    
    local in_range = {};
    for _, item in live:GetChildren() do
        if item.Name:sub(1,1) == "." or not item:FindFirstChild("HumanoidRootPart") then continue end

        if aztup.flags.air_counter_ally_check then
            if target_filter.is_allowed(item, {
                PVP = true
            }) then
                continue            
end
        end

        local hrp = item.HumanoidRootPart;
        local distance = (hrp.Position - local_player.root_part.Position).Magnitude;

        if distance <= aztup.flags.air_counter_range then
            table.insert(in_range, item);
        end
    end

    for _, target in next, in_range do
        anti_air:FireServer(target);
    end
end)