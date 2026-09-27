
local passive_parser = {} do 
    passive_parser.__index = passive_parser;
    function passive_parser.parse(character)
        local self = setmetatable({}, passive_parser);
        self.passives = EffectReplicator.Passives;
        self.character = character;

        return self    
end;
    
    function passive_parser:get_passive(index)
        if not self.passives then return nil end;
        return self.passives[index]    
end;

    function passive_parser:get_all_passives()
        if not self.passives then return {}end;
        return self.passives    
end;

    function passive_parser:add_passive(new_passive)
        EffectReplicator.Passives[new_passive] = true;
    end;

    function passive_parser:remove_passive(passive_to_remove)
        if not self.passives then return end;
        local had = EffectReplicator.Passives[passive_to_remove];
        EffectReplicator.Passives[passive_to_remove] = nil;

        return had    
end;

    function passive_parser:save()
    end;

    function passive_parser:destroy()
        self.character = nil;
        self.passives = nil;
        self = nil;
    end;
end;

return passive_parser