local feature = Feature:new("auto_equip_weapon");

local function is_using_utility_tool()
    local character = local_player.character;
    if not character then return false end;

    return character:FindFirstChildOfClass("Tool") ~= nil
end

local function draw_weapon()
    if is_using_utility_tool() then return end;

    local character = local_player.character;
    local character_handler = character and character:FindFirstChild("CharacterHandler");
    local requests = character_handler and character_handler:FindFirstChild("Requests");
    local draw_weapon_remote = requests and requests:FindFirstChild("DrawWeapon");

    if draw_weapon_remote then
        draw_weapon_remote:FireServer(true);
    end
end

function feature:enable()
	self.removed_hook = EffectReplicatorHandler:hook("removed", function(effect)
		if effect.Class ~= "Equipped" then return end;

        task.delay(0.1, function()
            if EffectReplicator:FindEffect("Equipped") then return end;
            draw_weapon();
        end);
	end);

    self.running = true;
    task.spawn(function()
        while self.running do
            if not EffectReplicator:FindEffect("Equipped") then
                draw_weapon();
            end;

            task.wait(1);
        end;
    end);
end;

function feature:disable()
	if self.removed_hook then
		self.removed_hook:remove();
	end;

    self.running = false;
end;

return feature
