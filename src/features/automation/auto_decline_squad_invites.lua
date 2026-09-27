local feature = Feature:new("auto_decline_squad_invites", local_player.instance.PlayerGui.ChildAdded, LPH_NO_VIRTUALIZE(function(item)
    if item.Name == "ChoicePrompt" then
        local title = item:FindFirstChild("Title", true);
        local desc = item:FindFirstChild("Desc", true);

        if title and title.Text:find("Squad Invitation") then
            if desc then
                Logger:notify("Declined a squad invitation from '" .. desc.Text:split("join ")[2]:split("'s")[1]:sub(1) .. "'")
            end; 

            item.Choice:FireServer(false);
            item.Enabled = false;
        end;
    end;
end)) 

return feature