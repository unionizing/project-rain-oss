return loadstring([[
    local assert = assert
local type = type
local setfenv = setfenv

getfenv().LPH_JIT = function(f, ...)
    assert(type(f) == "function" and #{...} == 0, "LPH_JIT only accepts a single constant function as an argument.")
    return f
end
LPH_JIT_MAX = LPH_JIT

getfenv().LPH_NO_VIRTUALIZE = function(f, ...)
    assert(type(f) == "function" and #{...} == 0, "LPH_NO_VIRTUALIZE only accepts a single constant function as an argument.")
    return f
end

getfenv().LPH_NO_UPVALUES = function(f, ...)
    assert(type(setfenv) == "function", "LPH_NO_UPVALUES can only be used on Lua versions with getfenv & setfenv")
    assert(type(f) == "function" and #{...} == 0, "LPH_NO_UPVALUES only accepts a single constant function as an argument.")
    return f
end

getfenv().LPH_CRASH = function(...)
    assert(#{...} == 0, "LPH_CRASH does not accept any arguments.")
end
]])()