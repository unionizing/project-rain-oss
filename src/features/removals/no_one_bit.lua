local parser = require("@src/utility/deepwoken/ssv_parser");
local last_update = 0;
local feature;
feature = Feature:new("no_one_bit", scheduler:add_task(1), LPH_NO_VIRTUALIZE(function()
    if not local_player.character then return end
    last_update = tick();
    
    local parsed = parser.parse(local_player.character);
    if parsed:remove_passive("OneBit") then
        feature.removed = true;
        parsed:save();
    end;

    if not feature.server_swim or not feature.server_swim:IsDescendantOf(game) then
        feature.server_swim = KeyHandler:get_key("ServerSwim");
    end;

    parsed:destroy();
end));

function feature:enable()
    task.spawn(pcall, function()
        repeat task.wait() until local_player.character and KeyHandler;
        local parsed = parser.parse(local_player.character);
        self.removed = parsed:remove_passive("OneBit");
        parsed:save();
        parsed:destroy();

        while not self.server_swim do
            pcall(function()
                self.server_swim = KeyHandler:get_key("ServerSwim");
            end);
            task.wait();
        end;
    end);
end;

function feature:disable()
    if self.removed then
        local parsed = parser.parse(local_player.character);
        parsed:add_passive("OneBit")
        parsed:save();
        parsed:destroy();
    end;
end

return feature