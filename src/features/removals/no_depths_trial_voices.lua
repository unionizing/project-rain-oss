local feature = Feature:new("no_depths_trial_voices");

function feature:enable()
	if not workspace:WaitForChild("DepthsTrial", 60) then return end

	workspace.DescendantAdded:Connect(function(sound) 
		if not sound:IsA("Sound") then return end

		task.wait();
		sound:Destroy();
	end);
end;

return feature  