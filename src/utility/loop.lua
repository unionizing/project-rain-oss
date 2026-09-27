return {
    run_for = function(time, callback)
        local task_conn;
        
        task_conn = services.RunService.PreSimulation:Connect(function(dt)
            if callback(dt) then
                task_conn:Disconnect();
            end;    
        end);
        
        task.delay(time, function()
            task_conn:Disconnect();
        end);
    end;
}