local MarkedInstanceCreator = {}





function MarkedInstanceCreator:new(markers, instance_type, settings)
	local instance = Instance.new(instance_type)
	for index, value in settings do
		instance[index] = value
	end

	Markers:mark(instance)

	return instance
end

return MarkedInstanceCreator