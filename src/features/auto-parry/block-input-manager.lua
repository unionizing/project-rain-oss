local BlockInputManagerClass = {};
function BlockInputManagerClass.new()
    local self = setmetatable({}, {
        __index = BlockInputManagerClass
    });
    self.tasks = {};

    function self:add_task(name, mob, box_func, range)
        local block_input = aztup.flags.block_input;
        if not block_input then return {debris=function()end,remove=function()end}end;

        local allowed_targets = aztup_options.allowed_bi_targets.Value;

        if mob.Name:sub(1, 1) == "." and not allowed_targets.PVE then
            return {debris=function()end,remove=function()end}        
end;

        if mob.Name:sub(1, 1) ~= "." and not allowed_targets.PVP then
            return {debris=function()end,remove=function()end}        
end;

        if not local_player.root_part or not mob:FindFirstChild("HumanoidRootPart") then
            return {debris=function()end,remove=function()end}        
end; 

        local id = services.HttpService:GenerateGUID(false);
        self.tasks[id] = {
            name = name,
            mob = mob,
            range = range,
            in_hitbox = box_func
        };

        return {
            removed = false,
            remove = function()
                
                
                
                
        
                self.removed = true;
                self.tasks[id] = nil;
            end,
            debris = function(time, time2)
                task.delay(typeof(time) == "table" and time2 - Latency:half_ping() or time - Latency:half_ping(), function()
                    
                    
                    
                    
                    
                    self.tasks[id] = nil;
                end);
            end
        }
    end

    LPH_NO_VIRTUALIZE(function()
        function self:should_block_input()
            local should_block = false;
            for index, task in self.tasks do
                if not task.mob or not task.mob.Parent then
                    self.tasks[index] = nil;
                end;
            
                if task.mob then
                    local mob_root = task.mob:FindFirstChild("HumanoidRootPart");
                    if not mob_root then continue end
                
                    local distance = (local_player.root_part.Position - mob_root.Position).Magnitude;
                    if task.range and distance > task.range or task.in_hitbox and not task.in_hitbox() then continue end
                
                    if not should_block then
                        local block_input = aztup.flags.block_input;
                        if not block_input then return {debris=function()end,remove=function()end}end;
                        
                        local allowed_targets = aztup_options.allowed_bi_targets.Value;
                        should_block = allowed_targets.PVE and task.mob.Name:sub(1, 1) == "." or allowed_targets.PVP
                    end;
                end;
            end;

            return should_block        
end;
    end)();

    return self
end


getgenv().BlockInputManager = BlockInputManagerClass.new();
return getgenv().BlockInputManager