local action = require("@src/features/auto-parry/data/action")


return {
    new = function()
        return action.new({ signal = true })
    end,
}