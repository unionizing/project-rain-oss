local signal = require("@src/utility/signal")

local actionCreator = {} do
    function actionCreator.new(opts)
        opts = opts or {}

        local self
        self = setmetatable({}, {
            __index = actionCreator,
            __newindex = function(_, k, v)
                if k == "actions" or k == "pending_action" or k == "signal" or k == "_signal_enabled" or k == "cancelled" then
                    rawset(self, k, v)
                    return
                elseif k == "when_ms" then
                    rawset(self, "when", v / 1000);
                    return                
end
                self.pending_action[k] = v
            end
        })

        self.actions = {}
        self.pending_action = {}
        self.signal = signal.new()
        self._signal_enabled = opts.signal == true
        self.cancelled = false;

        return self
    end

    function actionCreator:enable_signal(b)
        self._signal_enabled = b == true
        return self
    end

    function actionCreator:get_signal()
        return self.signal
    end

    
    function actionCreator:play()
        local id = #self.actions + 1
        self.actions[id] = self.pending_action
        self.pending_action = {}

        if self._signal_enabled then
            self:get_signal():fire(id)
        end

        return self
    end

    
    function actionCreator:push()
        table.insert(self.actions, self.pending_action)
        self.pending_action = {}
        return self
    end

    function actionCreator:get()
        return self.actions
    end
end

return actionCreator