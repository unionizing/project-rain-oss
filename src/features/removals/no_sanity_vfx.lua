local self; do
    self = Feature:new("no_sanity_vfx", scheduler:add_task(2.5), LPH_NO_VIRTUALIZE(function()
        for _, object in services.CollectionService:GetTagged("StatVFX") do
            if table.find(self.gone, object) then continue end

            object.Parent = services.ReplicatedStorage; 
            table.insert(self.gone, object);
        end; 

        local player_gui = local_player.instance:FindFirstChild("PlayerGui");
        if not player_gui then return end

        local overlay_ui = player_gui:FindFirstChild("OverlayGui")
        if not overlay_ui then return end

        overlay_ui.Enabled = false;
    end))
    self.gone = {};

    function self:disable()
        if not self.gone then return end
        for _, object in self.gone do
            object.Parent = services.Lighting;
        end;

        table.clear(self.gone);
    end
end

return self