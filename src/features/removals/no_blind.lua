local parser = require("@src/utility/deepwoken/ssv_parser");
local feature;

feature = Feature:new("no_blind", scheduler:add_task(0.5), LPH_NO_VIRTUALIZE(function()
    if not local_player.character then return end
    last_update = tick();
    
    local parsed = parser.parse(local_player.character);
    if parsed:remove_passive("Blinded") or parsed:remove_passive("Blind") then
        feature.removed = true;
        parsed:save();
    end;

    parsed:destroy();
end));

function feature:disable()
    if self.removed then
        local parsed = parser.parse(local_player.character);
        parsed:add_passive("Blind")
        parsed:save();
        parsed:destroy();
    end;
end

return feature