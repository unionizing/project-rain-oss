local char_to_hex = function(c)
    return string.format("%%%02X", string.byte(c))
end

local hex_to_char = function(x)
    return string.char(tonumber(x, 16))
end

return {
    encode = function(url)
        if url == nil then
            return
        end
        url = url:gsub("\n", "\r\n")
        url = url:gsub("([^%w ])", char_to_hex)
        url = url:gsub(" ", "+")
        return url
    end,

    decode = function(url)
        if url == nil then
            return
        end
        url = url:gsub("+", " ")
        url = url:gsub("%%(%x%x)", hex_to_char)
        return url
    end
}