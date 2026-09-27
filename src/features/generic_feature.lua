local profiler = require("@src/utility/profiler");
local feature = {} do
    feature.__index = feature;

    
    
    
    
    
    function feature.new(_, id: string, conn: RBXScriptConnection?, func: any?)
        local self = setmetatable({}, feature);

        self.id = id;
        self.conn = conn or Instance.new("BindableEvent").Event;
        self.func = func or function() end;
        self.update = profiler.wrap_no_xpcall(id, self.func);
        self.current_connection = nil; 

        return self    
end;

    
    function feature:enable() end;
 
    
    function feature:disable() end;
end; 

return feature