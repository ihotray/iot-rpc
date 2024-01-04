local cjson = require 'cjson.safe'
local rpc = require 'iot.rpc'
local uci = require 'uci'

local M = {}

function M.load(param)
    local c = uci.cursor()
    local res = c:get_all(param.config)
    return rpc.result_response('uci', res or cjson.null)
end

function M.get(param)
    local c = uci.cursor()
    local res = c:get(param.config, param.section, param.option)
    return rpc.result_response('uci', res or cjson.null)
end

function M.set(param)
    local c = uci.cursor()

    for option, value in pairs(param.values) do
        c:set(param.config, param.section, option, value)
    end

    local res = c:commit(param.config)

    return rpc.result_response('uci', res or cjson.null)

end

function M.delete(param)
    local c = uci.cursor()
    local config = param.config
    local section = param.section
    local options = param.options

    if options then
        for _, option in ipairs(options) do
            c:delete(config, section, option)
        end
    else
        c:delete(config, section)
    end

    local res = c:commit(config)
    
    return rpc.result_response('uci', res or cjson.null)

end

function M.add(param)
    local c = uci.cursor()
    local config = param.config
    local typ = param.type
    local name = param.name
    local values = param.values

    if name then
        c:set(config, name, typ)
    else
        name = c:add(config, typ)
    end

    for option, value in pairs(values) do
        c:set(config, name, option, value)
    end

    local res = c:commit(config)
    
    return rpc.result_response('uci', res or cjson.null)

end

return M
