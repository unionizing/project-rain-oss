








local AssetId = {}


local PROTOCOL = {
    UNKNOWN = 1,
    NULL = 2,
    RBXASSET = 3,
    RBXTEMP = 4,
    RBXASSETID = 5,
    ENCRYPTEDASSETID = 6,
    HTTP = 7,
    FILE = 8,
    RBXHTTP = 9,
    RBXAPP = 10,
    RBXTHUMB = 11,
    RBXGAMEASSET = 12,
    RBXASSETHASH = 13,
    RBXRUNTIME = 14,
}

AssetId.PROTOCOL = PROTOCOL



local function compare_eq(str: string, pos: number, len: number, s: string): boolean
    return string.sub(str, pos + 1, pos + len) == s
end



function AssetId.classify(str: string): number
    local len = #str

    if len == 0 then
        return PROTOCOL.NULL
    end

    if len < 10 then
        if len < 5 then
            return PROTOCOL.UNKNOWN
        end
    elseif compare_eq(str, 0, 3, "rbx") then
        local c = string.byte(str, 4)

        if c == 116 then 
            if compare_eq(str, 4, 6, "emp://") then
                return PROTOCOL.RBXTEMP
            end

            return compare_eq(str, 4, 7, "humb://") and PROTOCOL.RBXTHUMB or PROTOCOL.UNKNOWN
        end

        if c == 97 then 
            if compare_eq(str, 4, 11, "ssethash://") then
                return PROTOCOL.RBXASSETHASH
            elseif compare_eq(str, 4, 7, "sset://") then
                return PROTOCOL.RBXASSET
            elseif compare_eq(str, 4, 9, "ssetid://") then
                return PROTOCOL.RBXASSETID
            end

            return compare_eq(str, 4, 5, "pp://") and PROTOCOL.RBXAPP or PROTOCOL.UNKNOWN
        end

        if len < 23 then
            if len == 10 then
                return PROTOCOL.UNKNOWN
            end
        elseif compare_eq(str, 3, 19, "encryptedassetid://") then
            return PROTOCOL.ENCRYPTEDASSETID
        end

        if compare_eq(str, 3, 7, "http://") then
            return PROTOCOL.RBXHTTP
        end

        if len < 16 then
            if len < 14 then
                return PROTOCOL.UNKNOWN
            end
        elseif compare_eq(str, 3, 12, "gameasset://") then
            return PROTOCOL.RBXGAMEASSET
        end

        return compare_eq(str, 3, 10, "runtime://") and PROTOCOL.RBXRUNTIME or PROTOCOL.UNKNOWN
    end

    
    if compare_eq(str, 0, 4, "http") then
        return PROTOCOL.HTTP
    end

    if len >= 8 and compare_eq(str, 0, 7, "file://") then
        return PROTOCOL.FILE
    end

    return PROTOCOL.UNKNOWN
end



local function parse_id_at(str: string, offset: number): (string?, string?)
    if #str < offset + 1 then
        return nil, "<error:  missing assetid>"
    end

    local first = string.byte(str, offset + 1)
    if first < 48 or first > 57 then
        return nil, "<error:  assetid does not start with a number>"
    end

    
    local window = string.sub(str, offset + 1, offset + 19)
    local digits = string.match(window, "^[0-9]+") :: string

    return digits, nil
end


local function ascii_lower(str: string): string
    return (string.gsub(str, "[A-Z]", function(c: string)
        return string.char(string.byte(c) + 32)
    end))
end


function AssetId.get_id(str: string): (string?, string?)
    local protocol = AssetId.classify(str)

    if protocol == PROTOCOL.RBXASSETID then
        return parse_id_at(str, 13)
    end

    if protocol == PROTOCOL.HTTP or protocol == PROTOCOL.RBXHTTP then
        
        local head = ascii_lower(string.sub(str, 1, 128))
        local found = string.find(head, "id=", 1, true)

        if not found then
            return nil, "<error: id not found in first 128 char for http AssetId>"
        end

        return parse_id_at(head, (found - 1) + 3)
    end

    if protocol == PROTOCOL.FILE then
        return nil, "<error: file:// not allowed>"
    elseif protocol == PROTOCOL.RBXTEMP then
        return nil, "<error: rbxtemp:// not allowed>"
    elseif protocol == PROTOCOL.RBXASSET then
        return nil, "<error: rbxasset:// file not found>"
    elseif protocol == PROTOCOL.NULL then
        return nil, "<error: null id>"
    end

    return nil, "<error: unknown AssetId protocol>"
end


function AssetId.normalize(str: string): string
    local id, err = AssetId.get_id(str)
    return id and ("rbxassetid://" .. id) or (err :: string)
end

return AssetId
