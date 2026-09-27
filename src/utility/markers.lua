


local Markers = {}
Markers.__index = Markers

function Markers.new()
	return setmetatable({
		_marked_instances = {},
	}, Markers)
end

function Markers:mark(instance)
	return table.insert(self._marked_instances, instance)
end

function Markers:get()
	return self._marked_instances
end

function Markers:clear()
	for i = #self._marked_instances, 1, -1 do
		local inst = self._marked_instances[i]
		if inst then
			pcall(function()
				inst:Destroy()
			end)
		end
		self._marked_instances[i] = nil
	end
end

return Markers