local feature = Feature:new("parry_sounds");

function feature.reconnect(character)
    if not character then
        return    
end;
    if feature.current then
        feature.current:Disconnect();
        feature.current = nil;
    end;

    feature.current = character:WaitForChild("HumanoidRootPart").ChildAdded:Connect(function(child)
        if not child.Name:match("4954186776") then
            return        
end;
    
        local sound
        local enabledSounds = {}

        
        for name, enabled in pairs(aztup_options.parry_sound_type.Value) do
            if enabled then
                table.insert(enabledSounds, name)
            end
        end

        
        if #enabledSounds == 0 then
            return
        end

        
        sound = enabledSounds[math.random(1, #enabledSounds)]
        child.PlaybackSpeed = 1;
        child.AssetId = getcustomasset("Project Rain/Assets/Parry Sounds/" .. sound .. ".mp3")
        child.Volume = aztup.flags.parry_sound_volume;
    
        if child:WaitForChild("AudioPitchShifter", 0.2) then
            child.AudioPitchShifter.Pitch = 1;
        end;
    end);
end;

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