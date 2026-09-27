
local safeNAN;
safeNAN = function(v369)  
    
    if v369 == v369 then
        return v369    
elseif typeof(v369) == "Vector3" then
        local l_v369_0 = v369;
        return (Vector3.new(safeNAN(l_v369_0.X), safeNAN(l_v369_0.Y), safeNAN(l_v369_0.Z)))    
elseif typeof(v369) == "CFrame" then
        local l_v369_1 = v369;
        local v372 = safeNAN(l_v369_1.Position);
        local l_Rotation_0 = l_v369_1.Rotation;
        if l_Rotation_0 ~= l_Rotation_0 then
            l_Rotation_0 = CFrame.identity;
        end;
        return CFrame.new(v372) * l_Rotation_0    
elseif typeof(v369) == "number" then
        return v369 == v369 and v369 or 0    
else
        return v369    
end;
end;

local last_lagback = 0;
local threads = {};
return {
    new = function(target_cframe, ping_based, speed)
        speed = speed or 190

        if aztup.flags.force_tween_speed then
            speed = aztup.flags.force_tween_speed_value;
        end;

        if aztup.flags.force_no_tween_ping_comp then
            ping_based = false;
        end;

        local target_cframe = target_cframe

        local conn
        conn = services.RunService.PreSimulation:Connect(function(dt)
            if not local_player or not local_player.root_part then
                return
            end

            local target_pos = typeof(target_cframe) == "function" and target_cframe().Position or target_cframe.Position

            local root = local_player.root_part
            local current_pos = root.Position
            local offset = target_pos - current_pos
            local distance = offset.Magnitude

            if distance <= 0.01 or distance ~= distance then
                return
            end

            if target_pos.Magnitude >= 1000000 then
                if conn then
                    conn:Disconnect()
                    conn = nil
                end

                return            
end;

            local_player.root_part.AssemblyLinearVelocity = Vector3.zero
            local_player.root_part.CFrame = CFrame.new(root.CFrame.X, target_pos.Y, root.CFrame.Z)

            local dir = offset.Unit
            local move_speed = ping_based and speed * math.max(0.6, 1 - Latency:get_ping()) or speed
            
            local root_attachment = local_player.root_part:FindFirstChild("RootAttachment");
            local align_position = root_attachment and root_attachment:FindFirstChild("AlignPosition");
            if align_position then
                
                last_lagback = tick();
            end

            if tick() - last_lagback < 1 then
                move_speed = math.min(80, move_speed * 0.75);
            end;

            local step = move_speed * dt

            if step > distance then
                step = distance
            end

            if offset.Magnitude <= 0.01 then
                return
            end

            if not aztup.flags.dont_fly_on_tween then
                root.Velocity = Vector3.zero;
            end;
            
            root.CFrame = safeNAN(root.CFrame + safeNAN(dir * step))
        end)


        table.insert(threads, {
            task = task.spawn(function()
                if not local_player or not local_player.root_part then
                    return
                end
                local root = local_player.root_part
                while ((typeof(target_cframe) == "function" and target_cframe().Position or target_cframe.Position) - root.Position).Magnitude > 10 do
                    task.wait()
                end

                root.CFrame = typeof(target_cframe) == "function" and target_cframe() or target_cframe

                if conn then
                    conn:Disconnect()
                    conn = nil
                end
            end),
            conn = conn
        })

        return {
            stop = function()
                if conn then
                    conn:Disconnect()
                    conn = nil
                end
            end,
            wait = function()
                if not local_player or not local_player.root_part then
                    return
                end

                local root = local_player.root_part

                while ((typeof(target_cframe) == "function" and target_cframe().Position or target_cframe.Position) - root.Position).Magnitude > 10 do
                    task.wait()
                end
            end,
        }
    end,
    stop_all = function()
        for _, thread in threads do
            if thread.conn then
                thread.conn:Disconnect();
            end;

            if thread.task then
                pcall(task.cancel, thread.task);
            end;
        end;

        table.clear(threads);
    end,
    register_lagback = function()
        last_lagback = tick();
    end
}