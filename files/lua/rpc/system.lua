local rpc = require 'iot.rpc'

local M = {}

function M.reboot()
    os.execute('sh -c "sleep 3; sync; /etc/init.d/iot-agent-cloud stop; reboot" &')
    return rpc.result_response('system', {
        reboot = 'success'
    })
end

return M
