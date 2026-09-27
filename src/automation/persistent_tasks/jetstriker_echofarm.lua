local automation_struct = require("@src/automation/struct");

local echofarm = {
    has_reqs = function()
    end,
    has_oath = function()
    end,
    kill_slot = function(slot)
    end
}

function echofarm:handle_cc()
end




--[[
return automation_struct:construct({
    persistent_data_store = 'jetstriker_echofarm_store',
    persistent_data_flag = 'jetstriker_echofarm',
    id = 'jetstriker_echofarm',
    
    state_machine = StateMachine.create({
        initial = "idle",
        events = {
            -- Check area
            --- Depths = Main Menu Kill Self
            --- Eastern = Main Menu Kill Self
            --- Etrean = No oaths, jetstriker reqs (Get Jetstriker) | Oath or no jetstriker reqs (Kill Self)
            --- Main menu = No slot saved (End farm) | Slot saved (Kill saved slot)

            {name = 'start', from = 'idle', to = '_check_area'},

            {name = 'depths', from = '_check_area', to = '_kill_self'},
            {name = 'main_menu', from = '_check_area', to = '_kill_self'},
            {name = 'eastern', from = '_check_area', to = '_kill_self'},
            {name = 'etrean_die', from = '_check_area', to = '_kill_self'},

            {name = 'character_creation', from = '_check_area', to = '_create_character'},
            {name = 'handle_trial', from = '_check_area', to = '_trial_handler'},
            {name = 'etrean_live', from = '_check_area', to = '_obtain_jetstriker'},

            {name = 'end_farm', from = '_check_area', to = 'idle'},
            {name = 'end_farm', from = '_kill_self', to = 'idle'},
            {name = 'end_farm', from = '_create_character', to = 'idle'},
            {name = 'end_farm', from = '_trial_handler', to = 'idle'},
            {name = 'end_farm', from = '_obtain_jetstriker', to = 'idle'}
        },
        callbacks = {
            onenter_check_area = function(self)
                local is_mainmenu = false
                local is_character_creation = false
                local is_trial = false

                if is_eastern then self:eastern(); return; end
                if is_depths then self:depths(); return; end


                if is_etrean and echofarm.has_reqs() and not echofarm.has_oath() then 
                    self:etrean_live(); 
                    return; 
                else self:etrean_die(); return; end

                if is_mainmenu then self:main_menu(); return; end
                if is_character_creation then self:character_creation(); return; end
            end,
        },
    }),
    features = {
        "no_fall",
        "noclip",
        "fly",
        "no_fire",
        "no_stun",
        "fast_swing",
        "auto_equip_weapon"
    },

    not_allowed = function()
        return false; --todo
    end,

    character_creator_handler_used = false,
    character_creator_handler_opts = {
    }
})
    ]]--