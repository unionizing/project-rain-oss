

local feature = Feature:new(STR_TBL_SF_INVOKE("fall_multiplier"));

function feature:update()
    feature:unload()  
    self.modified_data = {};

    local multiplier = aztup.flags[STR_TBL_SF_INVOKE("fall_multiplier_slider")] / 100;

    local player_gui = local_player.instance:FindFirstChild(STR_TBL_SF_INVOKE("PlayerGui"));
    if not player_gui then return end; 

    local world_client = player_gui:FindFirstChild(STR_TBL_SF_INVOKE("WorldClient"));
    if not world_client then return end;

    local script_env;
    local fall_func;
    local trys = 0;

    repeat 
        trys += 1;
        script_env = getsenv(world_client);
        fall_func = script_env and script_env.fall;
        if fall_func then
            break        
end
        task.wait(1);
        if trys >= 10 then
            Logger:long_notify(string.format("Fall Multiplier has failed to get the function after %i tries. This is likely due to a improper getsenv implementation", trys))
        end
    until script_env and fall_func;

    for index, constant in getconstants(fall_func) do
        if typeof(constant) == "number" and constant == 2.0 then
            setconstant(fall_func, index, constant / multiplier);

            table.insert(self.modified_data, {
                func = fall_func,
                index = index,
                original = constant
            });
        end
    end

    local current_fall_remote = KeyHandler:get_key(STR_TBL_SF_INVOKE("FallDamage"));

    if self.fall_remote == current_fall_remote then
        repeat task.wait(10)
            current_fall_remote = KeyHandler:get_key(STR_TBL_SF_INVOKE("FallDamage"))
        until current_fall_remote ~= self.fall_remote;
    end

    self.fall_remote = current_fall_remote;
end;

function feature:unload()
    if not self.modified_data then return end;
    self:unload_modified_data();
    self.modified_data = nil;
end;

function feature:unload_modified_data()
    for _, data in ipairs(self.modified_data) do
        setconstant(data.func, data.index, data.original);
    end
end;

function feature:enable()
    self:update();

    local updated = true;
    aztup_options.fall_multiplier_slider:OnChanged(function()
        if not aztup.flags.fall_multiplier then return end;
        updated = false;

        task.delay(1, function()
            if updated then return end;
            updated = true;
            self:update();
        end);
    end);

    self.child_added_connection = local_player.instance.ChildAdded:Connect(function(child)
        if child.Name == STR_TBL_SF_INVOKE("PlayerGui") then
            self:update();

            if self.player_gui_connection then
                self.player_gui_connection:Disconnect();
                self.player_gui_connection = nil;
            end

            self.player_gui_connection = child.ChildAdded:Connect(function(grandchild)
                if grandchild.Name == STR_TBL_SF_INVOKE("WorldClient") then
                    self:update();
                end
            end);
        end
    end);

    
    self.player_gui_connection = local_player.instance.PlayerGui.ChildAdded:Connect(function(grandchild)
        if grandchild.Name == STR_TBL_SF_INVOKE("WorldClient") then
            self:update();
        end
    end);
end;

function feature:disable()
    self:unload();

    if self.child_added_connection then
        self.child_added_connection:Disconnect();
        self.child_added_connection = nil;
    end;

    if self.player_gui_connection then
        self.player_gui_connection:Disconnect();
        self.player_gui_connection = nil;
    end;
end;

return feature