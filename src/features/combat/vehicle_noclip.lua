local feat = Feature:new("vehicle_noclip")

function feat:enable()
    local steering = EffectReplicator:FindEffect("Steering") or EffectReplicator:FindEffect("RootedGesture");
    if not steering then 
        aztup_toggles.vehicle_speed:SetValue(false);
        if aztup.flags.vehicle_noclip then
            aztup_toggles.vehicle_noclip:SetValue(false);
        end
        Logger:notify_sound("Not steering a boat. Toggling off boat noclip.");
        return    
end

    self.turned_on_noclip = not aztup.flags.noclip;
    if self.turned_on_noclip then
        aztup_toggles.noclip:SetValue(true);
    end;
end
 
function feat:disable()
    if self.turned_on_noclip then
        aztup_toggles.noclip:SetValue(false);
    end;
end

return feat