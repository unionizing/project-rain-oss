local DefendActionManager = require("@src/features/auto-parry/defend-action-manager")
getgenv().DefendActionManager = DefendActionManager
getgenv().Latency = require("@src/utility/latency")

local function checkRange(obj, rangeCheck)
	if not (obj and obj.Position and local_player and local_player.root_part) then
		return false, math.huge
	end
	local distance = (obj.Position - local_player.root_part.Position).Magnitude
	return distance <= rangeCheck, distance
end

local function checkRangeFromPing(obj, rangeCheck, speed)
	if not (obj and obj.Position and local_player and local_player.root_part) then
		return false, math.huge, 0
	end
	local distance = (obj.Position - local_player.root_part.Position).Magnitude
	local ping = (Latency and Latency.get_ping and Latency:get_ping()) or 0
	distance -= (speed or 0) * (ping * 2)
	return distance <= rangeCheck, distance, (speed and speed ~= 0) and (ping / speed) or 0
end

local last_parry_at = tick()

local thrown = workspace:FindFirstChild("Thrown") or workspace:WaitForChild("Thrown", 10)
if thrown then
	aztup.maid:give_task(thrown.ChildAdded:Connect(LPH_NO_VIRTUALIZE(function(part)
		if not (aztup and aztup.flags and aztup.flags.auto_parry) then
			return
		end
		if not (part and part.Parent and local_player and local_player.root_part) then
			return
		end

		local live = workspace:FindFirstChild("Live")
		if not live then
			return
		end

		if part.Name == "ArdourBall2" then
			local nomad
			for _, child in live:GetChildren() do
				if child.Name:match("nomad") then
					nomad = child
					break
				end
			end

			if not nomad then
				return
			end
			local cond = false
			repeat
				task.wait()
				local pos_delta = (part.Position - local_player.root_part.Position)

				if
					math.abs(pos_delta.X) < 15
					and math.abs(pos_delta.Y) < 15
					and math.abs(pos_delta.Z) < 15
					and tick() - last_parry_at >= 0.1
				then
					cond = true
				elseif not part.Parent then
					cond = true
					return
				end
			until cond
			if not part.Parent then
				return
			end

			general:generic_parry_ap_task(nomad)
		elseif part.Name == "SlotBall" then
			repeat
				task.wait()
			until not part.Parent or (part.Position - local_player.root_part.Position).Magnitude < 20
			if not part.Parent then
				return
			end

			local current_angel
			for _, angel in live:GetChildren() do
				if angel.Name:match(".angel") then
					current_angel = angel
					break
				end
			end

			general:generic_parry_ap_task(current_angel)
		elseif part.Name == "BoneSpear" then
			local has_bonekeeper, bk
			for _, child in live:GetChildren() do
				if child.Name:match("boneboy") then
					has_bonekeeper = true
					bk = child
					break
				end
			end

			if has_bonekeeper then
				task.wait(2.15)
			end

			repeat
				task.wait()
			until not part.Parent
				or (part.Position - local_player.root_part.Position).Magnitude
					< (workspace:FindFirstChild("Layer2Floor1") and 30 or 75)
			if not part.Parent then
				return
			end

			if not workspace:FindFirstChild("Layer2Floor1") then
				local w = 0.2 - ((Latency and Latency.get_ping and Latency:get_ping()) or 0)
				if w > 0 then
					task.wait(w)
				end
			end

			general:generic_parry_ap_task(bk or workspace.Live:GetChildren()[2])
		elseif part.Name == "Flamewalker" and aztup.flags.no_rosen_fire then
			part.CanTouch = false

			local touch = part:WaitForChild("TouchInterest", 3.5)
			if touch then
				services.Debris:AddItem(touch, 0)
			end
		elseif part.Name == "Cyclone" then
			local backpack = local_player.instance:FindFirstChild("Backpack")
			if not backpack then
				return
			end
			if backpack:FindFirstChild("Mantra:EruptionBlood{{Scarlet Cyclone}}") then
				return
			end

			local user
			for _, player in services.Players:GetPlayers() do
				if
					player:FindFirstChild("Backpack")
					and player.Backpack:FindFirstChild("Mantra:EruptionBlood{{Scarlet Cyclone}}", true)
				then
					user = player.Character
					break
				end
			end

			if not user then
				return
			end

			repeat
				task.wait()
				local pos_delta = (part.Position - local_player.root_part.Position)

				if math.abs(pos_delta.X) < 12 and math.abs(pos_delta.Y) < 15 and math.abs(pos_delta.Z) < 12 then
					general:generic_parry_ap_task(user)
					break
				end
			until not part.Parent
		elseif part.Name:find("AraneaProjectile") or part.Name:find("SuperArrow") then
			local allowed_targets = aztup_options.allowed_targets.Value
			if not allowed_targets.PVP and not allowed_targets.All then
				return
			end

			local name = part.Name:split("_")[2]
			if not name then
				return
			end
			local user = services.Players:FindFirstChild(name)
			if not user then
				return
			end
			if user == local_player.instance then
				return
			end

			repeat
				task.wait()
				local pos_delta = (part.Position - local_player.root_part.Position)

				if math.abs(pos_delta.X) < 12 and math.abs(pos_delta.Y) < 15 and math.abs(pos_delta.Z) < 12 then
					general:generic_parry_ap_task(user.Character)
					break
				end
			until not part.Parent
		elseif part.Name:find("ShadeArrow") then
			local allowed_targets = aztup_options.allowed_targets.Value
			if not allowed_targets.PVP and not allowed_targets.All then
				return
			end

			local name = part.Name:split("_")[2]
			if not name then
				return
			end
			local user = services.Players:FindFirstChild(name)
			if not user then
				return
			end
			if user == local_player.instance then
				return
			end

			repeat
				task.wait()
				local pos_delta = (part.Position - local_player.root_part.Position)

				if math.abs(pos_delta.X) < 15 and math.abs(pos_delta.Y) < 16 and math.abs(pos_delta.Z) < 15 then
					general:generic_parry_ap_task(user.Character)
					break
				end
			until not part.Parent
		elseif part.Name == "Bullet" and not checkRange(part, 10) then
			local closest_player
			local closest_distance = math.huge
			for _, char in workspace:WaitForChild("Live"):GetChildren() do
				if char and char:FindFirstChild("HumanoidRootPart") then
					local distance = (part.Position - char.HumanoidRootPart.Position).Magnitude
					if distance < closest_distance then
						closest_distance = distance
						closest_player = char
					end
				end
			end

			if closest_distance > 120 then
				return
			end

			repeat
				task.wait()
			until (checkRangeFromPing(part, 20, 20)) or not part.Parent
			if not part.Parent then
				return
			end

			if closest_player and closest_player ~= local_player.character then
				general:generic_parry_ap_task(closest_player)
			end
		elseif part.Name == "SeekerOrb" then
			local closest_player
			local closest_distance = math.huge
			for _, char in workspace:WaitForChild("Live"):GetChildren() do
				if char and char:FindFirstChild("HumanoidRootPart") then
					local distance = (part.Position - char.HumanoidRootPart.Position).Magnitude
					if distance < closest_distance then
						closest_distance = distance
						closest_player = char
					end
				end
			end

			if closest_distance > 150 then
				return
			end

			repeat
				task.wait()
			until (checkRange(part, 2)) or not part.Parent
			if not part.Parent then
				return
			end

			
			local rocketPropulsion = part:WaitForChild('RocketPropulsion', 10)
			if (not rocketPropulsion or rocketPropulsion.Target ~= local_player.root_part) then return end			
			task.wait(0.3 - Latency:get_ping());

			if closest_player and closest_player ~= local_player.character then
				general:generic_parry_ap_task(closest_player)
			end
		end
	end)))
