local rpc = require 'iot.rpc'
local ubus = require 'ubus'

local M = {}

function M.call(param)
    local conn = ubus.connect()
    if not conn then
        error("Failed to connect to ubus")
        return rpc.error_response('ubus', rpc.ERROR_CODE_INVALID_UBUS)
    end
    local resp = conn:call(param.object, param.method, param.param or {})
    conn:close()

    return rpc.result_response('ubus', resp)
end

return M
