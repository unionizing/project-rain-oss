local ht = services.HttpService; local jd = ht.JSONDecode; local tbl;
local extra_data = LPH_NO_VIRTUALIZE(function() 
    function decode_asset(asset)
         local decoded = services.EncodingService:Base64Decode(buffer.fromstring(asset));
         local decompress = services.EncodingService:DecompressBuffer(decoded, Enum.CompressionAlgorithm.Zstd);
         return buffer.tostring(decompress)    
end;
    tbl = jd(ht, decode_asset(inline_asset_b96("@assets/base.json")));
    return jd(ht, decode_asset(inline_asset_b96("@assets/extra_data.json")))
end)()
LPH_NO_VIRTUALIZE(function() for k,v in extra_data do tbl[k] = v end; end)();
tbl['AbyssalRidge'] = (function() 
return {
    ids = {
        "14912083756"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    action_type = "Spell", 

    run = function(action)
        action.when = 0.775;
        action.offset = CFrame.new(0, 0, 0)
        action.hitbox = Vector3.new(25, 25, 25);
        action.type = "Parry"

        action:push();

        return action    
end    
} 
end)();
tbl['ArcBeam'] = (function() 
return {
    ids = {
        "9481400792",
        "9481398449"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    action_type = "Spell", 

    run = function(action)
        
        local root = defender.entity:FindFirstChild("HumanoidRootPart");
        if not root then return end

        local aerial = not track.Animation.AnimationId:find("9481400792");

        if not aerial then
            local delta = local_player.root_part.Position - root.Position
            local z_diff = delta:Dot(root.CFrame.LookVector);

            action.when = z_diff >= 15 and (z_diff >= 30 and 0.5 or 0.4) or 0.225;
            action.hitbox = Vector3.new(30, 60, 50)
            action.offset = CFrame.new(0,0,-30);
        else
            local diff = self:distance();

            action.when = diff >= 20 and (diff >= 35 and 0.6 or 0.5) or 0.35;
            action.hitbox = Vector3.new(30, 60, 50)
            action.offset = CFrame.new(0,0,0);
        end
        
        
        action.name = string.format("(%.2f) Arc Beam", self:distance())
        action:push();

        return action    
end    
} 
end)();
tbl['ArkasidJump'] = (function() 
return {
    ids = {
        "99884262476386"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true, 
    allow_parry_to_block = false,

    run = function(action)
        action.when = 0.65;
        action.offset = CFrame.new(0, 0, 0)
        action.hitbox = Vector3.new(20, 20, 30);
        action.name = "Arkasid Jump"
                
        action:push();

        return action    
end    
} 
end)();
tbl['ArkasidSleepSpin'] = (function() 

return {
    ids = {
        "140594691648105"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true, 
    allow_parry_to_block = false,

    run = function(action)
        action.when = 0.3;
        action.offset = CFrame.new(0, 0, 0)
        action.hitbox = Vector3.new(20, 20, 20);
        action.name = "Arkasid Sleep Spin 1"
                
        action:push();

        action.when = 0.3 * 2;
        action.offset = CFrame.new(0, 0, 0)
        action.hitbox = Vector3.new(20, 20, 30);
        action.name = "Arkasid Sleep Spin 2"
                
        action:push();

        return action    
end    
} 
end)();
tbl['ArkasidSpin'] = (function() 
return {
    ids = {
        "90936075863505"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true, 
    allow_parry_to_block = false,

    run = function(action)
        action.when = 0.3;
        action.offset = CFrame.new(0, 0, 0)
        action.hitbox = Vector3.new(20, 20, 20);
        action.name = "Arkasid Spin 1"
                
        action:push();

        action.when = 0.3 * 2;
        action.offset = CFrame.new(0, 0, 0)
        action.hitbox = Vector3.new(20, 20, 20);
        action.name = "Arkasid Spin 2"
                
        action:push();

        return action    
end    
} 
end)();
tbl['ArkasidSpit'] = (function() 
return {
    ids = {
        "108989457380156"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true, 
    allow_parry_to_block = false,

    run = function(action)
        action.when = 0.9;
        action.offset = CFrame.new(0, 0, 0)
        action.hitbox = Vector3.new(20, 30, 20);
        action.name = "Arkasid Spit"
                
        action:push();

        return action    
end    
} 
end)();
tbl['Ascension'] = (function() 
return {
    ids = {
        "9461513613"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    action_type = "Spell", 

    run = function(action)
        action.when = math.min(50 + self:distance() * 10) / 1000;
        action.type = "Dodge";
        action.hitbox = Vector3.new(30, 60, 50)
        action.offset = CFrame.new();
        action.name = string.format("(%.2f) Ascension", self:distance())
        action:push();

        return action    
end    
} 
end)();
tbl['AstralWind'] = (function() 
return {
    ids = {
        "6470684331"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    action_type = "Spell", 

    run = function(action)
        task.delay(0.3 - Latency:get_ping(), function()
            action.predict = true;
            action.predict_time = 0.25;
            action.base_and_predict = true;
            action.detect_gale_feint = true;

            action.when = 0;
            action.offset = CFrame.new(0, 0, 0)
            action.hitbox = Vector3.new(40, 10, 40) + (Vector3.new(0, 0, 1) * math.clamp(defender.entity.HumanoidRootPart.Velocity.Magnitude, 0, 25));

            action:play();
        end)

        return action    
end    
} 
end)();
tbl['Authority Flourish'] = (function() 
return {
    ids = {
        "85186188251021"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    action_type = "M1", 

    run = function(action)
        action.name = string.format("Authority Flourish %s - %s", weapon.length, weapon.type);
        action.when = 0.3;
        action.offset = CFrame.new(0, 0, -5)
        action.hitbox = Vector3.one * weapon.length * 2.5;
        action.shape = "ball";

        action:push();

        return action    
end    
} 
end)();
tbl['BellmarrowCrit'] = (function() 
return {
    ids = {
        "139686454345909"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    action_type = "Critical", 

    run = function(action)
        action.when = 0.95
        action.type = "Parry";
        action.ignore_early_end = true;
        action.hitbox = Vector3.new(80, 80, 80)
        action.offset = CFrame.new();
        action.name = "Bellmarrow Crit"
        action:push();

        return action    
end    
} 
end)();
tbl['BlindingDawn'] = (function() 
return {
    ids = {
        "10622235550"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true, 
    action_type = "Spell", 

    run = function(action) 
        action.when = 0.5;
        action.hitbox = Vector3.new(35, 20, 35);
                
        action:push();

        local start = tick();
        action.when = 0.5;
        action.hitbox = Vector3.new(35, 20, 35);
        action.type = "RPUE Parry";
        action.condition = function()
            return self:is_playing() and defender.entity.Parent and tick() - start <= 2        
end;

        action.wait = function()
            task.wait(Latency:get_ping() / 2);
        end

        action.should = function()
            return defender:in_hitbox(Vector3.new(35, 20, 35), CFrame.new(), true)        
end;

        action:push();

        return action    
end    
} 
end)();
tbl['BloodEdge'] = (function() 
return {
    ids = {
        "11493923277"
    },
    default_chance = 100,
    allow_block_input = false,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        local root = defender.entity:FindFirstChild("HumanoidRootPart");
        if not root then return end

	    if root:WaitForChild("REP_SOUND_15776883341", 0.1) then
            local delta = local_player.root_part.Position - root.Position
            local z_diff = delta:Dot(root.CFrame.LookVector);
            


	    	action.when = z_diff >= 15 and 0.5 or 0.4
	    	action.hitbox = Vector3.new(20, 20, 35)
            action.half_size_offset = true;
	    	action.name = string.format("Bloodedge %.2f", z_diff);
            action:push();
            return action	    
else
            action.when = 0.3;
            action.hitbox = Vector3.new(weapon.length * 2.5, weapon.length * 2, weapon.length * 2.4);
            action.offset = CFrame.new(0,0,-5)
            action.name = "Scythe";
            action:push();
	    end

        return action    
end    
} 
end)();
tbl['BoneSpear'] = (function() 
return {
    ids = {
        "9681908909" 
    },
    action_type = "Parry",
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        local bk
        for _, child in workspace.Live:GetChildren() do
            if child.Name:match("boneboy") then
                bk = child
                break
            end
        end

        if not bk then return action end

        task.wait(2.0) 
        local start = tick()
        local maxWaitTime = 3

        while tick() - start < maxWaitTime do
            for _, object in workspace:WaitForChild("Thrown"):GetChildren() do
                if object.Name == "BoneSpear" then
                    local distanceThreshold = workspace:FindFirstChild("Layer2Floor1") and 30 or 75
                    
                    if (object.Position - local_player.root_part.Position).Magnitude < distanceThreshold then
                        if not workspace:FindFirstChild("Layer2Floor1") then
                            task.wait(0.2 - Latency:get_ping())
                        end
                        
                        action.name = "BoneSpear Parry"
                        action.when = 0
                        action.type = "Parry"
                        action.offset = CFrame.new(0, 0, 0)
                        action.hitbox = Vector3.new(30, 30, 30)
                        action.ignore_hitbox = true
                        action.ignore_early_end = true
                        
                        action:push()
                        return action
                    end
                end
            end
            task.wait()
        end

        return action
    end    
}
 end)();
tbl['BonekeeperCharge'] = (function() 
return {
    ids = {
        "9681905891"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true, 

    run = function(action) 
        task.wait(0.8 - Latency:get_ping())
        local when = tick();
        repeat task.wait() until tick() - when > 2 or (local_player.root_part.Position - defender.entity.HumanoidRootPart.Position).Magnitude < 30
        if tick() - when > 2 then
            return action        
end

        action.when = 0;
        action.offset = CFrame.new(0, 0, 0)
        action.hitbox = Vector3.new(100, 30, 100);
                
        action:push();

        return action    
end    
} 
end)();
tbl['BonekeeperFloor'] = (function() 
return {
    ids = {
        "9681916972"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        for i = 0, 10 do
            action.when = 0.4;
            action.offset = CFrame.new(0, 0, 0)
            action.hitbox = Vector3.new(80, 250, 80);
            action.type = "Jump"
    
            action:push();
        end;

        return action    
end    
} 
end)();
tbl['BonekeeperLeap'] = (function() 
return {
    ids = {
        "9681472252"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        action.when = 0;
        action.type = "Jump";
        action.offset = CFrame.new(0, 0, 0)
        action.hitbox = Vector3.new(200, 200, 200);
                
        action:push();

        return action    
end    
} 
end)();
tbl['BonekeeperSweep'] = (function() 
return {
    ids = {
        "9681421310"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        action.when = 0.6;
        action.offset = CFrame.new(0, 0, -10)
        action.hitbox = Vector3.new(20, 30, 40);

        action:push();

        return action    
end    
} 
end)();
tbl['BurningServants'] = (function() 
return {
    ids = {
        "5769343416"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    action_type = "Spell", 

    run = function(action)
        local hrp = defender.entity:FindFirstChild("HumanoidRootPart")
        if not hrp then
            return
        end
    
        local player = game:GetService("Players"):GetPlayerFromCharacter(defender.entity)
        local backpack = player and player:FindFirstChild("Backpack")
    
        if backpack and backpack:FindFirstChild("Mantra:SquadFire{{Burning Servants}}") then
            local data = mantra.data(defender.entity, "Mantra:SquadFire{{Burning Servants}}")
            local range = data.stratus * 2 + data.cloud * 1
    
            action.when = 0.32
            action.type = "Parry"
            action.hitbox = Vector3.new(30 + range, 25, 30 + range)
            action.name = "Burning Servants Timing"
            action:push();
    
            action.when = 2.3
            action.type = "Parry"
            action.hitbox = Vector3.new(30 + range, 25, 30 + range)
            action.name = "Burning Servants Timing";
            action.ignore_early_end = true;

            return action:push()        
else
            local data = mantra.data(defender.entity, "Mantra:SquadIce{{Frozen Servants}}")
            local range = data.stratus * 2 + data.cloud * 1
    
            action.when = 0.750
            action.type = "Parry"
            action.hitbox = Vector3.new(20 + range, 25, 20 + range)
            action.name = "(1) Frozen Servants Timing"
            action:push();
    
            action.when = 1.05;
            action.type = "Parry"
            action.hitbox = Vector3.new(20 + range, 25, 20 + range)
            action.name = "(2) Frozen Servants Timing 2"
            action.ignore_early_end = true;
            return action:push()        
end
    end    
} 
end)();
tbl['Caltrops'] = (function() 
return {
    ids = {
        "14954130177"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true, 
    action_type = "Spell", 

    run = function(action) 
        action.when = math.min(100 + (self:distance() * 8)) / 1000;
        action.offset = CFrame.new(0, 0, -25)
        action.hitbox = Vector3.new(20, 30, 50);
                
        action:push();

        return action    
end    
} 
end)();
tbl['ChaserSlam'] = (function() 
return {
    ids = {
        "14531935090"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        repeat
            task.wait()
        until track.TimePosition >= 0.92
    
        action.when = 0
        action.type = "Parry"
        action.hitbox = Vector3.new(145, 65, 145)
        action.name = string.format("(%.2f) Chaser Slam", track.Speed)
        action:push();

        return action    
end    
} 
end)();
tbl['ChimecallerCrit'] = (function() 
return {
    ids = {
        "75972447119162"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    action_type = "Critical", 

    run = function(action)
        action.when = math.min(1350 + self:distance() * 2) / 1000;
        action.type = "Dodge";
        action.ignore_early_end = true;
        action.hitbox = Vector3.new(100, 50, 100)
        action.offset = CFrame.new();
        action.name = string.format("(%.2f) Chimecaller Crit", self:distance())
        action:push();

        return action    
end    
} 
end)();
tbl['ClutchingShadow'] = (function() 
return {
    ids = {
        "6385078248"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    action_type = "Spell", 

    run = function(action)
        task.wait(0.2 - Latency:get_ping());
        if not local_player.character:FindFirstChild("NewShadow", true) then return end
        action.when = 0;
        action.offset = CFrame.new();
        action.hitbox = Vector3.new(100, 100, 100);

        action:push();

        return action    
end    
} 
end)();
tbl['ColdpointCrit'] = (function() 
return {
    ids = {
        "100635703599003"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    action_type = "Critical", 

    run = function(action)
        action.when = 0.5
        action.type = "Parry";
        action.ignore_early_end = true;
        action.hitbox = Vector3.new(15, 15, 40)
        action.offset = CFrame.new(0, 0, -20);
        action.name = "Coldpoint Crit"
        action:push();

        return action    
end    
} 
end)();
tbl['CrimsonRain'] = (function() 
return {
    ids = {
        "83367609184503"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        
        
        
        
        
        
        
        

        return action    
end    
} 
end)();
tbl['CrystalImpaleWindup'] = (function() 
return {
    ids = { "6054920207" },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    ignore_animation_early_end = true,
    action_type = "Undefined",

    run = function(action)
        action.when = 0.37
        action.type = "Parry"
        action.hitbox = Vector3.new(25, 30, 30)
        action.name = "Crystal Impale Windup"
        action:push()
        return action
    end,
} 
end)();
tbl['CurvedCrit'] = (function() 
return {
    ids = {
        "13290263661"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        local distance = self:distance()

        local d = distance;

        local t = d / 20
        local w = d <= 12 and 0.45 or 0.3 + 0.45 * t;
        action.when = w;

		action.type = "Parry" 
        action.offset = CFrame.new(0,0,-(60 / 2))
		action.hitbox = Vector3.new(25, 25, 70)
        action.ignore_early_end = true;
		action.name = string.format("Curved (%.2f, %.2f)", distance, w);
        action:push();

        action.when = w + 0.3;

		action.type = "Parry" 
        action.ignore_early_end = true;
        action.offset = CFrame.new(0,0,-(60 / 2))
		action.hitbox = Vector3.new(25, 25, 70)
		action.name = string.format("Curved (%.2f)", distance)
        action:push();

        return action    
end    
} 
end)();
tbl['CurvedCritDual'] = (function() 
return {
    ids = {
        "13277887570"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        local distance = self:distance()

        local d = math.clamp(distance, 0, 30)

        local t = d / 30
        action.when = 0.20 + 0.45 * t

		action.type = "Parry" 
        action.offset = CFrame.new(0,0,-(70 / 2))
		action.hitbox = Vector3.new(25, 25, 70)
		action.name = string.format("Curved Dual (%.2f)", distance)
        action:push();

        return action    
end    
} 
end)();
tbl['DaggerCritical'] = (function() 
return {
    ids = {
        "7350770431"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    

    run = function(action)
        local distance = self:distance()

        action.when = 0.4
        if distance >= 11 then
            action.when = 0.65
        end
        if distance >= 13 then
            action.when = 0.8
        end
        action.type = "Parry"
        action.offset = CFrame.new(0,0,-5)
        action.hitbox = Vector3.new(14, 15, 15)
        action:push()
        return action    
end    
} 
end)();
tbl['DarkBlade'] = (function() 
return {
    ids = {
        "6038858570"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        local num = 1;
        action.when = 0.15

		action.type = "Parry" 
        action.offset = CFrame.new(0,0,-7.5)
		action.hitbox = Vector3.new(16, 23, 22)
		action.name = string.format("Dark Blade %i", 1)
        action:push();

        task.delay(0.2 - Latency:get_ping(), function()
            local conn = thrown.ChildAdded:Connect(function(part)
                if EffectReplicator:FindEffect("ParryCool") or not local_player.tracker:can_parry() then return end
                if part.Name == "ShadowSlash" then
                    num += 1;
                    if num == 2 then return end

                    action.when = 0

                    action.type = "Parry" 
                    action.offset = CFrame.new(0,0,-7.5)
                    action.hitbox = Vector3.new(16, 23, 22)
                    action.name = string.format("Dark Blade %i", num)
                    action:play();
                end;
            end);

            task.delay(5, function()
                conn:Disconnect();
            end);
        end);

        return action    
end    
} 
end)();
tbl['DeepWidowSwing'] = (function() 
return {
    ids = {
        "6428514850",
        "6428519131"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
	    local speed = track.Speed
        local when = 0.3;

	    if speed >= 0.45 and speed <= 0.55 then
	    	when = 1.050
	    end

	    if speed >= 0.75 and speed <= 0.85 then
	    	when = 0.750
	    end

	    if speed >= 0.9 and speed <= 1.0 then
	    	when = 0.540
	    end

	    if defender.entity.Name:match(".miniwidow") then
		    action.hitbox = Vector3.new(25, 25, 25)
            when /= 1.1
        else
		    action.hitbox = Vector3.new(40, 40, 40)
        end;
		action.type = "Parry" 
        action.when = when;
        action.offset = CFrame.new(0,0,0)
		action.name = string.format("Deep Widow Swing %.2f %.2f", speed, when)
        action:push();

        return action    
end    
} 
end)();
tbl['DukeCrouchSlash'] = (function() 
return {
    ids = {
        "75177662439153"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    action_type = "Spell", 

    run = function(action)
		action.when = 0.8
		action.type = "Crouch"
		action.hitbox = Vector3.new(50, 25, 50)
        action.offset = CFrame.new(0,0,-25);
		action.name = "Duke Wind Slash"
        action:push();

        return action    
end    
} 
end)();
tbl['DukeGolemPunch'] = (function() 
return {
    ids = {
        "75216423575082"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    action_type = "Spell", 

    run = function(action)
		action.when = 0.9
		action.type = "Dodge"
		action.hitbox = Vector3.new(50, 50, 50)
        action.offset = CFrame.new(0,0,-25);
		action.name = "Golem Punch"
        action:push();

        return action    
end    
} 
end)();
tbl['DukeGolemSlam'] = (function() 
return {
    ids = {
        "112517047632505"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    action_type = "Spell", 

    run = function(action)
		action.when = 0.5
		action.type = "Crouch"
		action.hitbox = Vector3.new(50, 50, 50)
		action.name = "Golem Slam"
        action:push();

        return action    
end    
} 
end)();
tbl['DukeGolemSlam2'] = (function() 
return {
    ids = {
        "82450781977821"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    action_type = "Spell", 

    run = function(action)
		action.when = 0.65
		action.type = "Jump"
		action.hitbox = Vector3.new(50, 50, 50)
		action.name = "Golem Slam"
        action:push();

        return action    
end    
} 
end)();
tbl['DukeGrasp'] = (function() 
return {
    ids = {
        "8285321158"
    },
    action_type = "Spell",
    default_chance = 100,

    allow_block_input = false,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = false,

    run = function(action)
        task.wait(0.2 - Latency:get_ping());

        action.name = "Duke Bomb Grab Short";
        action.when = 0;
        action.hitbox = Vector3.new(2000, 2000, 2000);
        action.half_size_offset = true;
        action.type = "Dodge";
                
        action:push();

        local has_grab = false;
        local start = tick();

        while tick() - start < 1 or has_grab do
            has_grab = false;
            for _, object in workspace:WaitForChild("Thrown"):GetChildren() do
                if object.Name ~= "GrabPart" then continue end

                has_grab = true;
                
                action.name = "Duke Bomb Grab";
                action.when = 0;
                action.ignore_hitbox = true;
                action.ignore_early_end = true;
                action.half_size_offset = true;
                action.type = "Dodge";

                action:push();
            
                return action            
end;
            task.wait();
        end;

        return action    
end    
} 
end)();
tbl['DukeNewStomp'] = (function() 
return {
  ids = {
      "105478410111896"
  },
  default_chance = 100,
  allow_block_input = false,
  allow_parry_to_roll = true,
  allow_roll_to_parry = true,
  allow_parry_to_block = true,

  run = function(action)
        local distance = self:distance();
      
        if defender.entity.Name:match(".theduke") then
            if distance > 10 then
                action.when = 1.0 
            else
                action.when = 0.8
            end
            action.name = string.format("Duke Stomp %.2f", distance);
        else
            if distance > 25 then
                action.when = math.min(325 + distance * 13, 3000) / 1000
            else
                action.when = 0.65
            end
            action.name = string.format("Pillars of Erisia %.2f", distance);
        end;
      
        action.hitbox = Vector3.new(40, 20, 60)
        action.half_size_offset = true;
        action.type = "Dodge";
        action:push();

        return action  
end    
} 
end)();
tbl['DukeStomp'] = (function() 
return {
  ids = {
      "8290626574"
  },
  default_chance = 100,
  allow_block_input = false,
  allow_parry_to_roll = true,
  allow_roll_to_parry = true,
  allow_parry_to_block = true,

  run = function(action)
        local distance = self:distance();
      
        if defender.entity.Name:match(".theduke") then
            if distance > 10 then
                action.when = 1.0 
            else
                action.when = 0.8
            end
            action.name = string.format("Duke Stomp %.2f", distance);
        else
            action.when = 0.4
            action.name = string.format("Pillars of Erisia %.2f", distance);
        end;
      
        action.hitbox = Vector3.new(40, 20, 60)
        action.half_size_offset = true;
        action.type = "Dodge";
        action:push();

        return action  
end    
} 
end)();
tbl['DukeTripleKick'] = (function() 
return {
    ids = {
        "10358800338"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    action_type = "Spell", 

    run = function(action)
		action.when = 0.7
		action.type = "Jump"
		action.hitbox = Vector3.new(50, 50, 50)
        action.offset = CFrame.new(0,0,-25);
		action.name = "Kick 1"
        action:push();

		action.when = 1.65
		action.type = "Jump"
		action.hitbox = Vector3.new(50, 50, 50)
        action.offset = CFrame.new(0,0,-25);
		action.name = "Kick 2"
        action:push();

        action.when = 2.500
		action.type = "Jump"
		action.hitbox = Vector3.new(50, 50, 50)
        action.offset = CFrame.new(0,0,-25);
		action.name = "Kick 3"
        action:push();

        return action    
end    
} 
end)();
tbl['DukeWindBlast'] = (function() 
return {
    ids = {
        "8286153000"
    },
    action_type = "Spell",
    default_chance = 100,

    allow_block_input = false,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = false,

    run = function(action)
        task.wait(0.1 - Latency:get_ping());

        action.name = "Duke Arrow Short";
        action.when = 0;
        action.hitbox = Vector3.new(100, 100, 100);
        action.half_size_offset = true;
        action.type = "Parry";
                
        action:push();

        local has_blast = false;
        local start = tick();

        while tick() - start < 1 or has_blast do
            has_blast = false;
            for _, object in workspace:WaitForChild("Thrown"):GetChildren() do
                if object.Name ~= "DukeBlast" then continue end

                has_blast = true;
                
                action.name = "Duke Arrow";
                action.when = 0;
                action.ignore_hitbox = true;
                action.ignore_early_end = true;
                action.half_size_offset = true;
                action.type = "Parry";

                action:push();
            
                return action            
end;
            task.wait();
        end;

        return action    
end    
} 
end)();
tbl['ElderPrimaSixStomp'] = (function() 
return {
	ids = { "82589408775991" },
	default_chance = 100,
	allow_block_input = true,
	allow_parry_to_roll = true,
	action_type = "Undefined",

	run = function(action)
		local timings = { 0.550, 1.000, 1.450, 1.800, 2.150, 2.550 } 

		local humanoid = defender.entity:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			return
		end

		local halfhp = humanoid.Health <= (humanoid.MaxHealth / 2)

		for idx = 1, 6 do
			local when = timings[idx]

			if halfhp then
				when = when / 1.25
			end

			action.when = when
			action.type = "Parry"
			action.hitbox = Vector3.new(100, 250, 100)
			action.name = string.format("(%.2f) Primadon SixStomp %i", track.Speed, idx)
			action:push()
		end

		return action
	end,
}

 end)();
tbl['ElderPrimadonHandSlam'] = (function() 
return {
	ids = { "139012331361882" },
	default_chance = 100,
	allow_block_input = true,
	allow_parry_to_roll = true,
	action_type = "Undefined",

	run = function(action)
		local when = ((1200 * 1.21) / track.Speed) / 1000
		action.when = when
		action.type = "Dodge"
		action.hitbox = Vector3.new(80, 250, 140)
		action.name = string.format("(%.2f) Dynamic Primadon Timing", track.Speed)
		action:push()

		return action
	end,
}

 end)();
tbl['ElderPrimadonStomp'] = (function() 
return {
    ids = { "122173613929787" },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    action_type = "Undefined",

    run = function(action)
        action.when = ((750 * 1.21) / track.Speed) / 1000
        action.type = "Parry"
        action.hitbox = Vector3.new(80, 250, 140)
        action.name = string.format("(%.2f) Dynamic Primadon Timing", track.Speed)
        action:push()
        return action
    end,
}
 end)();
tbl['ElderPrimadonUltimateStomp'] = (function() 
return {
    ids = { "82315723491864" },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    action_type = "Undefined",

    run = function(action)
        action.when = ((2130 * 1.21) / track.Speed) / 1000
        action.type = "Parry"
        action.hitbox = Vector3.new(100, 250, 100)
        action.name = string.format("(%.2f) Dynamic Primadon Timing", track.Speed)
        action:push()
        return action
    end,
}
 end)();
tbl['ElectroCarveMagnet'] = (function() 
return {
    ids = { "15433825224" },
    action_type = "Spell",
    default_chance = 100,
    allow_block_input = false,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = false,

    run = function(action)
        task.wait(0.45 - Latency:get_ping())

        action.name = "Electro Carve Magnet"
        action.when = 0
        action.offset = CFrame.new(0, 0, -15)
        action.hitbox = Vector3.new(15, 20, 30)
        action:push()

        if general:in_hitbox(local_player.root_part.CFrame, defender.entity.HumanoidRootPart.CFrame, Vector3.new(15, 20, 35), CFrame.new(0, 0, -10), false) then return action end

        local has_semtex = false
        local start = tick()

        while tick() - start < 1 or has_semtex do
            has_semtex = false
            for _, object in workspace:WaitForChild("Thrown"):GetChildren() do
                if object.Name ~= "Semtex" then continue end

                has_semtex = true
                if general:in_hitbox(local_player.root_part.CFrame, object.CFrame, Vector3.new(10, 10, 80), CFrame.new(0, 0, -40), false) then
                    action.name = "Electro Carve Magnet"
                    action.when = 0
                    action.offset = CFrame.new(0, 0, -15)
                    action.ignore_hitbox = true
                    action.ignore_early_end = true
                    action:push()
                    return action
                end
            end
            task.wait()
        end

        return action
    end
}
 end)();
tbl['EnforcerPullStart'] = (function() 
return {
    ids = {
        "7271659917"
    },
    default_chance = 100,
    allow_block_input = false,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        if not (aztup and aztup.flags and aztup.flags.no_enforcer_pull) then
            action.when = 0.4;
            action.type = "Dodge";
            action.offset = CFrame.new();
            action.hitbox = Vector3.new(100, 100, 100);
    
            action:push();
        end;

        return action    
end    
} 
end)();
tbl['EnforcerSpin'] = (function() 
return {
    ids = {
        "7019018522"
    },
    default_chance = 100,
    allow_block_input = false,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        action.when = 0.3;
        action.offset = CFrame.new();
        action.hitbox = Vector3.new(16,20,16);

        action:push();

        action.when = 0.3;
        action.offset = CFrame.new();
        action.hitbox = Vector3.new(16,20,16);
        action.type = "RPUE Parry";
        action.condition = function()
            return self:is_playing() and defender.entity.Parent        
end;

        action.wait = function()
            task.wait(Latency:get_ping());
        end

        action.should = function()
            return defender:in_hitbox(Vector3.new(16,20,16), CFrame.new(), true)        
end;

        action:push();

        return action    
end    
} 
end)();
tbl['EtherBarrage'] = (function() 
return {
    ids = {
        "18637932235"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    ignore_animation_early_end = true,
    
    action_type = "Spell", 

    run = function(action)
        action.when = 0.5;
        action.offset = CFrame.new(0,0,-20);
        action.hitbox = Vector3.new(50, 30, 40);
        action.type = "Start Block";
        action:push();

        action.when = 1.3;
        action.offset = CFrame.new(0,0,-20);
        action.hitbox = Vector3.new(50, 30, 40);
        action.type = "End Block";
        action:push();

        return action    
end    
} 
end)();
tbl['FerrymanAssault'] = (function() 
local teleportedAt = tick();
local firstAnim = tick();

return {
    ids = {
        "5968288116"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = false,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        local target = defender.entity:FindFirstChild('Target');
        if not target then
	        local player = game:GetService("Players"):GetPlayerFromCharacter(defender.entity)
	        local backpack = player and player:FindFirstChild("Backpack")

	        local mantra = backpack and backpack:FindFirstChild("Mantra:StrikeWind{{Wind Passage}}")
            if not mantra then 
                return action            
end;
            action.name = "Wind Passage";
            action.hitbox = Vector3.new(30, 30, 100);
            action.offset = CFrame.new(0,0,0);
            action.when = 0.41;
            action:push();
            return action        
elseif target.Value ~= local_player.character then return action end;

        local hum = defender.entity:FindFirstChild("Humanoid");
        if not hum or hum.Health <= 0 then return action end;

		if (hum.Health / hum.MaxHealth) * 100 >= 50 then
			if tick()-teleportedAt > 2 then
				if tick() - firstAnim > 3 then
					firstAnim = tick();
					return action				
end
				teleportedAt = tick();
                action.when = 0.8;
                action.ignore_hitbox = true;
                action.name = string.format("Ferryman Teleport [1, %i]", math.round((hum.Health / hum.MaxHealth) * 100));
        
                return action:push()			
else
				teleportedAt = tick();
                action.when = 0.2;
                action.ignore_hitbox = true;
                action.name = string.format("Ferryman Teleport [2, %i]", math.round((hum.Health / hum.MaxHealth) * 100));
        
                return action:push()			
end
		else
			if tick()-teleportedAt > 2 then
				if tick() - firstAnim > 3 then
					firstAnim = tick();
					return action				
end
				teleportedAt = tick();

                action.when = 0.8;
                action.ignore_hitbox = true;
                action.name = string.format("Ferryman Teleport [3, %i]", math.round((hum.Health / hum.MaxHealth) * 100));
        
                return action:push()			
else
				teleportedAt = tick();
				
                action.when = 0.1;
                action.ignore_hitbox = true;
                action.name = string.format("Ferryman Teleport [4, %i]", math.round((hum.Health / hum.MaxHealth) * 100));
        
                return action:push()			
end
		end

        return action    
end    
} 
end)();
tbl['FireEruption'] = (function() 
return {
    ids = {
        "8378263543"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    action_type = "Spell", 

    run = function(action)
        if defender.entity:FindFirstChild("HumanoidRootPart") and defender.entity:FindFirstChild("HumanoidRootPart"):WaitForChild("REP_SOUND_3755636152", 0.1) then
            action.when = 0.45;
            action.name = "Ignition Deepcrusher Critical"
            action.offset = CFrame.new(0, 0, 0)
            action.hitbox = Vector3.new(25, 25, 25);
            action.ignore_early_end = true;
            action.type = "Parry";
            action:push();

            action.when = 0.9;
            action.name = "Ignition Deepcrusher Critical"
            action.offset = CFrame.new(0, 0, 0)
            action.hitbox = Vector3.new(40, 25, 40);
            action.ignore_early_end = true;
            action.type = "Parry";
            action:push();
            return action        
end;

		action.when = 0.350
		action.type = "Parry"
		action.hitbox = Vector3.new(30, 25, 35)
		action.name = "Fire Eruption 1st"
        action:push();

		action.when = 1.100
		action.type = "Parry"
		action.hitbox = Vector3.new(30, 25, 30)
		action.name = "Fire Eruption 2nd"
        action:push();

        return action    
end    
} 
end)();
tbl['FirePalm'] = (function() 
return {
    ids = {
        "7618754583"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        local data = mantra.data(defender.entity, "Mantra:PalmFire{{Fire Palm}}")
        local range = data.stratus * 3 + data.cloud * 2
    
        local hrp = defender.entity:FindFirstChild("HumanoidRootPart")
        if not hrp then
            return
        end

        action.when = 0.35
        if hrp:WaitForChild("REP_SOUND_4377231054", 0.1) then
            action.type = "Parry"
            action.offset = CFrame.new(0,0,-15);
            action.hitbox = Vector3.new(30, 20, 30)
            action.name = "Gale Punch"
            action.detect_gale_feint = true;
            action:push();
        else
            action.type = "Parry"
            action.offset = CFrame.new(0,0,-26.5);
            action.hitbox = Vector3.new(25, 25, 70 + range)
            action.name = "Fire Palm 0.7"
            action:push();
        end

        return action    
end    
} 
end)();
tbl['FiringLine'] = (function() 
return {
    ids = {
        "7543558046",
        "13282373122"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    action_type = "Spell", 

    run = function(action)
        local mantra = mantra.data(defender.entity, "Mantra:GunMetal{{Firing Line}}")

        
        
        if mantra.blast then
            action.when = 0.3;
            action.ignore_early_end = true;
            action.hitbox = Vector3.new(40, 40, 60)
            action.offset = CFrame.new(0,0,0);
            action.name = string.format("Blast Spark Firing Line %i", self:distance());
            action:push();

            action.when = 0.5;
            action.ignore_auto_parry_frames = true;
            action.ignore_early_end = true;
            action.hitbox = Vector3.new(40, 40, 60)
            action.offset = CFrame.new(0,0,0);
            action.name = string.format("Blast Spark Firing Line %i", self:distance());
            action:push();
        end;

        return action    
end    
} 
end)();
tbl['FlameAssault'] = (function() 
return {
    ids = {
        "7543558046"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    action_type = "Spell", 

    run = function(action)

        
        
    
        action.when = self:distance() <= 18 and 0.45 or math.min(350 + self:distance() * 5) / 1000;
        action.hitbox = Vector3.new(40, 40, 60)
        action.offset = CFrame.new(0,0,-30);
        action.name = string.format("(%.2f) Flame Assault", self:distance());
        action:push();
        return action    
end    
} 
end)();
tbl['FlameBlind'] = (function() 
return {
    ids = {
        "7585268054"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        
        action.ignore_early_end = true;
        action.when = 0.6;
        action.type = "Parry";
        action.offset = CFrame.new(0, 0, 0)
        action.hitbox = Vector3.one * 50;
                
        action:push();

        return action    
end    
} 
end)();
tbl['FlameGrab'] = (function() 
return {
    ids = {
        "5750353585"
    },
    default_chance = 100,
    allow_block_input = false,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    action_type = "Spell", 

    run = function(action)

        
        
    
        action.when = 0
        action.hitbox = Vector3.new(20, 20, 25)
        action:push();

        action.when = 0;
        action.offset = CFrame.new(0,0,-13.5);
        action.hitbox = Vector3.new(25,40,25);
        action.type = "RPUE Parry";
        local shoulds = 0;
        action.condition = function()
            return self:is_playing() and defender.entity.Parent and shoulds <= 1        
end;

        action.wait = function()
            task.wait(); 
        end

        action.should = function()
            if defender:in_hitbox(Vector3.new(20,20,20), CFrame.new(0,0,-10), true) then
                shoulds += 1;
                return true            
end
            return false        
end;

        action:push();

        
        
        
    
        
        
        
    
        
        
        
    
        
        
        
        
        

        return action    
end    
} 
end)();
tbl['FlameRepulsion'] = (function() 
return {
    ids = {
        "5774829118"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    action_type = "Spell", 

    run = function(action)
	    local data = mantra.data(defender.entity, "Mantra:RepulsionFire{{Flame Repulsion}}")
	    local range = data.stratus * 14 + data.cloud * 10

	    action.when = 0.5;
	    action.type = "Parry"
	    action.hitbox = Vector3.new(32 + range, 32 + range, 32 + range)
        action.shape = "ball";

	    return action:push()    
end    
} 
end)();
tbl['FlareVolley'] = (function() 
return {
    ids = {
        "17665718967"
    },
    action_type = "Spell", 
    default_chance = 100, 

    allow_block_input = false,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = false,

    run = function(action)
        action.name = "Flare Volley";
        action.when = math.min(300 + self:distance() * 8, 3000) / 1000;
        action.ignore_early_end = true;
        action.offset = CFrame.new(0, 0, -50)
        action.hitbox = Vector3.new(30, 15, 100);
        action:push();

        return action    
end    
} 
end)();
tbl['FleetingSparks'] = (function() 
local function areOrbsStillAlive(orbs)
	for _, orb in next, orbs do
		if not orb.Parent then
			continue
		end

		if not orb:FindFirstChild("PointLight") then
			continue
		end

		return true
	end

	return false
end

return {
	ids = {
		"7599113567",
	},
	action_type = "Spell", 
	default_chance = 100,
	allow_block_input = false,
	allow_parry_to_roll = true,
	allow_roll_to_parry = true,
	allow_parry_to_block = true,

	run = function(action)
		local thrown = workspace:FindFirstChild("Thrown")
		if not thrown then
			return action
		end

		task.spawn(function()
			local listenerConn = local_player.character.DescendantAdded:Connect(function(child)
				if child.Name ~= "Targeted" then
					return
				end
				if not child.Parent or not child.Parent:IsA("Attachment") then
					return
				end

           		action.ignore_early_end = true;
           		action.name = "Ice Daggers Effect"
           		action.when = 0.3;
           		action.type = "Parry"
           		action.ignore_hitbox = true;

           		action:play();
			end)

			task.wait(1.2)

			listenerConn:Disconnect()
		end)

		task.wait(0.7 - Latency:get_ping())

		local orbs = {}

		for _, part in pairs(thrown:GetChildren()) do
			if not part:IsA("BasePart") then
				continue
			end

			if not part.Name:match("LightningMote") then
				continue
			end

			orbs[#orbs + 1] = part
		end

		local blockStarted = false

		while task.wait() do
			for _, orb in next, orbs do
				if not areOrbsStillAlive(orbs) then
					DefendActionManager:queue_unblock_task(defender.entity, 0)

					return action
				end

				if not orb or not orb.Parent then
					continue
				end

				if (orb.Position - local_player.root_part.Position).Magnitude >= 50 then
					continue
				end

				if blockStarted then
					continue
				end

				DefendActionManager:queue_block_task(defender.entity, 0)

				blockStarted = true
			end
		end

		return action
	end,
}

 end)();
tbl['GaleTrap'] = (function() 
return {
  ids = {
      "7608490737"
  },
  action_type = "Spell", 
  default_chance = 100, 

  allow_block_input = true,
  allow_parry_to_roll = true,
  allow_roll_to_parry = true,
  allow_parry_to_block = false,
  ignore_animation_early_end = true,

  run = function(action)
      local player = game:GetService("Players"):GetPlayerFromCharacter(defender.entity)
      local backpack = player and player:FindFirstChild("Backpack")

    if backpack and backpack:FindFirstChild("Mantra:ForgeFire{{Fire Forge}}") then      
          action.when = 0;
          action.ignore_early_end = true;
          action.name = "FireForgeClose"
          action.type = "Parry"
          action.hitbox = Vector3.new(15, 15, 20)
          action.offset = CFrame.new(0, 0, 0);
          action:push()
          return action      
end
    
      if backpack and backpack:FindFirstChild("Mantra:TrapWind{{Galetrap}}") then      
          action.when = 0.27;
          action.ignore_early_end = true;
          action.name = "GaleTrap"
          action.type = "Parry"
          action.hitbox = Vector3.new(10, 25, 40)
          action.offset = CFrame.new(0, 0, -20);
          action:push()
          return action      
end
      
      return action  
end    
} 
end)();
tbl['GenericAerial'] = (function() 
return {
    ids = {
        "7576748728",
        "7576614609",
        "11363599835",
        "95071929775027",
        "8194213529"
    },
    action_type = "M1", 
    default_chance = 100, 

    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = false,

    run = function(action)
        if not weapon.type or not weapon.length then return end
        
        task.wait(((0.163 / track.Speed) + 0.1) - Latency:get_ping());
        while self:is_playing() and task.wait(0.035) do
            if not defender or not defender.entity then continue end
            if not defender:in_hitbox_with_pos(
                local_player.root_part.CFrame, 
                defender.entity.HumanoidRootPart.CFrame, 
                Vector3.new(12, 20, ((weapon.length * 2.9) + (Latency:get_ping() * weapon.length))), 
                CFrame.new(0,0,-5)
            ) then continue end
    
            action.base_and_predict = true;
            action.predict = true;
            action.name = string.format("Aerial [%s, %s, %s]", weapon.length, weapon.type, track.Animation.AnimationId);
            action.when = 0;
    
            action.offset = CFrame.new(0, 0, weapon.length * -0.8)
            action.ignore_hitbox = true;
            
                    
            action:push();
            break        
end;

        return action    
end    
} 
end)();
tbl['GenericKick'] = (function() 
return {
    ids = {
        "9484850093",
        "106333512017575"
    },
    action_type = "M1", 
    default_chance = 100, 

    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = false,

    run = function(action)
        if not weapon.type or not weapon.length then return end

        action.base_and_predict = true;
        action.predict = true;
    
        action.name = string.format("Kick - %0.2f, %s", weapon.length, weapon.type);
        local hitbox = Vector3.new(weapon.length * 2.25, weapon.length * 3, weapon.length * 2.25);
        local windup = 0.35;

        if weapon.type == "Rifle" then
            windup =  (0.16 / track.Speed) + 0.150;
            hitbox = Vector3.new(weapon.length * 2.3, weapon.length * 3, weapon.length * 2);

        end

        action.when = windup;
        action.hitbox = hitbox;
        action.name = string.format("%s Kick - %0.1f", weapon.type, weapon.length);
        action.predict_rotation = true;
        action.offset = CFrame.new(0, 0, -5)

        if aztup_options.m1_timing_hitbox_type.Value == "Ball" then
            action.shape = "ball";
        end
        
        action:push();

        return action    
end    
} 
end)();
tbl['GenericM1'] = (function() 
 function has_heavy_hands(mob)
    for _,v in next, mob:GetChildren() do
        if v.Name ~= 'Ring' or v:GetAttribute("EquipmentRef") ~= "Heavy Hands Ring" then continue end 

        return true    
end

    return false
end;
 
local timing_ids = {
    '93964938784148', 
    '93964938784148', 
    '86466909898596', 
    '119153579346494',
    '12106093579',           
    '12106095892',           
    '96251946143797',           
    '107771611881875',           
    '7600485223',           
    '16654113357',           
    '14435770311',           
    
    '11493920418',           
    '88620745767944',           
    '17666279427',           
    '17666287806',           
    '7600485223',           
    '7627854272',           
    '101975669191368',           
    '9597280175',           
    '5067105317',           
    '16654113357',           
    '115757796989607',           
    
    '16372422960',           
    '106608030834708',           
    '9928485641',           
    
    '16654105888',           
    '90742361803263',           
    '80513922848003',           
    '114108670383026',           
    '11186654931',           
    '7600450739',           
    '16372478422',           
    '6607519294',           
    '131576892263777',           
    '6063195211',           
    '9832727905',           
    '7627049402',           
    '9313226324',           
    '13241958217',           
    '11186656574',           
    '7627049402',           
    '7627854272',           
    '103284896140202',           
    '8161044711',           
    '16372479940',           
    '8249177669',           
    '9930447958',           
    '7627854272',           
    '113419264758259',           
    '16654099937',           
    '8249175106',           
    '9832727905',           
    '6607519294',           
    '14435773739',           
    '7616407967',           
    '11493920418',           
    '17666284182',           
    '9597272746',           
    '12138861998',           
    '8161043368',           
    '14435763579',           
    '74422917176963',           
    '16654099937',           
    '12106093579',           
    '7627854272',           
    '13241958217',           
    '6063188218',           
    '13242083070',           
    '16654099937',           
    '123115833203242',           
    '5064195992',           
    '16654105888',           
    '81374297342678',           
    '9928485641',           
    '8161039359',           
    '14435778571',           
    '8161043368',           
    '9832721746',           
    
    '99450771029342',           
    '7600450739',           
    '7627889074',           
    '9832721746',           
    '98624535650879',           
    '12138857946',           
    '81374297342678',           
    
    '9832724876',           
    '16372478422',           
    '88620745767944',           
    '7627854272',           
    '12138860062',           
    '9928429385',           
    '17197732174',           
    '139109176874463',           
    '8161039359',           
    '16372412925',           
    '8161043368',           
    '100190998225588',           
    '106858298622632',           
    '106858298622632',           
    '16654105888',           
    '101975669191368',           
    '77160956516659',           
    '102858834757078',           
    '17197704130',           
    '111781160894259',           
    '101975669191368',           
    '111781160894259',           
    '106608030834708',           
    '16654113357',           
    '97447284729710',           
    '94626092299428',           
    '7627889074',           
    '7600450739',           
    '5067105317',           
    '11493920418',           
    '119672037814127',           
    '13242083070',           
    '7627889074',           
    '122256431354649',           
    '135226142279222',           
    '13241958217',           
    '94626092299428',           
    '7600450739',           
    '14435766591',           
    '90742361803263',           
    '131576892263777',           
    '13241958217',           
    '7627854272',           
    '7600450739',           
    '16372427756',           
    '7600485223',           
    '9597272746',           
    '94626092299428',           
    '121003629056681',           
    '89177958009696',           
    '7626771915',           
    '87039001813522',           
    '12106091136',           
    '138417702895229',           
    '94626092299428',           
    '11186652658',           
    '8161044711',           
    '8249175106',           
    '7626771915',           
    '5064195992',           
    '110004733402661',           
    '5064195992',           
    '102858834757078',           
 
    '12106091136',           
    '12106095892',           
    '9832724876',           
    '123115833203242',           
    '5067105317',           
    '17197593993',           
    '7626771915',           
    '9930618934',           
    '6607538047',           
    '7626771915',           
    '125647240494772',           
    '16372476897',           
    '8161039359',           
    "7600450739", 
    "7600485223", 
    "7600224169", 
    "7600160919",
    "5064195992", 
    "5067105317", 
    
    "6675698010", 
    "6675703249", 
    "107653610777693",

    "7627372304",
    "7627558238",
    "5950080662",

    
    "123456225328134",
    
    "6437665734",
    "6432920452",

    
    "9597289518",
    "96170267983421", 
    "17666287806", 
    "17636520960", 
    "92625055798566", 
    "83142103198119" 
};














return {
    ids = timing_ids,
    action_type = "M1", 
    default_chance = 100, 

    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = false,

    run = function(action)
        if not weapon.type or not weapon.length then return end

        action.base_and_predict = true;
        action.predict = true;
        action.predict_rotation = true;
        

        
        
        local debug_extras = "";
        local ignore_ball = false;
        local hitbox = Vector3.new(weapon.length * 2.65, weapon.length * 3, weapon.length * 2.8); 
        local windup = 0;
        local offset = CFrame.new(0, 0, -5);
        if weapon.type == "Greataxe" and track.Speed ~= 1.0 then
            windup = (0.171 / track.Speed) + 0.120
        elseif weapon.type == "Greataxe" and track.Speed == 1.0 then
            windup = (0.171 / track.Speed)
            windup += 0.250 / (weapon.ss * (has_heavy_hands(defender.entity) and 0.9 or 1))
        elseif weapon.type == "Greathammer" and track.Speed ~= 1.0 then
            windup = (0.150 / track.Speed) + 0.150
        elseif weapon.type == "Greathammer" and track.Speed == 1.0 then
            windup = (0.150 / track.Speed)
            windup += 0.250 / weapon.ss
        elseif weapon.type == "Greatcannon" and track.Speed ~= 1.0 then
            windup = (0.155 / track.Speed) + 0.160
        elseif weapon.type == "Greatcannon" and track.Speed == 1.0 then
            windup = (0.155 / track.Speed) + 0.300
        elseif weapon.type == "Rapier" then
            windup = (0.155 / track.Speed) + 0.120
        elseif weapon.type == "Bow" then
            local thrown_object = workspace.Thrown:FindFirstChild("Attach_" .. defender.entity.Name)
            local tip_attachment: Attachment? = thrown_object and thrown_object:FindFirstChild("HandWeapon") and thrown_object:FindFirstChild("HandWeapon"):FindFirstChild("TipAttachment");
            if tip_attachment then 
                local ready = false;
                while task.wait() and self:is_playing() do
                    ready = tip_attachment:FindFirstChild("Spark");
                    if ready then break end
                end

                if not ready then return end
            end
            windup = 0
            hitbox = Vector3.new(weapon.length * 2, weapon.length * 2, weapon.length * 2); 
            ignore_ball = true;
        elseif weapon.type == "Pistol" and not (track.Animation.AnimationId:match("14435770311") or track.Animation.AnimationId:match("14435773739") or track.Animation.AnimationId:match("14435778571")) then
            windup = 0.350 / weapon.ss
        elseif weapon.type == "Pistol" and (track.Animation.AnimationId:match("14435770311") or track.Animation.AnimationId:match("14435773739") or track.Animation.AnimationId:match("14435778571")) then
	        local ispeed = track.Speed
            repeat
                task.wait()
            until track.Speed ~= ispeed
    
            windup = 0.075 / track.Speed
    
            if track.Speed == 0.0 then
                windup = 0.100
            end
        elseif weapon.type == "Rifle" and track.Animation.AnimationId:match("9928485641") then    
            windup = track.Speed * 0.55
            
    
            if track.Speed == 0.0 then
                windup = 0.100
                debug_extras ..= " 0s"
            end
            debug_extras ..= " [odd anim]"
        elseif weapon.type == "Rifle" then
            windup = (0.2 / track.Speed)
        elseif weapon.type == "Club" then
            windup = (0.180 / track.Speed) + 0.100
        elseif weapon.type == "Twinblade" then
            windup = (0.150 / track.Speed) + 0.050
            
            if track.Animation.AnimationId:match("123456225328134") then
                windup = 0.45;
                debug_extras ..= "first"
            end
        elseif weapon.type == "Spear" then
            windup = (0.150 / track.Speed) + 0.100
            hitbox = Vector3.new(weapon.length * 2.5, weapon.length * 2, weapon.length * 2.4);
            ignore_ball = true
        elseif weapon.type == "Greatsword" then
            hitbox = Vector3.one * (weapon.length * 2.5); 
            windup = (0.158 / track.Speed) + 0.150
        elseif weapon.type == "Fist" then 
            windup = (0.140 / track.Speed) + 0.130
            for _, anim in defender.entity.Humanoid:GetPlayingAnimationTracks() do
                if anim.Animation.AnimationId == "rbxassetid://92562352733890" then
                    windup = 0;
                end
            end
        elseif weapon.type == "Dagger" then
            windup = (0.150 / track.Speed) + 0.075
            hitbox = Vector3.new(weapon.length * 3.8, weapon.length * 4, weapon.length * 4); 
        elseif weapon.type == "Sword" then
            windup = (0.150 / track.Speed) + 0.05
            hitbox = Vector3.one * (weapon.length * 2.5); 
            ignore_ball = true;
        end
        if weapon.type == "Staff" then
            windup = (0.150 / track.Speed) + 0.08
            hitbox = Vector3.new(weapon.length * 3.65, weapon.length * 2.7, weapon.length * 3.8); 
        end

        if weapon.type == "Rifle" then
            hitbox = Vector3.new(weapon.length * 3.8, weapon.length * 4.5, weapon.length * 3);
            if track.Animation.AnimationId:match("9928485641") then
                hitbox = Vector3.new(weapon.length * 3, weapon.length * 4.5, weapon.length * 2.5);
            end
            
            debug_extras ..= " [" .. track.Animation.AnimationId .. "]";
        elseif weapon.type == "Twinblade" then
            hitbox = Vector3.new(weapon.length * 3, weapon.length * 4.5, weapon.length * 3.15);
        elseif weapon.type == "Fist" then
            hitbox = Vector3.one * (weapon.length * 2.5); 
        end

        if weapon.type == "Rifle" then
            hitbox = Vector3.new(weapon.length * 2.5, weapon.length * 2, weapon.length * 1.75);
            ignore_ball = true;
            action.predict_time = 0.1;
            action.base_and_predict = true;
        end;

        local debug_name = string.format("%s M1 - %0.2f, %0.1f, %s", weapon.type, windup * 2.351, weapon.length, #debug_extras > 0 and debug_extras or "none");
        action.name = debug_name;
        action.when = windup;
        action.predict_rotation = true;
        action.offset = offset;

        if aztup_options.m1_timing_hitbox_type.Value == "Ball" and not ignore_ball then
            action.shape = "ball";
        end

        action.hitbox = hitbox;
        action:push();
        return action    
end    
} 
end)();
tbl['GenericRunning'] = (function() 
return {
    ids = {
            '6669352471',           
            '112381112390648',           
            '8367730650',           
            '5063313656',           
            '5827250000',           
            '17108126093',           
            
            '5827250000',           
            '6669352471',           
            '6669352471',           
            '6669352471',           
            '5063313656',           
            '8367730650',           
            '11493924588',           
            '4699358112',           
            '11493924588',           
            '5827250000',           
            '8367730650',           
            '5063313656',           
            '5063313656',           
            '5063313656',           
            '5063313656',           
            '135041461821238',           
            '6669352471',           
            '5827250000',           
            '5063313656',           
            '11493924588',           
            '5063313656',           
            '5063313656',           
            '11493924588',           
            '5063313656',           
            '101584283427561',           
            '6669352471',           
            '4699358112',           
            '133871771843754',           
            '5063313656',           
            '4699358112',           
            '5063313656',           
            '4699358112',           
            '5827250000',           
            '8367730650',           
            '8367730650',           
            
            '11493924588',           
            '5063313656',           
            '17108040817',           
            '82342705344145',           
            '4699358112',           
            '12496646061',           
            '17108040817',           
            '6669352471',           
            '4699358112',           
            '17108040817',           
            '5063313656',           
            '5827423063', 
    },
    action_type = "M1", 
    default_chance = 100, 

    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = false,

    run = function(action)
        if not weapon.type or not weapon.length then return end

        action.base_and_predict = true;
        action.predict = true;

        

        
        
        action.hitbox = Vector3.new(weapon.length * 2.65, weapon.length * 3, weapon.length * 3); 
        action.offset = CFrame.new(0, 0, -5)

        local windup = 0;
        if weapon.type == "Dagger" then
            windup = (0.147 / track.Speed) + 0.140
        elseif weapon.type == "Greatsword" then
            windup = (0.160 / track.Speed) + 0.160
            windup += 0.1 / weapon.ss
            action.hitbox = Vector3.new(weapon.length * 2.65, weapon.length * 3, weapon.length * 4); 

        elseif weapon.type == "Greataxe" then
            windup = (0.150 / track.Speed) + 0.100
            windup += 0.100 / weapon.ss
        elseif weapon.type == "Greatcannon" then
            windup = (0.160 / track.Speed) + 0.160
            windup += 0.100 / weapon.ss
        elseif weapon.type == "Greathammer" then
            windup = (0.160 / track.Speed) + 0.160
            windup += 0.100 / weapon.ss
            action.hitbox = Vector3.new(weapon.length * 2.65, weapon.length * 3, weapon.length * 4); 
        elseif weapon.type == "Spear" then
            windup = (0.150 / track.Speed) + 0.140
            windup += 0.100 / weapon.ss
        elseif weapon.type == "Pistol" then
            repeat
                task.wait()
            until track.Speed >= 0.1
    
            windup = (0.300 / track.Speed)
        elseif weapon.type == "Rifle" then
            windup = (0.169 / track.Speed) + 0.180
            windup += 0.100 / weapon.ss
            action.hitbox = Vector3.new(weapon.length * 2.65, weapon.length * 3, weapon.length * 2.825); 
            action.offset = CFrame.new()
            action.half_size_offset = true;
        elseif weapon.type == "Sword" then
            windup = (0.135 / track.Speed) + 0.100
            windup += 0.1 / weapon.ss
        elseif weapon.type == "Staff" then
            windup = (0.135 / track.Speed) + 0.100
            windup += 0.150 / weapon.ss
            action.hitbox = Vector3.new(weapon.length * 2.65, weapon.length * 3, weapon.length * 2.8); 
            action.offset = CFrame.new()
            action.half_size_offset = true;
        elseif weapon.type == "Rapier" then
            windup = (0.238 / track.Speed) + 0.060
        elseif weapon.type == "Club" then
            windup = (0.173 / track.Speed) + 0.100
            windup += 0.150 / weapon.ss
        elseif weapon.type == "Bow" then
            windup = 0.2
        elseif weapon.type == "Twinblade" then
            windup = (0.164 / track.Speed) + 0.100
            windup += 0.150 / weapon.ss
        elseif weapon.type == "Fist" then
            windup = (0.153 / track.Speed) + 0.120
            action.hitbox = Vector3.new(weapon.length * 2.65, weapon.length * 3, weapon.length * 3.3); 
            action.offset = CFrame.new()
            action.half_size_offset = true;
        end
    
        action.name = string.format("Running Attack - %0.2f, %0.2f, %s", windup, weapon.length, weapon.type);
        action.when = windup;
                
        action:push();

        return action    
end    
} 
end)();
tbl['GolemSpin'] = (function() 
return {
    ids = {
        "6501497627"
    },
    default_chance = 100,
    allow_block_input = false,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        action.when = 0.8 + 2.7;
        action.offset = CFrame.new(0,0,-13.5);
        action.hitbox = Vector3.new(25,40,25);
        task.delay(0.8 + 2.7, function() 
            print(self:is_playing() and defender.entity.Parent)
        end);

        action:push();

        action.when = 0.8 + 2.7;
        action.offset = CFrame.new(0,0,-13.5);
        action.hitbox = Vector3.new(25,40,25);
        action.type = "RPUE Parry";
        action.condition = function()
            return self:is_playing() and defender.entity.Parent        
end;

        action.wait = function()
            task.wait(.125 - Latency:half_ping());
        end

        action.should = function()
            return general:in_hitbox(local_player.root_part.CFrame, defender.entity:GetPivot(), Vector3.new(25,40,35), CFrame.new(0,0,-13.5), false)        
end;

        action:push();

        return action    
end    
} 
end)();
tbl['GrandJavelin'] = (function() 
return {
    ids = {
        "8183996606"
    },
    action_type = "Spell",
    default_chance = 100,
    allow_block_input = false,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = false,

    run = function(action)
        task.wait(0.4 - Latency:get_ping())

        action.name = "Grand Javelin"
        action.when = 0
        action.offset = CFrame.new(0, 0, -15)
        action.hitbox = Vector3.new(15, 20, 30)
        action:push()

        if general:in_hitbox(local_player.root_part.CFrame, defender.entity.HumanoidRootPart.CFrame, Vector3.new(15, 20, 35), CFrame.new(0, 0, -10), false) then return action end

        local has_javelin = false
        local start = tick()

        while tick() - start < 1 or has_javelin do
            has_javelin = false
            for _, object in workspace:WaitForChild("Thrown"):GetChildren() do
                if object.Name ~= "SpearPart" or object.Name:find("Splinter") then continue end

                has_javelin = true
                if general:in_hitbox(local_player.root_part.CFrame, object.CFrame, Vector3.new(10, 10, 80), CFrame.new(0, 0, -40), false) then
                    action.name = "Grand Javelin"
                    action.when = 0
                    action.offset = CFrame.new(0, 0, -15)
                    action.ignore_hitbox = true
                    action.ignore_early_end = true
                    action:push()
                    return action
                end
            end
            task.wait()
        end

        return action
    end
}
 end)();
tbl['IceCarve'] = (function() 
return {
    ids = {
        "15714151635"
    },
    action_type = "Spell", 
    default_chance = 100, 

    allow_block_input = false,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = false,

    run = function(action)
        local mantra = mantra.data(defender.entity, "Mantra:CarveIce{{Ice Carve}}")
        if mantra and mantra.spring then
            action.ignore_early_end = true;
            action.name = "Ice Carve Spring Spark"
            action.when = 0.2;
            action.type = "Dodge"
            action.offset = CFrame.new(0, 0, -10)
            action.hitbox = Vector3.new(40, 32, 25);

            action:push();

            action.ignore_early_end = true;
            action.name = "Ice Carve Spring Spark"
            action.when = 0.3;
            action.type = "Dodge"
            action.offset = CFrame.new(0, 0, -25)
            action.hitbox = Vector3.new(40, 32, 25);

            action:push();

            return action        
end

        action.name = "Ice Carve";
        action.when = 0.2;
        action.offset = CFrame.new(0, 0, -7.5)
        action.hitbox = Vector3.new(15,20,15);
                
        action:push();

        
        
        
        
        
        
        
        
        
        
        
        
        

        return action    
end    
} 
end)();
tbl['IceFlock'] = (function() 
return {
    ids = {
        "16079914008"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    

    run = function(action)
        local distance = self:distance()
        action.when = 0.5

        action.type = "Parry"
        action.name = string.format("%.2f Ice Flock", distance)
        action.hitbox = Vector3.new(30, 20, 30) 
        action:push()
        
        action.when = 0.7

        action.type = "Parry"
        action.name = string.format("%.2f Ice Flock", distance)
        action.hitbox = Vector3.new(30, 20, 30) 
        action:push()
        return action    
end    
} 
end)();
tbl['IceForge'] = (function() 
return {
    ids = {
        "8467835626"
    },
    action_type = "Spell", 
    default_chance = 100, 

    allow_block_input = false,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = false,

    run = function(action)
        local cube_conn do
            local cube_count = 0;
            local last_parry = 0;
            cube_conn = workspace.Thrown.ChildAdded:Connect(function(a)
                if a.Name == "Cube" then
                    cube_count += 1;
                    if cube_count >= 3 then
                        cube_conn:Disconnect();
                    end;
                    repeat 
                        task.wait()         
                    until a.Velocity.Magnitude > 10 and (a.Position - local_player.root_part.Position).Magnitude < (a.Velocity.Magnitude / 1.85) or not a.Parent;
                    if not a.Parent then return end
                    if a.Velocity.Magnitude < 25 then
                        task.wait(0.5 + (self:distance() / 30));
                    end;
                    if tick() - last_parry < 0.2 and (a.Position - local_player.root_part.Position).Magnitude > 20 then return end
    
                    if a.Velocity.Magnitude < 0.5 then
                        return                    
end
                    DefendActionManager:queue_generic_parry_task(defender.entity, 0);
                    last_parry = tick();
                end
            end);
    
            task.delay(15, function()
                cube_conn:Disconnect();
            end);
        end;

        task.wait(0.4 - Latency:get_ping());

        local start = tick();
        local has_ice_dagger = false;
        while tick() - start < 2 or has_ice_dagger do
            has_ice_dagger = false;
            for _, child in workspace.Thrown:GetChildren() do
                if child.Name ~= "IceShuriken" then continue end
                if child.Velocity.Magnitude <= 0.2 then continue end


                has_ice_dagger = true;
                local mag = (child.Position - game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).Magnitude;
                if mag > 30 then continue end

                action.name = "Ice Forge";
                action.when = 0;
                action.ignore_early_end = true;
                action.offset = CFrame.new(0, 0, 0)
                action.hitbox = Vector3.new(2000, 2000, 2000);
                action.ignore_hitbox = true;
                        
                action:push();
                return action            
end;
            task.wait();
        end;

        return action    
end    
} 
end)();
tbl['IceSpike'] = (function() 
return {
    ids = {
        "7543723607"
    },
    default_chance = 100,
    allow_block_input = false,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        local start = tick(); 
        repeat 
            task.wait() 

            for _, spike in pairs(workspace.Thrown:GetChildren()) do
                if spike.Name == "IceCircle" and general:in_hitbox(local_player.root_part.CFrame, spike.CFrame, Vector3.new(15, 20, 15), CFrame.new(), true) then
                    action.when = 0.2;
                    action.offset = CFrame.new(0, 0, -10)
                    action.hitbox = Vector3.new(20, 30, 40);
                    action.ignore_hitbox = true;
                    action:push();
                    return action                
end
            end
        until tick() - start > 1;

        
        
        

        

        return action    
end    
} 
end)();
tbl['Iceberg'] = (function() 
return {
    ids = {
        "9234812388"
    },
    action_type = "Spell", 
    default_chance = 100, 

    allow_block_input = false,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = false,

    run = function(action)
        action.name = "Iceberg";
        action.when = 1;
        action.offset = CFrame.new(0, 0, 0)
        action.hitbox = Vector3.new(40, 10, 40);
                
        action:push();

        return action    
end    
} 
end)();
tbl['ImperatorsEdgeCrit'] = (function() 
return {
    ids = {
        "74712624949815"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        local distance = self:distance()

        local d = distance;

        local t = d / 40
        local w = d <= 12 and 0.45 or 0.3 + 0.45 * t;
        action.when = w;

		action.type = "Parry" 
        action.offset = CFrame.new(0,0,-(80 / 2))
		action.hitbox = Vector3.new(7.5, 25, 90)
        action.ignore_early_end = true;
		action.name = string.format("Imperators Edge Crit (%.2f, %.2f)", distance, w);
        action:push();
        return action    
end    
} 
end)();
tbl['KaritaLeap'] = (function() 
return {
    ids = {
        "73703637156475"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)

        action.when = 0.5

		action.type = "Parry" 
        action.offset = CFrame.new(0, 0, -20)
		action.hitbox = Vector3.new(15, 10, 45)
		action.name = "Karita Leap"
        action:push();

        return action    
end    
} 
end)();
tbl['KickFollowupTitus'] = (function() 
return {
    ids = {
        "80865399851806"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        if not defender.entity.Name:find(".titus") or defender.entity:FindFirstChild("Target") and defender.entity:FindFirstChild("Target").Value ~= local_player.character then return action end
        action.when = 0.3;
        action.type = "Dodge";
        action.offset = CFrame.new(0, 0, 0)
        action.ignore_hitbox = true;
                
        action:push();

        return action    
end    
} 
end)();
tbl['KingCrocSlam'] = (function() 
return {
    ids = {
        "9921853885"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    action_type = "M1", 

    run = function(action)
        action.when = 0.7;
        action.offset = CFrame.new(0, 0, 0)
        action.hitbox = Vector3.new(40, 40, 40);
        action.type = "Jump"

        action:push();

        return action    
end    
} 
end)();
tbl['KyrsgardeChampionFiveHitCombo'] = (function() 
return {
    ids = {
        "132499670118034"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        action.when = 0.64;
        action.type = "Parry";
        action.offset = CFrame.new(0, 0, 0);
        action.hitbox = Vector3.new(200, 150, 190);
        action.name = "Ice Champion 5-Hit Combo 1";
        action:push();

        action.when = 1.15;
        action.type = "Parry";
        action.offset = CFrame.new(0, 0, 0);
        action.hitbox = Vector3.new(200, 150, 190);
        action.name = "Ice Champion 5-Hit Combo 2";
        action:push();

        action.when = 2.15;
        action.type = "Parry";
        action.offset = CFrame.new(0, 0, 0);
        action.hitbox = Vector3.new(200, 150, 190);
        action.name = "Ice Champion 5-Hit Combo 3";
        action:push();

        action.when = 2.70;
        action.type = "Parry";
        action.offset = CFrame.new(0, 0, 0);
        action.hitbox = Vector3.new(200, 150, 190);
        action.name = "Ice Champion 5-Hit Combo 4";
        action:push();

        action.when = 3.80;
        action.type = "Dodge";
        action.offset = CFrame.new(0, 0, 0);
        action.hitbox = Vector3.new(200, 150, 190);
        action.name = "Ice Champion 5-Hit Combo 5";
        action:push();

        return action    
end    
} 
end)();
tbl['KyrsgardeChampionFourHitCombo'] = (function() 
return {
    ids = {
        "127741055541488"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        action.when = 0.64;
        action.type = "Parry";
        action.offset = CFrame.new(0, 0, 0);
        action.hitbox = Vector3.new(200, 150, 190);
        action.name = "Ice Champion 4-Hit Combo 1";
        action:push();

        action.when = 1.34;
        action.type = "Parry";
        action.offset = CFrame.new(0, 0, 0);
        action.hitbox = Vector3.new(200, 150, 190);
        action.name = "Ice Champion 4-Hit Combo 2";
        action:push();

        action.when = 2.04;
        action.type = "Legit Jump";
        action.offset = CFrame.new(0, 0, 0);
        action.hitbox = Vector3.new(200, 150, 190);
        action.name = "Ice Champion 4-Hit Combo 3";
        action:push();

        action.when = 3.10;
        action.type = "Dodge";
        action.offset = CFrame.new(0, 0, 0);
        action.hitbox = Vector3.new(200, 150, 190);
        action.name = "Ice Champion 4-Hit Combo 4";
        action:push();

        return action    
end    
} 
end)();
tbl['KyrsgardeChampionSpikeCombo'] = (function() 
return {
    ids = {
        "133763199472108"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        action.when = 0.90;
        action.type = "Dodge";
        action.offset = CFrame.new(0, 0, 0);
        action.hitbox = Vector3.new(200, 150, 190);
        action.name = "Ice Champion Spike Combo 1";
        action:push();

        action.when = 1.55;
        action.type = "Parry";
        action.offset = CFrame.new(0, 0, 0);
        action.hitbox = Vector3.new(200, 150, 190);
        action.name = "Ice Champion Spike Combo 2";
        action:push();

        action.when = 2.10;
        action.type = "Parry";
        action.offset = CFrame.new(0, 0, 0);
        action.hitbox = Vector3.new(200, 150, 190);
        action.name = "Ice Champion Spike Combo 3";
        action:push();

        action.when = 3.25;
        action.type = "Parry";
        action.offset = CFrame.new(0, 0, 0);
        action.hitbox = Vector3.new(200, 150, 190);
        action.name = "Ice Champion Spike Combo 4";
        action:push();

        return action    
end    
} 
end)();
tbl['KyrsgardeChampionSweep'] = (function() 
return {
    ids = {
        "80169226986818"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        action.when = 0.57;
        action.type = "Legit Jump";
        action.offset = CFrame.new(0, 0, 0);
        action.hitbox = Vector3.new(200, 150, 190);
        action.name = "Ice Champion Sweep 1";
        action:push();

        action.when = 0.75;
        action.type = "Crouch";
        action.offset = CFrame.new(0, 0, 0);
        action.hitbox = Vector3.new(200, 150, 190);
        action.name = "Ice Champion Sweep 2";
        action:push();


        






return action    
end    
} 
end)();
tbl['KyrsgardeChampionThreeHitCombo'] = (function() 
return {
    ids = {
        "100777123071173"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        action.when = 0.51;
        action.type = "Parry";
        action.offset = CFrame.new(0, 0, 0);
        action.hitbox = Vector3.new(200, 150, 190);
        action.name = "Ice Champion 3-Hit Combo 1";
        action:push();

        action.when = 1.12;
        action.type = "Parry";
        action.offset = CFrame.new(0, 0, 0);
        action.hitbox = Vector3.new(200, 150, 190);
        action.name = "Ice Champion 3-Hit Combo 2";
        action:push();

        action.when = 1.26;
        action.type = "Crouch";
        action.offset = CFrame.new(0, 0, 0);
        action.hitbox = Vector3.new(200, 150, 190);
        action.name = "Ice Champion 3-Hit Combo 3";
        action:push();

        













return action    
end    
} 
end)();
tbl['KyrsgardeChampionWindupSlash'] = (function() 
return {
    ids = {
        "106268260112496"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        action.when = 0.50;
        action.type = "Start Block";
        action.offset = CFrame.new(0, 0, 0);
        action.hitbox = Vector3.new(200, 150, 190);
        action.name = "Ice Champion Windup Slash";
        action:push();

        action.when = 2.00;
        action.type = "End Block";
        action.offset = CFrame.new(0, 0, 0);
        action.hitbox = Vector3.new(200, 150, 190);
        action.name = "Ice Champion Windup Slash 2";
        action:push();

        return action    
end    
} 
end)();
tbl['LightningStream'] = (function() 
local function checkRangeFromPing(obj, rangeCheck, speed)
    if (not local_player.root_part) then return false end;

    local distance = (obj.Position - local_player.root_part.Position).Magnitude;

    distance = (obj.Position - local_player.root_part.Position).Magnitude;
    distance -= speed * (Latency:get_ping() / 1000);

    return distance <= rangeCheck, distance, Latency:get_ping() / speed
end;

return {
    ids = {
        "7761251007"
    },
    default_chance = 100,
    allow_block_input = false,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true, 
    allow_parry_to_block = false,

    run = function(action)
		local distance = self:distance();
		if (distance > 200) then return end;
		local ranAt = tick();
        
        
		repeat
			for _, v in next, workspace.Thrown:GetChildren() do
				if (v.Name == 'STREAMPART' and v:IsA('BasePart')) then
					local rocket: RocketPropulsion = v:FindFirstChild('RocketPropulsion');
					local rocketTarget = rocket and rocket.Target;
					if (rocketTarget ~= local_player.root_part) then continue end;
					if(not checkRangeFromPing(v, 22.5 + math.min(rocket.MaxSpeed / 3, 10), rocket.MaxSpeed)) then continue end;
					
                    action.when = 0.2;
                    action.offset = CFrame.new(0, 0, 0)
                    action.hitbox = Vector3.new(2500, 2500, 2500);
                    action.ignore_early_end = true;
                    action.ignore_hitbox = true;
                    action:push();
                    
					return action				
end;
			end;
			task.wait();
		until tick() - ranAt > 3.5;
        
        
        
        
        
        
		

        return action    
end    
} 
end)();
tbl['LightningStreamCast'] = (function() 
return {
    ids = {
        "5968796999"
    },
    default_chance = 100,
    allow_block_input = false,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true, 
    allow_parry_to_block = false,

    run = function(action)
        action.when = 0.5;
        action.ignore_early_end = true;
        action.offset = CFrame.new(0, 0, -7.5)
        action.hitbox = Vector3.new(0,0,15);
        action:push();

        return action    
end    
} 
end)();
tbl['LightningStreamPull'] = (function() 
local function checkRangeFromPing(obj, rangeCheck, speed)
    if (not local_player.root_part) then return false end;

    local distance = (obj.Position - local_player.root_part.Position).Magnitude;

    distance = (obj.Position - local_player.root_part.Position).Magnitude;
    distance -= speed * (Latency:get_ping() / 1000);

    return distance <= rangeCheck, distance, Latency:get_ping() / speed
end;

return {
    ids = {
        "7761286827"
    },
    default_chance = 100,
    allow_block_input = false,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true, 
    allow_parry_to_block = false,

    run = function(action)
		
		
        
        
        
        
        
        
        

        
        
        
        
        

        
        
        
        
        
        
        
        
        
        
        
        
        
        return action    
end    
} 
end)();
tbl['LionfishBeam'] = (function() 
return {
    ids = {
        "6372560712"
    },
    default_chance = 100,
    allow_block_input = false,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true, 
    allow_parry_to_block = false,

    run = function(action)
		local target = defender.entity:FindFirstChild('Target');
		target = target and target.Value;

		if (target ~= local_player.character) then return end;

		local wasUp = false;

		repeat
			local _, _, z = defender.entity:GetPivot():ToOrientation();

			if (z < -1.7 and not wasUp) then
				wasUp = true;
			elseif (z > -1.5 and wasUp) then
                action.when = math.min(0.1 - (Latency:get_ping() * 2));
                action.offset = CFrame.new(0, 0, 0)
                action.hitbox = Vector3.new(2500, 2500, 2500);
                action.ignore_hitbox = true;
                action.type = "Dodge";
                action:push();
				break			
end;

			task.wait();
		until not self:is_playing() or not defender.entity.Parent;

        return action    
end    
} 
end)();
tbl['LionfishTripleBite'] = (function() 
return {
    ids = {
        "5680585677"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        action.when = 0.45;
        action.type = "Parry";
        action.offset = CFrame.new(0, 0, 0);
        action.hitbox = Vector3.new(200, 150, 190);
        action.name = "Lionfish Triple Bite 1";
        action:push();

        action.when = 1.15;
        action.type = "Parry";
        action.offset = CFrame.new(0, 0, 0);
        action.hitbox = Vector3.new(200, 150, 190);
        action.name = "Lionfish Triple Bite 2";
        action:push();

        action.when = 1.85;
        action.type = "Parry";
        action.offset = CFrame.new(0, 0, 0);
        action.hitbox = Vector3.new(200, 150, 190);
        action.name = "Lionfish Triple Bite 3";
        action:push();

        return action    
end    
} 
end)();
tbl['LordsSlice'] = (function() 
return {
    ids = {
        "11328614766"
    },
    action_type = "M1", 
    default_chance = 100, 

    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = false,

    run = function(action)
        local distance = self:distance();
        action.when = math.min(0.375 + distance * 0.012)
        action.type = "Parry"
        action.hitbox = Vector3.new(100, 100, 100)
        action.name = string.format("(%.2f) ContractorPull", distance)
        
        return action:push()    
end    
} 
end)();
tbl['MetalBallModule'] = (function() 
return {
    ids = {
        "14953939237"
    },
    action_type = "Spell", 
    default_chance = 100, 

    allow_block_input = false,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = false,

    run = function(action)
        task.wait(0.5 - Latency:get_ping())
        local spikeBall = defender.entity:WaitForChild("SpikeBall2", 0.1) or defender.entity:WaitForChild("SpikeBall", 0.1)
    
        while task.wait() do
            if not spikeBall or not spikeBall.Parent then break end
            if self:distance() <= 29.5 then
		        action.when = 0
                action.hitbox = Vector3.one * (29.5 * 2);
                action.ignore_early_end = true;
                action.shape = "ball";
                action.name = "Metal Ball";
                action:push();
                break            
end
        end
        return action    
end    
} 
end)();
tbl['MirrorIllusion'] = (function() 
return {
    ids = {
        "87085678581483"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    action_type = "Spell", 

    run = function(action)
        action.when = 0.6;
        action.offset = CFrame.new(0, 0, 0)
        action.hitbox = Vector3.new(50, 50, 50);
        action.type = "Dodge"

        action:push();

        return action    
end    
} 
end)();
tbl['OxidizingRush'] = (function() 
return {
    ids = {
        "13567686046"
    },
    default_chance = 100,
    allow_block_input = true,   
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        local shoulds = 0;
        action.type = "RPUE Parry";
        action.when = math.max(0.2 + (self:distance() * 0.013));

        action.condition = function()
            return self:is_playing() and defender.entity.Parent and shoulds == 0        
end;

        action.wait = function()
            task.wait(Latency:get_ping() / 2);
        end

        action.should = function()
            local should = defender:in_hitbox(Vector3.new(25, 14, 15), CFrame.new(0,0,-7.5), false);
            if should then
                shoulds += 1;
            end
            return should        
end;

        action:push();

        return action    
end    
} 
end)();
tbl['PetrasCrit'] = (function() 
return {
    ids = {
        "12071557016"
    },
    default_chance = 100,
    allow_block_input = true,   
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        action.type = "Parry"
        action.offset = CFrame.new(0,0,-25);
        action.hitbox = Vector3.new(25, 25, 50)
        action.name = "Petras Crit"
        action.ignore_early_end = true;
        action.when = math.max(self:distance() * 0.02);
        action:push();

        return action    
end    
} 
end)();
tbl['PleetskysRunningCrit'] = (function() 
return {
    ids = { "18109641443" },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    ignore_early_end = false,
    action_type = "Critical",

    run = function(action)
        local hrp = defender.entity:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local distance = self:distance() or 0
        local sound = hrp:WaitForChild("REP_SOUND_15237686618", 0.1)
        if not sound then return end

        local when = distance <= 35 and 0.15 or 0.25

        action.when = when
        action.type = "Parry"
        action.ignore_hitbox = true
        action.name = string.format("Inferno Running Crit Far (%.1f dist, %.2f when)", distance, when)
        
        action:push()
        return action
    end
}
 end)();
tbl['PrimadonGrab'] = (function() 
return {
    ids = {
        "9225086332"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        local mob = defender.entity
        if not mob then return action end
        
        local hum = mob:FindFirstChild("Humanoid")
        if not hum then return action end
        
        local timingValue = 0.9
        
        action.when = timingValue
        action.type = "Dodge"
        action.offset = CFrame.new(0, 0, 0)
        action.hitbox = Vector3.new(110, 250, 110)
        action.name = "Primadon Grab"
        
        action:push()
        return action
    end    
}
 end)();
tbl['PrimadonKick'] = (function() 
return {
    ids = {
        "6438111139"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,

    run = function(action)
        local mob = defender.entity
        if not mob then return action end
        
        local hum = mob:FindFirstChild("Humanoid")
        if not hum then return action end
        
        local timingValue = mob.Name:match(".monkyking") and 0.6 or 0.9
    
        if hum.Health <= (hum.MaxHealth / 2) then
            timingValue = timingValue / 1.25
        end
        
        action.when = timingValue
        action.type = "Dodge"
        action.offset = CFrame.new(0, 0, 0)
        action.hitbox = Vector3.new(110, 250, 110)
        action.name = "Primadon Kick"
        
        action:push()
        return action
    end    
}
 end)();
tbl['PrimadonMidPunch'] = (function() 
return {
    ids = {
        "8365199156"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        local timingValue = (0.6 * 1.12)
        
        action.when = timingValue
        action.type = "Parry"
        action.offset = CFrame.new(0, 0, 0)
        action.hitbox = Vector3.new(110, 250, 110)
        action.name = "Primadon Mid Punch"
        
        action:push()
        return action
    end    
}
 end)();
tbl['PrimadonPunch'] = (function() 
return {
    ids = {
        "9225081967"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        local timingValue = (1.05 * 0.7) / track.Speed
        
        action.when = timingValue
        action.type = "Parry"
        action.offset = CFrame.new(0, 0, 0)
        action.hitbox = Vector3.new(80, 250, 120)
        action.name = "Primadon Punch"
        
        action:push()
        return action
    end    
}
 end)();
tbl['PrimadonStomp'] = (function() 
return {
    ids = { "9225098544" },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    ignore_hitbox_check = false,
    allow_parry_to_block = true,

    run = function(action)
        local mob = defender.entity
        if not mob then return end

        local hum = mob:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        local hitbox = Vector3.new(50, 250, 50)
        if mob.Name:match(".monkyking") then
            hitbox = Vector3.new(80, 250, 80)
        end

        local when = ((750 * 1.21) / track.Speed) / 1000
        if hum.Health <= (hum.MaxHealth / 2) then
            when = when / 1.21
        end

        action.when = when
        action.type = "Parry"
        action.hitbox = hitbox
        action.name = "Primadon Stomp"

        action:push()
        return action
    end
}
 end)();
tbl['PrimadonTripleStomp'] = (function() 
return {
    ids = {
        "6432260013"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        local mob = defender.entity
        if not mob then return action end
        
        local hum = mob:FindFirstChild("Humanoid")
        if not hum then return action end
        
        local baseTimings = {0.8, 1.4, 2.05}
        
	    if mob.Name:match(".monkyking") and track.Speed >= 1.5 and track.Speed <= 1.7 then
	    	baseTimings = {
	    		[1] = 0.6,
	    		[2] = 1,
	    		[3] = 1.4,
	    	}
	    end
    
	    if mob.Name:match(".monkyking") and track.Speed >= 1.7 and track.Speed <= 2.15 then
	    	baseTimings = {
	    		[1] = 0.5,
	    		[2] = 0.9,
	    		[3] = 1.4,
	    	}
	    end

        local multiplier = 1.0
        if hum.Health <= (hum.MaxHealth / 2) then
            multiplier = 1.25
        end
        
        for i = 1, 3 do
            local timingValue = baseTimings[i] / multiplier
            
            action.when = timingValue
            action.type = "Parry"
            action.offset = CFrame.new(0, 0, 0)
            action.hitbox = Vector3.new(110, 250, 110)
            action.name = string.format("Primadon Triple Stomp %d", i)
            action:push()
        end
        
        return action
    end    
}
 end)();
tbl['ProminenceDraw'] = (function() 
return {
    ids = {
        "12706574441"
    },
    default_chance = 100,
    allow_block_input = true,   
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        action.type = "Parry"
        action.offset = CFrame.new(0,0,0);
        action.hitbox = Vector3.new(100, 100, 100)
        action.name = "Prominence Draw"
        action.when = math.max(0.33 + (self:distance() * (4 / 1000)));
        action:push();
        
        return action    
end    
} 
end)();
tbl['PutridEdenstaff'] = (function() 
return {
    ids = {
        "15250125394"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    action_type = "Critical", 

    run = function(action)
        action.when = 0.775;
        action.offset = CFrame.new(0, 0, 0)
        action.hitbox = Vector3.new(25, 25, 25);
        action.type = "Parry"

        action:push();

        return action    
end    
} 
end)();
tbl['RandomHeavyRunningAttack'] = (function() 

return {
    ids = { "5067090007" },
    action_type = "M1",
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,

    run = function(action)
        if not weapon.type or not weapon.length then return end

        local hrp = defender.entity:FindFirstChild("HumanoidRootPart")
        local vel = hrp and Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z).Magnitude or 0

        if vel >= 8 then
            
            action.hitbox = Vector3.new(weapon.length * 2.65, weapon.length * 3, weapon.length * 2.8)
            action.offset = CFrame.new(0, 0, -5)
            action.base_and_predict = true
            action.predict = true

            local windup = 0
            if weapon.type == "Greataxe" then
                windup = (0.150 / track.Speed) + 0.100
                windup += 0.100 / weapon.ss
            elseif weapon.type == "Greathammer" then
                windup = (0.160 / track.Speed) + 0.180
                windup += 0.100 / weapon.ss
                action.hitbox = Vector3.new(weapon.length * 2.65, weapon.length * 3, weapon.length * 4)
            end

            action.name = string.format("Running Attack - %0.2f, %0.2f, %s", windup, weapon.length, weapon.type)
            action.when = windup
            action:push()
        else
            
            action.base_and_predict = true
            action.predict = true

            local hitbox = Vector3.new(weapon.length * 2.65, weapon.length * 3, weapon.length * 2.8)
            local windup = 0

            if weapon.type == "Greataxe" and track.Speed ~= 1.0 then
                windup = (0.171 / track.Speed) + 0.120
            elseif weapon.type == "Greataxe" and track.Speed == 1.0 then
                windup = (0.171 / track.Speed)
                windup += 0.250 / (weapon.ss * (has_heavy_hands(defender.entity) and 0.9 or 1))
            elseif weapon.type == "Greathammer" and track.Speed ~= 1.0 then
                windup = (0.150 / track.Speed) + 0.150
            elseif weapon.type == "Greathammer" and track.Speed == 1.0 then
                windup = (0.150 / track.Speed)
                windup += 0.250 / weapon.ss
            end

            action.name = string.format("%s M1 - %0.2f, %0.1f", weapon.type, windup * 2.351, weapon.length)
            action.when = windup
            action.offset = CFrame.new(0, 0, -5)
            action.hitbox = hitbox
            action:push()
        end

        return action
    end
}
 end)();
tbl['RapidPunches'] = (function() 
return {
    ids = {
        "8150828674"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true, 
    allow_parry_to_block = false,

    run = function(action)
        if defender.entity:FindFirstChild("HumanoidRootPart") and defender.entity:FindFirstChild("HumanoidRootPart"):WaitForChild("REP_SOUND_6323221579", 0.1) then
            action.when = 0.425;
            action.name = "Radiant Kick"
            action.offset = CFrame.new(0, 0, 0)
            action.hitbox = Vector3.new(100, 100, 100);
            action.ignore_early_end = true;
            action.type = "Parry";
            action:push();
            return action        
end;

        action.when = 0.2;
        action.offset = CFrame.new(0, 0, 0)
        action.hitbox = Vector3.new(16, 10, 12);
        action.type = "Parry";
        action.ignore_feints = true;
        action.name = "Rapid Punches";
        action:push();
        return action    
end    
} 
end)();
tbl['RapidPunchesLoop'] = (function() 
return {
    ids = {
        "8150846354"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true, 
    allow_parry_to_block = false,

    run = function(action)
        action.when = 0.1;
        action.offset = CFrame.new(0, 0, -3)
        action.hitbox = Vector3.new(16, 10, 12);
        action.type = "RPUE Parry";
        action.condition = function()
            return self:is_playing() and defender.entity.Parent        
end;
        
        action.wait = function()
            task.wait(Latency:get_ping() / 2);
        end 

        action.should = function()
            return defender:in_hitbox(Vector3.new(16, 10, 12), CFrame.new(0, 0, -3), false)        
end;
        action.ignore_feints = true;
        action.name = "Rapid Punches Loop";
        action:push();
        return action    
end    
} 
end)();
tbl['RecallCrimsonRain'] = (function() 
return {
    ids = {
        "73745318478429"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        local item = thrown:WaitForChild("BloodDagger_"..defender.entity.Name, 5);
        if not item then return end;
        while task.wait() do
            local found = false;
            for _, item in thrown:GetChildren() do
                if item.Name == "BloodDagger_"..defender.entity.Name then
                    if general:in_hitbox(local_player.root_part.CFrame, item.CFrame, Vector3.new(25, 10, 35 + (80 * Latency:get_ping())), CFrame.new(0, 0, 25), true) then

                        action.when = 0;
		                action.type = "Parry" 
                        action.ignore_hitbox = true;
                        action.ignore_early_end = true;
		                action.name = string.format("CrimsonRainRecall (%.2f)", self:distance())
                        action:push();
                        return action                    
end
                    found = true;
                end 
            end

            if not found then break end
        end

        return action    
end    
} 
end)();
tbl['Revenge'] = (function() 
return {
  ids = {
      "8066909599"
  },
  default_chance = 100,
  allow_block_input = true,
  allow_parry_to_roll = true,
  allow_roll_to_parry = true,
  allow_parry_to_block = true,
  action_type = "Spell", 

  run = function(action)
	  local data = mantra.data(defender.entity, "Mantra:RevengeAgility{{Revenge}}")
	  local range = data.rush * 12 + data.drift * 6

    action.when = 0.4;
    action.offset = CFrame.new(0, 0, 0)
    action.hitbox = Vector3.new(20, 20, 30 + range)
    action.half_size_offset = true;

    action:push();

    return action  
end    
} 
end)();
tbl['RisingShadow'] = (function() 
return {
    ids = {
        "9149348937"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true, 
    allow_parry_to_block = false,

    run = function(action)
        action.when = 0.4;
        action.offset = CFrame.new(0, 0, 0);
        action.hitbox = Vector3.new(10, 10, 10);
        action.type = "Parry";
        action.ignore_feints = true;
        action.no_more_actions = true;
        action.name = "Rising Shadow";
        action:push();
        action.when = 0.6;
        action.offset = CFrame.new(0, 0, 0);
        action.hitbox = Vector3.new(15, 15, 15);
        action.type = "Parry";
        action.ignore_feints = true;
        action.no_more_actions = true;
        action.name = "Rising Shadow";
        action:push();
        action.when = 0.9;
        action.offset = CFrame.new(0, 0, 0);
        action.hitbox = Vector3.new(18, 18, 18);
        action.type = "Parry";
        action.ignore_feints = true;
        action.name = "Rising Shadow";
        action:push();
        return action    
end    
} 
end)();
tbl['RisingThunder'] = (function() 
return {
    ids = { "15214200859" },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    ignore_early_end = false,

    run = function(action)
        local distance = self:distance() or 0
        
        local parryTime = 0.35  
        
        if distance >= 40 then
            parryTime = 0.60
        elseif distance >= 30 then
            parryTime = 0.60
        elseif distance >= 20 then
            parryTime = 0.60
        elseif distance >= 10 then
            parryTime = 0.57
        elseif distance >= 6 then
            parryTime = 0.35
        end
        
        action.when = parryTime
        action.type = "Parry"
        action.hitbox = Vector3.new(20.5, 13, 45.5)
        action.offset = CFrame.new(0, 0, -10)
        action.name = string.format("Rising Thunder (%.2f dist, %.2f time)", distance, parryTime)
        action:push()

        return action
    end
}
 end)();
tbl['RisingThunderEnd'] = (function() 
return {
    ids = {
        "12333759044"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    

    run = function(action) 
        task.wait(0.9);
        if defender.entity:GetPivot().Y < local_player.root_part.CFrame.Y + 10 then return end

        action.when = 1.1 - 0.9;
        action.ignore_early_end = true;
        action.type = "Start Block"
        action.hitbox = Vector3.new(30, 100, 40) 
        action:push()
        return action    
end    
} 
end)();
tbl['RockmallerCrit'] = (function() 
return {
    ids = {
        "85298007288557"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    action_type = "Critical", 

    run = function(action)
        action.when = 0.425;
        action.offset = CFrame.new(0, 0, 0)
        action.hitbox = Vector3.new(22, 12, 25);

        action:push();

        return action    
end    
} 
end)();
tbl['ShadowAssault'] = (function() 
return {
    ids = {
        "6318273143"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    action_type = "Spell", 

    run = function(action)

        
        
    
        action.when = self:distance() <= 18 and 0.6 or math.min(600 + self:distance() * 4) / 1000;
        action.hitbox = Vector3.new(40, 40, 40)
        action.offset = CFrame.new(0,0,-20);
        action.name = string.format("(%.2f) Shadow Assault", self:distance());
        action:push();
        return action    
end    
} 
end)();
tbl['ShadowEruption-Generic'] = (function() 
return {
    ids = {
        "8018953639"
    },
    default_chance = 100, 

    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = false,

    run = function(action)
	    local distance = self:distance()
	    local data = mantra.data(defender.entity, "Mantra:EruptionShadow{{Shadow Eruption}}")
	    local dataTwo = mantra.data(defender.entity, "Mantra:RestraintShadow{{Shadow Chains}}")
	    local size = data.stratus * 5.5 + data.cloud * 4.5
	    local range = dataTwo.perfect * 8 + dataTwo.crystal * 6
		local root = defender.entity:FindFirstChild("HumanoidRootPart")
		if not root then
			return print("..?")
		end
			
	    if root:FindFirstChild("REP_SOUND_5188185503") then
	    	
	    	
	    	
	    	

        	task.wait(0.6 - Latency:get_ping());

			local chain_portal_ice do
        	    for _, chain_portal in workspace.Thrown:GetChildren() do
        	        if chain_portal.Name ~= "ChainPortalIce" then
        	            continue        	        
end

        	        if (chain_portal.Position - local_player.root_part.Position).Magnitude > 20 then
        	            continue        	        
end

        	        chain_portal_ice = chain_portal;
        	    end;
        	end;
        	if not chain_portal_ice then return end
        	chain_portal_ice:WaitForChild("Beam");
        	repeat task.wait() until chain_portal_ice.Beam.Enabled;
        	action.when = 0.5;
        	action.ignore_early_end = true;
        	action.hitbox = Vector3.new(50, 50, 50);
        	action.offset = CFrame.new(0, 0, 0)
        	action.ignore_hitbox = true;

        	action:push();
	    elseif thrown:FindFirstChild("ChainPortalShadow") then
	    	action.when = math.min(0.200 + distance * 0.006)
	    	action.hitbox = Vector3.new(55 + range, 55 + range, 55 + range)
	    	action.name = "Shadow Chains"
	    else
	    	action.when = 0
	    	action.hitbox = Vector3.new(35 + size, 35 + size, 35 + size)
	    	action.name = "Shadow Eruption"
	    end

		action:push();

        return action    
end    
} 
end)();
tbl['ShadowMeteors'] = (function() 
return {
    ids = {
        "6701095669"
    },
    default_chance = 100,
    allow_block_input = false,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    

    run = function(action)
        local start = tick();
        local has_ice_dagger = true;
        local a = {};
        while tick() - start < 2 or has_ice_dagger do
            has_ice_dagger = false;
            for _, child in workspace.Thrown:GetChildren() do
                if child.Name ~= "ImpactIndicator" or a[child] then continue end
                has_ice_dagger = true;
                a[child] = true;

                task.wait(0.5 - Latency:get_ping());
                if general:in_hitbox(local_player.root_part.CFrame, child.CFrame, child.Size + Vector3.new(25,30,25), CFrame.new(0,0,0), true) then
                    action.type = "Parry";  
                    action.when = 0;
                    action.name = string.format("%.2f Shadow Meteor", (child.Position - local_player.root_part.Position).Magnitude);
                    action.ignore_hitbox = true;
                    action.ignore_early_end = true;
                    action:play()
                end;
            end;
            task.wait();
        end;

        action.actions = {};
        return action    
end    
} 
end)();
tbl['ShadowRoar'] = (function() 
return {
    ids = {
        "7620630583"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    

    run = function(action)
    
        
        
        
        
        
        action.when = 0.45;
        action.ignore_early_end = true;
        action.offset = CFrame.new(0,0,-20);
        action.hitbox = Vector3.new(30, 30, 30);
        action.type = "RPUE Parry";
        action.condition = function()
            return (workspace.Thrown:FindFirstChild("RoarParticles") or self:is_playing()) and defender.entity.Parent        
end;

        action.wait = function()
            task.wait(Latency:get_ping() / 2);
        end

        action.should = function()
            return defender:in_hitbox(Vector3.new(30, 30, 30), CFrame.new(0,0,-15), true)        
end;
        action:push();

        return action    
end    
} 
end)();
tbl['SharkoCero'] = (function() 
return {
    ids = {
        "91389074160755"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        repeat
            task.wait()
        until track.TimePosition >= 2.85
    
        action.when = 0
        action.type = "Dodge"
        action.hitbox = Vector3.new(50, 65, 145)
        action.name = string.format("(%.2f) Sharko Cero", track.Speed)
        action:push();

        return action    
end    
} 
end)();
tbl['SilentheartHeavyRising'] = (function() 
return {
    ids = { "139465383955578" },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,

    run = function(action)
        action.when = track.Speed <= 1.1 and 0.5 or 0.4
        action.type = "Parry"
        action.hitbox = Vector3.new(40, 40, 40)
        action.name = ("Silentheart Heavy Rising Star")
        action:push()

        return action
    end
}
 end)();
tbl['SilentheartMayhemHeavy'] = (function() 
return {
    ids = {
        "81062541535552"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    

    run = function(action)

        repeat
            task.wait()
        until track.TimePosition >= 0.615
    
        action.type = "Parry"
        action.name = "Silentheart Mayhem Heavy"
        action.hitbox = Vector3.new(30, 50, 30);
        action:push()
        return action    
end    
} 
end)();
tbl['SilentheartMayhemLight'] = (function() 
return {
    ids = { "85523657178401" },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    ignore_early_end = false,

    run = function(action)
        local distance = self:distance() or 0
        local speed = track.Speed
        local when

        if speed >= 0.7 then
            when = 0.15
        else
            when = 0.18
        end

        if distance >= 10 then
            when = when + 0.03
        end

        if distance >= 20 then
            when = when + 0.04
        end

        if distance >= 40 then
            when = when + 0.45
        end

        when = math.clamp(when, 0.15, 0.80)

        action.when = when
        action.type = "Parry"
        action.hitbox = Vector3.new(20, 40, 40)
        action.offset = CFrame.new(0, 0, -20)
        action.name = string.format("(speed:%.2f dist:%.2f when:%.3f) Light Mayhem Silentheart", speed, distance, when)

        action:push()
        return action
    end
}
 end)();
tbl['SilentheartMayhemMedium'] = (function() 
return {
    ids = { "132164383275060" },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    ignore_early_end = false,

    run = function(action)
        local distance = self:distance() or 0
        local speed = track.Speed
        local when = 0.45

        if speed >= 0.7 then
            when = 0.40
        end

        if distance >= 10 then
            when = when + 0.025
        end

        if distance >= 20 then
            when = when + 0.025
        end

        action.when = when
        action.type = "Parry"
        action.offset = CFrame.new(0,0,-20)
        action.hitbox = Vector3.new(20, 15, 45)
        action.name = "Silentheart Medium Mayhem"

        action:push()
        return action
    end
}
 end)();
tbl['SoulflareSiphon'] = (function() 
return {
    ids = {
        "14428696078"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    

    run = function(action)
        action.when = math.max(0.3 + (self:distance() * 0.013));
        action.offset = CFrame.new(0,0,-7.5);
        action.hitbox = Vector3.new(20, 30, 16);
        action.type = "Parry"
        action.name = string.format("Soulflare Siphon %.2f %.2f", self:distance(), track.Speed)
        action:push()


        return action    
end    
} 
end)();
tbl['SquidwardEruption'] = (function() 
return {
    ids = {
        "6922310516"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    

    run = function(action)
        local distance = self:distance()
        local speed = track.Speed;
        local low_speed_variant = speed >= 0.2 and speed <= 0.3;

        action.when_ms = low_speed_variant and 975 or 450 + (distance * 4)
        action.type = low_speed_variant and "Jump" or "Dodge"
        action.hitbox = Vector3.new(40, 40, 50)
        action.name = string.format("(%.2f) (%.2f) Squidward Eruption", distance, track.Speed)
        action:push()

        return action    
end    
} 
end)();
tbl['StoneKnightSlash'] = (function() 
return {
    ids = {
        "85401018793125"
    },
    action_type = "Spell", 
    default_chance = 100, 

    allow_block_input = false,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = false,

    run = function(action)
        task.wait(0.6 - Latency:get_ping());

        action.name = "Stone Knight Slash";
        action.when = 0;
        action.offset = CFrame.new(0, 0, -15)
        action.hitbox = Vector3.new(15,20,30);
                
        action:push();

        if general:in_hitbox(local_player.root_part.CFrame, defender.entity.HumanoidRootPart.CFrame, Vector3.new(15,20,35), CFrame.new(0, 0, -10), false) then return action end

        local has_javelin = false;
        local start = tick();

        while tick() - start < 1 or has_javelin do
            has_javelin = false;
            for _, object in workspace:WaitForChild("Thrown"):GetChildren() do
                if object.Name ~= "WindSlashProjectileBigSnow" then continue end

                has_javelin = true;
                if general:in_hitbox(local_player.root_part.CFrame, object.CFrame, Vector3.new(10, 10, 80), CFrame.new(0, 0, -40), false) then 
                    action.name = "Stone Knight Slash";
                    action.when = 0;
                    action.offset = CFrame.new(0, 0, -15)
                    action.ignore_hitbox = true;
                    action.ignore_early_end = true;

                    action:push();
                
                    return action                
end
            end;
            task.wait();
        end;

        return action    
end    
} 
end)();
tbl['StrongLeft'] = (function() 
return {
    ids = {
        "8085349676"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    

    run = function(action)
        action.when = 0.5
        action.hitbox = Vector3.new(23, 15, 25);
        action.type = "Parry"
        action.name = string.format("Strong Left %.2f %.2f", self:distance(), track.Speed)
        
	    if defender.entity.Name:match(".theduke") then
            action.ignore_hitbox = true;
	    end;

        action:push()


        return action    
end    
} 
end)();
tbl['Taunt'] = (function() 
return {
    ids = {
        "8198764550"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    

    run = function(action) 
        local allowed = false;
        local conn = defender.entity.DescendantAdded:Connect(function(item)
            if item.Name ~= "REP_SOUND_4953084421" then return end
            allowed = true;
        end);
        local wait_amount = 0.5 - Latency:get_ping();
        task.wait(wait_amount);
        conn:Disconnect();
        if not allowed then return end
        action.type = "Parry";
        action.when = 0;
        action.hitbox = Vector3.new(15, 30, 20);
        action.offset = CFrame.new(0,0,-10);
        action.ignore_early_end = true;
        action:push()

        return action    
end    
} 
end)();
tbl['ThresherBite'] = (function() 
return {
    ids = {
        "8226933122"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true, 
    allow_parry_to_block = false,

    run = function(action)
        action.when = 0.4;
        action.offset = CFrame.new(0, 0, 0)
        action.hitbox = Vector3.new(40, 30, 40);
                
        action:push();

        action.when = 0.45 * 2;
        action.offset = CFrame.new(0, 0, 0)
        action.hitbox = Vector3.new(40, 30, 40);
                
        action:push();

        action.when = 1.45;
        action.offset = CFrame.new(0, 0, 0)
        action.hitbox = Vector3.new(40, 30, 40);
                
        action:push();

        return action    
end    
} 
end)();
tbl['TitusLariat'] = (function() 
return {
    ids = {
    "93803643628347"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    ignore_hitbox_check = false,
    ignore_early_end = false,

    run = function(action)
        local distance = self:distance();
        local mob = defender.entity
        if not mob then
            action:push();
            return action        
end
        
        if mob.Name:match(".titus") then

            action.when = 0.7;
            action.offset = CFrame.new(0, 0, -20);
            action.hitbox = Vector3.new(20, 50, 40);
            action.type = "Dodge";
            action.name = "TitusLariat";
        else
            if distance > 15 then
                action.when = 0.7;
            else
                action.when = 0.4;
            end
            action.offset = CFrame.new(0, 0, -20);
            action.hitbox = Vector3.new(10, 10, 30);
            action.type = "Parry";
            action.name = "SovereignLariat";
        end
        
        action:push();
        return action    
end    
} 
end)();
tbl['TitusSkycrash'] = (function() 
return {
    ids = {
    "118932415770119"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    ignore_hitbox_check = false,
    ignore_early_end = false,

    run = function(action)
        local mob = defender.entity
        if not mob then
            action:push();
            return action        
end
        
        if mob.Name:match(".titus") then

action.hitbox = Vector3.new(0,0,0);
action.offset = CFrame.new(0,0,0);
action.when = 1;
action.type = "";
action:push();
action.delay_until_in_hitbox = false;
action.hitbox = Vector3.new(210,100,130);
action.offset = CFrame.new(0,0,0);
action.when = 1.3;
            action.type = "Dodge";
            action.name = "TitusSkycrash";
        else

            action.when = 0.1;
            action.offset = CFrame.new(0, 0, -20);
            action.hitbox = Vector3.new(10, 10, 30);
            action.type = "Parry";
            action.name = "SovereignSkycrash";
        end
        
        action:push();
        return action    
end    
} 
end)();
tbl['TitusThrow'] = (function() 
return {
    ids = {
        "128613582420698"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    ignore_hitbox_check = false,
    ignore_early_end = false,

    run = function(action)
        local mob = defender.entity if not mob then
            action:push();
            return action        
end
        
        if mob.Name:match(".titus") then

            action.when = 0.45;
            action.offset = CFrame.new(0, 0, 0);
            action.hitbox = Vector3.new(34, 34, 34);
            action.type = "Dodge";
            action.name = "TitusThrow";
        else

            action.when = 0.45;
            action.offset = CFrame.new(0, 0, 0);
            action.hitbox = Vector3.new(34, 34, 34);
            action.type = "Parry";
            action.name = "TitusThrow";
        end
        
        action:push();
        return action    
end    
} 
end)();
tbl['TwisterKicks'] = (function() 
return {
    ids = {
        "16394277950"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        
        task.wait(0.3 - Latency:get_ping())

        local start = tick();
        while self:is_playing() and tick() - start < 0.5 do            
            if defender:in_hitbox(Vector3.new(15,15,21), CFrame.new(0,0,0), true, true, 0, true, true) then

           		action.ignore_early_end = true;
           		action.name = "Twister Kicks"
           		action.when = 0;
           		action.type = "Parry"
           		action.ignore_hitbox = true;
                action.detect_gale_feint = true;

           		action:push();
                return action            
end;
            
            task.wait(1 / 30);
        end;

        return action    
end    
} 
end)();
tbl['WardensBlade'] = (function() 
return {
    ids = {
        "5786525661"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        action.when = 0.4;
        action.offset = CFrame.new();
        action.hitbox = Vector3.new(300, 300, 300)
        action.type = "RPUE Parry";
        action.ignore_early_end = true;
        action.condition = function()
            local center = defender.entity:FindFirstChild("IceBladeCenter")
            if not center then
                return
            end
    
            if not center:FindFirstChild("IceSword") then
                return
            end

            return defender.entity.Parent        
end;

        action.wait = function()
            task.wait(0.15 - (Latency:get_ping() / 2));
        end

        action.should = function()
            return self:distance() <= 10
        end;

        action:push();

        return action    
end    
} 
end)();
tbl['WindCarve'] = (function() 
return {
    ids = {
        "6466993564"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,

    run = function(action)
        action.type = "Parry"
        action.when = 0.4;

        action.offset = CFrame.new(0,0,-7.5);
        action.hitbox = Vector3.new(20, 20, 30) 
        action:push()
        return action    
end    
} 
end)();
tbl['WindGun'] = (function() 
return {
    ids = {
        "8310877920"
    },
    default_chance = 100,
    allow_block_input = true,
    allow_parry_to_roll = true,
    allow_roll_to_parry = true,
    allow_parry_to_block = true,
    

    run = function(action)
        local distance = self:distance()
        action.when = 0.4
    
        if distance >= 20 then
            action.when = 0.55
        end
    
        action.type = "Parry"
        action.name = string.format("%.2f Wind Gun", distance)
        action.hitbox = Vector3.new(30, 20, 40) 
        action:push()
        return action    
end    
} 
end)();
return tbl