end

local last_telegraph_attach = tick()

function run_af()
	if not aztup.flags.auto_feint then
        return    
end;

    if not EffectReplicator:FindEffect("LightAttack") and not EffectReplicator:FindEffect("MidAttack") then
        return    
end;

    if EffectReplicator:FindEffect("FeintCool") then
        return    
end;

    

    local character_handler = local_player.character:FindFirstChild("CharacterHandler");
    local feint_release = character_handler and character_handler:FindFirstChild("FeintRelease", true);
    local feint_click = KeyHandler:get_key("FeintClick");

    if not feint_release or not feint_click then
        return false    
end;

    feint_click:FireServer({
        A = false,
        Left = false,
        S = false,
        NOAERIALS = false,
        Space = false,
        Right = true,
        W = false,
        D = false
    })
    task.wait(0.05);
    feint_release:FireServer({
        A = false,
        Left = false,
        S = false,
        NOAERIALS = false,
        Space = false,
        Right = false,
        W = false,
        D = false
    })
end;


aztup.maid:give_task(workspace.DescendantAdded:Connect(LPH_NO_VIRTUALIZE(function(projectile)
	if not (aztup and aztup.flags and aztup.flags.auto_parry) then
		return
	end

	local allowed_targets = aztup_options.allowed_targets.Value
	if not allowed_targets.PVE and not allowed_targets.All then
		return
	end

	local live = workspace:FindFirstChild("Live")
	if not live then
		return
	end
	
	if projectile.Name == "REP_SOUND_1590181673" and projectile:FindFirstAncestorWhichIsA("Model").Name == "MetalTurret" then
		
		
		local closest_player
		local closest_distance = math.huge
		for _, char in workspace:WaitForChild("Live"):GetChildren() do
			if char and char:FindFirstChild("HumanoidRootPart") then
				local distance = (projectile.Parent.Position - char.HumanoidRootPart.Position).Magnitude
				if distance < closest_distance then
					closest_distance = distance
					closest_player = char
				end
			end
		end
		local pos_delta = (projectile.Parent.Position - local_player.root_part.Position)
		
		if
			not (
				math.abs(pos_delta.X) < 10
				and math.abs(pos_delta.Y) < 15
				and math.abs(pos_delta.Z) < 50
			)
		then
			return		
end;
		if closest_distance > 120 or not services.Players:GetPlayerFromCharacter(closest_player) or not services.Players:GetPlayerFromCharacter(closest_player).Backpack:FindFirstChild("Mantra:TurretMetal{{Metal Turret}}") then
			return
		end

		if closest_player == local_player.character then return end

		DefendActionManager:queue_generic_dodge_task(closest_player)
	elseif projectile.Name == "ParticleEmitter3" and string.find(projectile:GetFullName(), "avatar") then
		local sdelay = (Latency:get_ping() / 2)
		task.wait(0.75 - sdelay)

		local avatar = projectile.Parent.Parent.Parent
		local target = avatar and avatar:FindFirstChild("Target")

		if target and target.Value ~= local_player.character then
			return
		end

		repeat
			general:generic_parry_ap_task(avatar)
			task.wait(0.15 - (Latency:get_ping() / 2))
		until not projectile.Parent or not projectile.Enabled
	elseif projectile.Name == "GrabPart" then
		repeat
			task.wait()
		until not projectile.Parent or (projectile.Position - local_player.root_part.Position).Magnitude < 20
		if not projectile.Parent then
			return
		end

		local ethiron
		for _, entity in workspace:WaitForChild("Live"):GetChildren() do
			if entity.Name:match("avatar") then
				ethiron = entity
				break
			end
		end

		DefendActionManager:queue_generic_dodge_task(ethiron)
	elseif projectile.Name == "SpikeStabEff" then
		local chaser
		for _, entity in live:GetChildren() do
			if not entity.Name:match(".chaser") then
				continue
			end
			chaser = entity
			break
		end

		if not chaser then
			return
		end

		BlockInputManager:add_task("SpikeStabEff", chaser, nil, 2000):debris(0.6)
		run_af()
		task.wait(0.6 - Latency:get_ping())
		run_af()
		if (projectile.Position - local_player.root_part.Position).Magnitude > 20 then
			return
		end

		if aztup.flags.auto_parry_debug then
			Library:Notify("[SpikeStabEff] Performing action 1: Parry")
		end
		DefendActionManager:queue_generic_parry_task(chaser)
	elseif projectile.Name == "HitTendril" then
		local chaser
		for _, entity in live:GetChildren() do
			if not entity.Name:match(".chaser") then
				continue
			end
			chaser = entity
			break
		end

		if not chaser then
			return
		end

		local hrp = chaser:FindFirstChild("HumanoidRootPart")
		if not hrp then
			return
		end

		local hasTelegraph = projectile.Parent == hrp or hrp:FindFirstChild("TelegraphAttach") ~= nil

		if hasTelegraph then
			run_af()
			task.wait(0.585 - Latency:get_ping())
			run_af()
			if aztup.flags.auto_parry_debug then
				Library:Notify("[HitTendril] Performing action 1: Dodge")
			end
			DefendActionManager:queue_generic_dodge_task(chaser)
		else
			run_af()
			task.wait(0.600 - Latency:get_ping())
			run_af()

			if aztup.flags.auto_parry_debug then
				Library:Notify("[HitTendril] Performing action 1: Parry")
			end
			DefendActionManager:queue_generic_parry_task(chaser)
		end
	end
end)))

return nil
