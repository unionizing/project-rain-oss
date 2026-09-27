local self;
self = Feature:new("experimental_bug_fixes", services.RunService.RenderStepped, LPH_JIT(function()
    if tick() - (self.last or 0) < 1 then
        return
    end
    local ui_vanity = local_player.instance.PlayerGui:FindFirstChild("UIVanity");
    if not ui_vanity then
        self.last = tick();
        return
    end

    local backpack_gui = local_player.instance.PlayerGui:FindFirstChild("BackpackGui");
    if not backpack_gui then
        self.last = tick();
        return
    end

    local topbar_gui = local_player.instance.PlayerGui:FindFirstChild("StatsGui");
    if not topbar_gui then
        self.last = tick();
        return
    end

    local should_be_visible = true;
    if 
        local_player.instance:GetAttribute("CharacterCreation") or 
        local_player.instance:HasTag("NoTopbar") or 
        local_player.instance:GetAttribute("Freecam") or 
        local_player.instance:GetAttribute("InCutscene") or
        backpack_gui.Enabled
    then
        should_be_visible = false;
    end

    if should_be_visible and not topbar_gui.Enabled then
        
        
        
        

        topbar_gui.Enabled = true;
    end;

    self.last = tick();
end));
return self