return function()
    KeyHandler:get_key("FallDamage"):FireServer((local_player.humanoid.Health + local_player.humanoid.MaxHealth) * 2, false);
end