
local feature = Feature:new("fake_void");

function feature:go()
	task.wait(0.15);
	services.ReplicatedStorage.Requests.Danger.ClearTags:FireServer(
	    true
	)

	require("@src/features/buttons/tp_to_void")();
	task.wait(1 / 5);
	require("@src/features/buttons/tp_to_roof")();
end;

local toggled_no_kill_bricks_for_user = false;
function feature:enable()
	if not aztup.flags.no_kill_bricks then
		aztup_toggles.no_kill_bricks:SetValue(true);
		toggled_no_kill_bricks_for_user = true;
	end

	self.touched_connection = aztup.features.no_kill_bricks.touched_fake.Event:Connect(function(fake_killbrick)
		feature:go();
	end);
end; 

function feature:disable()
	if toggled_no_kill_bricks_for_user then
		aztup_toggles.no_kill_bricks:SetValue(false);
		toggled_no_kill_bricks_for_user = false;
	end

	if self.touched_connection then
		self.touched_connection:Disconnect();
		self.touched_connection = nil;
	end
end;

return feature