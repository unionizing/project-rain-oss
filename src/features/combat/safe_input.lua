local self = Feature:new("block_input", scheduler:add_task(5), LPH_NO_VIRTUALIZE(function()
    local cached_offhand = KeyHandler:get_cache("OffhandAttack");
    local cached_critical = KeyHandler:get_cache("CriticalClick");

    if cached_critical and cached_offhand and cached_critical:IsDescendantOf(local_player.character) and cached_offhand:IsDescendantOf(local_player.character) then
        return    
end

    KeyHandler:get_key("OffhandAttack");
    KeyHandler:get_key("CriticalClick");
end));

return self