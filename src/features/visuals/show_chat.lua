local feature = Feature:new("show_chat");

function feature:disable()
    local chatWindowConfiguration = game:GetService("TextChatService").ChatWindowConfiguration;

    chatWindowConfiguration.Enabled = false;
end;

function feature:enable()
	local chatWindowConfiguration = game:GetService("TextChatService").ChatWindowConfiguration;

	chatWindowConfiguration.Enabled = true;
end;

return feature