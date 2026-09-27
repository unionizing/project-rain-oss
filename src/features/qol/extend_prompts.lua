local self = Feature:new("extend_prompts", services.CollectionService:GetInstanceAddedSignal('InteractProxPrompt'));
function self:extend(prompt: ProximityPrompt)
    if not prompt or not prompt:IsA("ProximityPrompt") or prompt:GetAttribute("OriginalMax") then
        return    
end
	
	local ActivationDistance = prompt.MaxActivationDistance
	prompt:SetAttribute('OriginalMax', ActivationDistance)
	prompt.MaxActivationDistance = ActivationDistance * 2

    table.insert(self.modified_prompts, prompt);
end;

function self:enable()
    self.modified_prompts = {};
	for _, prompt in pairs(services.CollectionService:GetTagged('InteractProxPrompt')) do
		self:extend(prompt);
	end
end;

function self:disable()
    if not self.modified_prompts then return end

    for _, modified_prompt in self.modified_prompts do
        if not modified_prompt:GetAttribute("OriginalMax") then continue end
        
        modified_prompt.MaxActivationDistance = modified_prompt:GetAttribute("OriginalMax");
        modified_prompt:SetAttribute("OriginalMax", nil);
    end
end;

self.func = function(prompt: ProximityPrompt)
    self:extend(prompt);
end;

return self