local self = Feature:new("give_animation_gamepass");

function self:enable()
    services.CollectionService:AddTag(local_player.instance, "EmotePack1")
    services.CollectionService:AddTag(local_player.instance, "EmotePack2")
    services.CollectionService:AddTag(local_player.instance, "MetalBadge")
    
    local gesture_gui = local_player.instance.PlayerGui:FindFirstChild("GestureGui")
    if gesture_gui then
        for _, v in next, gesture_gui:FindFirstChild("GestureScroll", true):GetChildren() do
            if v:IsA("TextLabel") then
                v:Destroy()
            end
        end
        gesture_gui.GestureFrame.GestureClient.Enabled = false
        gesture_gui.GestureFrame.GestureClient.Enabled = true
    end
end;

return self