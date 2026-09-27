



local Fallback = {}
Fallback.__index = Fallback
Fallback.__type = "Fallback"







function Fallback.new(options)
    local self = setmetatable({}, Fallback)

    self.getPriority = options.getPriority
    self.execute = options.execute
    self.shouldExecute = options.shouldExecute

    return self
end

return Fallback