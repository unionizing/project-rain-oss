local feature = Feature:new("no_mob_encounters");
feature.saved = {};

function feature:is_encounter(part)
    return table.find({
        "BonekeeperBridge",
        "BounderValley"
    }, part.Name) == nil
end;

function feature:enumerate_instances(instance)
    if not instance then return end

    for _, child in instance:GetChildren() do
        if self:is_encounter(child) then
            self.saved[child.Parent] = self.saved[child.Parent] or {};
            table.insert(self.saved[child.Parent], child);
            child.Parent = nil;
        end;
    end;
end;

function feature:enable()
    self:enumerate_instances(workspace:FindFirstChild("EncounterTriggers"));
end

function feature:disable()
    for parent, parts in pairs(self.saved) do
        for _, part in parts do
            part.Parent = parent;
        end;
    end;
    
    table.clear(self.saved);
end

return feature