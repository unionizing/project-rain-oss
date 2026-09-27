return function()
    repeat 
        KeyHandler:get_key("FallDamage"):FireServer(100, false);
        task.wait(0.35) 
    until EffectReplicator:FindEffect("Knocked");
end