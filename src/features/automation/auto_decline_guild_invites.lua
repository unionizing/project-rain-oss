local feature = Feature:new("auto_decline_guild_invites", local_player.instance.PlayerGui.ChildAdded, LPH_NO_VIRTUALIZE(function(item)
    if item.Name == "ChoicePrompt" then
        local title = item:FindFirstChild("Title", true);

        if title and title.Text:find("Join Guild") then
            Logger:long_notify("A user has attempted to invite you to a guild. Declining.")
            item.Choice:FireServer(false);
            item.Enabled = false;
        end;
    end;
end)) 

return feature