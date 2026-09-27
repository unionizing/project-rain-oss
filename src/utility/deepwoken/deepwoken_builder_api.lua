local url_encoding = require("@src/utility/urlencoding");


local deepwoken_builder_api = {} do
    deepwoken_builder_api.__index = deepwoken_builder_api

    function deepwoken_builder_api:request_build(url)
        local build_id = url:match("id=([%w]+)")
        if not build_id then
            return false, "bad id"        
end
        return request({
            Url = "https://deepwoken.co/api/proxy?url=" .. url_encoding.encode(string.format("https://api.deepwoken.co/build?id=%s&options={}", build_id)),
            Method = "GET",
            Headers = {
                ["Content-Type"] = "application/x-www-form-urlencoded"
            },
            Body = "url=" .. url_encoding.encode(url)
        }).Body
    end;

    function deepwoken_builder_api:get_general_data()
        return request({
            Url = "https://deepwoken.co/api/proxy?url=https%3A%2F%2Fapi.deepwoken.co%2Fget%3Ftype%3Dall&options=%7B%22signal%22%3A%7B%7D%7D",
            Method = "GET",
            Headers = {
                ["Content-Type"] = "application/x-www-form-urlencoded"
            },
        }).Body
    end;
end;

return deepwoken_builder_api