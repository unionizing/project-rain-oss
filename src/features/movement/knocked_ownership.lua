local self = Feature:new("knocked_ownership", is_chime and Instance.new("BindableEvent").Event or game:GetService("RunService").RenderStepped);

local picked_tool;

function self:pick()
    local parts = {};

    for _, handle in local_player.instance.Backpack:QueryDescendants("Tool > BasePart") do
        if handle.Name ~= "Handle" then continue end
     
        local tool = handle.Parent;
        if tool:FindFirstChildWhichIsA("LuaSourceContainer") and not tool:FindFirstChild("Training") or tool.Name == "Weapon Manual" then continue end
     
        table.insert(parts, handle);
    end;

    table.sort(parts, function(a, b)
        return a.Size.Magnitude < b.Size.Magnitude    
end)

    return parts[1] and parts[1].Parent
end

function self:equip()
    picked_tool = self:pick();
    if not picked_tool then return end

    local_player.humanoid:EquipTool(picked_tool);
end;

function self:unequip()
    if not picked_tool or picked_tool.Parent ~= local_player.character then return end

    picked_tool.Parent = local_player.instance.Backpack;
    picked_tool = nil;
end;

function self.update()
    if not EffectReplicator:FindEffect("Knocked") then
        self:unequip();
        return    
end

    local character = local_player.character;
    if not character then return end

    if not picked_tool then
        self:equip();
    else
        self:unequip();
    end;
end;

function self:disable()
    self:unequip();
end;

return self