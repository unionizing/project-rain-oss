local feature = Feature:new("restore_old_weapon_behaviour");

function feature:enable()
    self.char_added = local_player.instance.CharacterAdded:Connect(feature.reconnect);

    feature.reconnect(local_player.character);
end;

function feature:disable()
    if self.char_added then
        self.char_added:Disconnect();
    end;

    if self.current then
        self.current:Disconnect();
        self.current = nil;
    end;
end;

return feature