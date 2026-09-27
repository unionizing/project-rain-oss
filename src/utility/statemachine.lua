
    

local StateMachine = {}
StateMachine.__index = StateMachine


local NONE = "none"
local ASYNC = "async"


local function callHandler(handler, params)
	if not handler then
		return
	end

	return handler(unpack(params))
end

local function createTransition(name)
    local can, to, from, params

    local function transition(self, ...)
        if self.asyncState == NONE then
            can, to = self:can(name)
            from = self.current
            params = { self, name, from, to, ... }

            if not can then
                self.currentTransitioningEvent = nil
                return false
            end

            self.currentTransitioningEvent = name
            local beforeReturn = callHandler(self["onbefore" .. name], params)
            local leaveReturn = callHandler(self["onleave" .. from], params)

            if not self["onleave" .. from] and self.dexit then
                leaveReturn = self.dexit()
            end

            if beforeReturn == false or leaveReturn == false then
                self.currentTransitioningEvent = nil
                return false
            end

            self.asyncState = name .. "WaitingOnLeave"

            if leaveReturn ~= ASYNC then
                return transition(self, ...)
            end

            return true
        elseif self.asyncState == name .. "WaitingOnLeave" then
            self.current = to

            local enterReturn = callHandler(self["onenter" .. to] or self["on" .. to], params)

            self.asyncState = name .. "WaitingOnEnter"

            if enterReturn ~= ASYNC then
                return transition(self, ...)
            end

            return true
        elseif self.asyncState == name .. "WaitingOnEnter" then
            callHandler(self["onafter" .. name] or self["on" .. name], params)
            callHandler(self["onstatechange"], params)
            self.asyncState = NONE
            self.currentTransitioningEvent = nil
            return true
        else
            if string.find(self.asyncState, "WaitingOnLeave") or string.find(self.asyncState, "WaitingOnEnter") then
                self.asyncState = NONE
                return transition(self, ...)
            end
        end

        self.currentTransitioningEvent = nil
        return false
    end

    return transition
end

local function addToMap(map, event)
	if type(event.from) == "string" then
		map[event.from] = event.to
	else
		for _, from in ipairs(event.from) do
			map[from] = event.to
		end
	end
end

function StateMachine.create(options)
	assert(options.events)

	local fsm = {}
	setmetatable(fsm, StateMachine)

	fsm.options = options
	fsm.current = options.initial or "none"
	fsm.asyncState = NONE
	fsm.events = {}
	fsm.dexit = options.dexit

	for _, event in ipairs(options.events or {}) do
		local name = event.name
		fsm[name] = fsm[name] or createTransition(name)
		fsm.events[name] = fsm.events[name] or { map = {} }
		addToMap(fsm.events[name].map, event)
	end

	for name, callback in pairs(options.callbacks or {}) do
		fsm[name] = callback
	end

	return fsm
end

function StateMachine:is(state)
	return self.current == state
end

function StateMachine:can(e)
	local event = self.events[e]
	local to = event and event.map[self.current] or event.map["*"]
	return to ~= nil, to
end

function StateMachine:cannot(e)
	return not self:can(e)
end

function StateMachine:transition(event)
	if self.currentTransitioningEvent == event then
		return self[self.currentTransitioningEvent](self)
	end
end

function StateMachine:cancelTransition(event)
	if self.currentTransitioningEvent == event then
		self.asyncState = NONE
		self.currentTransitioningEvent = nil
	end
end

StateMachine.NONE = NONE
StateMachine.ASYNC = ASYNC

return StateMachine









