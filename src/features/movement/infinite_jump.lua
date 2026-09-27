local feature = Feature:new("infinite_jump", game:GetService("RunService").PreSimulation, LPH_NO_VIRTUALIZE(function()
    if is_chime and aztup.flags.chime_safety then
        return aztup_toggles.infinite_jump:SetValue(false)    
end;
    
    if aztup.flags.fly then return end
    if not local_player.character then return end
    if not services.UserInputService:IsKeyDown(Enum.KeyCode.Space) then return end
    if services.UserInputService:GetFocusedTextBox() then return end

    local_player.root_part.AssemblyLinearVelocity *= Vector3.new(1, 0, 1);
    local_player.root_part.AssemblyLinearVelocity += Vector3.new(0, aztup.flags.jump_power, 0);

    return
end));

return feature