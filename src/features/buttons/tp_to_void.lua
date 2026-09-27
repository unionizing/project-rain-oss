return function()
    local character = local_player.character;
    if not character then return end

    local position = character:GetPivot()
    character:PivotTo(CFrame.new(position.X, math.random(-40000, -30000), position.Z));
end