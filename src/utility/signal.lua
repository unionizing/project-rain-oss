

local signal = {}
signal.__index = signal

function signal:connect(event_function)
	local event = typeof(self.signal) == "Instance" and self.signal:IsA("BindableEvent") and self.signal.Event or self.signal;
	return event:Connect(event_function)
end

function signal:wait()
	self.signal:Wait();
end;

function signal:fire(...)
	self.signal:Fire(...);
end;

function signal:destroy(...)
	self.signal:Destroy();
end;

function signal.new()
	local self = setmetatable({}, signal)
	self.signal = Instance.new("BindableEvent");
	return self
end

return signal
