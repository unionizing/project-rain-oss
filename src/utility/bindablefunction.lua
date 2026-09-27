



export type Callback = (...any) -> ...any

export type BindableFunction = {
    _connect: RBXScriptConnection?,
    _target: any?,
    _method: Callback?,
    __call: (BindableFunction,...any) -> ...any,
    bind: (BindableFunction, target: any, method: Callback?) -> Callback,
    disconnect: (BindableFunction) -> (),
}

local BindableFunction = {}
BindableFunction.__index = BindableFunction

function BindableFunction.new(callback: Callback?)
    local self = setmetatable({
        _connect = nil,
        _target = nil,
        _method = callback,
    }, BindableFunction)

    return self
end





function BindableFunction:bind(target: any, method: Callback?): Callback
    self._target = target
    if method then
        self._method = method
    end

    local function boundCallback(...: any)
        if not self._method then
            return
        end
        return self._method(self._target, ...)
    end

    return boundCallback
end

function BindableFunction:__call(...: any): ...any
    if not self._method then
        return
    end
    return self._method(self._target, ...)
end

return BindableFunction