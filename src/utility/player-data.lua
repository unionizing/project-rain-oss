
local signal = require("@src/utility/signal")
local maid = require("@src/utility/maid")

local player_data = {} do
    player_data.__index = player_data

    function player_data.new()
        local self = setmetatable({}, player_data)

        self.instance = services.Players.LocalPlayer
        task.spawn(pcall, function() 
            self.character = self.instance.Character or self.instance.CharacterAdded:Wait()
        end);
        self.character_added = signal.new()
        self.root_added = signal.new()
        self.hum_added = signal.new()
        self.data_maid = maid.new()
        self.tracker = require("@src/utility/deepwoken/action_tracker").new(self);

        self.player_gui = self.instance:FindFirstChild("PlayerGui");
        self.ui_items = {}; 
        aztup.maid:give_task(self.instance.ChildAdded:Connect(function(child)
            if child.Name == "PlayerGui" then
                self.player_gui = child;
                self.ui_items = {};
            end;
        end));

        
        aztup.maid:give_task(self.data_maid)

        
        local function bind_character(character)
            
            self.data_maid:do_cleaning()

            self.character = character
            self.root_part = nil
            self.humanoid = nil

            self.character_added:fire(character)

            
            self.data_maid:give_task(character.ChildAdded:Connect(function(part)
                if part.Name == "HumanoidRootPart" then
                    self.root_part = part
                    self.root_added:fire(part)
                elseif part.Name == "Humanoid" then
                    self.humanoid = part
                    self.hum_added:fire(part)
                end
            end))

            
            self.root_part = character:FindFirstChild("HumanoidRootPart")
            self.humanoid = character:FindFirstChild("Humanoid")

            if self.root_part then
                self.root_added:fire(self.root_part)
            end
            if self.humanoid then
                self.hum_added:fire(self.humanoid)
            end
        end

        
        aztup.maid:give_task(self.instance.CharacterAdded:Connect(bind_character))

        
        if self.character then
            bind_character(self.character)
        end

        return self
    end
end

return player_data.new()