
local profiler = {};

function profiler.wrap_no_xpcall(label, func): (...any)
    return function(...) 
        
        func(...);
        
    end
end

function profiler.wrap(label, func): (...any)
    return function(...) 
        
        xpcall(func, warn, ...);
        
    end
end

return profiler