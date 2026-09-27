local saved = {};
local feature = Feature:new("no_yun_shul_gate", not is_depths and Instance.new("BindableEvent").Event or scheduler:add_task(3.5), LPH_NO_VIRTUALIZE(function()
    local mechanisms = workspace:FindFirstChild("Mechanisms");
    if not mechanisms then return end;
    
    for _, gate in mechanisms:GetChildren() do
        if gate.Name ~= "ResonanceDoor" then continue end;

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