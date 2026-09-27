local queue = {} do
    queue.__index = queue;

    function queue.new()
        local self = setmetatable({}, queue);

        self.tasks = {};

        return self    
end

    function queue:push(task)
        table.insert(self.tasks, task);
    end

    function queue:pop()
        return table.remove(self.tasks, 1)    
end

    function queue:empty()
        return #self.tasks == 0    
end
end

return queue