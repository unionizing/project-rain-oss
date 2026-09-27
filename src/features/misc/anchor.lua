local feat = Feature:new("anchor");

function feat:enable()
    if not local_player.character then return end
    self.effect = EffectReplicator:CreateEffect("FreezeRoot", {});
end;

function feat:disable()
    if self.effect then
        task.defer(function()
            self.effect:Remove(true);
        end);
    end;
end;

return feat