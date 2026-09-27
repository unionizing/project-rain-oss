

local connections = {};
local function enable()
    local function added_callback(object)
        if object.Name == "RightFrame" and object.Parent.Name == "BackpackGui" then
            local visible_callback = function()
                Library.KeybindFrame.Visible = not object.Visible and aztup_toggles.KeybindShower.Value;
                Library:SetWatermarkVisibility(not object.Visible and aztup_toggles.Watermark.Value)
			    Library:SetInfoLoggerVisibility(not object.Visible and aztup_toggles.Console.Value)

                if not object.Visible and aztup_toggles.Console.Value then
			        Library:UpdateInfoLoggerSize()
                end;
            end;
            local visible_changed = object:GetPropertyChangedSignal("Visible"):Connect(visible_callback);

            object.Destroying:Connect(function() 
                Library.KeybindFrame.Visible = aztup_toggles.KeybindShower.Value;
                Library:SetWatermarkVisibility(aztup_toggles.Watermark.Value)
			    Library:SetInfoLoggerVisibility(aztup_toggles.Console.Value)

                if aztup_toggles.Console.Value then
			        Library:UpdateInfoLoggerSize()
                end;

                visible_changed:Disconnect();
                table.remove(connections, table.find(connections, visible_changed));
            end);

            if object.Visible then
                visible_callback();
            end;

            table.insert(connections, visible_changed);
        end;
    end;

    for _, object in local_player.instance.PlayerGui:GetDescendants() do
        task.spawn(added_callback, object);
    end;

    connections[1] = local_player.instance.PlayerGui.DescendantAdded:Connect(added_callback);
    aztup.maid:give_task(connections[1]);
end;

local function disable()
    for i, v in pairs(connections) do
        v:Disconnect();
    end;
    connections = {};
end;

local function toggle()
    local on = aztup_toggles.auto_hide_hud.Value;

    if on then enable() else disable() end;
end;

task.spawn(function()
    repeat task.wait() until aztup_toggles.auto_hide_hud;
    aztup_toggles.auto_hide_hud:OnChanged(toggle);
    toggle();
end);

return {}