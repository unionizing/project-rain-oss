local saved = {};
local feature = Feature:new("no_castle_light_gate", not is_depths and Instance.new("BindableEvent").Event or scheduler:add_task(3.5), LPH_NO_VIRTUALIZE(function()
    for _, gate in workspace:GetChildren() do
        if gate.Name ~= "LifeField" then continue end;

        table.insert(saved, gate);
        gate.Parent = nil;
    end;
end));

function feature:disable()
    for _, gate in saved do
        gate.Parent = workspace;
    end;
end

return feature