local feature_class;
feature_class = Feature:new("no_respawn_time");

local original_bindable = Instance.new("BindableEvent");
original_bindable.Event:Connect(function()
    local events = game:GetService("ReplicatedStorage"):FindFirstChild("Requests");
    if not events then return end
    
    events.Reset:FireServer();
end)

local pr_bindable = Instance.new("BindableEvent");
pr_bindable.Event:Connect(require("@src/features/buttons/respawn"))

function feature_class:enable()
    self.was_on = true;

    repeat task.wait() until pcall(function()
        game:GetService("StarterGui"):SetCore("ResetButtonCallback", pr_bindable)
    end);
end;

function feature_class:disable()
    if not self.was_on then return end
    game:GetService("StarterGui"):SetCore("ResetButtonCallback", original_bindable)
end;

return feature_class