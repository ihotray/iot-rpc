local rpc = require './iot-rpc'
local md5 = require 'iot.md5'

-- md5
local md5ctx = md5.new()
md5ctx:hash("admin")
print(md5ctx:done())

local r1 = rpc.call('{"method": "call", "param": ["ubus", "call", {"object": "system", "method": "board"}]}')
print(r1)