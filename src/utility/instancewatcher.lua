

local InstanceWatcher = {} do 
    InstanceWatcher.__index = InstanceWatcher;

    function InstanceWatcher.new(parent_instance, match_function, callback_function, should_wait): InstanceWatcher
        local self = setmetatable({}, InstanceWatcher);

        self.parent_instance = parent_instance;
        self.match_function = match_function;
        self.callback_function = callback_function;

        aztup.maid:give_task(self.parent_instance.ChildAdded:Connect(function(child_instance)
            if self.match_function(child_instance) then
                self.callback_function(child_instance)
            else
                task.delay(0.1, function()
                    if child_instance.Parent and self.match_function(child_instance) then
                        self.callback_function(child_instance)
                    end
                end)
            end
        end));

        task.spawn(function() 
            for _, child_instance in parent_instance:GetChildren() do
                task.spawn(function() 
                    if self.match_function(child_instance) then
                        self.callback_function(child_instance)
                    end
                end)

                if should_wait then
                    task.wait();
                end;
            end
        end);
        
        return self
    end
end

getgenv().InstanceWatcher = InstanceWatcher
return InstanceWatcher