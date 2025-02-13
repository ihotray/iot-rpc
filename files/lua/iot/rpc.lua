
local cjson = require 'cjson.safe'

local M = {
    ERROR_CODE_NONE = 0,
    ERROR_CODE_INVALID_PARAMS = -10001,
    ERROR_CODE_INVALID_USERNAME_PASSWORD = -11000,
    ERROR_CODE_INVALID_UBUS = -11001,
}

M.error_response = function(method, code, message)
    return cjson.encode({
        code = code,
        method = method,
        message = message
    })
end

M.result_response = function(method, data)
    return cjson.encode({
        code = M.ERROR_CODE_NONE,
        method = method,
        data = data
    })
end

function M.call(mod, func, args, ext)

    local script = '/usr/share/iot/rpc/' .. mod .. '.lua'
    local ok, funcs = pcall(dofile, script)
    if not ok then
        return M.error_response(mod, M.ERROR_CODE_INVALID_PARAMS)
    end

    if not funcs or not funcs[func] then
        return M.error_response(mod, M.ERROR_CODE_INVALID_PARAMS)
    end

    return funcs[func](args, ext)
end

return M