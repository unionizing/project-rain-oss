
local scheduler = {};
local tasks = {};

function scheduler:add_task(every)
    local task = {
        event = Instance.new("BindableEvent"),
        every = every,
        last_run = 0
    };
    table.insert(tasks, task);

    return task.event.Event
end

function scheduler.run()
    local current_time = tick();
    for _, task in tasks do
        if current_time - task.last_run >= task.every then
            task.event:Fire();
            task.last_run = current_time;
        end
    end
end

aztup.maid:give_task(services.RunService.Heartbeat:Connect(scheduler.run))

return scheduler