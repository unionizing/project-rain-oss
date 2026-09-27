
local self = Feature:new(STR_TBL_SF_INVOKE("show_all_on_map"));

function self:enable()
    local modules = services.ReplicatedStorage:FindFirstChild(STR_TBL_SF_INVOKE("Modules"));
    local reputation_system = modules and modules:FindFirstChild(STR_TBL_SF_INVOKE("ReputationSystem"));
    if not reputation_system then return end

    self.reputation_system = base_require(reputation_system);
    self.old_is_ally = hookfunction(self.reputation_system.IsAlly, function(...)
        local calling_script = getcallingscript();
        if calling_script and calling_script.Name == STR_TBL_SF_INVOKE("MapClient") then
            return true        
end

        return self.old_is_ally(...)    
end);

    if not local_player.character then return end
    local old_guild = local_player.character:GetAttribute(STR_TBL_SF_INVOKE("Guild"));
    local_player.character:SetAttribute(STR_TBL_SF_INVOKE("Guild"), old_guild .. " ");
    local_player.character:SetAttribute(STR_TBL_SF_INVOKE("Guild"), old_guild);

    





end;

function self:disable()
    if not self.old_is_ally then return end

    hookfunction(self.reputation_system.IsAlly, self.old_is_ally);
    self.old_is_ally = nil;

    local old_guild = local_player.character:GetAttribute(STR_TBL_SF_INVOKE("Guild"));
    local_player.character:SetAttribute("Guild", old_guild .. " ");
    local_player.character:SetAttribute("Guild", old_guild); 
end;

return self